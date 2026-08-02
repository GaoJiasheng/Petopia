import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../app/game_services.dart';
import '../app/home_moment_queue.dart';
import '../app/notification_service.dart';
import '../app/startup_metrics.dart';
import '../app/distribution_environment.dart';
import '../audio/audio_service.dart';
import '../audio/route_audio.dart';
import '../config/game_config.dart';
import '../domain/enums.dart';
import '../l10n/petopia_localizations.dart';
import '../l10n/petopia_text.dart';
import '../purchases/support_benefits.dart';
import '../purchases/support_catalog.dart';
import '../purchases/support_purchase_controller.dart';
import 'app_error_state.dart';
import 'app_icons.dart';
import 'adaptive_layout.dart';
import 'pet_action_cue.dart';
import 'pet_art.dart';
import 'petopia_theme.dart';
import 'yard_art.dart';
import 'yard_render_policy.dart';
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
import 'support_yard_screen.dart';
import 'visitor_dex_screen.dart';

/// 触发一次宠物动作动画（自增 seq 以便重复播同一动作）。
void _fireCue(WidgetRef ref, String pose) {
  final prev = ref.read(petActionCueProvider);
  ref.read(petActionCueProvider.notifier).state = PetActionCue(
    pose,
    (prev?.seq ?? 0) + 1,
  );
}

String _interactionName(CareAction action) => switch (action) {
  CareAction.feed => 'eat',
  CareAction.pat => 'pat',
  CareAction.toy => 'play',
  CareAction.bath => 'bath',
};

@visibleForTesting
DateTime nextYardDaypartBoundary(DateTime now) {
  final morning = DateTime(now.year, now.month, now.day, 6);
  final dusk = DateTime(now.year, now.month, now.day, 16);
  final night = DateTime(now.year, now.month, now.day, 18);
  if (now.isBefore(morning)) return morning;
  if (now.isBefore(dusk)) return dusk;
  if (now.isBefore(night)) return night;
  return morning.add(const Duration(days: 1));
}

void _showCareFeedback(BuildContext context, CareFeedbackView? feedback) {
  if (feedback == null) return;
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFFDF8EE),
        margin: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          MediaQuery.paddingOf(context).bottom + 124,
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: feedback.contented
                ? const Color(0xFFA7C4A0)
                : const Color(0xFFE9DECD),
          ),
        ),
        duration: const Duration(milliseconds: 2400),
        content: Row(
          children: [
            Icon(
              feedback.contented
                  ? Icons.favorite_rounded
                  : feedback.preferred
                  ? Icons.auto_awesome_rounded
                  : Icons.pets_rounded,
              size: 20,
              color: feedback.contented
                  ? const Color(0xFF7FA778)
                  : PetopiaColors.actionAccent,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: AppText(
                feedback.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B5445),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            AppText(
              '+${feedback.expApplied}',
              style: const TextStyle(
                color: PetopiaColors.actionAccent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
}

YardAmbience _yardAmbience({
  required int hour,
  required Weather weather,
  required String themeId,
}) {
  if (weather == Weather.rain || weather == Weather.thunder) {
    return YardAmbience.rain;
  }
  if (weather == Weather.snow || themeId == 'snow_house') {
    return YardAmbience.snow;
  }
  if (themeId == 'sea_breeze') return YardAmbience.seaside;
  if (YardArt.isNight(hour)) return YardAmbience.meadowNight;
  if (hour >= 16) return YardAmbience.meadowDusk;
  return YardAmbience.meadowDay;
}

/// 院子主屏（P2 响应式版）：满幅背景 + 宠物立绘 + 状态卡 + 4 照料动作（带冷却）。
/// 动作走真实服务链路（ExpEngine→审计→sqflite）。Flame 动画场景为后续。
class YardHomeScreen extends ConsumerStatefulWidget {
  final bool enableCooldownRefresh;
  final int? visualTestHour;

  const YardHomeScreen({
    super.key,
    this.enableCooldownRefresh = true,
    this.visualTestHour,
  }) : assert(
         visualTestHour == null ||
             (visualTestHour >= 0 && visualTestHour <= 23),
       );

  @override
  ConsumerState<YardHomeScreen> createState() => _YardHomeScreenState();
}

class _YardHomeScreenState extends ConsumerState<YardHomeScreen>
    with WidgetsBindingObserver, RouteAware {
  Timer? _presenceTimer;
  Timer? _memoryRecoveryTimer;
  Timer? _dayNightTimer;
  PageRoute<dynamic>? _yardRoute;
  Bgm? _currentYardBgm;
  YardAmbience? _currentYardAmbience;
  String? _precacheKey;
  int _precacheGeneration = 0;
  final DateTime _openedAt = DateTime.now().toUtc();
  final Set<String> _shownArrivalPostcards = <String>{};
  final List<AchievementUnlockCue> _achievementMoments =
      <AchievementUnlockCue>[];
  bool _momentOpen = false;
  bool _onboardingOpen = false;
  bool _automaticMomentPresentedThisActivation = false;
  bool _eventPresentedThisActivation = false;
  bool _memoryPressureConstrained = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.enableCooldownRefresh) {
      _presenceTimer = Timer.periodic(const Duration(minutes: 1), (_) {
        ref.read(gameControllerProvider.notifier).recordActiveHeartbeat();
      });
    }
    _scheduleDayNightRefresh();
  }

  void _scheduleDayNightRefresh() {
    _dayNightTimer?.cancel();
    final now = DateTime.now();
    final nextBoundary = nextYardDaypartBoundary(now);
    _dayNightTimer = Timer(
      nextBoundary.difference(now) + const Duration(seconds: 1),
      () {
        if (!mounted) return;
        setState(() {});
        _scheduleDayNightRefresh();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _automaticMomentPresentedThisActivation = false;
      _eventPresentedThisActivation = false;
      _scheduleDayNightRefresh();
      if (mounted) setState(() {});
      unawaited(ref.read(gameControllerProvider.notifier).onAppResumed());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(ref.read(gameControllerProvider.notifier).onAppPaused());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is! PageRoute<dynamic> || identical(route, _yardRoute)) return;
    if (_yardRoute != null) {
      petopiaRouteObserver.unsubscribe(this);
    }
    _yardRoute = route;
    petopiaRouteObserver.subscribe(this, route);
  }

  @override
  void didPopNext() {
    final bgm = _currentYardBgm;
    final ambience = _currentYardAmbience;
    if (bgm == null || ambience == null) return;
    final audio = ref.read(audioServiceProvider);
    unawaited(audio.playBgm(bgm));
    unawaited(audio.playYardAmbience(ambience));
  }

  @override
  void didPop() {}

  @override
  void didPush() {}

  @override
  void didPushNext() {}

  @override
  void didHaveMemoryPressure() {
    _precacheGeneration += 1;
    _precacheKey = null;
    _memoryRecoveryTimer?.cancel();
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache
      ..clear()
      ..clearLiveImages();
    if (mounted && !_memoryPressureConstrained) {
      setState(() => _memoryPressureConstrained = true);
    }
    _memoryRecoveryTimer = Timer(const Duration(minutes: 2), () {
      if (!mounted) return;
      _precacheKey = null;
      setState(() => _memoryPressureConstrained = false);
    });
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _memoryRecoveryTimer?.cancel();
    _dayNightTimer?.cancel();
    _precacheGeneration += 1;
    WidgetsBinding.instance.removeObserver(this);
    petopiaRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref
        .watch(supportPurchaseControllerProvider)
        .valueOrNull;
    final supportBenefits = supportState?.benefits ?? const SupportBenefits();
    ref.listen<AchievementUnlockCue?>(achievementUnlockCueProvider, (
      previous,
      next,
    ) {
      if (next == null || next.seq == previous?.seq) return;
      _achievementMoments.add(next);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    });
    ref.listen<SaveWriteCue?>(saveWriteCueProvider, (previous, next) {
      if (next == null || next.seq == previous?.seq) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final recovered = next.status == SaveWriteStatus.recovered;
        final messenger = ScaffoldMessenger.of(context);
        messenger
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: const Color(0xFFFDF8EE),
              margin: EdgeInsets.fromLTRB(
                18,
                0,
                18,
                MediaQuery.paddingOf(context).bottom + 124,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: PetopiaColors.line),
              ),
              content: Row(
                children: [
                  Icon(
                    recovered
                        ? Icons.save_rounded
                        : Icons.warning_amber_rounded,
                    color: recovered
                        ? const Color(0xFF668B61)
                        : PetopiaColors.actionAccent,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      recovered ? '小院记录已经安全补上。' : '暂时无法写入记录，稍后会自动重试。',
                      style: const TextStyle(
                        color: PetopiaColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      });
    });
    final notificationRequest = ref.watch(notificationOpenRequestProvider);
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () => const _AppLaunchSurface(),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          StartupMetrics.markFirstInteractiveFrame();
          final lifecycleState =
              WidgetsBinding.instance.lifecycleState ??
              AppLifecycleState.resumed;
          final controller = ref.read(gameControllerProvider.notifier);
          if (lifecycleState == AppLifecycleState.resumed) {
            unawaited(controller.onAppResumed());
          } else {
            unawaited(controller.onAppPaused());
          }
        });
        final pet = view.pet;
        final ctrl = ref.read(gameControllerProvider.notifier);
        final routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        // 院子 BGM 按时段切换（幂等，已在播则忽略）。
        final hour = widget.visualTestHour ?? DateTime.now().hour;
        final nightTheme = YardArt.isNight(hour);
        final yardBgm = nightTheme
            ? Bgm.yardNight
            : (hour >= 16 ? Bgm.yardDusk : Bgm.yardDay);
        final yardAmbience = _yardAmbience(
          hour: hour,
          weather: view.weather,
          themeId: view.activeThemeId,
        );
        _currentYardBgm = yardBgm;
        _currentYardAmbience = yardAmbience;
        if (routeIsCurrent) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || !(ModalRoute.of(context)?.isCurrent ?? true)) {
              return;
            }
            final lifecycleState =
                WidgetsBinding.instance.lifecycleState ??
                AppLifecycleState.resumed;
            if (lifecycleState != AppLifecycleState.resumed) {
              return;
            }
            final audio = ref.read(audioServiceProvider);
            unawaited(audio.playBgm(yardBgm));
            unawaited(audio.playYardAmbience(yardAmbience));
          });
        }
        if (!view.onboardingComplete && routeIsCurrent) {
          _scheduleOnboarding(ctrl, needsAdoption: view.pet == null);
        } else if (!_onboardingOpen && routeIsCurrent) {
          _scheduleNextMoment(
            ctrl,
            view,
            pet: pet,
            notificationRequest: notificationRequest,
          );
        }
        final petAsset = pet == null
            ? null
            : PetArt.stage(pet.speciesId, pet.stage, variantId: pet.variantId);
        final conserveMemory = YardRenderPolicy.conserveMemory(
          view.renderQuality,
          memoryPressure: _memoryPressureConstrained,
        );
        if (pet != null && petAsset != null) {
          _precacheCurrentPetAssets(
            context,
            pet,
            petAsset,
            preloadLimit: YardRenderPolicy.actionPreloadLimit(
              view.renderQuality,
              memoryPressure: _memoryPressureConstrained,
            ),
            preloadBudgetFraction: YardRenderPolicy.actionPreloadBudgetFraction(
              view.renderQuality,
              memoryPressure: _memoryPressureConstrained,
            ),
            priorityAction: switch (view.careTutorialStep) {
              0 => 'pat',
              1 => 'eat',
              _ =>
                view.preferredCareAction == null
                    ? null
                    : _interactionName(view.preferredCareAction!),
            },
          );
        }
        return AnnotatedRegion(
          value: PetopiaSystemUi.yard(hour: hour),
          child: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                final wideLayout = PetopiaAdaptive.useYardSidePanels(size);
                final sceneScale = wideLayout ? 1.16 : 1.0;
                final petWidth = PetopiaAdaptive.petStageWidth(size);
                final petAlignment = Alignment(0, wideLayout ? 0.32 : 0.4);
                final sourceWidth = wideLayout ? 2732 : 1290;
                final backgroundCacheWidth = math.min(
                  sourceWidth,
                  math.max(
                    1,
                    (constraints.maxWidth *
                            MediaQuery.devicePixelRatioOf(context))
                        .ceil(),
                  ),
                );
                final supportNow = DateTime.now().toUtc();
                final treatActive = supportBenefits.treatActive(supportNow);
                final lanternActive = supportBenefits.lanternActive(supportNow);
                final bouquetActive = supportBenefits.bouquetActive(supportNow);
                final visibleDecor =
                    _visibleDecor(
                      view.decorSlots,
                      view.luxuryStage,
                      wideLayout: wideLayout,
                    ).where(
                      (decor) =>
                          !(treatActive && decor.decorId == 'food_bowl_full') &&
                          !(lanternActive && decor.decorId == 'night_light') &&
                          !(bouquetActive &&
                              decor.decorId == 'flowerbed_small'),
                    );
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      YardArt.themeBg(
                        view.activeThemeId,
                        wide: wideLayout,
                        night: nightTheme,
                      ),
                      key: const ValueKey<String>('yard_background'),
                      fit: BoxFit.cover,
                      cacheWidth: backgroundCacheWidth,
                      errorBuilder: (_, _, _) => Image.asset(
                        YardArt.themeBg(
                          '',
                          wide: wideLayout,
                          night: nightTheme,
                        ),
                        fit: BoxFit.cover,
                        cacheWidth: backgroundCacheWidth,
                      ),
                    ),
                    // 摆件中景层（渲染在宠物之下）：自定义 slots 为空时使用默认布置。
                    for (final decor in visibleDecor)
                      _YardDecor(
                        imageKey: ValueKey<String>(
                          'yard_decor_${view.luxuryStage}_${decor.decorId}',
                        ),
                        align: decor.anchor.align,
                        decorId: decor.decorId,
                        width: decor.anchor.width * sceneScale,
                      ),
                    if (lanternActive)
                      _SupportYardDecor(
                        key: const ValueKey<String>('support_yard_lantern'),
                        assetPath: SupportCatalog.lantern.assetPath,
                        alignment: const Alignment(-0.50, 0.36),
                        width: 104 * sceneScale,
                      ),
                    if (bouquetActive)
                      _SupportYardDecor(
                        key: const ValueKey<String>('support_yard_bouquet'),
                        assetPath: SupportCatalog.bouquet.assetPath,
                        alignment: const Alignment(0.76, 0.34),
                        width: 116 * sceneScale,
                      ),
                    if (treatActive)
                      _SupportYardDecor(
                        key: const ValueKey<String>('support_yard_treat'),
                        assetPath: SupportCatalog.treat.assetPath,
                        alignment: const Alignment(0.42, 0.66),
                        width: 92 * sceneScale,
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
                              reduceEffects: conserveMemory,
                              onTap: () {
                                _runMoment(() async {
                                  await showVisitorArrivalDialog(
                                    context,
                                    ctrl,
                                    visitor,
                                  );
                                  ctrl.markVisitorArrivalSeen(visitor.id);
                                });
                              },
                            ),
                          );
                        },
                      ),
                    if (petAsset != null)
                      Align(
                        alignment: petAlignment,
                        child: Consumer(
                          builder: (context, petRef, _) {
                            return RepaintBoundary(
                              child: PetSprite(
                                key: const ValueKey<String>('yard_pet_sprite'),
                                assetPath: petAsset,
                                width: petWidth,
                                speciesId: pet!.speciesId,
                                variantId: pet.variantId,
                                stage: pet.stage,
                                reduceEffects: conserveMemory,
                                cue: petRef.watch(petActionCueProvider),
                                semanticLabel: context.tr('摸摸${pet.name}'),
                                onTap: () async {
                                  if (await ctrl.pat()) {
                                    _fireCue(petRef, 'pat');
                                    if (context.mounted) {
                                      _showCareFeedback(
                                        context,
                                        ctrl.takeCareFeedback(),
                                      );
                                    }
                                  }
                                },
                              ),
                            );
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
                            child: Semantics(
                              key: const ValueKey<String>('active_revisitor'),
                              button: true,
                              label: context.tr(
                                '回访伙伴 ${revisitor.name}，点按查看近况',
                              ),
                              child: Material(
                                type: MaterialType.transparency,
                                child: InkResponse(
                                  radius: rect.width * 0.5,
                                  onTap: () {
                                    _runMoment(() async {
                                      await _showRevisitorDialog(
                                        ctrl,
                                        revisitor,
                                      );
                                      ctrl.markRevisitorArrivalSeen(
                                        revisitor.id,
                                      );
                                    });
                                  },
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
                              ),
                            ),
                          );
                        },
                      ),
                    Positioned.fill(
                      child: _YardAtmosphere(
                        weather: view.weather,
                        reduceEffects: conserveMemory,
                      ),
                    ),
                    _YardOverlay(view: view, ref: ref, wideLayout: wideLayout),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAchievementToast(
    BuildContext context,
    List<String> names,
  ) async {
    if (!mounted || names.isEmpty) return;
    final title = names.length == 1
        ? names.first
        : '${names.first} 等 ${names.length} 项';
    final controller = ScaffoldMessenger.of(context).showSnackBar(
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
              child: AppText(
                '达成成就：$title',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
    await controller.closed;
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

  void _scheduleNextMoment(
    GameController ctrl,
    GameView view, {
    required PetView? pet,
    required NotificationOpenRequest? notificationRequest,
  }) {
    if (_momentOpen || !mounted) return;
    final postcards = _arrivalPostcards(ctrl);
    final postcard = postcards.isEmpty ? null : postcards.first;
    final event = _eventPresentedThisActivation ? null : view.pendingEvent;
    final kind = HomeMomentPolicy.next(
      hasNotification: notificationRequest != null,
      hasPostcard: postcard != null,
      hasVisitor: view.visitorArrival != null,
      hasRevisitor: view.revisitorArrival != null,
      hasOfflineWelcome: view.offlineWelcome != null,
      hasSaveRecovery: view.saveRecovery != null,
      hasSpecialEvent: event?.type == EventType.special,
      hasDailyEvent: event?.type == EventType.daily,
      hasAchievement: _achievementMoments.isNotEmpty,
      allowSocialArrivals:
          view.onboardingComplete && view.careTutorialStep >= 3,
      allowAutomaticMoment: !_automaticMomentPresentedThisActivation,
    );
    if (kind == null) return;

    switch (kind) {
      case HomeMomentKind.notification:
        final request = notificationRequest!;
        _runMoment(() => _openNotification(request, ctrl, view, pet: pet));
        return;
      case HomeMomentKind.postcard:
        final item = postcard!;
        _shownArrivalPostcards.addAll(postcards.map((arrival) => arrival.id));
        _runAutomaticMoment(() {
          ctrl.trackPostcardRead(item.id);
          return showPostcardArrivalDialog(
            context,
            item,
            arrivalCount: postcards.length,
            useBackdropBlur: YardRenderPolicy.useBackdropBlur(
              view.renderQuality,
              memoryPressure: _memoryPressureConstrained,
            ),
          );
        });
        return;
      case HomeMomentKind.visitor:
        final arrival = view.visitorArrival!;
        _runAutomaticMoment(() async {
          unawaited(ref.read(audioServiceProvider).sfx(Sfx.visitorArrive));
          await showVisitorArrivalDialog(context, ctrl, arrival);
          ctrl.markVisitorArrivalSeen(arrival.id);
        });
        return;
      case HomeMomentKind.revisitor:
        final arrival = view.revisitorArrival!;
        _runAutomaticMoment(() async {
          await _showRevisitorDialog(ctrl, arrival);
          ctrl.markRevisitorArrivalSeen(arrival.id);
        });
        return;
      case HomeMomentKind.offlineWelcome:
        final welcome = view.offlineWelcome!;
        _runAutomaticMoment(() async {
          await _showOfflineWelcome(welcome);
          ctrl.dismissOfflineWelcome(welcome.seq);
        });
        return;
      case HomeMomentKind.saveRecovery:
        final recovery = view.saveRecovery!;
        _runAutomaticMoment(() async {
          await _showSaveRecovery(recovery);
          ctrl.dismissSaveRecovery();
        });
        return;
      case HomeMomentKind.specialEvent:
      case HomeMomentKind.dailyEvent:
        final pending = event!;
        _eventPresentedThisActivation = true;
        _runAutomaticMoment(
          () => _showEvent(
            ctrl,
            pending,
            pet: pet,
            activeThemeId: view.activeThemeId,
            weather: view.weather,
          ),
        );
        return;
      case HomeMomentKind.achievement:
        final cue = _achievementMoments.removeAt(0);
        _runAutomaticMoment(() => _showAchievementToast(context, cue.names));
        return;
    }
  }

  Future<void> _openNotification(
    NotificationOpenRequest request,
    GameController ctrl,
    GameView view, {
    required PetView? pet,
  }) async {
    ref.read(notificationOpenRequestProvider.notifier).state = null;
    switch (request.destination) {
      case NotificationDestination.postcard:
        PostcardView? match;
        for (final card in ctrl.postcards()) {
          if (card.journeyId == request.targetId) {
            match = card;
            break;
          }
        }
        if (match != null) {
          _shownArrivalPostcards.add(match.id);
          ctrl.trackPostcardRead(match.id);
          await showPostcardArrivalDialog(
            context,
            match,
            useBackdropBlur: YardRenderPolicy.useBackdropBlur(
              view.renderQuality,
              memoryPressure: _memoryPressureConstrained,
            ),
          );
        } else {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AlbumScreen()));
        }
        return;
      case NotificationDestination.revisit:
        final revisitor = view.revisitor;
        if (revisitor != null && revisitor.id == request.targetId) {
          await _showRevisitorDialog(ctrl, revisitor);
          ctrl.markRevisitorArrivalSeen(revisitor.id);
        } else {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const AlbumScreen()));
        }
        return;
      case NotificationDestination.event:
        final event = view.pendingEvent;
        if (event != null &&
            (event.id == request.targetId ||
                event.eventId == request.targetId)) {
          _eventPresentedThisActivation = true;
          await _showEvent(
            ctrl,
            event,
            pet: pet,
            activeThemeId: view.activeThemeId,
            weather: view.weather,
          );
        }
        return;
      case NotificationDestination.anniversary:
        await Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const AlbumScreen()));
        return;
    }
  }

  List<PostcardView> _arrivalPostcards(GameController ctrl) {
    final threshold = _openedAt.subtract(const Duration(seconds: 10));
    final arrivals = <PostcardView>[];
    for (final card in ctrl.postcards()) {
      if (_shownArrivalPostcards.contains(card.id)) continue;
      if (card.sentAt.toUtc().isBefore(threshold)) continue;
      arrivals.add(card);
    }
    return arrivals;
  }

  void _runAutomaticMoment(Future<void> Function() present) {
    _automaticMomentPresentedThisActivation = true;
    _runMoment(present);
  }

  void _runMoment(Future<void> Function() present) {
    if (_momentOpen || !mounted) return;
    _momentOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        _momentOpen = false;
        return;
      }
      try {
        await present();
      } finally {
        if (mounted) {
          setState(() => _momentOpen = false);
        } else {
          _momentOpen = false;
        }
      }
    });
  }

  Future<void> _showOfflineWelcome(OfflineWelcomeView welcome) async {
    await showGeneralDialog<void>(
      context: context,
      requestFocus: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      transitionDuration: PetopiaMotion.duration(context, PetopiaMotion.modal),
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
  }

  Future<void> _showSaveRecovery(SaveRecoveryView recovery) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const AppIcon(
          'set_about',
          size: 42,
          fallback: Icons.shield_outlined,
        ),
        title: const AppText('小院已安全恢复'),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppText(
            context.l10n.bilingual(
              zhHans: recovery.message,
              en: recovery.messageEn.isEmpty
                  ? recovery.message
                  : recovery.messageEn,
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(height: 1.55),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            autofocus: true,
            onPressed: () => Navigator.of(context).pop(),
            child: const AppText('回到小院'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEvent(
    GameController ctrl,
    EventPresentationView event, {
    required PetView? pet,
    required String activeThemeId,
    required Weather weather,
  }) async {
    if (!mounted) return;
    final audio = ref.read(audioServiceProvider);
    unawaited(audio.sfx(Sfx.eventCard));
    if (event.type == EventType.special) {
      unawaited(audio.playBgm(Bgm.eventSpecial));
    }
    final choiceIndex = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EventDialog(
        event: event,
        pet: pet,
        activeThemeId: activeThemeId,
        weather: weather,
      ),
    );
    ctrl.resolveEvent(
      event.id,
      choiceIndex: choiceIndex != null && choiceIndex >= 0 ? choiceIndex : null,
    );
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
    unawaited(ref.read(audioServiceProvider).visitorVoice(visitor.id));
    return showGeneralDialog<void>(
      context: context,
      requestFocus: true,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: PetopiaMotion.duration(
        context,
        PetopiaMotion.standard,
      ),
      pageBuilder: (context, _, _) {
        return Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Semantics(
                  scopesRoute: true,
                  namesRoute: true,
                  label: context.tr('${visitor.name}来到院子'),
                  explicitChildNodes: true,
                  child: _VisitorArrivalCard(
                    visitor: visitor,
                    onInteract: () => ctrl.interactVisitor(visitor.id),
                  ),
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
    String staticAsset, {
    required int preloadLimit,
    required double preloadBudgetFraction,
    required String? priorityAction,
  }) {
    final key =
        '${pet.speciesId}:${pet.variantId}:${pet.stage}:$staticAsset:'
        '$preloadLimit:$preloadBudgetFraction:$priorityAction';
    if (_precacheKey == key) return;
    _precacheKey = key;
    final generation = ++_precacheGeneration;

    final hasExactActions =
        preloadLimit > 0 &&
        PetArt.hasExactAction(variantId: pet.variantId, stage: pet.stage);
    if (!hasExactActions) return;
    final orderedActions = <String>[
      ?priorityAction,
      for (final action in PetArt.interactionNames)
        if (action != priorityAction) action,
    ];
    final assets = <String>[
      for (final action in orderedActions)
        PetArt.actionSheet(pet.speciesId, action),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || generation != _precacheGeneration) return;
      unawaited(
        _precachePetAssets(
          assets,
          generation,
          preloadLimit: preloadLimit,
          preloadBudgetFraction: preloadBudgetFraction,
        ),
      );
    });
  }

  Future<void> _precachePetAssets(
    List<String> assets,
    int generation, {
    required int preloadLimit,
    required double preloadBudgetFraction,
  }) async {
    // Let the full-bleed yard and current static pet settle before decoding
    // optional 4096px action sheets. Memory pressure cancels this queue.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    for (var index = 0; index < assets.length; index++) {
      if (!mounted || generation != _precacheGeneration) return;
      final cache = PaintingBinding.instance.imageCache;
      const projectedSheetBytes = 4096 * 512 * 4;
      final preloadBudget = (cache.maximumSizeBytes * preloadBudgetFraction)
          .round();
      if (index >= preloadLimit ||
          (index > 0 &&
              cache.currentSizeBytes + projectedSheetBytes > preloadBudget)) {
        return;
      }
      try {
        await precacheImage(AssetImage(assets[index]), context);
      } catch (_) {
        // PetSprite keeps its static fallback when an optional sheet is absent.
      }
      if (index < assets.length - 1) {
        await Future<void>.delayed(const Duration(milliseconds: 180));
      }
    }
  }
}

class _AppLaunchSurface extends StatelessWidget {
  const _AppLaunchSurface();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnnotatedRegion(
      value: PetopiaSystemUi.lightSurface(),
      child: Scaffold(
        backgroundColor: PetopiaColors.background,
        body: Semantics(
          liveRegion: true,
          label: context.tr('小院正在醒来'),
          child: ExcludeSemantics(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/runtime/pets/cat/pet_cat_var01_stageA.webp',
                    width: 132,
                    height: 132,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 14),
                  if (reduceMotion)
                    const SizedBox.square(
                      dimension: 8,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: PetopiaColors.actionAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  else
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: PetopiaColors.actionAccent,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
              label: context.tr('${welcome.petName}睡饱后回到你身边'),
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
                AppText(
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
                AppText(
                  context.l10n.bilingual(
                    zhHans: welcome.story,
                    en: welcome.storyEn.isEmpty
                        ? welcome.story
                        : welcome.storyEn,
                  ),
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
                    label: const AppText('抱抱它'),
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
    final showTestFlightControl =
        testFlightToolsCompiled &&
        (ref.watch(isTestFlightProvider).valueOrNull ?? false);
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sidePadding = wideLayout ? 28.0 : 16.0;
          final actionWidth = wideLayout ? 560.0 : 620.0;
          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePadding, 10, sidePadding, 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: pet == null
                        ? _TopMenuOnly(
                            view: view,
                            showTestFlightControl: showTestFlightControl,
                          )
                        : _InfoCard(
                            view: view,
                            showTestFlightControl: showTestFlightControl,
                            onTap: () => _openPetDetail(context, pet),
                          ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    sidePadding,
                    constraints.maxHeight < 680 ? 88 : 120,
                    sidePadding,
                    12,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: actionWidth),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: pet == null
                          ? const _AdoptCta()
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (view.canGraduate)
                                  _GraduateBanner(
                                    onTap: () => _graduate(context, pet),
                                  ),
                                _ActionBar(
                                  ref: ref,
                                  cooldown: view.cooldownSec,
                                  dailyMaxed: view.dailyMaxed,
                                  preferredAction: view.preferredCareAction,
                                  careContented: view.careContented,
                                  careTutorialStep: view.careTutorialStep,
                                  onTutorialDone: ref
                                      .read(gameControllerProvider.notifier)
                                      .completeCareTutorial,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
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
                child: AppText(
                  '院子里来了新朋友',
                  style: TextStyle(
                    color: Color(0xFF6B5445),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              IconButton(
                tooltip: context.tr('关闭'),
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.close_rounded,
                  color: PetopiaColors.mutedText,
                ),
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
          AppText(
            visitor.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            _visitorRarityLabel(visitor.rarity),
            style: const TextStyle(
              color: PetopiaColors.actionAccent,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          AppText(
            context.l10n.bilingual(
              zhHans: _outcome?.message ?? visitor.message,
              en: _outcome?.messageEn.isNotEmpty == true
                  ? _outcome!.messageEn
                  : visitor.messageEn.isEmpty
                  ? visitor.message
                  : visitor.messageEn,
            ),
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
            child: AppText(
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
              autofocus: true,
              style: FilledButton.styleFrom(
                backgroundColor: PetopiaColors.actionAccent,
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
              child: AppText(
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
      title: AppText(
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
          AppText(
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
          child: AppText(interacted ? '在院子里好好休息' : '欢迎回家'),
        ),
      ],
    );
  }
}

class _EventDialog extends StatefulWidget {
  final EventPresentationView event;
  final PetView? pet;
  final String activeThemeId;
  final Weather weather;

  const _EventDialog({
    required this.event,
    required this.pet,
    required this.activeThemeId,
    required this.weather,
  });

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
      canPop: _selectedChoice == null,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Material(
            color: const Color(0xFFFFFDF7),
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _EventMoment(
                    event: event,
                    pet: widget.pet,
                    activeThemeId: widget.activeThemeId,
                    weather: widget.weather,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 19, 22, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AppIcon(
                              special ? 'ach_firstgrad' : 'src_event',
                              size: 28,
                              fallback: special
                                  ? Icons.auto_awesome_rounded
                                  : Icons.wb_sunny_rounded,
                            ),
                            const SizedBox(width: 9),
                            Flexible(
                              child: AppText(
                                context.l10n.bilingual(
                                  zhHans: event.title,
                                  en: event.titleEn.isEmpty
                                      ? event.title
                                      : event.titleEn,
                                ),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF6B5445),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        AnimatedSwitcher(
                          duration: PetopiaMotion.duration(
                            context,
                            const Duration(milliseconds: 260),
                          ),
                          child: AppText(
                            context.l10n.bilingual(
                              zhHans: selected?.resultScript ?? event.script,
                              en: selected == null
                                  ? (event.scriptEn.isEmpty
                                        ? event.script
                                        : event.scriptEn)
                                  : (selected.resultScriptEn.isEmpty
                                        ? selected.resultScript
                                        : selected.resultScriptEn),
                            ),
                            key: ValueKey(_selectedChoice),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF6B5445),
                              height: 1.6,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (hasChoices && selected == null) ...[
                          const SizedBox(height: 18),
                          for (
                            var index = 0;
                            index < event.choices.length;
                            index++
                          ) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () =>
                                    setState(() => _selectedChoice = index),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF6B5445),
                                  side: const BorderSide(
                                    color: Color(0xFFE8CDAE),
                                  ),
                                  minimumSize: const Size(48, 48),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 13,
                                  ),
                                ),
                                child: AppText(
                                  context.l10n.bilingual(
                                    zhHans: event.choices[index].text,
                                    en: event.choices[index].textEn.isEmpty
                                        ? event.choices[index].text
                                        : event.choices[index].textEn,
                                  ),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            if (index != event.choices.length - 1)
                              const SizedBox(height: 9),
                          ],
                        ],
                        if (!hasChoices || selected != null) ...[
                          const SizedBox(height: 14),
                          Semantics(
                            label: context.tr('本次收获'),
                            child: AppText(
                              [
                                if (event.expReward +
                                        (selected?.expDelta ?? 0) >
                                    0)
                                  '经验 +${event.expReward + (selected?.expDelta ?? 0)}',
                                if (event.currencyReward > 0)
                                  '暖绒 +${event.currencyReward}',
                              ].join(' · '),
                              style: const TextStyle(
                                color: Color(0xFFE08F42),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () => Navigator.of(
                                context,
                              ).pop(_selectedChoice ?? -1),
                              child: const AppText('记进手账'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EventMoment extends StatelessWidget {
  const _EventMoment({
    required this.event,
    required this.pet,
    required this.activeThemeId,
    required this.weather,
  });

  final EventPresentationView event;
  final PetView? pet;
  final String activeThemeId;
  final Weather weather;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final profile = _eventArtProfile(event.eventId, activeThemeId, weather);
    return Semantics(
      image: true,
      label: context.l10n.bilingual(
        zhHans: '${event.title}的水彩小景',
        en: '${event.titleEn.isEmpty ? event.title : event.titleEn} watercolor scene',
      ),
      child: ExcludeSemantics(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final petWidth = math.min(
                constraints.maxWidth * 0.36,
                constraints.maxHeight * 0.82,
              );
              final petArt = pet == null
                  ? const SizedBox.shrink()
                  : Image.asset(
                      PetArt.stage(
                        pet!.speciesId,
                        pet!.stage,
                        variantId: pet!.variantId,
                      ),
                      width: petWidth,
                      height: petWidth,
                      fit: BoxFit.contain,
                    );
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    YardArt.themeBg(
                      profile.themeId,
                      wide: true,
                      night: profile.night,
                    ),
                    fit: BoxFit.cover,
                    alignment: profile.backgroundAlignment,
                  ),
                  if (profile.overlayAsset case final overlay?)
                    Opacity(
                      opacity: profile.overlayOpacity,
                      child: Image.asset(overlay, fit: BoxFit.cover),
                    ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: profile.tint.withValues(
                        alpha: profile.tintOpacity,
                      ),
                    ),
                  ),
                  Align(
                    alignment: profile.petAlignment,
                    child: reduceMotion
                        ? petArt
                        : TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: const Duration(milliseconds: 760),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 18 * (1 - value)),
                                  child: Transform.scale(
                                    alignment: Alignment.bottomCenter,
                                    scale: 0.92 + value * 0.08,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                            child: petArt,
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

typedef _EventArtProfile = ({
  String themeId,
  String? overlayAsset,
  double overlayOpacity,
  Color tint,
  double tintOpacity,
  Alignment backgroundAlignment,
  Alignment petAlignment,
  bool night,
});

_EventArtProfile _eventArtProfile(
  String eventId,
  String activeThemeId,
  Weather weather,
) {
  final specialTheme = switch (eventId) {
    'ev_s01' => 'snow_house',
    'ev_s02' => 'candy_bakery',
    'ev_s03' || 'ev_s08' => 'starry_camp',
    'ev_s04' || 'ev_s14' => 'rain_moss',
    'ev_s05' || 'ev_s13' => 'bamboo_tea',
    'ev_s06' || 'ev_s16' => 'autumn_jam',
    'ev_s07' || 'ev_s11' => 'wheat_kite',
    'ev_s09' || 'ev_s15' => 'four_seasons',
    'ev_s10' || 'ev_s18' => 'moonlight',
    'ev_s12' => 'sea_breeze',
    'ev_s17' || 'ev_s19' => 'sakura',
    'ev_s20' => 'meadow',
    _ => activeThemeId,
  };
  final night = const {
    'ev_s03',
    'ev_s08',
    'ev_s10',
    'ev_s18',
  }.contains(eventId);
  final snow = eventId == 'ev_s01' || weather == Weather.snow;
  final rain =
      !snow &&
      (eventId == 'ev_s04' ||
          eventId == 'ev_s14' ||
          weather == Weather.rain ||
          weather == Weather.thunder);
  final overlay = snow
      ? 'assets/art/world/fx/yard_fx_snow_overlay.webp'
      : rain
      ? 'assets/art/world/fx/yard_fx_rain_overlay.webp'
      : null;
  return (
    themeId: specialTheme,
    overlayAsset: overlay,
    overlayOpacity: 0.42,
    tint: night ? const Color(0xFF27386A) : const Color(0xFFFFF0D2),
    tintOpacity: night ? 0.03 : 0.05,
    backgroundAlignment: const Alignment(0, 0.34),
    petAlignment: const Alignment(0, 0.72),
    night: night,
  );
}

class _YardAtmosphere extends StatefulWidget {
  final Weather weather;
  final bool reduceEffects;

  const _YardAtmosphere({required this.weather, this.reduceEffects = false});

  @override
  State<_YardAtmosphere> createState() => _YardAtmosphereState();
}

class _YardAtmosphereState extends State<_YardAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _thunder;

  @override
  void initState() {
    super.initState();
    _thunder = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncThunder();
  }

  @override
  void didUpdateWidget(covariant _YardAtmosphere oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncThunder();
  }

  void _syncThunder() {
    final shouldAnimate =
        widget.weather == Weather.thunder &&
        !widget.reduceEffects &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (shouldAnimate && !_thunder.isAnimating) {
      _thunder.repeat();
    } else if (!shouldAnimate && _thunder.isAnimating) {
      _thunder.stop();
      _thunder.value = 0;
    }
  }

  @override
  void dispose() {
    _thunder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsset = YardArt.weatherFx(widget.weather.name);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (weatherAsset.isNotEmpty)
            Opacity(
              opacity: widget.weather == Weather.snow ? 0.30 : 0.16,
              child: Image.asset(weatherAsset, fit: BoxFit.cover),
            ),
          if (widget.weather == Weather.cloudy)
            ColoredBox(color: const Color(0xFFB8C6C4).withValues(alpha: 0.08)),
          if (widget.weather == Weather.fog)
            ColoredBox(color: Colors.white.withValues(alpha: 0.12)),
          if (widget.weather == Weather.thunder &&
              !reduceMotion &&
              !widget.reduceEffects)
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
  final Key? imageKey;
  const _YardDecor({
    required this.align,
    required this.decorId,
    required this.width,
    this.imageKey,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Image.asset(
        key: imageKey,
        YardArt.decor(decorId),
        width: width,
        errorBuilder: (_, _, _) => const SizedBox(),
      ),
    );
  }
}

class _SupportYardDecor extends StatelessWidget {
  const _SupportYardDecor({
    super.key,
    required this.assetPath,
    required this.alignment,
    required this.width,
  });

  final String assetPath;
  final Alignment alignment;
  final double width;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Align(
          alignment: alignment,
          child: Image.asset(
            assetPath,
            width: width,
            fit: BoxFit.contain,
            cacheWidth: 512,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}

typedef _VisitorMotionProfile = ({
  Duration frameDuration,
  Duration driftDuration,
  double dx,
  double dy,
  double angle,
  double scale,
  double opacityPulse,
  bool hop,
});

_VisitorMotionProfile _visitorMotionProfile(String id) {
  return switch (id) {
    'visitor_snail' => (
      frameDuration: const Duration(milliseconds: 5200),
      driftDuration: const Duration(milliseconds: 6800),
      dx: 1.2,
      dy: 0.3,
      angle: 0.004,
      scale: 0.004,
      opacityPulse: 0,
      hop: false,
    ),
    'visitor_butterfly' => (
      frameDuration: const Duration(milliseconds: 1800),
      driftDuration: const Duration(milliseconds: 3900),
      dx: 4.0,
      dy: 5.2,
      angle: 0.034,
      scale: 0.018,
      opacityPulse: 0.025,
      hop: false,
    ),
    'visitor_firefly' ||
    'visitor_starbug' ||
    'visitor_campfire_light' ||
    'visitor_rainbow_shade' ||
    'visitor_night_blob' => (
      frameDuration: const Duration(milliseconds: 2400),
      driftDuration: const Duration(milliseconds: 4400),
      dx: 3.0,
      dy: 4.0,
      angle: 0.020,
      scale: 0.024,
      opacityPulse: 0.10,
      hop: false,
    ),
    'visitor_sparrow' ||
    'visitor_pigeon' ||
    'visitor_crow' ||
    'visitor_egret' ||
    'visitor_owl' => (
      frameDuration: const Duration(milliseconds: 2800),
      driftDuration: const Duration(milliseconds: 4600),
      dx: 1.5,
      dy: 2.1,
      angle: 0.016,
      scale: 0.010,
      opacityPulse: 0,
      hop: true,
    ),
    'visitor_frog' || 'visitor_squirrel' => (
      frameDuration: const Duration(milliseconds: 2600),
      driftDuration: const Duration(milliseconds: 4100),
      dx: 2.4,
      dy: 3.2,
      angle: 0.018,
      scale: 0.016,
      opacityPulse: 0,
      hop: true,
    ),
    'visitor_hedgehog' || 'visitor_snowhare' => (
      frameDuration: const Duration(milliseconds: 3400),
      driftDuration: const Duration(milliseconds: 5200),
      dx: 1.3,
      dy: 1.5,
      angle: 0.010,
      scale: 0.012,
      opacityPulse: 0,
      hop: false,
    ),
    'visitor_calico' || 'visitor_tanuki' || 'visitor_fox' || 'visitor_deer' => (
      frameDuration: const Duration(milliseconds: 3800),
      driftDuration: const Duration(milliseconds: 5600),
      dx: 1.6,
      dy: 1.8,
      angle: 0.012,
      scale: 0.014,
      opacityPulse: 0,
      hop: false,
    ),
    _ => (
      frameDuration: const Duration(milliseconds: 3200),
      driftDuration: const Duration(milliseconds: 5000),
      dx: 1.5,
      dy: 1.8,
      angle: 0.012,
      scale: 0.012,
      opacityPulse: 0,
      hop: false,
    ),
  };
}

class _YardVisitor extends StatefulWidget {
  final VisitorPresenceView visitor;
  final double size;
  final bool reduceEffects;
  final VoidCallback onTap;
  const _YardVisitor({
    required this.visitor,
    required this.size,
    required this.reduceEffects,
    required this.onTap,
  });

  @override
  State<_YardVisitor> createState() => _YardVisitorState();
}

class _YardVisitorState extends State<_YardVisitor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: _visitorMotionProfile(widget.visitor.id).driftDuration,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  void _syncMotion() {
    final shouldAnimate =
        !widget.reduceEffects &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (!shouldAnimate) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat();
    }
  }

  @override
  void didUpdateWidget(_YardVisitor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visitor.id != widget.visitor.id) {
      _motion.duration = _visitorMotionProfile(widget.visitor.id).driftDuration;
    }
    _syncMotion();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitor = widget.visitor;
    final profile = _visitorMotionProfile(visitor.id);
    final reduceMotion =
        widget.reduceEffects || MediaQuery.disableAnimationsOf(context);
    final sprite = SpriteSheetPlayer(
      key: ValueKey<String>('visitor_sprite:${visitor.yardAsset}'),
      assetPath: visitor.yardAsset,
      size: widget.size,
      duration: profile.frameDuration,
      loop: true,
      animate: !reduceMotion,
      fallback: _VisitorLogoFallback(visitor: visitor, size: widget.size),
    );
    return Semantics(
      key: const ValueKey<String>('active_visitor'),
      button: true,
      label: context.tr('来客 ${visitor.name}，点按查看互动'),
      child: Material(
        type: MaterialType.transparency,
        child: InkResponse(
          onTap: widget.onTap,
          radius: widget.size * 0.5,
          child: reduceMotion
              ? Opacity(opacity: 0.94, child: sprite)
              : RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: _motion,
                    child: sprite,
                    builder: (context, child) {
                      final phase = math.sin(_motion.value * math.pi * 2);
                      final lift = profile.hop
                          ? -phase.abs() * profile.dy
                          : phase * profile.dy;
                      final scale = 1 + phase.abs() * profile.scale;
                      return Opacity(
                        opacity: 0.94 - phase.abs() * profile.opacityPulse,
                        child: Transform.translate(
                          offset: Offset(phase * profile.dx, lift),
                          child: Transform.rotate(
                            angle: phase * profile.angle,
                            alignment: Alignment.bottomCenter,
                            child: Transform.scale(
                              scale: scale,
                              alignment: Alignment.bottomCenter,
                              child: child,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
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

class _TodayYardRow extends StatelessWidget {
  const _TodayYardRow({required this.item});

  final TodayYardItemView item;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: item.completed,
      label: context.tr(item.label),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            AnimatedContainer(
              duration: PetopiaMotion.duration(
                context,
                const Duration(milliseconds: 220),
              ),
              width: 28,
              height: 28,
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
                  : Center(child: _todayYardIcon(item.kind, 18)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppText(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.completed
                      ? PetopiaColors.mutedText
                      : const Color(0xFF604B3E),
                  fontSize: 12.5,
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
  // Keep the lower side lanes open for a daily visitor or returning pet.
  8: _DecorAnchor(Alignment(-0.72, 0.20), 88),
  9: _DecorAnchor(Alignment(0.78, 0.72), 86),
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

const _wideLuxuryDecor = <int, List<_VisibleDecor>>{
  1: [
    _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.76, 0.02), 128)),
    _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.44, 0.68), 104)),
    _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.78, 0.34), 142)),
  ],
  2: [
    _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.76, 0.02), 128)),
    _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.44, 0.68), 104)),
    _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.78, 0.34), 142)),
    _VisibleDecor('welcome_bell', _DecorAnchor(Alignment(-0.48, 0.34), 104)),
  ],
  3: [
    _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.78, 0.04), 128)),
    _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.42, 0.68), 104)),
    _VisibleDecor('mushroom_bench', _DecorAnchor(Alignment(0.72, 0.10), 146)),
    _VisibleDecor('night_light', _DecorAnchor(Alignment(-0.50, 0.36), 104)),
    _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.80, 0.46), 138)),
  ],
  4: [
    _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.80, 0.08), 126)),
    _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.44, 0.70), 102)),
    _VisibleDecor('arch_flower', _DecorAnchor(Alignment(-0.08, 0.02), 230)),
    _VisibleDecor('mushroom_bench', _DecorAnchor(Alignment(0.72, 0.12), 142)),
    _VisibleDecor('wood_sign', _DecorAnchor(Alignment(-0.56, 0.48), 116)),
    _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.82, 0.48), 136)),
  ],
  5: [
    _VisibleDecor('tree_seasonal', _DecorAnchor(Alignment(-0.70, -0.02), 270)),
    _VisibleDecor('attic_house', _DecorAnchor(Alignment(0.74, -0.02), 248)),
    _VisibleDecor('mailbox_wood', _DecorAnchor(Alignment(-0.82, 0.52), 122)),
    _VisibleDecor('food_bowl_full', _DecorAnchor(Alignment(0.42, 0.70), 102)),
    _VisibleDecor('arch_flower', _DecorAnchor(Alignment(-0.08, 0.10), 220)),
    _VisibleDecor('flowerbed_small', _DecorAnchor(Alignment(0.80, 0.48), 134)),
  ],
  6: [
    _VisibleDecor('tree_seasonal', _DecorAnchor(Alignment(-0.72, -0.04), 286)),
    _VisibleDecor('attic_house', _DecorAnchor(Alignment(0.74, -0.04), 264)),
    _VisibleDecor('arch_flower', _DecorAnchor(Alignment(-0.08, 0.08), 228)),
    _VisibleDecor('album_shelf', _DecorAnchor(Alignment(-0.70, 0.54), 190)),
    _VisibleDecor('pond_small', _DecorAnchor(Alignment(0.68, 0.54), 192)),
    _VisibleDecor('mailbox_red', _DecorAnchor(Alignment(0.86, 0.20), 116)),
  ],
};

List<_VisibleDecor> _visibleDecor(
  List<YardSlotView> slots,
  int luxuryStage, {
  required bool wideLayout,
}) {
  if (slots.isEmpty) {
    if (wideLayout) {
      return _wideLuxuryDecor[luxuryStage.clamp(1, 6)] ?? _wideLuxuryDecor[1]!;
    }
    return _defaultDecor;
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
  const _GraduateBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8EA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEBC998)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6B5445).withValues(alpha: 0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                AppIcon(
                  'ach_firstgrad',
                  size: 24,
                  fallback: Icons.flight_takeoff_rounded,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: AppText(
                    '准备启程 · 举行毕业典礼',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF6B5445),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF9A7D68),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 空院子的领养召唤卡。
class _AdoptCta extends StatelessWidget {
  const _AdoptCta();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9DDC8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B5445).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const AppIcon('nav_codex', size: 42, fallback: Icons.pets_rounded),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    '院子在等新朋友',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B5445),
                    ),
                  ),
                  SizedBox(height: 3),
                  AppText(
                    '开启下一段安静的陪伴',
                    style: TextStyle(
                      fontSize: 12,
                      color: PetopiaColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdoptScreen()),
              ),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const AppText('领养'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(88, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final GameView view;
  final VoidCallback onTap;
  final bool showTestFlightControl;
  const _InfoCard({
    required this.view,
    required this.onTap,
    required this.showTestFlightControl,
  });

  @override
  Widget build(BuildContext context) {
    final pet = view.pet!;
    final textScaler = MediaQuery.textScalerOf(context);
    final largeText = textScaler.scale(14) >= 18;
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
    final title = AppText(
      '${pet.name}  ·  Lv ${pet.level}',
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Color(0xFF6B5445),
      ),
    );
    return Semantics(
      key: const ValueKey<String>('pet_info_card'),
      button: true,
      label: context.tr('查看${pet.name}的详情'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF493A31).withValues(alpha: 0.13),
              blurRadius: 18,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Material(
              color: const Color(0xFFFFFDF7).withValues(alpha: 0.82),
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 9, 8, 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: title),
                          const SizedBox(width: 6),
                          _WalletButton(wallet: view.wallet),
                          const SizedBox(width: 2),
                          _HomeMenuButton(view: view),
                          if (showTestFlightControl) ...[
                            const SizedBox(width: 2),
                            const _TestFlightDayButton(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Semantics(
                        label: context.tr(
                          pet.level >= GameConfig.maxLevel
                              ? '已达到最高等级'
                              : '当前等级进度 ${(levelProgress * 100).round()}%',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: levelProgress,
                            minHeight: 4,
                            backgroundColor: const Color(0xFFECE2D0),
                            color: view.canGraduate
                                ? const Color(0xFFE3A55E)
                                : const Color(0xFF98B894),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopMenuOnly extends StatelessWidget {
  final GameView view;
  final bool showTestFlightControl;
  const _TopMenuOnly({required this.view, required this.showTestFlightControl});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _WalletButton(wallet: view.wallet),
          const SizedBox(width: 4),
          _HomeMenuButton(view: view),
          if (showTestFlightControl) ...[
            const SizedBox(width: 4),
            const _TestFlightDayButton(),
          ],
        ],
      ),
    );
  }
}

class _TestFlightDayButton extends ConsumerStatefulWidget {
  const _TestFlightDayButton();

  @override
  ConsumerState<_TestFlightDayButton> createState() =>
      _TestFlightDayButtonState();
}

class _TestFlightDayButtonState extends ConsumerState<_TestFlightDayButton> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    final label = context.tr(_working ? '正在推进内测时间' : '测试：推进一天');
    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        label: label,
        child: SizedBox(
          width: 42,
          height: 42,
          child: OutlinedButton(
            key: const ValueKey<String>('testflight_advance_day'),
            onPressed: _working ? null : _advance,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: const Color(0xFF8A6F5D),
              backgroundColor: const Color(0xFFFFFBF2).withValues(alpha: 0.84),
              disabledForegroundColor: const Color(0xFFB8AA9E),
              side: const BorderSide(color: Color(0xFFE3D5C1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _working
                ? const SizedBox.square(
                    dimension: 15,
                    child: CircularProgressIndicator(strokeWidth: 1.8),
                  )
                : const AppText(
                    '+1',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _advance() async {
    setState(() => _working = true);
    final advanced = await ref
        .read(gameControllerProvider.notifier)
        .advanceOneDayForTesting();
    if (!mounted) return;
    setState(() => _working = false);
    if (!advanced) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1600),
          content: AppText(context.tr('内测时间已推进 1 天')),
        ),
      );
  }
}

class _WalletButton extends StatelessWidget {
  final int wallet;
  const _WalletButton({required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr('暖绒 $wallet，打开商店'),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openHomeTarget(context, _HomeMenuTarget.shop),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const WarmfluffIcon(size: 18),
                  const SizedBox(width: 3),
                  AppText(
                    '$wallet',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFD99048),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
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
  support,
}

Widget _homeScreenFor(_HomeMenuTarget target, PetView? pet) => switch (target) {
  _HomeMenuTarget.journal => const GrowthJournalScreen(),
  _HomeMenuTarget.album => const AlbumScreen(),
  _HomeMenuTarget.dex => const PetDexScreen(),
  _HomeMenuTarget.achievements => const AchievementsScreen(),
  _HomeMenuTarget.shop => const ShopScreen(),
  _HomeMenuTarget.decorate => const _YardDecorLayoutScreen(),
  _HomeMenuTarget.settings => const SettingsScreen(),
  _HomeMenuTarget.visitorDex => const VisitorDexScreen(),
  _HomeMenuTarget.support => SupportYardScreen(pet: pet),
};

void _openHomeTarget(
  BuildContext context,
  _HomeMenuTarget target, {
  PetView? pet,
}) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => _homeScreenFor(target, pet)));
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

class _HomeMenuButton extends ConsumerStatefulWidget {
  final GameView view;
  const _HomeMenuButton({required this.view});

  @override
  ConsumerState<_HomeMenuButton> createState() => _HomeMenuButtonState();
}

class _HomeMenuButtonState extends ConsumerState<_HomeMenuButton> {
  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey<String>('home_menu'),
      tooltip: context.tr('打开手账'),
      style: IconButton.styleFrom(
        fixedSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        backgroundColor: const Color(0xFFFFF1DF).withValues(alpha: 0.90),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: const AppIcon(
        'nav_menu',
        size: 22,
        fallback: Icons.menu_book_rounded,
      ),
      onPressed: _opening
          ? null
          : () async {
              setState(() => _opening = true);
              unawaited(ref.read(audioServiceProvider).sfx(Sfx.paperOpen));
              try {
                final benefits =
                    ref
                        .read(supportPurchaseControllerProvider)
                        .valueOrNull
                        ?.benefits ??
                    const SupportBenefits();
                final target = await _showAdaptiveNotebook(context, benefits);
                if (target != null && context.mounted) {
                  _openHomeTarget(context, target, pet: widget.view.pet);
                }
              } finally {
                if (mounted) setState(() => _opening = false);
              }
            },
    );
  }

  Future<_HomeMenuTarget?> _showAdaptiveNotebook(
    BuildContext context,
    SupportBenefits benefits,
  ) {
    return showGeneralDialog<_HomeMenuTarget>(
      context: context,
      requestFocus: true,
      barrierDismissible: true,
      barrierLabel: '关闭手账',
      barrierColor: Colors.black.withValues(alpha: 0.22),
      transitionDuration: PetopiaMotion.duration(context, PetopiaMotion.quick),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _AdaptiveNotebookDialog(view: widget.view, supportBenefits: benefits),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final eased = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: eased,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.035),
              end: Offset.zero,
            ).animate(eased),
            child: child,
          ),
        );
      },
    );
  }
}

class _AdaptiveNotebookDialog extends StatelessWidget {
  final GameView view;
  final SupportBenefits supportBenefits;
  const _AdaptiveNotebookDialog({
    required this.view,
    required this.supportBenefits,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final sidePanel = size.shortestSide >= 600;
          final maxWidth = sidePanel
              ? math.min(430.0, size.width * 0.48)
              : math.min(760.0, size.width);
          final maxHeight = sidePanel ? size.height : size.height * 0.82;
          return Align(
            alignment: sidePanel
                ? Alignment.centerRight
                : Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: maxWidth,
                maxHeight: maxHeight,
              ),
              child: sidePanel
                  ? SizedBox.expand(
                      child: _HomeMenuSheet(
                        view: view,
                        supportBenefits: supportBenefits,
                        sidePanel: true,
                      ),
                    )
                  : _HomeMenuSheet(
                      view: view,
                      supportBenefits: supportBenefits,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _HomeMenuSheet extends StatelessWidget {
  final GameView view;
  final SupportBenefits supportBenefits;
  final bool sidePanel;
  const _HomeMenuSheet({
    required this.view,
    required this.supportBenefits,
    this.sidePanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = Material(
      key: const ValueKey<String>('home_notebook_panel'),
      color: const Color(0xFFFFFCF5),
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: sidePanel ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 10, 8),
            child: Row(
              children: [
                const AppIcon(
                  'nav_menu',
                  size: 28,
                  fallback: Icons.menu_book_rounded,
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        '手账',
                        style: TextStyle(
                          color: Color(0xFF5F4B3E),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      AppText(
                        '今天也慢慢来。',
                        style: TextStyle(
                          color: Color(0xFF978575),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.tr('关闭'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF806E60),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDE2D0)),
          Flexible(
            fit: sidePanel ? FlexFit.tight : FlexFit.loose,
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                16,
                14,
                16,
                sidePanel ? 18 : 18 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (view.todayYard != null) ...[
                    _NotebookTodayCard(today: view.todayYard!),
                    const SizedBox(height: 10),
                  ],
                  if (view.activeVisitor != null) ...[
                    _NotebookVisitorCard(visitor: view.activeVisitor!),
                    const SizedBox(height: 10),
                  ],
                  if (view.recentMemories.isNotEmpty) ...[
                    _NotebookMemoryCard(memories: view.recentMemories),
                    const SizedBox(height: 16),
                  ],
                  if (supportBenefits.hasSupported) ...[
                    _NotebookSupportMemoryCard(benefits: supportBenefits),
                    const SizedBox(height: 16),
                  ],
                  const AppText(
                    '收藏与设置',
                    style: TextStyle(
                      color: Color(0xFF8A786A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: sidePanel ? 2.05 : 1.85,
                    children: [
                      for (final item in _homeMenuItems)
                        _HomeFeatureTile(item: item),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    if (sidePanel) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 28,
              offset: const Offset(-6, 8),
            ),
          ],
        ),
        child: body,
      );
    }
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.82,
      ),
      child: body,
    );
  }
}

class _NotebookTodayCard extends StatelessWidget {
  final TodayYardView today;
  const _NotebookTodayCard({required this.today});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEADCC5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              AppIcon('src_event', size: 22, fallback: Icons.wb_sunny_outlined),
              SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: AppText(
                  '今日院子',
                  maxLines: 2,
                  style: TextStyle(
                    color: Color(0xFF604B3E),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Flexible(
                flex: 2,
                child: AppText(
                  '随心完成',
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    color: Color(0xFF9A8776),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          for (final item in today.items) _TodayYardRow(item: item),
        ],
      ),
    );
  }
}

class _NotebookVisitorCard extends StatelessWidget {
  final VisitorPresenceView visitor;
  const _NotebookVisitorCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F7ED),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(context).pop(_HomeMenuTarget.visitorDex),
        child: Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFD8E1CE)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                  visitor.portraitAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const AppIcon(
                    'ach_visitor',
                    size: 34,
                    fallback: Icons.emoji_nature_rounded,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText(
                      '今天的来客',
                      style: TextStyle(
                        color: Color(0xFF8B7B6D),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    AppText(
                      visitor.interacted
                          ? '${visitor.name}正在院子里歇脚'
                          : '${visitor.name}正等你打个招呼',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF5F5147),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF8B7B6D)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotebookMemoryCard extends StatelessWidget {
  final List<YardMemoryView> memories;
  const _NotebookMemoryCard({required this.memories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 11, 13, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F4EA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7DDCF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bookmark_added_rounded,
                size: 19,
                color: Color(0xFF9B846F),
              ),
              SizedBox(width: 7),
              AppText(
                '院子记住的事',
                style: TextStyle(
                  color: Color(0xFF604B3E),
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final memory in memories.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    switch (memory.type) {
                      'growth' => Icons.spa_rounded,
                      'visitor' => Icons.emoji_nature_rounded,
                      'travel' => Icons.near_me_rounded,
                      _ => Icons.circle,
                    },
                    size: 15,
                    color: const Color(0xFFA68E77),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: AppText(
                      context.l10n.bilingual(
                        zhHans: memory.text,
                        en: memory.textEn.isEmpty ? memory.text : memory.textEn,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF77675A),
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _NotebookSupportMemoryCard extends StatelessWidget {
  const _NotebookSupportMemoryCard({required this.benefits});

  final SupportBenefits benefits;

  @override
  Widget build(BuildContext context) {
    final product =
        SupportCatalog.byId(benefits.lastProductId ?? '') ??
        SupportCatalog.guardian;
    return Semantics(
      button: true,
      label: context.tr('打开支持小院，${product.title}'),
      child: Material(
        color: const Color(0xFFFFFAEF),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: const ValueKey<String>('notebook_support_memory'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).pop(_HomeMenuTarget.support),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE8D8BC)),
            ),
            child: Row(
              children: [
                Image.asset(
                  product.assetPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  cacheWidth: 144,
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        '支持与回礼',
                        style: TextStyle(
                          color: Color(0xFF604B3E),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      AppText(
                        product.thankYou,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF817063),
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFA68E77),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeFeatureTile extends StatelessWidget {
  final ({
    _HomeMenuTarget target,
    String iconName,
    IconData fallback,
    String label,
  })
  item;
  const _HomeFeatureTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.tr(item.label),
      child: Material(
        color: const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          key: ValueKey<String>('menu_${item.target.name}'),
          borderRadius: BorderRadius.circular(8),
          onTap: () => Navigator.of(context).pop(item.target),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEDE4D6)),
            ),
            child: Row(
              children: [
                AppIcon(item.iconName, size: 27, fallback: item.fallback),
                const SizedBox(width: 9),
                Expanded(
                  child: AppText(
                    item.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B5445),
                      fontSize: 12,
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

class _YardDecorLayoutScreen extends ConsumerWidget {
  const _YardDecorLayoutScreen();

  static const _ink = Color(0xFF6B5445);
  static const _muted = PetopiaColors.mutedText;
  static const _paper = Color(0xFFFFFDF7);
  static const _bg = Color(0xFFF3E9D6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    final ctrl = ref.read(gameControllerProvider.notifier);
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const AppText(
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
                    child: AppText(
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
                        label: const AppText('去商店看看'),
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
              AppText(
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
                  child: const AppText('清空'),
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
    return Semantics(
      button: true,
      selected: selected,
      label: context.tr(item.name),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: AnimatedContainer(
            duration: PetopiaMotion.duration(
              context,
              const Duration(milliseconds: 140),
            ),
            width: 86,
            height: 92,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFFFE8BF)
                  : const Color(0xFFFFF7EA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFFE8A15C)
                    : const Color(0xFFEDE4D3),
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
                      color: PetopiaColors.mutedText,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AppText(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B5445),
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

class _ActionBar extends StatefulWidget {
  final WidgetRef ref;
  final Map<CareAction, int> cooldown;
  final Set<CareAction> dailyMaxed;
  final CareAction? preferredAction;
  final bool careContented;
  final int careTutorialStep;
  final VoidCallback onTutorialDone;
  const _ActionBar({
    required this.ref,
    required this.cooldown,
    required this.dailyMaxed,
    required this.preferredAction,
    required this.careContented,
    required this.careTutorialStep,
    required this.onTutorialDone,
  });

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar> {
  Timer? _cooldownTimer;
  late Map<CareAction, int> _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = Map<CareAction, int>.from(widget.cooldown);
    _updateTimer();
  }

  @override
  void didUpdateWidget(covariant _ActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameCooldowns(oldWidget.cooldown, widget.cooldown)) {
      _remaining = Map<CareAction, int>.from(widget.cooldown);
      _updateTimer();
    }
  }

  bool _sameCooldowns(Map<CareAction, int> left, Map<CareAction, int> right) {
    if (left.length != right.length) return false;
    for (final entry in left.entries) {
      if (right[entry.key] != entry.value) return false;
    }
    return true;
  }

  void _updateTimer() {
    final hasCooldown = _remaining.values.any((seconds) => seconds > 0);
    if (!hasCooldown) {
      _cooldownTimer?.cancel();
      _cooldownTimer = null;
      return;
    }
    _cooldownTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      var hasMore = false;
      setState(() {
        for (final action in CareAction.values) {
          final seconds = _remaining[action] ?? 0;
          if (seconds <= 0) continue;
          final next = seconds - 1;
          _remaining[action] = next;
          hasMore = hasMore || next > 0;
        }
      });
      if (!hasMore) {
        _cooldownTimer?.cancel();
        _cooldownTimer = null;
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.ref.read(gameControllerProvider.notifier);
    // 动作按钮：调用照料 + 触发对应序列帧动画（feed→eat/toy→play）。
    Future<void> run(Future<bool> Function() care, String pose) async {
      if (await care()) {
        _fireCue(widget.ref, pose);
        if (context.mounted) {
          _showCareFeedback(context, ctrl.takeCareFeedback());
        }
      }
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
          cooldownSec: _remaining[action] ?? 0,
          dailyMaxed: widget.dailyMaxed.contains(action),
          preferred:
              widget.preferredAction == action && widget.careTutorialStep >= 3,
          contented: widget.careContented,
          highlighted:
              (widget.careTutorialStep == 0 && action == CareAction.pat) ||
              (widget.careTutorialStep == 1 && action == CareAction.feed),
          highlightLabel: widget.careTutorialStep == 0
              ? '先摸摸头'
              : widget.careTutorialStep == 1
              ? '再喂点东西'
              : null,
          onTap: onTap,
        ),
    ];
    final textScaler = MediaQuery.textScalerOf(context);
    final largeText = textScaler.scale(14) >= 18;
    final accessibleButtonExtent = math.max(82.0, 64 + textScaler.scale(11));
    final actionLayout = LayoutBuilder(
      builder: (context, constraints) {
        if (largeText || constraints.maxWidth < 300) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisExtent: accessibleButtonExtent,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            children: buttons,
          );
        }
        return Row(
          children: [for (final button in buttons) Expanded(child: button)],
        );
      },
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE9DECD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF493A31).withValues(alpha: 0.13),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.careTutorialStep == 2) ...[
            _MailboxTutorialRow(onDone: widget.onTutorialDone),
            const Divider(height: 9, color: Color(0xFFE9DECD)),
          ],
          actionLayout,
        ],
      ),
    );
  }
}

class _MailboxTutorialRow extends StatelessWidget {
  final VoidCallback onDone;
  const _MailboxTutorialRow({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppIcon(
          'nav_album',
          size: 22,
          fallback: Icons.mail_outline_rounded,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: AppText(
            '以后会在邮箱收到它从远方寄来的信',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF6B5445),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        TextButton(
          onPressed: onDone,
          style: TextButton.styleFrom(
            minimumSize: const Size(64, 48),
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const AppText('知道了'),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String iconName;
  final String label;
  final int exp;
  final int cooldownSec;
  final bool dailyMaxed;
  final bool preferred;
  final bool contented;
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
    this.preferred = false,
    this.contented = false,
    this.highlighted = false,
    this.highlightLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onCd = cooldownSec > 0;
    final disabled = onCd || dailyMaxed;
    final icon = AppIcon(iconName, size: 32, fallback: Icons.pets);
    return Semantics(
      button: true,
      enabled: !disabled,
      label: context.tr(
        dailyMaxed
            ? '$label，今日次数已完成'
            : onCd
            ? '$label，${_formatCooldown(cooldownSec)}后可用'
            : preferred
            ? '$label，今天更合它心意，增加$exp点经验'
            : contented
            ? '$label，今天已经满足，仍可继续陪伴'
            : '$label，增加$exp点经验',
      ),
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: disabled ? null : onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: PetopiaMotion.duration(
                          context,
                          PetopiaMotion.micro,
                        ),
                        width: 46,
                        height: 46,
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: highlighted && !disabled
                              ? const Color(0xFFFFE2B8)
                              : disabled
                              ? const Color(0xFFF0EDE8).withValues(alpha: 0.92)
                              : const Color(0xFFFFF6E6),
                          shape: BoxShape.circle,
                          border: highlighted && !disabled
                              ? Border.all(
                                  color: const Color(0xFFE8A15C),
                                  width: 2,
                                )
                              : preferred && !disabled
                              ? Border.all(
                                  color: const Color(0xFFA7C4A0),
                                  width: 1.5,
                                )
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
                      if (preferred && !disabled)
                        const Positioned(
                          right: -2,
                          top: -2,
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 13,
                            color: Color(0xFF7FA778),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 20),
                    child: Center(
                      child: AppText(
                        dailyMaxed
                            ? '今日已完成'
                            : onCd
                            ? _formatCooldown(cooldownSec)
                            : highlighted
                            ? (highlightLabel ?? label)
                            : '$label +$exp',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: disabled ? 10 : 10.5,
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
