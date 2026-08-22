import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';

/// 横向序列帧条播放器（4096×512 = 8 帧，每帧 512×512）。
/// 纯 Flutter：异步加载 ui.Image → AnimationController 驱动帧号 → CustomPainter 画对应 srcRect。
/// 加载中/失败渲染 [fallback]，绝不崩、不留白。
class SpriteSheetPlayer extends StatefulWidget {
  static const defaultFps = 5;

  final String assetPath;
  final double size;
  final int frameCount;
  final int fps;
  final Duration? duration;
  final Duration? playDuration;
  final bool loop;
  final bool animate;
  final int staticFrame;
  final int cycles;
  final double holdTailFraction;
  final VoidCallback? onComplete;
  final Widget fallback;
  final bool evictOnDispose;

  const SpriteSheetPlayer({
    super.key,
    required this.assetPath,
    required this.size,
    required this.fallback,
    this.frameCount = 8,
    this.fps = defaultFps,
    this.duration,
    this.playDuration,
    this.loop = false,
    this.animate = true,
    this.staticFrame = 0,
    this.cycles = 1,
    this.holdTailFraction = 0,
    this.onComplete,
    this.evictOnDispose = false,
  });

  @override
  State<SpriteSheetPlayer> createState() => _SpriteSheetPlayerState();
}

class _SpriteSheetPlayerState extends State<SpriteSheetPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: _animationDuration(widget),
  );
  ImageInfo? _imageInfo;
  bool _failed = false;
  ImageStream? _stream;
  ImageStreamListener? _listener;
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && !widget.loop) {
        widget.onComplete?.call();
      }
    });
    _resolveImage();
  }

  @override
  void didUpdateWidget(SpriteSheetPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final assetChanged = oldWidget.assetPath != widget.assetPath;
    final timingChanged =
        oldWidget.duration != widget.duration ||
        oldWidget.frameCount != widget.frameCount ||
        oldWidget.fps != widget.fps;
    final playbackChanged =
        oldWidget.animate != widget.animate ||
        oldWidget.loop != widget.loop ||
        oldWidget.playDuration != widget.playDuration ||
        timingChanged;

    if (assetChanged) {
      _detachImageStream();
      _completionTimer?.cancel();
      _completionTimer = null;
      _c
        ..stop()
        ..value = 0
        ..duration = _animationDuration(widget);
      _replaceImageInfo(null);
      _failed = false;
      if (oldWidget.evictOnDispose) {
        unawaited(AssetImage(oldWidget.assetPath).evict());
      }
      _resolveImage();
      return;
    }

    if (timingChanged) _c.duration = _animationDuration(widget);
    if (playbackChanged) {
      _completionTimer?.cancel();
      _completionTimer = null;
      _c
        ..stop()
        ..value = 0;
      if (widget.animate && _imageInfo != null) _startPlayback();
    }
  }

  void _startPlayback() {
    _completionTimer?.cancel();
    _completionTimer = null;
    if (!widget.animate) return;
    if (widget.loop) {
      _c.repeat();
    } else if (widget.playDuration != null) {
      _c.repeat();
      _completionTimer = Timer(widget.playDuration!, () {
        if (!mounted) return;
        _c.stop();
        widget.onComplete?.call();
      });
    } else {
      _c.forward(from: 0);
    }
  }

  void _resolveImage() {
    final provider = AssetImage(widget.assetPath);
    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) {
          info.dispose();
          return;
        }
        setState(() => _replaceImageInfo(info));
        _startPlayback();
      },
      onError: (_, _) {
        if (!mounted) return;
        setState(() => _failed = true);
        final fallbackDuration =
            widget.playDuration ??
            widget.duration ??
            Duration(
              milliseconds: (widget.frameCount / widget.fps * 1000).round(),
            );
        if (widget.animate) {
          _completionTimer = Timer(fallbackDuration, () {
            if (mounted) widget.onComplete?.call();
          });
        }
      },
    );
    _stream = stream;
    _listener = listener;
    stream.addListener(listener);
  }

  void _detachImageStream() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) stream.removeListener(listener);
    _stream = null;
    _listener = null;
  }

  void _replaceImageInfo(ImageInfo? next) {
    final previous = _imageInfo;
    if (identical(previous, next)) return;
    _imageInfo = next;
    previous?.dispose();
  }

  @override
  void dispose() {
    _detachImageStream();
    _replaceImageInfo(null);
    _c.dispose();
    _completionTimer?.cancel();
    if (widget.evictOnDispose) {
      unawaited(AssetImage(widget.assetPath).evict());
    }
    super.dispose();
  }

  static Duration _animationDuration(SpriteSheetPlayer player) =>
      player.duration ??
      Duration(milliseconds: (player.frameCount / player.fps * 1000).round());

  @override
  Widget build(BuildContext context) {
    final img = _imageInfo?.image;
    if (_failed || img == null) return widget.fallback;
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final frame = widget.animate
              ? (_frameProgress(_c.value) * widget.frameCount).floor().clamp(
                  0,
                  widget.frameCount - 1,
                )
              : widget.staticFrame.clamp(0, widget.frameCount - 1);
          return CustomPaint(
            painter: _FramePainter(img, frame, widget.frameCount),
          );
        },
      ),
    );
  }

  double _frameProgress(double value) {
    if (widget.loop || widget.playDuration != null) return value;
    final hold = widget.holdTailFraction.clamp(0.0, 0.9);
    final active = 1 - hold;
    if (value >= active) return 1;
    final scaled = value / active * widget.cycles.clamp(1, 20);
    return scaled - scaled.floor();
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
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_FramePainter old) =>
      old.frame != frame || old.image != image;
}
