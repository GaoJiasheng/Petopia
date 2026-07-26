import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import '../audio/route_audio.dart';
import '../domain/enums.dart';
import 'adaptive_layout.dart';
import 'pet_art.dart';
import 'petopia_theme.dart';
import 'yard_art.dart';
import 'widgets/pet_sprite.dart';

/// 毕业典礼：Lv10 达标后举行。两幕——送别确认 → 已出发。
/// 暖绒收尾（结算走 EconomyService.settleGraduation），毕业后宠转漫游、院子空出。
class GraduationCeremonyScreen extends ConsumerStatefulWidget {
  final String petName;
  final String speciesId;
  final String variantId;
  const GraduationCeremonyScreen({
    super.key,
    required this.petName,
    required this.speciesId,
    required this.variantId,
  });

  @override
  ConsumerState<GraduationCeremonyScreen> createState() =>
      _GraduationCeremonyScreenState();
}

class _GraduationCeremonyScreenState
    extends ConsumerState<GraduationCeremonyScreen>
    with RouteAudio<GraduationCeremonyScreen> {
  static const _ink = PetopiaColors.ink;
  static const _muted = PetopiaColors.mutedText;
  static const _accent = PetopiaColors.actionAccent;

  bool _sending = false;
  bool _sent = false;
  int? _stops;
  String _routeTheme = '海滨';

  @override
  Bgm get routeBgm => Bgm.graduation;

  Future<void> _sendOff() async {
    setState(() => _sending = true);
    final stops = await ref
        .read(gameControllerProvider.notifier)
        .graduate(routeTheme: _routeTheme);
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            YardArt.themeBg('meadow'),
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          ColoredBox(color: const Color(0xFFFCEFD6).withValues(alpha: 0.38)),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final wide =
                    constraints.maxWidth >= 820 &&
                    constraints.maxWidth > constraints.maxHeight;
                final petWidth = (PetopiaAdaptive.petStageWidth(size) * 0.82)
                    .clamp(200.0, wide ? 320.0 : 280.0);
                return Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: PetopiaAdaptive.sideMargin(context),
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: wide ? 940 : 620),
                      child: AnimatedSwitcher(
                        duration: PetopiaMotion.duration(
                          context,
                          const Duration(milliseconds: 500),
                        ),
                        child: _sent
                            ? _sentView(context)
                            : _farewellView(context, petWidth, wide: wide),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _farewellView(
    BuildContext context,
    double petWidth, {
    required bool wide,
  }) {
    final pet = PetSprite(
      assetPath: PetArt.stage(
        widget.speciesId,
        PetStage.d,
        variantId: widget.variantId,
      ),
      width: petWidth,
    );
    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🎓 毕业啦',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: _ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '「${widget.petName}」长大了，是时候去看看外面的世界',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 15, color: _muted, height: 1.5),
        ),
        const SizedBox(height: 24),
        _routePicker(),
        const SizedBox(height: 18),
        _PrimaryButton(
          label: _sending ? '正在收拾行囊…' : '送它去旅行  🎒',
          onTap: _sending ? null : _sendOff,
        ),
        const SizedBox(height: 10),
        if (!_sending)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '再陪它一会儿',
              style: TextStyle(color: _muted, fontSize: 14),
            ),
          ),
      ],
    );
    return DecoratedBox(
      key: const ValueKey('farewell'),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: wide
            ? Row(
                children: [
                  Expanded(flex: 6, child: Center(child: pet)),
                  const SizedBox(width: 24),
                  Expanded(flex: 5, child: copy),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎓 毕业啦',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '「${widget.petName}」长大了，是时候去看看外面的世界',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: _muted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  pet,
                  const SizedBox(height: 24),
                  _routePicker(),
                  const SizedBox(height: 18),
                  _PrimaryButton(
                    label: _sending ? '正在收拾行囊…' : '送它去旅行  🎒',
                    onTap: _sending ? null : _sendOff,
                  ),
                  const SizedBox(height: 10),
                  if (!_sending)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        '再陪它一会儿',
                        style: TextStyle(color: _muted, fontSize: 14),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _routePicker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '第一程，想让它往哪里走？',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: '海滨',
                icon: Icon(Icons.waves_rounded, size: 18),
                label: Text('海边'),
              ),
              ButtonSegment(
                value: '森林',
                icon: Icon(Icons.forest_rounded, size: 18),
                label: Text('森林'),
              ),
              ButtonSegment(
                value: '城市',
                icon: Icon(Icons.location_city_rounded, size: 18),
                label: Text('城市'),
              ),
            ],
            selected: <String>{_routeTheme},
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? _ink : _muted,
              ),
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? const Color(0xFFFFE8C7)
                    : const Color(0xFFFFFDF7),
              ),
            ),
            onSelectionChanged: _sending
                ? null
                : (selected) => setState(() => _routeTheme = selected.first),
          ),
        ),
      ],
    );
  }

  Widget _sentView(BuildContext context) {
    final stops = _stops;
    return DecoratedBox(
      key: const ValueKey('sent'),
      decoration: _cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💌', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              '「${widget.petName}」出发了',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              stops == null
                  ? '它会一路旅行，常寄明信片回来。\n院子空出来了，去迎接下一位小伙伴吧。'
                  : '它会先往${_routeLabel(_routeTheme)}走，旅途大约经过 $stops 个地方。\n每隔些日子就会寄一张明信片回来 💌\n院子空出来了，去迎接下一位小伙伴吧。',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: _muted, height: 1.6),
            ),
            const SizedBox(height: 28),
            _PrimaryButton(
              label: '回到院子',
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: const Color(0xFFFFFDF7).withValues(alpha: 0.94),
    borderRadius: BorderRadius.circular(26),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 16)],
  );

  static String _routeLabel(String routeTheme) => switch (routeTheme) {
    '海滨' => '有海风的地方',
    '森林' => '树影深处',
    '城市' => '热闹的街灯',
    _ => '远方',
  };
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const _PrimaryButton({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: _GraduationCeremonyScreenState._accent,
        foregroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFE6DFD0),
        disabledForegroundColor: _GraduationCeremonyScreenState._muted,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );
  }
}
