import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../domain/enums.dart';
import '../../l10n/petopia_localizations.dart';
import '../pet_action_cue.dart';
import '../pet_art.dart';
import 'sprite_sheet_player.dart';

/// 会「呼吸」的宠物立绘：静止呼吸 + 点击弹跳 + 冒爱心；收到动作 cue 时播互动动画。
/// var01/C 使用手绘关键帧，其余身份使用保留原花色与成长体型的五秒动作编排。
class PetSprite extends StatefulWidget {
  final String assetPath;
  final double width;
  final VoidCallback? onTap;
  final String? speciesId; // 播动作帧需要
  final String? variantId;
  final PetStage? stage;
  final PetActionCue? cue; // 外部动作触发（喂/摸/玩/洗）
  final String? semanticLabel;
  final bool reduceEffects;
  const PetSprite({
    super.key,
    required this.assetPath,
    this.width = 220,
    this.onTap,
    this.speciesId,
    this.variantId,
    this.stage,
    this.cue,
    this.semanticLabel,
    this.reduceEffects = false,
  });

  @override
  State<PetSprite> createState() => _PetSpriteState();
}

class _PetSpriteState extends State<PetSprite> with TickerProviderStateMixin {
  static const _actionDuration = Duration(seconds: 5);

  late final AnimationController _breath;
  late final AnimationController _bounce;
  late final AnimationController _fidget;
  final math.Random _random = math.Random();
  Timer? _fidgetTimer;
  Timer? _actionTimer;
  int _fidgetKind = 0;
  int _heartSeq = 0;
  final List<int> _hearts = [];
  String? _playing; // 当前正在播的动作（null=静止呼吸）
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _fidget =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _fidget.value = 0;
            _scheduleFidget();
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion && !_reduceMotion) {
      _hearts.clear();
    }
    _reduceMotion = reduceMotion;
    if (_reduceMotion) {
      _fidgetTimer?.cancel();
      _fidget.stop();
      _fidget.value = 0;
      _breath.stop();
      _breath.value = 0;
    } else if (!_breath.isAnimating) {
      _breath.repeat(reverse: true);
      _scheduleFidget();
    }
  }

  @override
  void didUpdateWidget(PetSprite old) {
    super.didUpdateWidget(old);
    final cue = widget.cue;
    if (cue != null && cue.seq != old.cue?.seq) {
      _fidgetTimer?.cancel();
      _fidget.stop();
      _fidget.value = 0;
      setState(() => _playing = cue.action);
      _actionTimer?.cancel();
      _actionTimer = Timer(_actionDuration, () => _finishAction(cue.seq));
      if (cue.action == 'pat' && !_reduceMotion) _spawnHeart();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _bounce.dispose();
    _fidgetTimer?.cancel();
    _actionTimer?.cancel();
    _fidget.dispose();
    super.dispose();
  }

  void _finishAction(int seq) {
    if (!mounted || widget.cue?.seq != seq || _playing == null) return;
    _actionTimer?.cancel();
    _actionTimer = null;
    setState(() => _playing = null);
    _scheduleFidget();
  }

  void _scheduleFidget() {
    if (_reduceMotion ||
        _playing != null ||
        _fidget.isAnimating ||
        _fidgetTimer?.isActive == true) {
      return;
    }
    final delay = Duration(milliseconds: 8000 + _random.nextInt(7001));
    _fidgetTimer = Timer(delay, () {
      _fidgetTimer = null;
      if (!mounted || _reduceMotion || _playing != null) return;
      _fidgetKind = _nextFidgetKind();
      _fidget.forward(from: 0);
    });
  }

  int _nextFidgetKind() {
    final species = PetArt.dir(widget.speciesId ?? '');
    final offset = switch (species) {
      'parrot' || 'starbug' => 2,
      'snake' || 'chameleon' || 'turtle' => 1,
      _ => 0,
    };
    return (offset + _random.nextInt(3)) % 3;
  }

  void _spawnHeart() {
    final id = _heartSeq++;
    setState(() => _hearts.add(id));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _hearts.remove(id));
    });
  }

  void _onTap() {
    _fidgetTimer?.cancel();
    _fidget.stop();
    _fidget.value = 0;
    if (!_reduceMotion) {
      _bounce.forward(from: 0);
      _spawnHeart();
    }
    widget.onTap?.call();
    _scheduleFidget();
  }

  Widget _staticSprite() {
    // 换模演出：档位立绘切换时旧→新水彩晕染交叉淡入。
    return AnimatedSwitcher(
      duration: _reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 720),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 1.06, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: Image.asset(
        widget.assetPath,
        key: ValueKey(widget.assetPath),
        width: widget.width,
        errorBuilder: (_, _, _) => const SizedBox(),
      ),
    );
  }

  Widget _breathingStatic() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breath, _bounce, _fidget]),
      builder: (context, child) {
        final b = math.sin(_breath.value * math.pi);
        final dy = -b * 4;
        final scaleY = 1.0 + b * 0.025;
        final pop =
            1.0 +
            Curves.elasticOut.transform(_bounce.value) *
                0.08 *
                (1 - _bounce.value);
        final fidget = _fidgetTransform(_fidget.value);
        return Transform.translate(
          offset: Offset(fidget.dx, dy + fidget.dy),
          child: Transform.rotate(
            angle: fidget.angle,
            alignment: Alignment.bottomCenter,
            child: Transform.scale(
              alignment: Alignment.bottomCenter,
              scaleX: pop * fidget.scaleX,
              scaleY: scaleY * pop * fidget.scaleY,
              child: child,
            ),
          ),
        );
      },
      child: _staticSprite(),
    );
  }

  ({double dx, double dy, double angle, double scaleX, double scaleY})
  _fidgetTransform(double value) {
    if (value <= 0) {
      return (dx: 0, dy: 0, angle: 0, scaleX: 1, scaleY: 1);
    }
    final rise = math.sin(value * math.pi);
    final wave = math.sin(value * math.pi * 2);
    return switch (_fidgetKind) {
      0 => (
        dx: wave * 3.5,
        dy: -rise * 2.5,
        angle: wave * 0.04,
        scaleX: 1 + rise * 0.012,
        scaleY: 1 - rise * 0.008,
      ),
      1 => (
        dx: wave * 1.5,
        dy: rise * 2.5,
        angle: wave * 0.02,
        scaleX: 1 + rise * 0.035,
        scaleY: 1 - rise * 0.025,
      ),
      _ => (
        dx: wave * 2,
        dy: -rise * 5,
        angle: wave * 0.025,
        scaleX: 1 + rise * 0.018,
        scaleY: 1 + rise * 0.012,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = _reduceMotion;
    final playing = _playing;
    final Widget body;
    if (playing != null && widget.speciesId != null) {
      void onComplete() {
        _finishAction(widget.cue?.seq ?? -1);
      }

      final choreography = _StaticActionChoreography(
        key: ValueKey('pose_${widget.cue?.seq}'),
        action: playing,
        species: PetArt.dir(widget.speciesId!),
        stage: widget.stage ?? PetStage.c,
        duration: _actionDuration,
        reduceMotion: reduceMotion,
        onComplete: onComplete,
        child: _staticSprite(),
      );
      final useSheet =
          !reduceMotion &&
          !widget.reduceEffects &&
          PetArt.hasExactAction(
            variantId: widget.variantId,
            stage: widget.stage,
          );
      body = KeyedSubtree(
        key: ValueKey<String>('pet_action_$playing'),
        child: useSheet
            ? SpriteSheetPlayer(
                key: ValueKey('act_${widget.cue?.seq}'),
                assetPath: PetArt.actionSheet(widget.speciesId!, playing),
                size: widget.width,
                duration: _actionDuration,
                cycles: 2,
                holdTailFraction: 0.16,
                onComplete: onComplete,
                fallback: choreography,
              )
            : choreography,
      );
    } else if (reduceMotion) {
      body = _staticSprite();
    } else {
      body = _breathingStatic();
    }
    final content = Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: widget.onTap == null ? null : _onTap,
        radius: widget.width * 0.48,
        splashColor: const Color(0xFFF0B56F).withValues(alpha: 0.10),
        hoverColor: const Color(0xFFF0B56F).withValues(alpha: 0.06),
        focusColor: const Color(0xFFF0B56F).withValues(alpha: 0.09),
        child: SizedBox(
          width: widget.width,
          height: widget.width,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              AnimatedSwitcher(
                duration: reduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInOut,
                child: body,
              ),
              for (final id in _hearts)
                _FloatingHeart(key: ValueKey<String>('pet_heart_$id')),
            ],
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      label: context.tr(widget.semanticLabel ?? '摸摸宠物'),
      onTap: widget.onTap == null ? null : _onTap,
      child: ExcludeSemantics(child: content),
    );
  }
}

class _StaticActionChoreography extends StatefulWidget {
  final String action;
  final String species;
  final PetStage stage;
  final Duration duration;
  final bool reduceMotion;
  final VoidCallback onComplete;
  final Widget child;

  const _StaticActionChoreography({
    super.key,
    required this.action,
    required this.species,
    required this.stage,
    required this.duration,
    required this.reduceMotion,
    required this.onComplete,
    required this.child,
  });

  @override
  State<_StaticActionChoreography> createState() =>
      _StaticActionChoreographyState();
}

class _StaticActionChoreographyState extends State<_StaticActionChoreography>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) widget.onComplete();
      })
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        final frame = _petActionFrame(
          action: widget.action,
          species: widget.species,
          stage: widget.stage,
          t: t,
          reduceMotion: widget.reduceMotion,
        );
        final prop = _petActionPropFrame(
          action: widget.action,
          species: widget.species,
          t: t,
          reduceMotion: widget.reduceMotion,
        );
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              key: ValueKey<String>('pet_action_actor_${widget.action}'),
              offset: Offset(frame.dx, frame.dy),
              child: Transform.rotate(
                angle: frame.angle,
                alignment: Alignment.bottomCenter,
                child: Opacity(
                  opacity: frame.opacity,
                  child: Transform.scale(
                    alignment: Alignment.bottomCenter,
                    scaleX: frame.scaleX,
                    scaleY: frame.scaleY,
                    child: child,
                  ),
                ),
              ),
            ),
            _PetActionProp(
              key: ValueKey<String>('pet_action_prop_${widget.action}'),
              action: widget.action,
              frame: prop,
            ),
          ],
        );
      },
    );
  }
}

typedef _PetActionPropFrame = ({
  Alignment alignment,
  double widthFactor,
  double dx,
  double dy,
  double angle,
  double scale,
  double opacity,
});

class _PetActionProp extends StatelessWidget {
  final String action;
  final _PetActionPropFrame frame;

  const _PetActionProp({super.key, required this.action, required this.frame});

  @override
  Widget build(BuildContext context) {
    final assetName = switch (action) {
      'eat' => 'feed',
      _ => action,
    };
    return Align(
      alignment: frame.alignment,
      child: FractionallySizedBox(
        widthFactor: frame.widthFactor,
        child: Opacity(
          opacity: frame.opacity,
          child: Transform.translate(
            offset: Offset(frame.dx, frame.dy),
            child: Transform.rotate(
              key: ValueKey<String>('pet_action_prop_motion_$action'),
              angle: frame.angle,
              child: Transform.scale(
                scale: frame.scale,
                child: ExcludeSemantics(
                  child: Image.asset(
                    'assets/art/pets/action_props/pet_action_prop_$assetName.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

_PetActionPropFrame _petActionPropFrame({
  required String action,
  required String species,
  required double t,
  required bool reduceMotion,
}) {
  final edge = reduceMotion ? 1.0 : _actionEdge(t);
  final cycle = _actionCycle(t);
  final entrance = _smoothSegment(cycle, 0.02, 0.20);
  final exit = 1 - _smoothSegment(cycle, 0.80, 0.98);
  final presence = math.min(entrance, exit);
  final stroke = math.sin(_segment(cycle, 0.20, 0.78) * math.pi * 3).abs();
  final pulse = math.sin(cycle * math.pi * 2);
  final active = reduceMotion ? 0.0 : 1.0;
  final slowSpecies = species == 'turtle' || species == 'snake';
  final tempoScale = slowSpecies ? 0.64 : 1.0;
  final eatAlignment = switch (species) {
    'snake' || 'chameleon' || 'turtle' => const Alignment(-0.54, 0.66),
    'parrot' || 'starbug' || 'boo' => const Alignment(-0.18, 0.58),
    _ => const Alignment(-0.54, 0.72),
  };
  final eatWidth = switch (species) {
    'parrot' || 'starbug' || 'boo' => 0.32,
    _ => 0.35,
  };

  return switch (action) {
    'eat' => (
      alignment: eatAlignment,
      widthFactor: eatWidth,
      dx: pulse * 1.2 * tempoScale * active,
      dy: 3.0 + (1 - presence) * 9.0 * active,
      angle: pulse * 0.006 * active,
      scale: 0.94 + presence * 0.06,
      opacity: edge * presence,
    ),
    'pat' => (
      alignment: const Alignment(0.22, -0.82),
      widthFactor: 0.52,
      dx: pulse * 2.0 * active,
      dy: -28.0 + entrance * 16.0 + stroke * 8.0 * tempoScale * active,
      angle: -0.07 + pulse * 0.014 * active,
      scale: 0.96 + stroke * 0.035 * active,
      opacity: edge * presence,
    ),
    'play' => (
      alignment: const Alignment(0.72, 0.82),
      widthFactor: 0.42,
      dx: (-22.0 + entrance * 22.0 + pulse * 18.0 * tempoScale) * active,
      dy: 14.0 - stroke * 16.0 * tempoScale * active,
      angle: pulse * 0.22 * tempoScale * active,
      scale: 0.92 + stroke * 0.09 * active,
      opacity: edge * presence,
    ),
    'bath' => (
      alignment: const Alignment(0, 0.04),
      widthFactor: 1.02,
      dx: pulse * 1.4 * tempoScale * active,
      dy: 10.0 + (1 - presence) * 12.0 * active,
      angle: pulse * 0.008 * active,
      scale: 0.94 + presence * 0.07 + stroke * 0.015 * active,
      opacity: edge * presence,
    ),
    _ => (
      alignment: const Alignment(0, 0.68),
      widthFactor: 0.5,
      dx: 0,
      dy: 0,
      angle: 0,
      scale: 1,
      opacity: 0,
    ),
  };
}

typedef _PetActionFrame = ({
  double dx,
  double dy,
  double scaleX,
  double scaleY,
  double angle,
  double opacity,
});

typedef _PetMotionProfile = ({
  double tempo,
  double lift,
  double travel,
  double squash,
  double sway,
  double floatiness,
});

_PetMotionProfile _petMotionProfile(String species) {
  return switch (species) {
    'shiba' => (
      tempo: 1.18,
      lift: 1.08,
      travel: 1.12,
      squash: 0.92,
      sway: 0.75,
      floatiness: 0,
    ),
    'rabbit' => (
      tempo: 1.08,
      lift: 1.30,
      travel: 0.90,
      squash: 1.08,
      sway: 0.62,
      floatiness: 0,
    ),
    'uni' => (
      tempo: 0.96,
      lift: 1.24,
      travel: 0.96,
      squash: 0.82,
      sway: 0.70,
      floatiness: 0.35,
    ),
    'hamster' => (
      tempo: 1.36,
      lift: 0.82,
      travel: 0.72,
      squash: 1.24,
      sway: 0.72,
      floatiness: 0,
    ),
    'turtle' => (
      tempo: 0.52,
      lift: 0.30,
      travel: 0.42,
      squash: 0.38,
      sway: 0.34,
      floatiness: 0,
    ),
    'parrot' => (
      tempo: 1.24,
      lift: 1.12,
      travel: 0.76,
      squash: 0.60,
      sway: 1.16,
      floatiness: 0.22,
    ),
    'snake' => (
      tempo: 0.72,
      lift: 0.34,
      travel: 1.28,
      squash: 0.28,
      sway: 1.42,
      floatiness: 0,
    ),
    'chameleon' => (
      tempo: 0.62,
      lift: 0.46,
      travel: 0.64,
      squash: 0.44,
      sway: 1.18,
      floatiness: 0,
    ),
    'ember' => (
      tempo: 1.04,
      lift: 1.02,
      travel: 1.0,
      squash: 0.78,
      sway: 1.0,
      floatiness: 0.12,
    ),
    'boo' => (
      tempo: 0.68,
      lift: 0.72,
      travel: 0.70,
      squash: 0.72,
      sway: 0.92,
      floatiness: 1,
    ),
    'starbug' => (
      tempo: 1.10,
      lift: 1.18,
      travel: 1.02,
      squash: 0.42,
      sway: 1.14,
      floatiness: 0.82,
    ),
    _ => (
      tempo: 0.88,
      lift: 0.82,
      travel: 0.78,
      squash: 0.86,
      sway: 0.72,
      floatiness: 0,
    ),
  };
}

_PetActionFrame _petActionFrame({
  required String action,
  required String species,
  required PetStage stage,
  required double t,
  required bool reduceMotion,
}) {
  final profile = _petMotionProfile(species);
  final stageWeight = switch (stage) {
    PetStage.a => 0.72,
    PetStage.b => 0.86,
    PetStage.c => 1.0,
    PetStage.d => 0.92,
  };
  final reduced = reduceMotion ? 0.0 : 1.0;
  final strength = stageWeight * reduced;
  final edge = _actionEdge(t);
  final cycle = _actionCycle(t);
  final prepare = _smoothSegment(cycle, 0.04, 0.22);
  final engage = _smoothSegment(cycle, 0.20, 0.42);
  final release = 1 - _smoothSegment(cycle, 0.70, 0.94);
  final hold = math.min(engage, release) * edge;
  final recover = _smoothSegment(cycle, 0.72, 0.98);
  final gesturePhase = _segment(cycle, 0.25, 0.78);
  final wave = math.sin(gesturePhase * math.pi * 4 * profile.tempo) * hold;
  final beat =
      math.sin(gesturePhase * math.pi * 6 * profile.tempo).abs() * hold;
  final pounce = math.sin(_segment(cycle, 0.23, 0.72) * math.pi) * edge;

  var dx = 0.0;
  var dy = 0.0;
  var scaleX = 1.0;
  var scaleY = 1.0;
  var angle = 0.0;
  var opacity = 1.0;

  switch (action) {
    case 'eat':
      if (species == 'snake') {
        dx = (-prepare * 5.0 + wave * 5.5 * profile.travel) * strength;
        dy = (hold * 3.5 + beat * 1.8) * strength;
        angle = (-hold * 0.028 + wave * 0.030) * strength;
      } else if (species == 'turtle') {
        dx = (-hold * 7.0 + wave * 2.0) * strength;
        dy = (hold * 2.6 + beat * 1.2) * strength;
        angle = (-hold * 0.024 + wave * 0.010) * strength;
      } else {
        dx = -hold * 7.0 * profile.travel * strength;
        dy = (hold * 7.5 + beat * 2.8) * profile.squash * strength;
        angle = (-hold * 0.045 + wave * 0.012 * profile.sway) * strength;
        scaleX += (hold * 0.035 + beat * 0.018) * profile.squash * strength;
        scaleY -= (hold * 0.050 + beat * 0.024) * profile.squash * strength;
      }
      break;
    case 'pat':
      dy = (hold * 3.2 - beat * 2.2 * profile.lift) * strength;
      dx = (hold * 4.0 + wave * 1.6 * profile.travel) * strength;
      angle = (hold * 0.038 + wave * 0.014 * profile.sway) * strength;
      scaleX += (hold * 0.025 + beat * 0.008) * profile.squash * strength;
      scaleY -= (hold * 0.022 - beat * 0.010) * profile.squash * strength;
      if (species == 'snake' || species == 'chameleon') {
        dy *= 0.42;
        dx = (hold * 5.5 + wave * 4.4 * profile.travel) * strength;
      }
      break;
    case 'play':
      if (species == 'snake') {
        dx = (-prepare * 4.0 + pounce * 15.0 + wave * 5.0) * strength;
        dy = (-pounce * 4.5 + recover * 1.5) * strength;
        angle = (wave * 0.070 - pounce * 0.028) * strength;
      } else if (species == 'turtle') {
        dx = (-prepare * 2.0 + pounce * 7.0 + wave * 1.8) * strength;
        dy = -pounce * 3.2 * strength;
        angle = (wave * 0.015 - pounce * 0.020) * strength;
      } else {
        dx = (-prepare * 5.0 + pounce * 18.0 * profile.travel) * strength;
        dy = (-pounce * 13.0 * profile.lift + recover * 2.0) * strength;
        angle = (-prepare * 0.035 + pounce * 0.065 * profile.sway) * strength;
        scaleX +=
            (prepare * 0.045 - pounce * 0.018) * profile.squash * strength;
        scaleY -=
            (prepare * 0.055 - pounce * 0.030) * profile.squash * strength;
      }
      break;
    case 'bath':
      if (species == 'parrot') {
        dy = (hold * 5.0 - beat * 8.0) * strength;
        dx = wave * 6.5 * strength;
        angle = wave * 0.085 * strength;
      } else if (species == 'snake') {
        dx = wave * 7.0 * strength;
        dy = hold * 4.0 * strength;
        angle = wave * 0.040 * strength;
        scaleX += (hold * 0.018 + beat * 0.030) * strength;
        scaleY -= (hold * 0.025 + beat * 0.020) * strength;
      } else {
        dy = (hold * 7.0 + wave * 2.5 * profile.lift) * strength;
        dx = wave * 4.8 * profile.travel * strength;
        angle = wave * 0.055 * profile.sway * strength;
        scaleX += (hold * 0.025 + beat * 0.024) * profile.squash * strength;
        scaleY -= (hold * 0.040 + beat * 0.018) * profile.squash * strength;
      }
      break;
    default:
      dy = -pounce * 2.2 * profile.lift * strength;
      angle = wave * 0.012 * profile.sway * strength;
      break;
  }

  if (profile.floatiness > 0) {
    final floatPulse = math.sin(cycle * math.pi).abs();
    dy -= floatPulse * 4.0 * profile.floatiness * strength;
    opacity = 1 - floatPulse * 0.045 * profile.floatiness * strength;
  }
  return (
    dx: dx,
    dy: dy,
    scaleX: scaleX,
    scaleY: scaleY,
    angle: angle,
    opacity: opacity.clamp(0.88, 1.0).toDouble(),
  );
}

double _actionCycle(double t) {
  if (t >= 1) return 1;
  return (t * 2) % 1;
}

double _actionEdge(double t) => math
    .min(1.0, math.min(t / 0.06, (1 - t) / 0.06))
    .clamp(0.0, 1.0)
    .toDouble();

double _segment(double value, double start, double end) =>
    ((value - start) / (end - start)).clamp(0.0, 1.0).toDouble();

double _smoothSegment(double value, double start, double end) {
  final x = _segment(value, start, end);
  return x * x * (3 - 2 * x);
}

/// 点击时向上飘散并淡出的小爱心。
class _FloatingHeart extends StatefulWidget {
  const _FloatingHeart({super.key});
  @override
  State<_FloatingHeart> createState() => _FloatingHeartState();
}

class _FloatingHeartState extends State<_FloatingHeart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();
  late final double _dx = (math.Random().nextDouble() - 0.5) * 40;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(_dx, 28 - _c.value * 80),
            child: Opacity(
              opacity: (1 - _c.value).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 0.6 + Curves.easeOut.transform(_c.value) * 0.6,
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFF4A7B9),
                  size: 26,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
