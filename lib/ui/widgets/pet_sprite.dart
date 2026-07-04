import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../pet_action_cue.dart';
import '../pet_art.dart';
import 'sprite_sheet_player.dart';

/// 会「呼吸」的宠物立绘：静止呼吸 + 点击弹跳 + 冒爱心；收到动作 cue 时播序列帧动画。
/// 缺动作帧时优雅回落到静态立绘。
class PetSprite extends StatefulWidget {
  final String assetPath;
  final double width;
  final VoidCallback? onTap;
  final String? speciesId; // 播动作帧需要
  final PetActionCue? cue; // 外部动作触发（喂/摸/玩/洗）
  const PetSprite({
    super.key,
    required this.assetPath,
    this.width = 220,
    this.onTap,
    this.speciesId,
    this.cue,
  });

  @override
  State<PetSprite> createState() => _PetSpriteState();
}

class _PetSpriteState extends State<PetSprite> with TickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600))
    ..repeat(reverse: true);
  late final AnimationController _bounce = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));
  int _heartSeq = 0;
  final List<int> _hearts = [];
  String? _playing; // 当前正在播的动作（null=静止呼吸）

  @override
  void didUpdateWidget(PetSprite old) {
    super.didUpdateWidget(old);
    final cue = widget.cue;
    if (cue != null && cue.seq != old.cue?.seq) {
      setState(() => _playing = cue.action);
      if (cue.action == 'pat') _spawnHeart();
    }
  }

  @override
  void dispose() {
    _breath.dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _spawnHeart() {
    final id = _heartSeq++;
    setState(() => _hearts.add(id));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _hearts.remove(id));
    });
  }

  void _onTap() {
    _bounce.forward(from: 0);
    _spawnHeart();
    widget.onTap?.call();
  }

  Widget _staticSprite() {
    // 换模演出：档位立绘切换时旧→新水彩晕染交叉淡入。
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 720),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 1.06, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: Image.asset(widget.assetPath,
          key: ValueKey(widget.assetPath),
          width: widget.width,
          errorBuilder: (_, _, _) => const SizedBox()),
    );
  }

  Widget _breathingStatic() {
    return AnimatedBuilder(
      animation: Listenable.merge([_breath, _bounce]),
      builder: (context, child) {
        final b = math.sin(_breath.value * math.pi);
        final dy = -b * 4;
        final scaleY = 1.0 + b * 0.025;
        final pop = 1.0 +
            Curves.elasticOut.transform(_bounce.value) * 0.08 * (1 - _bounce.value);
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.scale(scaleX: pop, scaleY: scaleY * pop, child: child),
        );
      },
      child: _staticSprite(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playing = _playing;
    final Widget body;
    if (playing != null && widget.speciesId != null) {
      body = SpriteSheetPlayer(
        key: ValueKey('act_${widget.cue?.seq}'),
        assetPath: PetArt.actionSheet(widget.speciesId!, playing),
        size: widget.width,
        onComplete: () {
          if (mounted) setState(() => _playing = null);
        },
        fallback: _breathingStatic(), // 缺帧回落静态呼吸
      );
    } else {
      body = _breathingStatic();
    }
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.width,
        height: widget.width,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            body,
            for (final id in _hearts) _FloatingHeart(key: ValueKey(id)),
          ],
        ),
      ),
    );
  }
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
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();
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
        return Positioned(
          top: 30 - _c.value * 80,
          left: 90 + _dx,
          child: Opacity(
            opacity: (1 - _c.value).clamp(0.0, 1.0),
            child: Transform.scale(
              scale: 0.6 + Curves.easeOut.transform(_c.value) * 0.6,
              child: const Icon(Icons.favorite, color: Color(0xFFF4A7B9), size: 26),
            ),
          ),
        );
      },
    );
  }
}
