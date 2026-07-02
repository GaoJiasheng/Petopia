import '../config/game_config.dart';
import '../domain/enums.dart';
import '../domain/models/pet.dart';
import '../domain/models/logs.dart';
import 'audit_service.dart';
import 'clock_service.dart';
import 'exp_engine.dart';

/// 由等级派生 stage（Lv1-4=A, 5-7=B, 8-9=C, 10=D）。
PetStage deriveStage(int level) {
  if (level >= GameConfig.stageDLevel) return PetStage.d;
  if (level >= GameConfig.stageCLevel) return PetStage.c;
  if (level >= GameConfig.stageBLevel) return PetStage.b;
  return PetStage.a;
}

/// 由累计经验派生等级（用 cumExpAtLevel 阈值；封顶 maxLevel）。幂等。
int deriveLevel(int exp) {
  final cum = GameConfig.cumExpAtLevel;
  int lvl = 1;
  for (int i = 0; i < cum.length; i++) {
    if (exp >= cum[i]) {
      lvl = i + 1;
    } else {
      break;
    }
  }
  return lvl > GameConfig.maxLevel ? GameConfig.maxLevel : lvl;
}

/// ExpEngine 实现（spec-technical §3.2）。
///
/// 唯一加经验入口。性格加成按 tag 各自 floor 后累加（bonusRounding=floor，防通胀）。
/// 每次变动写 ExpLogEntry（INV-1：pet.exp==Σdelta；expAfter 冗余便于即时自检）。
/// 毕业仅置 ExpResult.graduated=true，由上层交 GraduationService 编排（保持本类纯粹）。
class ExpEngineImpl implements ExpEngine {
  final AuditService _audit;
  final ClockService _clock;

  /// 性格动作加成解析：返回 (tagId, source) 的加成比例（如贪吃 feed→0.10），无则 0。
  final double Function(String tagId, ExpSource source) _tagBonus;

  /// ID 生成器（注入便于测试；生产用 uuid）。
  final String Function() _idGen;

  ExpEngineImpl(this._audit, this._clock, this._tagBonus, this._idGen);

  @override
  ExpResult addExp({
    required Pet pet,
    required int baseDelta,
    required ExpSource source,
    String? sourceRef,
    String? note,
    bool applyPersonalityBonus = true,
  }) {
    assert(baseDelta >= 0, 'INV-5: baseDelta 不可为负');
    if (baseDelta < 0) return ExpResult.noop;

    int delta = baseDelta;
    if (applyPersonalityBonus) {
      for (final tag in pet.personality) {
        final b = _tagBonus(tag, source);
        if (b > 0) delta += (baseDelta * b).floor(); // 各 tag 分别 floor 后累加
      }
    }
    if (delta == 0) return ExpResult.noop;

    final levelBefore = pet.level;
    final stageBefore = pet.stage;

    pet.exp += delta;
    pet.level = deriveLevel(pet.exp);
    pet.stage = deriveStage(pet.level);

    _audit.appendExpLog(ExpLogEntry(
      id: _idGen(),
      petId: pet.id,
      timestamp: _clock.now(),
      sourceType: source,
      sourceRef: sourceRef,
      delta: delta,
      levelAt: levelBefore,
      expAfter: pet.exp, // 冗余，供 INV-1 即时自检
      note: note,
    ));

    final graduated = pet.level >= GameConfig.maxLevel && levelBefore < GameConfig.maxLevel;
    return ExpResult(
      deltaApplied: delta,
      levelBefore: levelBefore,
      levelAfter: pet.level,
      leveledUp: pet.level > levelBefore,
      evolved: pet.stage != stageBefore,
      graduated: graduated,
    );
  }

  @override
  ExpResult grantOffline({required Pet pet, required Duration elapsed}) {
    // 跨自然日则归零离线计数（renew 的日粒度部分）。
    final key = _dayKey(_clock.now());
    if (pet.offlineDayKey != key) {
      pet.offlineExpGrantedToday = 0;
      pet.offlineDayKey = key;
    }

    final cap = _isLazy(pet)
        ? GameConfig.lazyOfflineDailyCap
        : GameConfig.offlineDailyCap;
    final elapsedH = elapsed.inHours;

    int gain = elapsedH < GameConfig.offlineSingleCap
        ? elapsedH
        : GameConfig.offlineSingleCap; // 单段封顶
    final remainToday = cap - pet.offlineExpGrantedToday;
    if (gain > remainToday) gain = remainToday; // 自然日总上限
    if (gain < 0) gain = 0;

    ExpResult res = ExpResult.noop;
    if (gain > 0) {
      res = addExp(
        pet: pet,
        baseDelta: gain,
        source: ExpSource.offline,
        note: '${elapsedH}h offline',
        applyPersonalityBonus: false, // 离线不吃动作加成
      );
      pet.offlineExpGrantedToday += gain;
    }

    // ★ renew：无论是否给经验都重置在线锚点。
    pet.lastOnlineAt = _clock.now();
    return res;
  }

  bool _isLazy(Pet pet) => pet.personality.contains('p_lazy');

  String _dayKey(DateTime t) =>
      '${t.year.toString().padLeft(4, '0')}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
}
