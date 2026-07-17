import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../app/game_services.dart';
import '../audio/audio_service.dart';
import '../config/game_config.dart';
import '../domain/enums.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'adaptive_layout.dart';
import 'pet_action_cue.dart';
import 'pet_art.dart';
import 'yard_art.dart';
import 'widgets/pet_sprite.dart';
import 'widgets/sprite_sheet_player.dart';
import 'achievements_screen.dart';
import 'adopt_screen.dart';
import 'album_screen.dart';
import 'graduation_ceremony_screen.dart';
import 'growth_journal_screen.dart';
import 'onboarding_screen.dart';
import 'pet_dex_screen.dart';
import 'pet_detail_screen.dart';
import 'postcard_viewer_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'visitor_dex_screen.dart';

/// 触发一次宠物动作动画（自增 seq 以便重复播同一动作）。
void _fireCue(WidgetRef ref, String pose) {
  final prev = ref.read(petActionCueProvider);
  ref.read(petActionCueProvider.notifier).state = PetActionCue(
    pose,
    (prev?.seq ?? 0) + 1,
  );
}

/// 院子主屏（P2 响应式版）：满幅背景 + 宠物立绘 + 状态卡 + 4 照料动作（带冷却）。
/// 动作走真实服务链路（ExpEngine→审计→sqflite）。Flame 动画场景为后续。
class YardHomeScreen extends ConsumerStatefulWidget {
  const YardHomeScreen({super.key});

  @override
  ConsumerState<YardHomeScreen> createState() => _YardHomeScreenState();
}

class _YardHomeScreenState extends ConsumerState<YardHomeScreen>
    with WidgetsBindingObserver {
  Timer? _cooldownTimer;
  String? _precacheKey;
  final DateTime _openedAt = DateTime.now().toUtc();
  final Set<String> _shownArrivalPostcards = <String>{};
  bool _postcardDialogOpen = false;
  bool _visitorDialogOpen = false;
  bool _revisitorDialogOpen = false;
  bool _eventDialogOpen = false;
  bool _offlineWelcomeOpen = false;
  bool _onboardingOpen = false;
  bool _eventPresentedThisActivation = false;
  Bgm? _currentBgm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final async = ref.read(gameControllerProvider);
      if (async.hasValue &&
          async.requireValue.cooldownSec.values.any((seconds) => seconds > 0)) {
        ref.read(gameControllerProvider.notifier).refreshView();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _eventPresentedThisActivation = false;
      unawaited(ref.read(gameControllerProvider.notifier).onAppResumed());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(ref.read(gameControllerProvider.notifier).onAppPaused());
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AchievementUnlockCue?>(achievementUnlockCueProvider, (
      previous,
      next,
    ) {
      if (next == null || next.seq == previous?.seq) return;
      _showAchievementToast(context, next.names);
    });
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) {
        logUiError('yard startup', error, stackTrace);
        return Scaffold(
          backgroundColor: const Color(0xFFFAF3E3),
          body: AppLoadError(
            title: '小院暂时没有醒来',
            onRetry: () => ref.invalidate(gameControllerProvider),
          ),
        );
      },
      data: (view) {
        final pet = view.pet;
        final ctrl = ref.read(gameControllerProvider.notifier);
        final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        // 院子 BGM 按时段切换（幂等，已在播则忽略）。
        final hour = DateTime.now().hour;
        final yardBgm = (hour >= 19 || hour < 6)
            ? Bgm.yardNight
            : (hour >= 16 ? Bgm.yardDusk : Bgm.yardDay);
        if (_currentBgm != yardBgm) {
          _currentBgm = yardBgm;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) ref.read(audioServiceProvider).playBgm(yardBgm);
          });
        }
        if (!view.onboardingComplete && routeIsCurrent) {
          _scheduleOnboarding(ctrl, needsAdoption: view.pet == null);
        } else if (!_onboardingOpen && routeIsCurrent) {
          final offlineWelcome = view.offlineWelcome;
          if (offlineWelcome != null) {
            _scheduleOfflineWelcome(ctrl, offlineWelcome);
          } else {
            _schedulePostcardArrival(ctrl);
            _scheduleVisitorArrival(ctrl, view.visitorArrival);
            _scheduleRevisitorArrival(ctrl, view.revisitorArrival);
            _scheduleEvent(ctrl, view.pendingEvent);
          }
        }
        final petAsset = pet == null
            ? null
            : PetArt.stage(pet.speciesId, pet.stage, variantId: pet.variantId);
        if (pet != null && petAsset != null) {
          _precacheCurrentPetAssets(context, pet, petAsset);
        }
        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              final wideLayout = PetopiaAdaptive.useYardSidePanels(size);
              final sceneScale = wideLayout ? 1.16 : 1.0;
              final petWidth = PetopiaAdaptive.petStageWidth(size);
              final petAlignment = Alignment(0, wideLayout ? 0.32 : 0.4);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    YardArt.themeBg(view.activeThemeId),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Image.asset(
                      'assets/art/world/themes/yard_theme_meadow_bg.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (YardArt.luxuryDelta(view.luxuryStage) case final asset?)
                    IgnorePointer(
                      child: Image.asset(
                        asset,
                        key: ValueKey('yard_luxury_${view.luxuryStage}'),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    ),
                  // 摆件中景层（渲染在宠物之下）：自定义 slots 为空时使用默认布置。
                  for (final decor in _visibleDecor(
                    view.decorSlots,
                    view.luxuryStage,
                  ))
                    _YardDecor(
                      align: decor.anchor.align,
                      decorId: decor.decorId,
                      width: decor.anchor.width * sceneScale,
                    ),
                  if (view.activeVisitor != null)
                    Builder(
                      builder: (context) {
                        final visitor = view.activeVisitor!;
                        final placement = _visitorYardPlacement(visitor);
                        final rect = PetopiaAdaptive.yardSideActorRect(
                          sceneSize: size,
                          petWidth: petWidth,
                          petAlignment: petAlignment,
                          preferredAlignment: placement.alignment,
                          preferredSize: placement.size * sceneScale,
                        );
                        return Positioned.fromRect(
                          rect: rect,
                          child: _YardVisitor(
                            visitor: visitor,
                            size: rect.width,
                            onTap: () => showVisitorArrivalDialog(
                              context,
                              ctrl,
                              visitor,
                            ),
                          ),
                        );
                      },
                    ),
                  if (petAsset != null)
                    Align(
                      alignment: petAlignment,
                      child: PetSprite(
                        assetPath: petAsset,
                        width: petWidth,
                        speciesId: pet!.speciesId,
                        variantId: pet.variantId,
                        stage: pet.stage,
                        cue: ref.watch(petActionCueProvider),
                        onTap: () async {
                          if (await ctrl.pat()) _fireCue(ref, 'pat');
                        },
                      ),
                    ),
                  if (view.revisitor != null)
                    Builder(
                      builder: (context) {
                        final revisitor = view.revisitor!;
                        final visitorUsesRightLane =
                            view.activeVisitor != null &&
                            _visitorYardPlacement(
                                  view.activeVisitor!,
                                ).alignment.x >
                                0;
                        final revisitorAlignment = Alignment(
                          visitorUsesRightLane ? -0.56 : 0.56,
                          0.46,
                        );
                        final rect = PetopiaAdaptive.yardSideActorRect(
                          sceneSize: size,
                          petWidth: petWidth,
                          petAlignment: petAlignment,
                          preferredAlignment: revisitorAlignment,
                          preferredSize: petWidth * 0.48,
                        );
                        return Positioned.fromRect(
                          rect: rect,
                          child: GestureDetector(
                            onTap: () => _showRevisitorDialog(ctrl, revisitor),
                            child: Image.asset(
                              PetArt.stage(
                                revisitor.speciesId,
                                PetStage.d,
                                variantId: revisitor.variantId,
                              ),
                              width: rect.width,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  Positioned.fill(
                    child: _YardAtmosphere(
                      weather: view.weather,
                      hour: DateTime.now().hour,
                    ),
                  ),
                  _YardOverlay(view: view, ref: ref, wideLayout: wideLayout),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showAchievementToast(BuildContext context, List<String> names) {
    if (!mounted || names.isEmpty) return;
    final title = names.length == 1
        ? names.first
        : '${names.first} 等 ${names.length} 项';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF6B5445),
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 92),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const AppIcon(
              'ach_firstgrad',
              size: 28,
              fallback: Icons.emoji_events_rounded,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '达成成就：$title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _scheduleOnboarding(GameController ctrl, {required bool needsAdoption}) {
    if (_onboardingOpen || !mounted) return;
    _onboardingOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => OnboardingScreen(needsAdoption: needsAdoption),
        ),
      );
      if (mounted) setState(() => _onboardingOpen = false);
    });
  }

  void _schedulePostcardArrival(GameController ctrl) {
    if (_postcardDialogOpen || !mounted) return;
    final cards = ctrl.postcards();
    if (cards.isEmpty) return;
    final latest = cards.first;
    if (_shownArrivalPostcards.contains(latest.id)) return;
    final sentAt = latest.sentAt.toUtc();
    if (sentAt.isBefore(_openedAt.subtract(const Duration(seconds: 10)))) {
      return;
    }

    _shownArrivalPostcards.add(latest.id);
    _postcardDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showPostcardArrivalDialog(context, latest);
      if (mounted) _postcardDialogOpen = false;
    });
  }

  void _scheduleOfflineWelcome(
    GameController ctrl,
    OfflineWelcomeView welcome,
  ) {
    if (_offlineWelcomeOpen || !mounted) return;
    _offlineWelcomeOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showGeneralDialog<void>(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(
          context,
        ).modalBarrierDismissLabel,
        barrierColor: Colors.black.withValues(alpha: 0.18),
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (context, _, _) => Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: _OfflineWelcomeCard(welcome: welcome),
              ),
            ),
          ),
        ),
        transitionBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      );
      ctrl.dismissOfflineWelcome(welcome.seq);
      if (mounted) _offlineWelcomeOpen = false;
    });
  }

  void _scheduleVisitorArrival(
    GameController ctrl,
    VisitorPresenceView? arrival,
  ) {
    if (_visitorDialogOpen || _postcardDialogOpen || !mounted) return;
    if (arrival == null) return;

    _visitorDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await showVisitorArrivalDialog(context, ctrl, arrival);
      ctrl.markVisitorArrivalSeen(arrival.id);
      if (mounted) _visitorDialogOpen = false;
    });
  }

  void _scheduleRevisitorArrival(
    GameController ctrl,
    RevisitorPresenceView? arrival,
  ) {
    if (_revisitorDialogOpen || _postcardDialogOpen || !mounted) return;
    if (arrival == null) return;
    _revisitorDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _showRevisitorDialog(ctrl, arrival);
      ctrl.markRevisitorArrivalSeen(arrival.id);
      if (mounted) _revisitorDialogOpen = false;
    });
  }

  void _scheduleEvent(GameController ctrl, EventPresentationView? event) {
    if (_eventDialogOpen ||
        _eventPresentedThisActivation ||
        _postcardDialogOpen ||
        _visitorDialogOpen ||
        _revisitorDialogOpen ||
        !mounted ||
        event == null) {
      return;
    }
    _eventPresentedThisActivation = true;
    _eventDialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final choiceIndex = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _EventDialog(event: event),
      );
      ctrl.resolveEvent(
        event.id,
        choiceIndex: choiceIndex != null && choiceIndex >= 0
            ? choiceIndex
            : null,
      );
      if (mounted) _eventDialogOpen = false;
    });
  }

  Future<void> _showRevisitorDialog(
    GameController ctrl,
    RevisitorPresenceView revisitor,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _RevisitorDialog(
        revisitor: revisitor,
        onInteract: () => ctrl.interactRevisitor(revisitor.id),
      ),
    );
  }

  Future<void> showVisitorArrivalDialog(
    BuildContext context,
    GameController ctrl,
    VisitorPresenceView visitor,
  ) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (context, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: _VisitorArrivalCard(
                  visitor: visitor,
                  onInteract: () => ctrl.interactVisitor(visitor.id),
                ),
              ),
            ),
          ),
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

  void _precacheCurrentPetAssets(
    BuildContext context,
    PetView pet,
    String staticAsset,
  ) {
    final key = '${pet.speciesId}:${pet.variantId}:${pet.stage}:$staticAsset';
    if (_precacheKey == key) return;
    _precacheKey = key;

    const actions = ['eat', 'pat', 'play', 'bath'];
    final assets = [
      staticAsset,
      for (final action in actions) PetArt.actionSheet(pet.speciesId, action),
    ];
    for (final asset in assets) {
      unawaited(
        precacheImage(AssetImage(asset), context).catchError((Object _) {}),
      );
    }
  }
}

class _OfflineWelcomeCard extends StatelessWidget {
  const _OfflineWelcomeCard({required this.welcome});

  final OfflineWelcomeView welcome;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(24),
          image: const DecorationImage(
            image: AssetImage('assets/art/ui/ui_frame_offline_card.png'),
            fit: BoxFit.fill,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 28,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth >= 480;
            final art = Semantics(
              image: true,
              label: '${welcome.petName}睡饱后回到你身边',
              child: Image.asset(
                PetArt.stage(
                  welcome.speciesId,
                  welcome.stage,
                  variantId: welcome.variantId,
                ),
                width: horizontal ? 190 : 154,
                height: horizontal ? 190 : 154,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            );
            final words = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: horizontal
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  welcome.expGained > 0
                      ? '${welcome.petName}睡饱了，蹭蹭你 +${welcome.expGained}'
                      : '${welcome.petName}睡饱了，又来蹭蹭你',
                  textAlign: horizontal ? TextAlign.start : TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF604B3E),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  welcome.story,
                  textAlign: horizontal ? TextAlign.start : TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF7E6A5B),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: horizontal ? 210 : double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.favorite_rounded, size: 18),
                    label: const Text('抱抱它'),
                  ),
                ),
              ],
            );
            final content = horizontal
                ? Row(
                    children: [
                      art,
                      const SizedBox(width: 20),
                      Expanded(child: words),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [art, words],
                  );
            if (reduceMotion) return content;
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutBack,
              tween: Tween(begin: 0.96, end: 1),
              builder: (context, value, child) => Transform.scale(
                scale: value,
                alignment: Alignment.bottomCenter,
                child: child,
              ),
              child: content,
            );
          },
        ),
      ),
    );
  }
}

class _YardOverlay extends StatelessWidget {
  final GameView view;
  final WidgetRef ref;
  final bool wideLayout;
  const _YardOverlay({
    required this.view,
    required this.ref,
    required this.wideLayout,
  });

  @override
  Widget build(BuildContext context) {
    final pet = view.pet;
    if (!wideLayout) {
      final maxOverlayWidth = PetopiaAdaptive.isMediumUp(context)
          ? 720.0
          : double.infinity;
      Widget constrain(Widget child) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxOverlayWidth),
          child: child,
        ),
      );
      return SafeArea(
        child: Column(
          children: [
            if (pet != null)
              constrain(
                _InfoCard(
                  pet: pet,
                  wallet: view.wallet,
                  onTap: () => _openPetDetail(context, pet),
                ),
              )
            else
              const _TopMenuOnly(),
            const Spacer(),
            if (view.todayYard != null)
              constrain(_TodayYardButton(today: view.todayYard!)),
            if (view.todayYard != null) const SizedBox(height: 8),
            if (view.activeVisitor != null)
              constrain(_VisitorStayPill(visitor: view.activeVisitor!)),
            if (view.activeVisitor != null) const SizedBox(height: 10),
            if (pet == null)
              constrain(const _AdoptCta())
            else
              constrain(
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (view.canGraduate)
                      _GraduateBanner(onTap: () => _graduate(context, pet)),
                    if (view.careTutorialStep < 3) ...[
                      _CareTutorialHint(
                        step: view.careTutorialStep,
                        onDone: ref
                            .read(gameControllerProvider.notifier)
                            .completeCareTutorial,
                      ),
                      const SizedBox(height: 8),
                    ],
                    _ActionBar(
                      ref: ref,
                      cooldown: view.cooldownSec,
                      dailyMaxed: view.dailyMaxed,
                      careTutorialStep: view.careTutorialStep,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    final margin = PetopiaAdaptive.sideMargin(context);
    final panelWidth = PetopiaAdaptive.panelWidth(
      MediaQuery.sizeOf(context).width,
    );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(margin),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: panelWidth,
                child: pet != null
                    ? _InfoCard(
                        pet: pet,
                        wallet: view.wallet,
                        edgeToEdge: true,
                        onTap: () => _openPetDetail(context, pet),
                      )
                    : const _TopMenuOnly(),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: SizedBox(
                width: panelWidth,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (view.todayYard != null)
                      _TodayYardPanel(today: view.todayYard!),
                    if (view.todayYard != null && view.activeVisitor != null)
                      const SizedBox(height: 10),
                    if (view.activeVisitor != null)
                      _VisitorStayPill(
                        visitor: view.activeVisitor!,
                        compact: true,
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox(width: panelWidth, child: const _YardNavDock()),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: SizedBox(
                width: panelWidth,
                child: SingleChildScrollView(
                  reverse: true,
                  child: pet == null
                      ? const _AdoptCta(edgeToEdge: true)
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (view.canGraduate)
                              _GraduateBanner(
                                edgeToEdge: true,
                                onTap: () => _graduate(context, pet),
                              ),
                            if (view.careTutorialStep < 3) ...[
                              _CareTutorialHint(
                                step: view.careTutorialStep,
                                edgeToEdge: true,
                                onDone: ref
                                    .read(gameControllerProvider.notifier)
                                    .completeCareTutorial,
                              ),
                              const SizedBox(height: 8),
                            ],
                            _ActionBar(
                              ref: ref,
                              cooldown: view.cooldownSec,
                              dailyMaxed: view.dailyMaxed,
                              careTutorialStep: view.careTutorialStep,
                              edgeToEdge: true,
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

  void _graduate(BuildContext context, PetView pet) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GraduationCeremonyScreen(
          petName: pet.name,
          speciesId: pet.speciesId,
          variantId: pet.variantId,
        ),
      ),
    );
  }

  void _openPetDetail(BuildContext context, PetView pet) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => PetDetailScreen(initialPet: pet)),
    );
  }
}

class _VisitorArrivalCard extends StatefulWidget {
  final VisitorPresenceView visitor;
  final VisitorInteractionOutcome? Function() onInteract;
  const _VisitorArrivalCard({required this.visitor, required this.onInteract});

  @override
  State<_VisitorArrivalCard> createState() => _VisitorArrivalCardState();
}

class _VisitorArrivalCardState extends State<_VisitorArrivalCard> {
  VisitorInteractionOutcome? _outcome;
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final visitor = widget.visitor;
    final interacted = visitor.interacted || _outcome != null;
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const AppIcon(
                'ach_visitor',
                size: 24,
                fallback: Icons.people_alt_rounded,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  '院子里来了新朋友',
                  style: TextStyle(
                    color: Color(0xFF6B5445),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: '关闭',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: Color(0xFF8A7A6A)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Image.asset(
              visitor.portraitAsset,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const AppIcon(
                'ach_visitor',
                size: 56,
                fallback: Icons.emoji_nature_rounded,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            visitor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _visitorRarityLabel(visitor.rarity),
            style: const TextStyle(
              color: Color(0xFFE8A15C),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _outcome?.message ?? visitor.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 15,
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFA7C4A0).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              interacted
                  ? [
                      '这段相遇已经收进来客图鉴。',
                      if ((_outcome?.expApplied ?? 0) > 0)
                        '伙伴经验 +${_outcome!.expApplied}',
                    ].join('  ')
                  : '它会在小窝附近待到明天。和它打个招呼，就能留下这次相遇。',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B5445),
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE8A15C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              onPressed: _working
                  ? null
                  : () {
                      if (interacted) {
                        Navigator.of(context).pop();
                        return;
                      }
                      setState(() => _working = true);
                      final outcome = widget.onInteract();
                      if (!mounted) return;
                      setState(() {
                        _outcome = outcome;
                        _working = false;
                      });
                    },
              child: Text(
                interacted ? '收进来客图鉴' : '和它打个招呼',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RevisitorDialog extends StatefulWidget {
  final RevisitorPresenceView revisitor;
  final RevisitInteractionOutcome? Function() onInteract;
  const _RevisitorDialog({required this.revisitor, required this.onInteract});

  @override
  State<_RevisitorDialog> createState() => _RevisitorDialogState();
}

class _RevisitorDialogState extends State<_RevisitorDialog> {
  RevisitInteractionOutcome? _outcome;

  @override
  Widget build(BuildContext context) {
    final revisitor = widget.revisitor;
    final days =
        revisitor.leavesAt.difference(DateTime.now().toUtc()).inDays + 1;
    final interacted = revisitor.interacted || _outcome != null;
    return AlertDialog(
      backgroundColor: const Color(0xFFFFFDF7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      title: Text(
        '${revisitor.name} 回家看看了',
        style: const TextStyle(
          color: Color(0xFF6B5445),
          fontWeight: FontWeight.w900,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            PetArt.stage(
              revisitor.speciesId,
              PetStage.d,
              variantId: revisitor.variantId,
            ),
            width: 168,
            height: 168,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 12),
          Text(
            _outcome == null
                ? (interacted
                      ? '它会在院子里歇一歇，接下来约 $days 天都能看见这个熟悉的身影。'
                      : '它从旅途中回来串门。欢迎它回家，听听这次带回了什么故事。')
                : [
                    '它把一小包暖绒放进你手里：暖绒 +${_outcome!.gift}。',
                    if (_outcome!.currentPetExp > 0)
                      '新伙伴也和它聊了很久，经验 +${_outcome!.currentPetExp}。',
                    if (_outcome!.broughtCompanion) '远处还跟着一位害羞的旅行伙伴。',
                    '接下来约 $days 天，它会留在院子里。',
                  ].join('\n'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              height: 1.55,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () {
            if (interacted) {
              Navigator.of(context).pop();
              return;
            }
            final outcome = widget.onInteract();
            if (!mounted) return;
            setState(() => _outcome = outcome);
          },
          child: Text(interacted ? '在院子里好好休息' : '欢迎回家'),
        ),
      ],
    );
  }
}

class _EventDialog extends StatefulWidget {
  final EventPresentationView event;
  const _EventDialog({required this.event});

  @override
  State<_EventDialog> createState() => _EventDialogState();
}

class _EventDialogState extends State<_EventDialog> {
  int? _selectedChoice;

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final special = event.type == EventType.special;
    final hasChoices = event.choices.isNotEmpty;
    final selected = _selectedChoice == null
        ? null
        : event.choices[_selectedChoice!];
    return PopScope(
      canPop: false,
      child: AlertDialog(
        backgroundColor: const Color(0xFFFFFDF7),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        icon: AppIcon(
          special ? 'ach_special' : 'ach_event',
          size: 48,
          fallback: special
              ? Icons.auto_awesome_rounded
              : Icons.wb_sunny_rounded,
        ),
        title: Text(
          event.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF6B5445),
            fontWeight: FontWeight.w900,
          ),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selected?.resultScript ?? event.script,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF6B5445),
                  height: 1.6,
                  fontSize: 16,
                ),
              ),
              if (hasChoices && selected == null) ...[
                const SizedBox(height: 18),
                for (var index = 0; index < event.choices.length; index++) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => setState(() => _selectedChoice = index),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6B5445),
                        side: const BorderSide(color: Color(0xFFE8CDAE)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                      ),
                      child: Text(
                        event.choices[index].text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  if (index != event.choices.length - 1)
                    const SizedBox(height: 9),
                ],
              ],
              if (!hasChoices || selected != null) ...[
                const SizedBox(height: 14),
                Text(
                  [
                    if (event.expReward + (selected?.expDelta ?? 0) > 0)
                      '经验 +${event.expReward + (selected?.expDelta ?? 0)}',
                    if (event.currencyReward > 0) '暖绒 +${event.currencyReward}',
                  ].join(' · '),
                  style: const TextStyle(
                    color: Color(0xFFE8A15C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (!hasChoices || selected != null)
            FilledButton(
              onPressed: () => Navigator.of(context).pop(_selectedChoice ?? -1),
              child: const Text('记进手账'),
            ),
        ],
      ),
    );
  }
}

class _YardAtmosphere extends StatefulWidget {
  final Weather weather;
  final int hour;

  const _YardAtmosphere({required this.weather, required this.hour});

  @override
  State<_YardAtmosphere> createState() => _YardAtmosphereState();
}

class _YardAtmosphereState extends State<_YardAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _thunder = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
  )..repeat();

  @override
  void dispose() {
    _thunder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final night = widget.hour >= 19 || widget.hour < 6;
    final dusk = widget.hour >= 16 && widget.hour < 19;
    final weatherAsset = YardArt.weatherFx(widget.weather.name);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (night || dusk)
            Opacity(
              opacity: night ? 0.34 : 0.16,
              child: Image.asset(
                YardArt.timeFx(widget.hour),
                fit: BoxFit.cover,
              ),
            ),
          if (night)
            Opacity(
              opacity: 0.42,
              child: Image.asset(
                'assets/art/world/fx/yard_fx_night_stars.png',
                fit: BoxFit.cover,
              ),
            ),
          if (weatherAsset.isNotEmpty)
            Opacity(
              opacity: widget.weather == Weather.snow ? 0.30 : 0.16,
              child: Image.asset(weatherAsset, fit: BoxFit.cover),
            ),
          if (widget.weather == Weather.cloudy)
            ColoredBox(color: const Color(0xFFB8C6C4).withValues(alpha: 0.08)),
          if (widget.weather == Weather.fog)
            ColoredBox(color: Colors.white.withValues(alpha: 0.12)),
          if (widget.weather == Weather.thunder && !reduceMotion)
            AnimatedBuilder(
              animation: _thunder,
              builder: (context, _) {
                final pulse = math.pow(
                  math.max(0, math.sin(_thunder.value * math.pi * 6)),
                  18,
                );
                return ColoredBox(
                  color: Colors.white.withValues(alpha: pulse * 0.16),
                );
              },
            ),
        ],
      ),
    );
  }
}

String _visitorRarityLabel(VisitorRarity rarity) {
  return switch (rarity) {
    VisitorRarity.common => '常见来客',
    VisitorRarity.uncommon => '不常见来客',
    VisitorRarity.rare => '稀有来客',
    VisitorRarity.legendary => '传说来客',
  };
}

/// 院子摆件（中景静态层）。轻微投影让它「落」在草地上。
class _YardDecor extends StatelessWidget {
  final Alignment align;
  final String decorId;
  final double width;
  const _YardDecor({
    required this.align,
    required this.decorId,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Image.asset(
        YardArt.decor(decorId),
        width: width,
        errorBuilder: (_, _, _) => const SizedBox(),
      ),
    );
  }
}

class _YardVisitor extends StatelessWidget {
  final VisitorPresenceView visitor;
  final double size;
  final VoidCallback onTap;
  const _YardVisitor({
    required this.visitor,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: const ValueKey<String>('active_visitor'),
      button: true,
      label: '来客 ${visitor.name}，点按查看互动',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 260),
          opacity: 0.92,
          child: SpriteSheetPlayer(
            assetPath: visitor.yardAsset,
            size: size,
            duration: const Duration(milliseconds: 1200),
            loop: true,
            fallback: _VisitorLogoFallback(visitor: visitor, size: size),
          ),
        ),
      ),
    );
  }
}

class _VisitorLogoFallback extends StatelessWidget {
  final VisitorPresenceView visitor;
  final double size;
  const _VisitorLogoFallback({required this.visitor, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size * 0.82,
      height: size * 0.82,
      padding: EdgeInsets.all(size * 0.16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.72),
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Image.asset(
        visitor.portraitAsset,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => AppIcon(
          'ach_visitor',
          size: size * 0.42,
          fallback: Icons.emoji_nature_rounded,
        ),
      ),
    );
  }
}

class _VisitorYardPlacement {
  final Alignment alignment;
  final double size;
  const _VisitorYardPlacement(this.alignment, this.size);
}

_VisitorYardPlacement _visitorYardPlacement(VisitorPresenceView visitor) {
  return switch (visitor.id) {
    'visitor_butterfly' => const _VisitorYardPlacement(
      Alignment(0.47, 0.24),
      68,
    ),
    'visitor_firefly' || 'visitor_starbug' || 'visitor_campfire_light' =>
      const _VisitorYardPlacement(Alignment(0.46, 0.22), 72),
    'visitor_egret' ||
    'visitor_deer' ||
    'visitor_fox' => const _VisitorYardPlacement(Alignment(-0.54, 0.38), 104),
    'visitor_calico' ||
    'visitor_tanuki' ||
    'visitor_owl' ||
    'visitor_crow' ||
    'visitor_snowhare' => const _VisitorYardPlacement(
      Alignment(-0.50, 0.43),
      92,
    ),
    _ => const _VisitorYardPlacement(Alignment(-0.52, 0.46), 78),
  };
}

class _VisitorStayPill extends StatelessWidget {
  final VisitorPresenceView visitor;
  final bool compact;
  const _VisitorStayPill({required this.visitor, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(13) >= 17;
    return Padding(
      padding: compact
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 22),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(largeText ? 18 : 999),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const VisitorDexScreen()),
          ),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(largeText ? 18 : 999),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(
                  'ach_visitor',
                  size: 20,
                  fallback: Icons.people_alt_rounded,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    visitor.interacted
                        ? '今日来客：${visitor.name} · 已记入来客图鉴'
                        : '今日来客：${visitor.name} · 等你去打招呼',
                    maxLines: largeText || compact ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B5445),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayYardButton extends StatelessWidget {
  const _TodayYardButton({required this.today});

  final TodayYardView today;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => showModalBottomSheet<void>(
            context: context,
            useSafeArea: true,
            showDragHandle: true,
            backgroundColor: const Color(0xFFFFFDF7),
            constraints: const BoxConstraints(maxWidth: 640),
            builder: (_) => _TodayYardSheet(today: today),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const AppIcon(
                  'nav_menu',
                  size: 24,
                  fallback: Icons.auto_stories_rounded,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '今日院子',
                    style: TextStyle(
                      color: Color(0xFF604B3E),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  '${today.completedCount} / ${today.items.length} 已写下',
                  style: const TextStyle(
                    color: Color(0xFF8A7A6A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.expand_more_rounded, color: Color(0xFF8A7A6A)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayYardPanel extends StatelessWidget {
  const _TodayYardPanel({required this.today});

  final TodayYardView today;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppIcon(
                'nav_menu',
                size: 24,
                fallback: Icons.auto_stories_rounded,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '今日院子',
                  style: TextStyle(
                    color: Color(0xFF604B3E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '${today.completedCount}/${today.items.length}',
                style: const TextStyle(
                  color: Color(0xFFE8A15C),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in today.items) _TodayYardRow(item: item),
        ],
      ),
    );
  }
}

class _TodayYardSheet extends StatelessWidget {
  const _TodayYardSheet({required this.today});

  final TodayYardView today;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '今日院子',
            style: TextStyle(
              color: Color(0xFF604B3E),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '想做哪一件都好，慢慢来。',
            style: TextStyle(
              color: Color(0xFF8A7A6A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          for (final item in today.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TodayYardRow(item: item, roomy: true),
            ),
        ],
      ),
    );
  }
}

class _TodayYardRow extends StatelessWidget {
  const _TodayYardRow({required this.item, this.roomy = false});

  final TodayYardItemView item;
  final bool roomy;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: item.completed,
      label: item.label,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: roomy ? 8 : 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: roomy ? 34 : 28,
              height: roomy ? 34 : 28,
              decoration: BoxDecoration(
                color: item.completed
                    ? const Color(0xFFA7C4A0).withValues(alpha: 0.26)
                    : const Color(0xFFFFE8C9),
                shape: BoxShape.circle,
              ),
              child: item.completed
                  ? const Icon(
                      Icons.check_rounded,
                      size: 19,
                      color: Color(0xFF688463),
                    )
                  : Center(child: _todayYardIcon(item.kind, roomy ? 22 : 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                item.label,
                maxLines: roomy ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.completed
                      ? const Color(0xFF8A7A6A)
                      : const Color(0xFF604B3E),
                  fontSize: roomy ? 15 : 12.5,
                  fontWeight: item.completed
                      ? FontWeight.w600
                      : FontWeight.w800,
                  decoration: item.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _todayYardIcon(TodayYardKind kind, double size) {
  final (name, fallback) = switch (kind) {
    TodayYardKind.pat => ('act_pat', Icons.back_hand_rounded),
    TodayYardKind.feed => ('act_feed', Icons.restaurant_rounded),
    TodayYardKind.toy => ('act_toy', Icons.sports_baseball_rounded),
    TodayYardKind.bath => ('act_bath', Icons.bathtub_rounded),
    TodayYardKind.visitor => ('ach_visitor', Icons.flutter_dash_rounded),
    TodayYardKind.event => ('src_event', Icons.auto_stories_rounded),
  };
  return AppIcon(name, size: size, fallback: fallback);
}

class _DecorAnchor {
  final Alignment align;
  final double width;
  const _DecorAnchor(this.align, this.width);
}

class _VisibleDecor {
  final String decorId;
  final _DecorAnchor anchor;
  const _VisibleDecor(this.decorId, this.anchor);
}

const _decorAnchors = <int, _DecorAnchor>{
  0: _DecorAnchor(Alignment(-0.78, 0.02), 96),
  1: _DecorAnchor(Alignment(0.42, 0.66), 84),
  2: _DecorAnchor(Alignment(0.74, 0.34), 110),
  3: _DecorAnchor(Alignment(-0.12, 0.68), 100),
  4: _DecorAnchor(Alignment(-0.52, 0.58), 92),
  5: _DecorAnchor(Alignment(0.62, 0.08), 90),
  6: _DecorAnchor(Alignment(-0.34, 0.18), 82),
  7: _DecorAnchor(Alignment(0.20, 0.16), 84),
  8: _DecorAnchor(Alignment(-0.72, 0.38), 88),
  9: _DecorAnchor(Alignment(0.78, 0.54), 86),
  10: _DecorAnchor(Alignment(-0.30, 0.72), 78),
  11: _DecorAnchor(Alignment(0.28, 0.74), 78),
  12: _DecorAnchor(Alignment(-0.84, 0.62), 80),
  13: _DecorAnchor(Alignment(0.84, 0.18), 80),
};

const _defaultDecor = <_VisibleDecor>[
  _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.78, 0.02), 96)),
  _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.42, 0.66), 84)),
  _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.74, 0.34), 110)),
];

List<_VisibleDecor> _visibleDecor(List<YardSlotView> slots, int luxuryStage) {
  if (slots.isEmpty) {
    return luxuryStage <= 1 ? _defaultDecor : const <_VisibleDecor>[];
  }
  return [
    for (final slot in slots)
      if (slot.itemId != null && _decorAnchors[slot.pos] != null)
        _VisibleDecor(slot.itemId!, _decorAnchors[slot.pos]!),
  ];
}

/// 毕业提示横幅（达到毕业线时出现在动作栏上方）。
class _GraduateBanner extends StatelessWidget {
  final VoidCallback onTap;
  final bool edgeToEdge;
  const _GraduateBanner({required this.onTap, this.edgeToEdge = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: edgeToEdge
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF6C177), Color(0xFFE8A15C)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎓', style: TextStyle(fontSize: 20)),
              SizedBox(width: 10),
              Text(
                '它准备好去看世界了 · 举行毕业典礼',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 空院子的领养召唤卡。
class _AdoptCta extends StatelessWidget {
  final bool edgeToEdge;
  const _AdoptCta({this.edgeToEdge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: edgeToEdge
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '院子空着呢',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6B5445),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '迎接下一只小伙伴，开启新的陪伴',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A7A6A)),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdoptScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A15C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                '领养新伙伴  🐾',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final PetView pet;
  final int wallet;
  final bool edgeToEdge;
  final VoidCallback onTap;
  const _InfoCard({
    required this.pet,
    required this.wallet,
    required this.onTap,
    this.edgeToEdge = false,
  });

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 18;
    final levelIndex = (pet.level - 1).clamp(
      0,
      GameConfig.cumExpAtLevel.length - 1,
    );
    final levelStart = GameConfig.cumExpAtLevel[levelIndex];
    final nextLevelExp = pet.level >= GameConfig.maxLevel
        ? GameConfig.graduationExp
        : GameConfig.cumExpAtLevel[pet.level];
    final levelSpan = math.max(1, nextLevelExp - levelStart);
    final levelProgress = pet.level >= GameConfig.maxLevel
        ? 1.0
        : ((pet.exp - levelStart) / levelSpan).clamp(0.0, 1.0);
    final progressLabel = pet.level >= GameConfig.maxLevel
        ? '已经准备好启程'
        : '距 Lv ${pet.level + 1} 还差 ${math.max(0, nextLevelExp - pet.exp)}';
    final title = Text(
      '${pet.name} · Lv ${pet.level}（${pet.stage.name.toUpperCase()} 档）',
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6B5445),
      ),
    );
    final walletView = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const WarmfluffIcon(size: 18),
        const SizedBox(width: 3),
        Text(
          '$wallet',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFFE8A15C),
          ),
        ),
      ],
    );
    return Semantics(
      key: const ValueKey<String>('pet_info_card'),
      button: true,
      label: '查看${pet.name}的详情',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: edgeToEdge
              ? EdgeInsets.zero
              : const EdgeInsets.only(top: 12, left: 16, right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (largeText) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 6),
                    const _HomeMenuButton(),
                  ],
                ),
                const SizedBox(height: 6),
                Align(alignment: Alignment.centerRight, child: walletView),
              ] else
                Row(
                  children: [
                    Expanded(child: title),
                    const SizedBox(width: 8),
                    walletView,
                    const SizedBox(width: 4),
                    const _HomeMenuButton(),
                  ],
                ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: levelProgress,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFEDE4D3),
                  color: const Color(0xFFA7C4A0),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$progressLabel    性格：${pet.personality.join(" · ")}',
                maxLines: largeText ? 2 : 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8A7A6A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopMenuOnly extends StatelessWidget {
  const _TopMenuOnly();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: 12, right: 16),
        child: _HomeMenuButton(),
      ),
    );
  }
}

enum _HomeMenuTarget {
  journal,
  album,
  dex,
  achievements,
  shop,
  decorate,
  settings,
  visitorDex,
}

Widget _homeScreenFor(_HomeMenuTarget target) => switch (target) {
  _HomeMenuTarget.journal => const GrowthJournalScreen(),
  _HomeMenuTarget.album => const AlbumScreen(),
  _HomeMenuTarget.dex => const PetDexScreen(),
  _HomeMenuTarget.achievements => const AchievementsScreen(),
  _HomeMenuTarget.shop => const ShopScreen(),
  _HomeMenuTarget.decorate => const _YardDecorLayoutScreen(),
  _HomeMenuTarget.settings => const SettingsScreen(),
  _HomeMenuTarget.visitorDex => const VisitorDexScreen(),
};

void _openHomeTarget(BuildContext context, _HomeMenuTarget target) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => _homeScreenFor(target)));
}

const _homeMenuItems =
    <
      ({
        _HomeMenuTarget target,
        String iconName,
        IconData fallback,
        String label,
      })
    >[
      (
        target: _HomeMenuTarget.journal,
        iconName: 'nav_menu',
        fallback: Icons.auto_stories_rounded,
        label: '成长手账',
      ),
      (
        target: _HomeMenuTarget.album,
        iconName: 'nav_album',
        fallback: Icons.photo_album_rounded,
        label: '相册',
      ),
      (
        target: _HomeMenuTarget.dex,
        iconName: 'nav_codex',
        fallback: Icons.pets_rounded,
        label: '宠物图鉴',
      ),
      (
        target: _HomeMenuTarget.visitorDex,
        iconName: 'ach_visitor',
        fallback: Icons.people_alt_rounded,
        label: '来客图鉴',
      ),
      (
        target: _HomeMenuTarget.achievements,
        iconName: 'ach_firstgrad',
        fallback: Icons.emoji_events_rounded,
        label: '成就',
      ),
      (
        target: _HomeMenuTarget.shop,
        iconName: 'nav_shop',
        fallback: Icons.storefront_rounded,
        label: '商店',
      ),
      (
        target: _HomeMenuTarget.decorate,
        iconName: 'shop_deco',
        fallback: Icons.yard_rounded,
        label: '院子布置',
      ),
      (
        target: _HomeMenuTarget.settings,
        iconName: 'set_save',
        fallback: Icons.settings_rounded,
        label: '设置',
      ),
    ];

class _HomeMenuButton extends StatelessWidget {
  const _HomeMenuButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF1DF),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        key: const ValueKey<String>('home_menu'),
        tooltip: '手账菜单',
        icon: const AppIcon(
          'nav_menu',
          size: 22,
          fallback: Icons.menu_book_rounded,
        ),
        padding: EdgeInsets.zero,
        onPressed: () async {
          final target = await showModalBottomSheet<_HomeMenuTarget>(
            context: context,
            useSafeArea: true,
            isScrollControlled: true,
            backgroundColor: const Color(0xFFFFFDF7),
            showDragHandle: true,
            constraints: const BoxConstraints(maxWidth: 760),
            builder: (_) => const _HomeMenuSheet(),
          );
          if (target != null && context.mounted) {
            _openHomeTarget(context, target);
          }
        },
      ),
    );
  }
}

class _HomeMenuSheet extends StatelessWidget {
  const _HomeMenuSheet();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 4 : 2;
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: columns,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.45,
            children: [
              for (final item in _homeMenuItems)
                Semantics(
                  button: true,
                  label: item.label,
                  child: InkWell(
                    key: item.target == _HomeMenuTarget.settings
                        ? const ValueKey<String>('menu_settings')
                        : null,
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.of(context).pop(item.target),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppIcon(
                          item.iconName,
                          size: 30,
                          fallback: item.fallback,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF6B5445),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _YardNavDock extends StatelessWidget {
  const _YardNavDock();

  static const _targets = <_HomeMenuTarget>[
    _HomeMenuTarget.journal,
    _HomeMenuTarget.album,
    _HomeMenuTarget.dex,
    _HomeMenuTarget.visitorDex,
    _HomeMenuTarget.shop,
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final target in _targets)
              Builder(
                builder: (context) {
                  final item = _homeMenuItems.firstWhere(
                    (candidate) => candidate.target == target,
                  );
                  return IconButton(
                    tooltip: item.label,
                    onPressed: () => _openHomeTarget(context, target),
                    icon: AppIcon(
                      item.iconName,
                      size: 24,
                      fallback: item.fallback,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _YardDecorLayoutScreen extends ConsumerWidget {
  const _YardDecorLayoutScreen();

  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _paper = Color(0xFFFFFDF7);
  static const _bg = Color(0xFFF3E9D6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    final ctrl = ref.read(gameControllerProvider.notifier);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          '院子布置',
          style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          logUiError('yard decor', error, stackTrace);
          return AppLoadError(
            title: '院子布置暂时没有打开',
            onRetry: () => ref.invalidate(gameControllerProvider),
          );
        },
        data: (view) {
          final inventory = ctrl.decorInventory();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  PetopiaAdaptive.sideMargin(context),
                  8,
                  PetopiaAdaptive.sideMargin(context),
                  24,
                ),
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _paper.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
                    ),
                    child: Text(
                      inventory.isEmpty
                          ? '还没有可摆放的小物。去商店买到装饰后，就能指定到院子的固定位置。'
                          : '选择一个槽位，再点已拥有的小物；同一个小物只会出现在一个位置。',
                      style: const TextStyle(
                        color: _muted,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (inventory.isEmpty)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ShopScreen(),
                          ),
                        ),
                        icon: const AppIcon(
                          'shop_deco',
                          size: 22,
                          fallback: Icons.storefront_rounded,
                        ),
                        label: const Text('去商店看看'),
                      ),
                    ),
                  for (var pos = 0; pos < ctrl.decorSlotCount; pos++)
                    _DecorSlotEditor(
                      pos: pos,
                      current: _slotItem(view.decorSlots, pos),
                      inventory: inventory,
                      onSelect: (decorId) => ctrl.placeDecor(pos, decorId),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  static String? _slotItem(List<YardSlotView> slots, int pos) {
    for (final slot in slots) {
      if (slot.pos == pos) return slot.itemId;
    }
    return null;
  }
}

class _DecorSlotEditor extends StatelessWidget {
  final int pos;
  final String? current;
  final List<DecorItemView> inventory;
  final ValueChanged<String?> onSelect;
  const _DecorSlotEditor({
    required this.pos,
    required this.current,
    required this.inventory,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 7)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '位置 ${pos + 1}',
                style: const TextStyle(
                  color: Color(0xFF6B5445),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (current != null)
                TextButton(
                  onPressed: () => onSelect(null),
                  child: const Text('清空'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final item in inventory)
                  _DecorChoiceButton(
                    item: item,
                    selected: item.decorId == current,
                    onTap: () => onSelect(item.decorId),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorChoiceButton extends StatelessWidget {
  final DecorItemView item;
  final bool selected;
  final VoidCallback onTap;
  const _DecorChoiceButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        width: 86,
        height: 92,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFE8BF) : const Color(0xFFFFF7EA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFE8A15C) : const Color(0xFFEDE4D3),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                YardArt.decor(item.decorId),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.image_not_supported_rounded,
                  color: Color(0xFF8A7A6A),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B5445)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CareTutorialHint extends StatelessWidget {
  const _CareTutorialHint({
    required this.step,
    required this.onDone,
    this.edgeToEdge = false,
  });

  final int step;
  final VoidCallback onDone;
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context) {
    final (iconName, fallback, text) = switch (step) {
      0 => ('act_pat', Icons.back_hand_rounded, '先摸摸它，和新朋友打个招呼'),
      1 => ('act_feed', Icons.restaurant_rounded, '再准备一点吃的，它会记住这顿饭'),
      _ => ('nav_album', Icons.mail_outline_rounded, '邮箱以后会收到它从远方寄来的信'),
    };
    return Container(
      margin: edgeToEdge
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4DE).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0C58D)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Row(
        children: [
          AppIcon(iconName, size: 28, fallback: fallback),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF604B3E),
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.3,
              ),
            ),
          ),
          if (step >= 2) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onDone, child: const Text('记住啦')),
          ],
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  final WidgetRef ref;
  final Map<CareAction, int> cooldown;
  final Set<CareAction> dailyMaxed;
  final int careTutorialStep;
  final bool edgeToEdge;
  const _ActionBar({
    required this.ref,
    required this.cooldown,
    required this.dailyMaxed,
    required this.careTutorialStep,
    this.edgeToEdge = false,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(gameControllerProvider.notifier);
    // 动作按钮：调用照料 + 触发对应序列帧动画（feed→eat/toy→play）。
    Future<void> run(Future<bool> Function() care, String pose) async {
      if (await care()) _fireCue(ref, pose);
    }

    final actions = [
      (
        CareAction.feed,
        'act_feed',
        '喂食',
        GameConfig.feedExp,
        () => run(ctrl.feed, 'eat'),
      ),
      (
        CareAction.pat,
        'act_pat',
        '摸头',
        GameConfig.patExp,
        () => run(ctrl.pat, 'pat'),
      ),
      (
        CareAction.toy,
        'act_toy',
        '玩具',
        GameConfig.toyExp,
        () => run(ctrl.toy, 'play'),
      ),
      (
        CareAction.bath,
        'act_bath',
        '洗澡',
        GameConfig.bathExp,
        () => run(ctrl.bath, 'bath'),
      ),
    ];
    final buttons = [
      for (final (action, iconName, label, exp, onTap) in actions)
        _ActionButton(
          key: ValueKey<String>('care_action_${action.name}'),
          iconName: iconName,
          label: label,
          exp: exp,
          cooldownSec: cooldown[action] ?? 0,
          dailyMaxed: dailyMaxed.contains(action),
          highlighted:
              (careTutorialStep == 0 && action == CareAction.pat) ||
              (careTutorialStep == 1 && action == CareAction.feed),
          highlightLabel: careTutorialStep == 0
              ? '先摸摸头'
              : careTutorialStep == 1
              ? '再喂点东西'
              : null,
          onTap: onTap,
        ),
    ];
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 18;
    return Container(
      margin: edgeToEdge
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (largeText || constraints.maxWidth < 300) {
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisExtent: 94,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: buttons,
            );
          }
          return Row(
            children: [for (final button in buttons) Expanded(child: button)],
          );
        },
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String iconName;
  final String label;
  final int exp;
  final int cooldownSec;
  final bool dailyMaxed;
  final bool highlighted;
  final String? highlightLabel;
  final VoidCallback onTap;
  const _ActionButton({
    super.key,
    required this.iconName,
    required this.label,
    required this.exp,
    required this.cooldownSec,
    required this.dailyMaxed,
    this.highlighted = false,
    this.highlightLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onCd = cooldownSec > 0;
    final disabled = onCd || dailyMaxed;
    final icon = AppIcon(iconName, size: 38, fallback: Icons.pets);
    return Semantics(
      button: true,
      enabled: !disabled,
      label: dailyMaxed
          ? '$label，今日次数已完成'
          : onCd
          ? '$label，${_formatCooldown(cooldownSec)}后可用'
          : '$label，增加$exp点经验',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  height: 54,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: highlighted && !disabled
                        ? const Color(0xFFFFE2B8)
                        : disabled
                        ? const Color(0xFFF0EDE8).withValues(alpha: 0.92)
                        : const Color(0xFFFFF6E6),
                    shape: BoxShape.circle,
                    border: highlighted && !disabled
                        ? Border.all(color: const Color(0xFFE8A15C), width: 2)
                        : null,
                    boxShadow: highlighted && !disabled
                        ? [
                            BoxShadow(
                              color: const Color(
                                0xFFE8A15C,
                              ).withValues(alpha: 0.28),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: disabled
                      ? ColorFiltered(
                          colorFilter: const ColorFilter.matrix(<double>[
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0.2126,
                            0.7152,
                            0.0722,
                            0,
                            0,
                            0,
                            0,
                            0,
                            1,
                            0,
                          ]),
                          child: Opacity(opacity: 0.48, child: icon),
                        )
                      : icon,
                ),
                const SizedBox(height: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 28),
                  child: Center(
                    child: Text(
                      dailyMaxed
                          ? '今日已完成'
                          : onCd
                          ? _formatCooldown(cooldownSec)
                          : highlighted
                          ? (highlightLabel ?? label)
                          : '$label +$exp',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: disabled ? 10.5 : 11,
                        fontWeight: disabled
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: disabled
                            ? const Color(0xFF9A9086)
                            : const Color(0xFF6B5445),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatCooldown(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final minutes = seconds ~/ 60;
    final rest = seconds % 60;
    return '$minutes:${rest.toString().padLeft(2, '0')}';
  }
}
