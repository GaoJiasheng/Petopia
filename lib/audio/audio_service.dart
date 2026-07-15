import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 情境 BGM（对应 assets/audio/bgm/mix/m4a/bgm_*.m4a）。
enum Bgm {
  opening('bgm_opening'),
  yardDay('bgm_yard_day'),
  yardDusk('bgm_yard_dusk'),
  yardNight('bgm_yard_night'),
  adoption('bgm_adoption'),
  graduation('bgm_graduation'),
  shop('bgm_shop'),
  albumBrowse('bgm_album_browse'),
  postcardRead('bgm_postcard_read');

  const Bgm(this.file);
  final String file;
}

/// 事件 sting（对应 assets/audio/sting/m4a/sting_*.m4a）。
enum Sting {
  levelup('sting_levelup'),
  evolveB('sting_evolve_b'),
  evolveC('sting_evolve_c'),
  evolveD('sting_evolve_d'),
  achievement('sting_achievement'),
  achievementHidden('sting_achievement_hidden'),
  adoptionWelcome('sting_adoption_welcome'),
  graduationDepart('sting_graduation_depart'),
  eggUnlock('sting_egg_unlock'),
  meteor('sting_meteor'),
  rainbow('sting_rainbow'),
  birthday('sting_birthday'),
  fullmoon('sting_fullmoon'),
  firstSnow('sting_first_snow'),
  bonfire('sting_bonfire');

  const Sting(this.file);
  final String file;
}

/// 音频引擎：循环 BGM（情境切换） + 一次性 sting，支持独立开关。
abstract interface class AudioService {
  bool get musicEnabled;
  bool get effectsEnabled;

  /// 切到某情境 BGM（已在播则忽略）。
  Future<void> playBgm(Bgm bgm);

  /// 播一段事件 sting（叠加在 BGM 之上）。
  Future<void> sting(Sting s);

  Future<void> setMusicEnabled(bool enabled);
  Future<void> setEffectsEnabled(bool enabled);

  Future<void> dispose();
}

/// audioplayers 实现。任一播放异常都静默降级（绝不影响玩法）。
class AudioplayersAudioService implements AudioService {
  final AudioPlayer _bgm = AudioPlayer(playerId: 'petopia_bgm');
  final AudioPlayer _sfx = AudioPlayer(playerId: 'petopia_sfx');
  bool _musicEnabled = true;
  bool _effectsEnabled = true;
  Bgm? _current;
  Bgm? _loaded;
  int _bgmRequest = 0;

  AudioplayersAudioService() {
    _bgm.setReleaseMode(ReleaseMode.loop);
    _sfx.setReleaseMode(ReleaseMode.stop);
  }

  @override
  bool get musicEnabled => _musicEnabled;

  @override
  bool get effectsEnabled => _effectsEnabled;

  @override
  Future<void> playBgm(Bgm bgm) async {
    final previous = _current;
    if (previous == bgm) return;
    _current = bgm;
    if (!_musicEnabled) return;
    final request = ++_bgmRequest;
    try {
      if (previous != null) {
        for (var step = 3; step >= 0; step--) {
          if (request != _bgmRequest) return;
          await _bgm.setVolume(0.55 * step / 4);
          await Future<void>.delayed(const Duration(milliseconds: 45));
        }
      }
      await _bgm.stop();
      await _bgm.play(
        AssetSource('audio/bgm/mix/m4a/${bgm.file}.m4a'),
        volume: 0,
      );
      _loaded = bgm;
      for (var step = 1; step <= 5; step++) {
        if (request != _bgmRequest || !_musicEnabled) return;
        await _bgm.setVolume(0.55 * step / 5);
        await Future<void>.delayed(const Duration(milliseconds: 55));
      }
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> sting(Sting s) async {
    if (!_effectsEnabled) return;
    try {
      await _sfx.play(
        AssetSource('audio/sting/m4a/${s.file}.m4a'),
        volume: 0.9,
      );
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> setMusicEnabled(bool enabled) async {
    if (_musicEnabled == enabled) return;
    _musicEnabled = enabled;
    _bgmRequest += 1;
    try {
      if (!enabled) {
        await _bgm.pause();
      } else if (_current != null) {
        if (_loaded == _current) {
          await _bgm.setVolume(0.55);
          await _bgm.resume();
        } else {
          final target = _current!;
          _current = null;
          await playBgm(target);
        }
      }
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> setEffectsEnabled(bool enabled) async {
    _effectsEnabled = enabled;
    if (!enabled) {
      try {
        await _sfx.stop();
      } catch (_) {
        /* 无声降级 */
      }
    }
  }

  @override
  Future<void> dispose() async {
    await _bgm.dispose();
    await _sfx.dispose();
  }
}

/// 全局音频服务（单例，随 ProviderScope 生命周期释放）。
final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioplayersAudioService();
  ref.onDispose(svc.dispose);
  return svc;
});
