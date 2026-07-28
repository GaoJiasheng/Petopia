import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AudioMixProfile {
  static const bgmVolume = 0.55;
  static const ambienceVolume = 0.20;
  static const bgmFadeOutSteps = 4;
  static const bgmFadeInSteps = 6;
  static const bgmFadeOutStep = Duration(milliseconds: 70);
  static const bgmFadeInStep = Duration(milliseconds: 75);
  static const ambienceFadeOutSteps = 3;
  static const ambienceFadeInSteps = 5;
  static const ambienceFadeStep = Duration(milliseconds: 80);

  static double easedLevel(int step, int steps) {
    final progress = (step / steps).clamp(0.0, 1.0);
    return progress * progress * (3 - 2 * progress);
  }
}

/// 情境 BGM（对应 assets/audio/bgm/mix/m4a/bgm_*.m4a）。
enum Bgm {
  opening('bgm_opening'),
  yardDay('bgm_yard_day'),
  yardDusk('bgm_yard_dusk'),
  yardNight('bgm_yard_night'),
  adoption('bgm_adoption'),
  graduation('bgm_graduation'),
  eventSpecial('bgm_event_special_bed'),
  shop('bgm_shop'),
  albumBrowse('bgm_album_browse'),
  postcardRead('bgm_postcard_read');

  const Bgm(this.file);
  final String file;
}

/// 院子环境声层。与 BGM 分轨播放，保持低音量并随主题/天气切换。
enum YardAmbience {
  meadowDay('amb_meadow_day'),
  meadowDusk('amb_meadow_dusk'),
  meadowNight('amb_meadow_night'),
  rain('amb_gentle_rain'),
  snow('amb_soft_snow'),
  seaside('amb_seaside');

  const YardAmbience(this.file);
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

/// 短交互音效。WAV 48kHz / 16bit，优先保证触发延迟和动作同步。
enum Sfx {
  feed('sfx/wav/sfx_feed_eat.wav', 0.72),
  pat('sfx/wav/sfx_pat_fur.wav', 0.68),
  toy('sfx/wav/sfx_toy_play.wav', 0.70),
  bath('sfx/wav/sfx_bath_bubbles.wav', 0.68),
  eventCard('sfx/wav/sfx_event_card.wav', 0.66),
  visitorArrive('sfx/wav/sfx_visitor_arrive.wav', 0.64),
  paperOpen('ui/wav/ui_paper_open.wav', 0.58),
  tapSoft('ui/wav/ui_tap_soft.wav', 0.54);

  const Sfx(this.file, this.volume);
  final String file;
  final double volume;
}

/// 音频引擎：循环 BGM（情境切换） + 一次性 sting，支持独立开关。
abstract interface class AudioService {
  bool get musicEnabled;
  bool get effectsEnabled;

  /// 配置平台音频会话。可重复调用，实际初始化只执行一次。
  Future<void> initialize();

  /// 切到某情境 BGM（已在播则忽略）。
  Future<void> playBgm(Bgm bgm);

  /// 切换院子环境声。离开院子时会自动暂停，返回后恢复。
  Future<void> playYardAmbience(YardAmbience ambience);

  /// 播一段事件 sting（叠加在 BGM 之上）。
  Future<void> sting(Sting s);

  /// 播一段低延迟互动/UI 音效。
  Future<void> sfx(Sfx s);

  /// 播放当前访客的短声纹；未知访客静默忽略。
  Future<void> visitorVoice(String visitorId);

  Future<void> setMusicEnabled(bool enabled);
  Future<void> setEffectsEnabled(bool enabled);

  /// App 进入后台时暂停 BGM，并终止一次性音效。
  Future<void> pauseForInterruption();

  /// App 回到前台时恢复此前的 BGM 情境。
  Future<void> resumeAfterInterruption();

  Future<void> dispose();
}

/// audioplayers 实现。任一播放异常都静默降级（绝不影响玩法）。
class AudioplayersAudioService implements AudioService {
  final AudioPlayer _bgm = AudioPlayer(playerId: 'petopia_bgm');
  final AudioPlayer _ambience = AudioPlayer(playerId: 'petopia_ambience');
  final AudioPlayer _sting = AudioPlayer(playerId: 'petopia_sting');
  final AudioPlayer _sfx = AudioPlayer(playerId: 'petopia_sfx');
  final AudioPlayer _visitorVoice = AudioPlayer(
    playerId: 'petopia_visitor_voc',
  );
  bool _musicEnabled = true;
  bool _effectsEnabled = true;
  bool _interrupted = false;
  Bgm? _current;
  Bgm? _loaded;
  YardAmbience? _currentAmbience;
  YardAmbience? _loadedAmbience;
  int _bgmRequest = 0;
  int _ambienceRequest = 0;
  Future<void>? _initialization;

  @override
  bool get musicEnabled => _musicEnabled;

  @override
  bool get effectsEnabled => _effectsEnabled;

  @override
  Future<void> initialize() => _initialization ??= _initializePlatformAudio();

  Future<void> _initializePlatformAudio() async {
    try {
      // iOS 使用 ambient：遵守静音键、锁屏即停，且不会打断用户正在
      // 播放的音乐。Android 使用媒体流但不抢占其他音频焦点。
      await AudioPlayer.global.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.none,
            stayAwake: false,
          ),
          iOS: AudioContextIOS(category: AVAudioSessionCategory.ambient),
        ),
      );
      await Future.wait<void>([
        _bgm.setReleaseMode(ReleaseMode.loop),
        _ambience.setReleaseMode(ReleaseMode.loop),
        _sting.setReleaseMode(ReleaseMode.stop),
        _sfx.setReleaseMode(ReleaseMode.stop),
        _visitorVoice.setReleaseMode(ReleaseMode.stop),
      ]);
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> playBgm(Bgm bgm) async {
    final previous = _current;
    if (previous == bgm) return;
    _current = bgm;
    final yardContext = _isYardBgm(bgm);
    if (!yardContext) {
      _ambienceRequest += 1;
      try {
        await _ambience.pause();
      } catch (_) {
        /* 无声降级 */
      }
    }
    if (!_musicEnabled || _interrupted) return;
    await initialize();
    final request = ++_bgmRequest;
    try {
      if (previous != null) {
        for (
          var step = AudioMixProfile.bgmFadeOutSteps - 1;
          step >= 0;
          step--
        ) {
          if (request != _bgmRequest) return;
          await _bgm.setVolume(
            AudioMixProfile.bgmVolume *
                AudioMixProfile.easedLevel(
                  step,
                  AudioMixProfile.bgmFadeOutSteps,
                ),
          );
          await Future<void>.delayed(AudioMixProfile.bgmFadeOutStep);
        }
      }
      await _bgm.stop();
      await _bgm.play(
        AssetSource('audio/bgm/mix/m4a/${bgm.file}.m4a'),
        volume: 0,
      );
      _loaded = bgm;
      for (var step = 1; step <= AudioMixProfile.bgmFadeInSteps; step++) {
        if (request != _bgmRequest || !_musicEnabled) return;
        await _bgm.setVolume(
          AudioMixProfile.bgmVolume *
              AudioMixProfile.easedLevel(step, AudioMixProfile.bgmFadeInSteps),
        );
        await Future<void>.delayed(AudioMixProfile.bgmFadeInStep);
      }
      if (yardContext &&
          _effectsEnabled &&
          _currentAmbience != null &&
          !_interrupted) {
        await _resumeOrLoadAmbience(_currentAmbience!);
      }
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> playYardAmbience(YardAmbience ambience) async {
    final previous = _currentAmbience;
    _currentAmbience = ambience;
    if (!_effectsEnabled ||
        _interrupted ||
        _current == null ||
        !_isYardBgm(_current!)) {
      return;
    }
    if (previous == ambience && _loadedAmbience == ambience) {
      return;
    }
    await initialize();
    await _resumeOrLoadAmbience(ambience);
  }

  Future<void> _resumeOrLoadAmbience(YardAmbience ambience) async {
    final request = ++_ambienceRequest;
    try {
      if (_loadedAmbience == ambience) {
        await _ambience.setVolume(AudioMixProfile.ambienceVolume);
        await _ambience.resume();
        return;
      }
      if (_loadedAmbience != null) {
        for (
          var step = AudioMixProfile.ambienceFadeOutSteps - 1;
          step >= 0;
          step--
        ) {
          if (request != _ambienceRequest) return;
          await _ambience.setVolume(
            AudioMixProfile.ambienceVolume *
                AudioMixProfile.easedLevel(
                  step,
                  AudioMixProfile.ambienceFadeOutSteps,
                ),
          );
          await Future<void>.delayed(AudioMixProfile.ambienceFadeStep);
        }
      }
      await _ambience.stop();
      await _ambience.play(
        AssetSource('audio/ambient/m4a/${ambience.file}.m4a'),
        volume: 0,
      );
      _loadedAmbience = ambience;
      for (var step = 1; step <= AudioMixProfile.ambienceFadeInSteps; step++) {
        if (request != _ambienceRequest || !_effectsEnabled || _interrupted) {
          return;
        }
        await _ambience.setVolume(
          AudioMixProfile.ambienceVolume *
              AudioMixProfile.easedLevel(
                step,
                AudioMixProfile.ambienceFadeInSteps,
              ),
        );
        await Future<void>.delayed(AudioMixProfile.ambienceFadeStep);
      }
    } catch (_) {
      /* 无声降级 */
    }
  }

  static bool _isYardBgm(Bgm bgm) =>
      bgm == Bgm.yardDay || bgm == Bgm.yardDusk || bgm == Bgm.yardNight;

  @override
  Future<void> sting(Sting s) async {
    if (!_effectsEnabled || _interrupted) return;
    await initialize();
    try {
      await _sting.play(
        AssetSource('audio/sting/m4a/${s.file}.m4a'),
        volume: 0.9,
      );
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> sfx(Sfx s) async {
    if (!_effectsEnabled || _interrupted) return;
    await initialize();
    try {
      await _sfx.play(AssetSource('audio/${s.file}'), volume: s.volume);
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> visitorVoice(String visitorId) async {
    if (!_effectsEnabled || _interrupted) return;
    final validId = RegExp(r'^visitor_[a-z0-9_]+$').hasMatch(visitorId);
    if (!validId) return;
    await initialize();
    try {
      await _visitorVoice.play(
        AssetSource('audio/voc/m4a/voc_$visitorId.m4a'),
        volume: 0.52,
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
      } else if (!_interrupted && _current != null) {
        if (_loaded == _current) {
          await _bgm.setVolume(AudioMixProfile.bgmVolume);
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
      _ambienceRequest += 1;
      try {
        await _ambience.pause();
        await _sting.stop();
        await _sfx.stop();
        await _visitorVoice.stop();
      } catch (_) {
        /* 无声降级 */
      }
    } else if (!_interrupted &&
        _current != null &&
        _isYardBgm(_current!) &&
        _currentAmbience != null) {
      await _resumeOrLoadAmbience(_currentAmbience!);
    }
  }

  @override
  Future<void> pauseForInterruption() async {
    if (_interrupted) return;
    _interrupted = true;
    _bgmRequest += 1;
    _ambienceRequest += 1;
    try {
      await Future.wait<void>([
        if (_musicEnabled && _loaded != null) _bgm.pause(),
        if (_effectsEnabled && _loadedAmbience != null) _ambience.pause(),
        _sting.stop(),
        _sfx.stop(),
        _visitorVoice.stop(),
      ]);
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> resumeAfterInterruption() async {
    if (!_interrupted) return;
    _interrupted = false;
    final target = _current;
    if (target == null) return;
    try {
      if (_musicEnabled) {
        if (_loaded == target) {
          await _bgm.setVolume(AudioMixProfile.bgmVolume);
          await _bgm.resume();
        } else {
          _current = null;
          await playBgm(target);
        }
      }
      if (_effectsEnabled && _isYardBgm(target) && _currentAmbience != null) {
        await _resumeOrLoadAmbience(_currentAmbience!);
      }
    } catch (_) {
      /* 无声降级 */
    }
  }

  @override
  Future<void> dispose() async {
    await _bgm.dispose();
    await _ambience.dispose();
    await _sting.dispose();
    await _sfx.dispose();
    await _visitorVoice.dispose();
  }
}

/// 全局音频服务（单例，随 ProviderScope 生命周期释放）。
final audioServiceProvider = Provider<AudioService>((ref) {
  final svc = AudioplayersAudioService();
  ref.onDispose(svc.dispose);
  return svc;
});
