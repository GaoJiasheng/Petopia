import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import '../domain/enums.dart';
import 'pet_art.dart';
import 'widgets/pet_sprite.dart';

/// 毕业典礼：Lv10 达标后举行。两幕——送别确认 → 已出发。
/// 暖绒收尾（结算走 EconomyService.settleGraduation），毕业后宠转漫游、院子空出。
class GraduationCeremonyScreen extends ConsumerStatefulWidget {
  final String petName;
  final String speciesId;
  const GraduationCeremonyScreen({
    super.key,
    required this.petName,
    required this.speciesId,
  });

  @override
  ConsumerState<GraduationCeremonyScreen> createState() =>
      _GraduationCeremonyScreenState();
}

class _GraduationCeremonyScreenState
    extends ConsumerState<GraduationCeremonyScreen> {
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);

  bool _sending = false;
  bool _sent = false;
  int? _stops;

  @override
  void initState() {
    super.initState();
    ref.read(audioServiceProvider).playBgm(Bgm.graduation);
  }

  Future<void> _sendOff() async {
    setState(() => _sending = true);
    final stops = await ref.read(gameControllerProvider.notifier).graduate();
    if (!mounted) return;
    setState(() {
      _sending = false;
      _sent = true;
      _stops = stops;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5E9),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _sent ? _sentView(context) : _farewellView(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _farewellView(BuildContext context) {
    return Column(
      key: const ValueKey('farewell'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🎓 毕业啦',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: _ink)),
        const SizedBox(height: 8),
        Text('「${widget.petName}」长大了，是时候去看看外面的世界',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: _muted, height: 1.5)),
        const SizedBox(height: 20),
        PetSprite(
          assetPath: PetArt.stage(widget.speciesId, PetStage.d),
          width: 200,
        ),
        const SizedBox(height: 24),
        _PrimaryButton(
          label: _sending ? '正在收拾行囊…' : '送它去旅行  🎒',
          onTap: _sending ? null : _sendOff,
        ),
        const SizedBox(height: 10),
        if (!_sending)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('再陪它一会儿',
                style: TextStyle(color: _muted, fontSize: 14)),
          ),
      ],
    );
  }

  Widget _sentView(BuildContext context) {
    final stops = _stops;
    return Column(
      key: const ValueKey('sent'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('💌', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text('「${widget.petName}」出发了',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: _ink)),
        const SizedBox(height: 12),
        Text(
          stops == null
              ? '它会一路旅行，常寄明信片回来。\n院子空出来了，去迎接下一位小伙伴吧。'
              : '它的旅途大约会经过 $stops 个地方，\n每隔些日子就会寄一张明信片回来 💌\n院子空出来了，去迎接下一位小伙伴吧。',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: _muted, height: 1.6),
        ),
        const SizedBox(height: 28),
        _PrimaryButton(
          label: '回到院子',
          onTap: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        decoration: BoxDecoration(
          color: onTap == null
              ? const Color(0xFFE6DFD0)
              : _GraduationCeremonyScreenState._accent,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
      ),
    );
  }
}
