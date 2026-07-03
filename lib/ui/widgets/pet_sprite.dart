import 'dart:math' as math;
import 'package:flutter/material.dart';

/// 会「呼吸」的宠物立绘：持续起伏 + 点击弹跳 + 冒爱心。
/// 静态 PNG 也能有生命感；Spine 骨骼到位后可迁到 Flame。
class PetSprite extends StatefulWidget {
  final String assetPath;
  final double width;
  final VoidCallback? onTap;
  const PetSprite({super.key, required this.assetPath, this.width = 220, this.onTap});

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

  @override
  void dispose() {
    _breath.dispose();
    _bounce.dispose();
    super.dispose();
  }

  void _onTap() {
    _bounce.forward(from: 0);
    final id = _heartSeq++;
    setState(() => _hearts.add(id));
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _hearts.remove(id));
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
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
            AnimatedBuilder(
              animation: Listenable.merge([_breath, _bounce]),
              builder: (context, child) {
                // 呼吸：轻微上下浮动 + 竖向微缩放。
                final b = math.sin(_breath.value * math.pi);
                final dy = -b * 4;
                final scaleY = 1.0 + b * 0.025;
                // 点击弹跳：快速回弹。
                final pop = 1.0 + Curves.elasticOut.transform(_bounce.value) * 0.08 *
                    (1 - _bounce.value);
                return Transform.translate(
                  offset: Offset(0, dy),
                  child: Transform.scale(scaleX: pop, scaleY: scaleY * pop, child: child),
                );
              },
              // 换模演出：档位立绘切换时，旧→新水彩晕染交叉淡入（放大微溶）。
              child: AnimatedSwitcher(
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
              ),
            ),
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
