import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// 横向序列帧条播放器（4096×512 = 8 帧，每帧 512×512）。
/// 纯 Flutter：异步加载 ui.Image → AnimationController 驱动帧号 → CustomPainter 画对应 srcRect。
/// 加载中/失败渲染 [fallback]，绝不崩、不留白。
class SpriteSheetPlayer extends StatefulWidget {
  final String assetPath;
  final double size;
  final int frameCount;
  final int fps;
  final bool loop;
  final VoidCallback? onComplete;
  final Widget fallback;

  const SpriteSheetPlayer({
    super.key,
    required this.assetPath,
    required this.size,
    required this.fallback,
    this.frameCount = 8,
    this.fps = 12,
    this.loop = false,
    this.onComplete,
  });

  @override
  State<SpriteSheetPlayer> createState() => _SpriteSheetPlayerState();
}

class _SpriteSheetPlayerState extends State<SpriteSheetPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.frameCount / widget.fps * 1000).round()),
  );
  ui.Image? _image;
  bool _failed = false;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && !widget.loop) widget.onComplete?.call();
    });
    _resolveImage();
  }

  void _resolveImage() {
    final provider = AssetImage(widget.assetPath);
    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() => _image = info.image);
        if (widget.loop) {
          _c.repeat();
        } else {
          _c.forward(from: 0);
        }
      },
      onError: (_, _) {
        if (mounted) setState(() => _failed = true);
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) _stream!.removeListener(_listener!);
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final img = _image;
    if (_failed || img == null) return widget.fallback;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final frame =
              (_c.value * widget.frameCount).floor().clamp(0, widget.frameCount - 1);
          return CustomPaint(
            painter: _FramePainter(img, frame, widget.frameCount),
          );
        },
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  final ui.Image image;
  final int frame;
  final int frameCount;
  _FramePainter(this.image, this.frame, this.frameCount);

  @override
  void paint(Canvas canvas, Size size) {
    final fw = image.width / frameCount; // 每帧宽（512）
    final fh = image.height.toDouble();
    final src = Rect.fromLTWH(frame * fw, 0, fw, fh);
    final dst = Rect.fromLTWH(0, 0, size.width, size.height); // 方帧→方框，等比
    canvas.drawImageRect(image, src, dst, Paint()..filterQuality = FilterQuality.medium);
  }

  @override
  bool shouldRepaint(_FramePainter old) => old.frame != frame || old.image != image;
}
