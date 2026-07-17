import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../domain/enums.dart';
import 'adopt_screen.dart';
import 'pet_art.dart';
import 'yard_art.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key, required this.needsAdoption});

  final bool needsAdoption;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;
  bool _finishing = false;

  static const _ink = Color(0xFF5F493B);
  static const _accent = Color(0xFFE99C55);
  static const _pages = <_OnboardingPageData>[
    _OnboardingPageData(
      title: '院子醒来了',
      body: '这里总会为一位小伙伴，留下一片柔软的草地。',
      stage: PetStage.a,
      semantics: '一只刚来到院子的奶油橘色小猫',
    ),
    _OnboardingPageData(
      title: '陪它慢慢长大',
      body: '每一天的相处，都会悄悄写进属于你们的手账。',
      stage: PetStage.c,
      semantics: '已经长大的奶油橘色小猫',
    ),
    _OnboardingPageData(
      title: '远方也会寄回回忆',
      body: '毕业不是告别。它会背起行囊，从旅途中继续给你写信。',
      stage: PetStage.d,
      semantics: '准备旅行的奶油橘色小猫',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    await ref.read(gameControllerProvider.notifier).completeOnboarding();
    if (!mounted) return;
    if (widget.needsAdoption) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const AdoptScreen()),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _finish();
      return;
    }
    final target = _page + 1;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(target);
    } else {
      _pageController.animateToPage(
        target,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFCEFD6),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              YardArt.themeBg('meadow'),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
            ColoredBox(color: Colors.white.withValues(alpha: 0.16)),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: TextButton(
                            onPressed: _finishing ? null : _finish,
                            child: const Text(
                              '跳过',
                              style: TextStyle(
                                color: _ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: _pages.length,
                          onPageChanged: (value) =>
                              setState(() => _page = value),
                          itemBuilder: (context, index) =>
                              _OnboardingPage(data: _pages[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              label: '第 ${_page + 1} 页，共 ${_pages.length} 页',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  for (
                                    var index = 0;
                                    index < _pages.length;
                                    index++
                                  )
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      width: index == _page ? 24 : 8,
                                      height: 8,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: index == _page
                                            ? _accent
                                            : Colors.white.withValues(
                                                alpha: 0.78,
                                              ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: _finishing ? null : _next,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _accent,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(52),
                                  textStyle: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                child: _finishing
                                    ? const SizedBox.square(
                                        dimension: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _page == _pages.length - 1
                                            ? '去迎接第一位伙伴'
                                            : '继续',
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingPageData data;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageSize = (size.shortestSide * 0.54).clamp(220.0, 380.0);
    final wide = size.width >= 900 && size.width > size.height;
    final art = Semantics(
      image: true,
      label: data.semantics,
      child: Image.asset(
        PetArt.stage('pet_cat', data.stage),
        width: imageSize,
        height: imageSize,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
    final words = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: wide
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          data.title,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            color: _OnboardingScreenState._ink,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            data.body,
            textAlign: wide ? TextAlign.start : TextAlign.center,
            style: TextStyle(
              color: _OnboardingScreenState._ink.withValues(alpha: 0.88),
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
    if (wide) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Center(child: art)),
            const SizedBox(width: 52),
            Expanded(child: words),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Center(child: art)),
          words,
          const SizedBox(height: 18),
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.body,
    required this.stage,
    required this.semantics,
  });

  final String title;
  final String body;
  final PetStage stage;
  final String semantics;
}
