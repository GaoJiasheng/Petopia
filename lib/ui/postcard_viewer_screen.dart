import 'package:flutter/material.dart';

import '../app/game_controller.dart';

/// 明信片查看器：单张明信片的手账式展示——
/// 上半为地点照片（pc_bg）+ 邮戳贴角，下半为手写体正文，页脚署名/站序/日期。
class PostcardViewerScreen extends StatelessWidget {
  final PostcardView card;
  const PostcardViewerScreen({super.key, required this.card});

  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);

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
          child: Container(
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
                // 照片 + 宠物姿态 + 贴纸 + 邮戳
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 2,
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
                      child: Align(
                        alignment: const Alignment(0, 0.72),
                        child: Image.asset(
                          _poseAsset(card.speciesId, card.poseHint),
                          width: 190,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const SizedBox.shrink(),
                        ),
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
                          errorBuilder: (_, _, _) =>
                              const SizedBox(width: 46, height: 46),
                        ),
                      ),
                    ),
                  ],
                ),
                // 正文
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  child: Text(
                    card.bodyText,
                    style: const TextStyle(
                      fontSize: 15.5,
                      height: 1.7,
                      color: _ink,
                    ),
                  ),
                ),
                const Divider(
                  height: 20,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                  color: Color(0xFFEDE4D3),
                ),
                // 页脚
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _date(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';

  static String _poseAsset(String speciesId, String poseHint) {
    final species = switch (speciesId.startsWith('pet_')
        ? speciesId.substring(4)
        : speciesId) {
      'cham' => 'chameleon',
      final value => value,
    };
    final pose = poseHint == 'idle' ? 'gaze' : poseHint;
    return 'assets/art/postcards/poses/pc_pose_${species}_$pose.png';
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
