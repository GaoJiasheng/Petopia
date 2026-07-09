import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../app/game_controller.dart';

/// 明信片查看器：单张明信片的手账式展示——
/// 上半为地点照片（pc_bg）+ 邮戳贴角，下半为手写体正文，页脚署名/站序/日期。
class PostcardViewerScreen extends StatelessWidget {
  final PostcardView card;
  const PostcardViewerScreen({super.key, required this.card});

  static const _ink = Color(0xFF6B5445);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E9D6),
      appBar: AppBar(
        title: Text(
          card.locationName,
          style: const TextStyle(color: _ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF3E9D6),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: PostcardDisplayCard(card: card),
        ),
      ),
    );
  }
}

Future<void> showPostcardArrivalDialog(
  BuildContext context,
  PostcardView card,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 360),
    pageBuilder: (context, _, _) {
      return Stack(
        fit: StackFit.expand,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: ColoredBox(
              color: const Color(0xFFF3E9D6).withValues(alpha: 0.82),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: PostcardDisplayCard(
                  card: card,
                  arrivalMode: true,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// Reusable postcard card used by both album viewing and the receive popup.
class PostcardDisplayCard extends StatelessWidget {
  final PostcardView card;
  final bool arrivalMode;
  final VoidCallback? onClose;
  const PostcardDisplayCard({
    super.key,
    required this.card,
    this.arrivalMode = false,
    this.onClose,
  });

  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (arrivalMode) _ArrivalHeader(card: card, onClose: onClose),
          _PostcardPhoto(card: card),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Text(
              card.bodyText,
              style: const TextStyle(fontSize: 15.5, height: 1.7, color: _ink),
            ),
          ),
          const Divider(
            height: 20,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Color(0xFFEDE4D3),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, arrivalMode ? 10 : 16),
            child: Row(
              children: [
                const Icon(Icons.pets_rounded, size: 15, color: _muted),
                const SizedBox(width: 5),
                Text(
                  card.petName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
                const Spacer(),
                Text(
                  '第 ${card.seq + 1} 站 · ${_date(card.sentAt)}',
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          if (arrivalMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE8A15C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: onClose,
                  child: const Text(
                    '收进相册',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _date(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
}

class _ArrivalHeader extends StatelessWidget {
  final PostcardView card;
  final VoidCallback? onClose;
  const _ArrivalHeader({required this.card, this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 10, 12),
      child: Row(
        children: [
          const Icon(
            Icons.local_post_office_rounded,
            color: Color(0xFFE8A15C),
            size: 24,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '${card.petName} 从远方寄来一张明信片',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B5445),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            tooltip: '关闭',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded, color: Color(0xFF8A7A6A)),
          ),
        ],
      ),
    );
  }
}

class _PostcardPhoto extends StatelessWidget {
  final PostcardView card;
  const _PostcardPhoto({required this.card});

  static const _muted = Color(0xFF8A7A6A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        AspectRatio(
          aspectRatio: 3 / 2,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/art/postcards/backgrounds/${card.photoBg}.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: const Color(0xFFDCEAD8),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.photo_rounded,
                      size: 48,
                      color: _muted,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = constraints.maxWidth * 0.151;
                    return Stack(
                      children: [
                        Positioned(
                          left: constraints.maxWidth * 0.53 - size / 2,
                          top: constraints.maxHeight * 0.79 - size / 2,
                          child: Transform.rotate(
                            angle: -0.017,
                            child: _TravelerSceneAsset(
                              card.speciesId,
                              card.variantId,
                              size: size,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (card.stickerIds.isNotEmpty)
          Positioned(
            left: 14,
            bottom: 12,
            child: _StickerAsset(card.stickerIds.first, size: 50),
          ),
        if (card.stickerIds.length > 1)
          Positioned(
            right: 68,
            bottom: 16,
            child: Transform.rotate(
              angle: -0.08,
              child: _StickerAsset(card.stickerIds[1], size: 44),
            ),
          ),
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 4),
              ],
            ),
            child: Image.asset(
              'assets/art/postcards/stamps/${card.stampId}.png',
              width: 46,
              height: 46,
              errorBuilder: (_, _, _) => const SizedBox(width: 46, height: 46),
            ),
          ),
        ),
      ],
    );
  }
}

class _TravelerSceneAsset extends StatelessWidget {
  final String speciesId;
  final String variantId;
  final double size;
  const _TravelerSceneAsset(
    this.speciesId,
    this.variantId, {
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final species = _speciesSlug(speciesId);
    final variant = _variantSlug(variantId);
    final paths = <String>[
      if (variant != null)
        'assets/art/postcards/stickers/pc_sticker_traveler_${species}_${variant}_back.png',
      'assets/art/postcards/stickers/pc_sticker_traveler_${species}_var01_back.png',
      'assets/art/postcards/stickers/pc_sticker_traveler_${species}_back.png',
    ];
    return _buildAsset(
      paths,
      fallback: Image.asset(
        _poseAsset(speciesId, 'gaze'),
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildAsset(List<String> paths, {required Widget fallback}) {
    if (paths.isEmpty) return fallback;
    final path = paths.first;
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) =>
          _buildAsset(paths.sublist(1), fallback: fallback),
    );
  }
}

class _StickerAsset extends StatelessWidget {
  final String id;
  final double size;
  const _StickerAsset(this.id, {required this.size});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/art/postcards/stickers/$id.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}

String _speciesSlug(String speciesId) {
  return switch (speciesId.startsWith('pet_')
      ? speciesId.substring(4)
      : speciesId) {
    'cham' => 'chameleon',
    final value => value,
  };
}

String? _variantSlug(String variantId) {
  final match = RegExp(r'_v([1-5])$').firstMatch(variantId);
  final value = match == null ? null : int.tryParse(match.group(1)!);
  if (value == null) return null;
  return 'var${value.toString().padLeft(2, '0')}';
}

String _poseAsset(String speciesId, String poseHint) {
  final pose = poseHint == 'idle' ? 'gaze' : poseHint;
  return 'assets/art/postcards/poses/pc_pose_${_speciesSlug(speciesId)}_$pose.png';
}
