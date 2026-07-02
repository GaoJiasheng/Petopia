import '../domain/models/pet.dart';
import '../domain/models/game_state.dart';
import '../domain/models/logs.dart';

/// PostcardGenerator（spec-technical §3.5 / §6.3）。
///
/// 生成管线：地点 × 时间(季节/时段/天气) × 遭遇 × 碰撞 → 正文(性格文风) + 照片 + 邮戳。
/// 正文存渲染定稿（body_text）以保证回看一致；双入册（明信片相册 + 旅行相册均为视图，仅存一份实体）。
abstract interface class PostcardGenerator {
  /// 生成一张明信片并持久化。
  Postcard generate({required Pet pet, required Journey journey});

  /// 判定是否到寄片时刻；到点则 generate + 推进 stop；发本地通知（若开启）。
  /// 旅程中 1–3 天间隔，漫游期 10–15 天。
  Future<void> dailyTick({required Pet pet, required Journey journey});
}
