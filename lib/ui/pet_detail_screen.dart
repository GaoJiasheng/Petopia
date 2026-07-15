import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../config/game_config.dart';
import '../domain/enums.dart';
import 'adaptive_layout.dart';
import 'growth_journal_screen.dart';
import 'pet_art.dart';

class PetDetailScreen extends ConsumerWidget {
  const PetDetailScreen({super.key, required this.initialPet});

  final PetView initialPet;

  static const _bg = Color(0xFFFAF3E3);
  static const _paper = Color(0xFFFFFDF7);
  static const _ink = Color(0xFF604B3E);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);
  static const _green = Color(0xFF91B78B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final livePet = ref.watch(gameControllerProvider).valueOrNull?.pet;
    final pet = livePet ?? initialPet;
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
    final heroHeight = (MediaQuery.sizeOf(context).height * 0.38).clamp(
      260.0,
      scale > 1.35 ? 390.0 : 350.0,
    );
    final hero = Semantics(
      image: true,
      label: '${pet.name}，${pet.speciesName}，${_stageName(pet.stage)}',
      child: Image.asset(
        PetArt.stage(pet.speciesId, pet.stage, variantId: pet.variantId),
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    final details = _PetDetails(pet: pet);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        foregroundColor: _ink,
        elevation: 0,
        centerTitle: true,
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide =
              constraints.maxWidth >= 840 &&
              constraints.maxWidth >= constraints.maxHeight * 0.9;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: wide ? 1180 : 920),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(36),
                            child: Center(
                              child: SizedBox.square(
                                dimension: (constraints.maxWidth * 0.38).clamp(
                                  340.0,
                                  520.0,
                                ),
                                child: hero,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: ColoredBox(
                            color: _paper,
                            child: ListView(
                              padding: EdgeInsets.fromLTRB(
                                36,
                                42,
                                36,
                                36 + MediaQuery.paddingOf(context).bottom,
                              ),
                              children: [details],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: EdgeInsets.only(
                        bottom: 36 + MediaQuery.paddingOf(context).bottom,
                      ),
                      children: [
                        SizedBox(height: heroHeight, child: hero),
                        Container(
                          color: _paper,
                          padding: EdgeInsets.fromLTRB(
                            PetopiaAdaptive.sideMargin(context),
                            26,
                            PetopiaAdaptive.sideMargin(context),
                            28,
                          ),
                          child: details,
                        ),
                      ],
                    ),
            ),
          );
        },
      ),
    );
  }

  static String _stageName(PetStage stage) => switch (stage) {
    PetStage.a => '幼年 A 档',
    PetStage.b => '少年 B 档',
    PetStage.c => '成年 C 档',
    PetStage.d => '旅装 D 档',
  };

  static String _variantName(String variantId) {
    final match = RegExp(r'(\d+)$').firstMatch(variantId);
    final number = int.tryParse(match?.group(1) ?? '') ?? 1;
    return '第 $number 种花色';
  }

  static String _daysTogether(DateTime bornAt) {
    final days = DateTime.now().difference(bornAt).inDays + 1;
    return '相伴 ${days.clamp(1, 99999)} 天';
  }
}

class _PetDetails extends StatelessWidget {
  const _PetDetails({required this.pet});

  final PetView pet;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              '${pet.speciesName} · Lv ${pet.level}',
              style: const TextStyle(
                color: PetDetailScreen._ink,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            _StageBadge(label: PetDetailScreen._stageName(pet.stage)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${PetDetailScreen._variantName(pet.variantId)} · ${PetDetailScreen._daysTogether(pet.bornAt)}',
          style: const TextStyle(
            color: PetDetailScreen._muted,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            minHeight: 10,
            value: (pet.exp / GameConfig.graduationExp).clamp(0, 1),
            backgroundColor: const Color(0xFFEDE4D3),
            color: PetDetailScreen._green,
            semanticsLabel: '成长进度',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          pet.exp >= GameConfig.graduationExp
              ? '已经准备好背起行囊'
              : '经验 ${pet.exp} / ${GameConfig.graduationExp}',
          style: const TextStyle(
            color: PetDetailScreen._muted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 26),
        const Text(
          '它的性格',
          style: TextStyle(
            color: PetDetailScreen._ink,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final trait in pet.personality) _TraitChip(label: trait),
          ],
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const GrowthJournalScreen(),
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: PetDetailScreen._accent,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            icon: const Icon(Icons.auto_stories_rounded),
            label: const Text('翻开成长手账'),
          ),
        ),
      ],
    );
  }
}

class _StageBadge extends StatelessWidget {
  const _StageBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE7C8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: PetDetailScreen._ink,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _TraitChip extends StatelessWidget {
  const _TraitChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1E3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: PetDetailScreen._ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
