import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import '../l10n/petopia_localizations.dart';
import '../l10n/petopia_text.dart';
import '../purchases/support_benefits.dart';
import '../purchases/support_catalog.dart';
import '../purchases/support_purchase_controller.dart';
import 'pet_action_cue.dart';
import 'pet_art.dart';
import 'petopia_theme.dart';
import 'widgets/pet_sprite.dart';
import 'widgets/sprite_sheet_player.dart';

class SupportYardScreen extends ConsumerStatefulWidget {
  const SupportYardScreen({super.key, this.pet});

  final PetView? pet;

  @override
  ConsumerState<SupportYardScreen> createState() => _SupportYardScreenState();
}

class _SupportYardScreenState extends ConsumerState<SupportYardScreen> {
  var _lastDeliverySequence = 0;

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<SupportPurchaseState>>(
      supportPurchaseControllerProvider,
      (previous, next) {
        final delivery = next.valueOrNull?.delivery;
        if (delivery == null ||
            previous?.valueOrNull?.delivery?.sequence == delivery.sequence ||
            delivery.sequence <= _lastDeliverySequence ||
            !mounted) {
          return;
        }
        _lastDeliverySequence = delivery.sequence;
        if (!delivery.restored) {
          unawaited(ref.read(audioServiceProvider).sting(Sting.achievement));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showThankYou(delivery);
        });
      },
    );
    final async = ref.watch(supportPurchaseControllerProvider);
    return AnnotatedRegion(
      value: PetopiaSystemUi.lightSurface(),
      child: Scaffold(
        backgroundColor: PetopiaColors.background,
        appBar: AppBar(
          backgroundColor: PetopiaColors.background,
          foregroundColor: PetopiaColors.ink,
          elevation: 0,
          centerTitle: true,
          title: const AppText(
            '支持小院',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        body: async.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: PetopiaColors.actionAccent),
          ),
          error: (_, _) => const _SupportUnavailable(),
          data: (state) => _SupportBody(state: state),
        ),
      ),
    );
  }

  Future<void> _showThankYou(SupportDelivery delivery) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '完成',
      barrierColor: Colors.black.withValues(alpha: 0.32),
      transitionDuration: PetopiaMotion.duration(context, PetopiaMotion.modal),
      pageBuilder: (_, _, _) => delivery.opened
          ? _SupportGiftOpeningDialog(delivery: delivery)
          : _SupportThankYouDialog(delivery: delivery, pet: widget.pet),
      transitionBuilder: (_, animation, _, child) {
        final eased = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: eased,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1).animate(eased),
            child: child,
          ),
        );
      },
    );
  }
}

class _SupportBody extends ConsumerWidget {
  const _SupportBody({required this.state});

  final SupportPurchaseState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final side = MediaQuery.sizeOf(context).width >= 600 ? 32.0 : 18.0;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
    final productExtent = (224.0 + (textScale - 1).clamp(0.0, 2.3) * 128.0)
        .clamp(224.0, 520.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 760;
        return ListView(
          padding: EdgeInsets.fromLTRB(
            side,
            8,
            side,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SupportIntro(guardian: state.benefits.guardian),
                    if (state.message != null) ...[
                      const SizedBox(height: 14),
                      _SupportStatus(message: state.message!),
                    ],
                    const SizedBox(height: 20),
                    const AppText(
                      '支持选项',
                      style: TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const AppText(
                      '所有回礼均为装饰性内容，不会改变成长、暖绒、冷却、稀有度或可玩内容。',
                      style: TextStyle(
                        color: PetopiaColors.mutedText,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (twoColumns)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent: productExtent,
                        ),
                        itemCount: SupportCatalog.all.length,
                        itemBuilder: (_, index) => _SupportProductCard(
                          product: SupportCatalog.all[index],
                          state: state,
                          height: productExtent,
                        ),
                      )
                    else
                      for (
                        var index = 0;
                        index < SupportCatalog.all.length;
                        index++
                      ) ...[
                        _SupportProductCard(
                          product: SupportCatalog.all[index],
                          state: state,
                          height: productExtent,
                        ),
                        if (index != SupportCatalog.all.length - 1)
                          const SizedBox(height: 12),
                      ],
                    if (state.benefits.guardian) ...[
                      const SizedBox(height: 22),
                      const _GuardianLetter(),
                    ],
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton.icon(
                        key: const ValueKey<String>(
                          'restore_support_purchases',
                        ),
                        onPressed:
                            state.storeAvailable &&
                                !state.restoring &&
                                state.busyProductId == null
                            ? () => ref
                                  .read(
                                    supportPurchaseControllerProvider.notifier,
                                  )
                                  .restore()
                            : null,
                        icon: state.restoring
                            ? const SizedBox.square(
                                dimension: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.restore_rounded),
                        label: AppText(state.restoring ? '正在恢复' : '恢复“小院守护者”'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const AppText(
                      '购买由 App Store 处理。前三项是有固定展示时长的可重复装饰；小院守护者为一次性购买，可恢复。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: PetopiaColors.mutedText,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SupportIntro extends StatelessWidget {
  const _SupportIntro({required this.guardian});

  final bool guardian;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: context.tr(guardian ? '小院守护者已解锁' : '支持小院'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PetopiaColors.line),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/runtime/support/support_guardian_badge.webp',
                width: 96,
                height: 96,
                fit: BoxFit.contain,
                cacheWidth: 256,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      guardian ? '小院守护者已解锁' : '自愿支持暖绒小院',
                      style: const TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      guardian
                          ? '纪念徽章和特别来信已经收好；每天都可以在这里免费点亮一盏 24 小时的暖灯。'
                          : '支持完全自愿。所有回礼都只是装饰，不会影响成长、收集或概率。',
                      style: const TextStyle(
                        color: PetopiaColors.mutedText,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportProductCard extends ConsumerWidget {
  const _SupportProductCard({
    required this.product,
    required this.state,
    required this.height,
  });

  final SupportProductSpec product;
  final SupportPurchaseState state;
  final double height;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final offer = state.offers[product.id];
    final pendingCount = state.benefits.pendingCount(product.kind);
    final hasPendingGift = pendingCount > 0;
    final guardianLantern =
        product.kind == SupportProductKind.lantern &&
        state.benefits.guardian &&
        !hasPendingGift;
    final freeLanternAvailable =
        guardianLantern && state.benefits.canLightFreeLantern(now);
    final freeLanternBusy = state.busyProductId == guardianFreeLanternActionId;
    final openGiftBusy =
        state.busyProductId ==
        '$supportOpenGiftActionPrefix${product.kind.name}';
    final busy =
        state.busyProductId == product.id ||
        openGiftBusy ||
        (guardianLantern && freeLanternBusy);
    final owned =
        product.kind == SupportProductKind.guardian && state.benefits.guardian;
    final title = guardianLantern ? '今天的暖灯' : product.title;
    final subtitle = guardianLantern
        ? '今天也可以点一盏。\n暖灯会亮 24 小时。'
        : product.subtitle;
    final activeLabel = _activeLabel(product, state.benefits, now);
    final canBuy =
        state.storeAvailable &&
        offer != null &&
        !owned &&
        !state.restoring &&
        state.busyProductId == null;
    final canActivateFreeLantern =
        freeLanternAvailable && !state.restoring && state.busyProductId == null;
    final canOpenGift =
        hasPendingGift && !state.restoring && state.busyProductId == null;
    return Semantics(
      container: true,
      label: '${context.tr(title)}, ${context.tr(subtitle)}',
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: owned || guardianLantern
                  ? const Color(0xFFA7C4A0)
                  : PetopiaColors.line,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: 104,
                  child: Image.asset(
                    product.assetPath,
                    fit: BoxFit.contain,
                    cacheWidth: 280,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PetopiaColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AppText(
                        subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PetopiaColors.mutedText,
                          height: 1.35,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasPendingGift) ...[
                        const SizedBox(height: 5),
                        AppText(
                          '有 $pendingCount 份礼物在这里',
                          style: const TextStyle(
                            color: Color(0xFF9A7045),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ] else if (activeLabel != null) ...[
                        const SizedBox(height: 5),
                        AppText(
                          activeLabel,
                          style: const TextStyle(
                            color: Color(0xFF668B61),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          key: ValueKey<String>(
                            hasPendingGift
                                ? 'support_open_${product.kind.name}'
                                : guardianLantern
                                ? 'support_free_guardian_lantern'
                                : 'support_purchase_${product.kind.name}',
                          ),
                          onPressed: hasPendingGift
                              ? canOpenGift
                                    ? () => ref
                                          .read(
                                            supportPurchaseControllerProvider
                                                .notifier,
                                          )
                                          .openGift(product)
                                    : null
                              : guardianLantern
                              ? canActivateFreeLantern
                                    ? () => ref
                                          .read(
                                            supportPurchaseControllerProvider
                                                .notifier,
                                          )
                                          .lightFreeGuardianLantern()
                                    : null
                              : canBuy
                              ? () => ref
                                    .read(
                                      supportPurchaseControllerProvider
                                          .notifier,
                                    )
                                    .buy(product)
                              : null,
                          child: busy
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : AppText(
                                  hasPendingGift
                                      ? '拆开一份'
                                      : guardianLantern
                                      ? freeLanternAvailable
                                            ? '免费点亮'
                                            : '今天已经点亮'
                                      : owned
                                      ? '已解锁'
                                      : offer?.displayPrice ??
                                            (state.loadingOffers
                                                ? '正在连接'
                                                : '暂不可用'),
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
    );
  }

  String? _activeLabel(
    SupportProductSpec product,
    SupportBenefits benefits,
    DateTime now,
  ) {
    return switch (product.kind) {
      SupportProductKind.treat when benefits.treatActive(now) => '点心正在院子里',
      SupportProductKind.lantern
          when benefits.guardian && !benefits.canLightFreeLantern(now) =>
        _remainingLanternLabel(benefits.lanternUntil, now),
      SupportProductKind.lantern when benefits.lanternActive(now) =>
        '暖灯正在院子里亮着',
      SupportProductKind.bouquet when benefits.bouquetActive(now) =>
        '鲜花正在院子里盛开',
      SupportProductKind.guardian when benefits.guardian => '小院守护者已解锁',
      _ => null,
    };
  }

  String _remainingLanternLabel(DateTime? until, DateTime now) {
    if (until == null || !until.isAfter(now)) return '今天已经点亮';
    final minutes = until.difference(now).inMinutes;
    if (minutes <= 60) return '暖灯还会亮约 1 小时';
    final hours = (minutes / 60).ceil();
    if (hours <= 48) return '暖灯还会亮约 $hours 小时';
    return '暖灯还会亮约 ${(hours / 24).ceil()} 天';
  }
}

class _GuardianLetter extends StatelessWidget {
  const _GuardianLetter();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: context.tr('小院守护者特别感谢明信片'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: PetopiaColors.line),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 2,
                child: Image.asset(
                  'assets/runtime/support/support_guardian_postcard.webp',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  cacheWidth: 1200,
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(18, 15, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '写给小院守护者',
                      style: TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 7),
                    AppText(
                      '感谢你支持暖绒小院。守护灯、纪念徽章和特别来信已经解锁。',
                      style: TextStyle(
                        color: PetopiaColors.mutedText,
                        height: 1.6,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportStatus extends StatelessWidget {
  const _SupportStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7E9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFEADCC5)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: PetopiaColors.actionAccent,
                size: 20,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: AppText(
                  message,
                  style: const TextStyle(
                    color: PetopiaColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportUnavailable extends StatelessWidget {
  const _SupportUnavailable();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(28),
        child: AppText(
          '支持页面暂时没有打开。\n请稍后再试。',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: PetopiaColors.mutedText,
            height: 1.6,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SupportThankYouDialog extends StatelessWidget {
  const _SupportThankYouDialog({required this.delivery, this.pet});

  final SupportDelivery delivery;
  final PetView? pet;

  @override
  Widget build(BuildContext context) {
    final guardian = delivery.product.kind == SupportProductKind.guardian;
    return SafeArea(
      minimum: const EdgeInsets.all(18),
      child: Center(
        child: Material(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (guardian)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: AspectRatio(
                          aspectRatio: 3 / 2,
                          child: Image.asset(
                            'assets/runtime/support/'
                            'support_guardian_postcard.webp',
                            fit: BoxFit.cover,
                            cacheWidth: 1000,
                          ),
                        ),
                      )
                    else if (delivery.product.kind ==
                            SupportProductKind.treat &&
                        pet != null)
                      _SupportPetReaction(pet: pet!)
                    else
                      SizedBox.square(
                        dimension: 180,
                        child: Image.asset(
                          delivery.product.assetPath,
                          fit: BoxFit.contain,
                          cacheWidth: 420,
                        ),
                      ),
                    const SizedBox(height: 16),
                    AppText(
                      delivery.restored ? '小院守护者已恢复' : '感谢你的支持',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      delivery.product.thankYou,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PetopiaColors.mutedText,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        autofocus: true,
                        onPressed: () => Navigator.of(context).pop(),
                        child: const AppText('完成'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportGiftOpeningDialog extends StatefulWidget {
  const _SupportGiftOpeningDialog({required this.delivery});

  final SupportDelivery delivery;

  @override
  State<_SupportGiftOpeningDialog> createState() =>
      _SupportGiftOpeningDialogState();
}

class _SupportGiftOpeningDialogState extends State<_SupportGiftOpeningDialog> {
  var _finished = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.delivery.product;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final openingAsset = product.openingAssetPath;
    final finished = _finished || reduceMotion || openingAsset == null;
    final openedGift = Padding(
      key: const ValueKey<String>('support_gift_opened'),
      padding: const EdgeInsets.all(21),
      child: Image.asset(
        product.assetPath,
        fit: BoxFit.contain,
        cacheWidth: 420,
      ),
    );
    return SafeArea(
      minimum: const EdgeInsets.all(18),
      child: Center(
        child: Material(
          color: const Color(0xFFFFFCF6),
          borderRadius: BorderRadius.circular(8),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      image: true,
                      label: context.tr('${product.title}正在慢慢拆开'),
                      child: SizedBox.square(
                        dimension: 210,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 100),
                          child: finished
                              ? reduceMotion
                                    ? TweenAnimationBuilder<double>(
                                        key: const ValueKey<String>(
                                          'support_gift_opened_reduced_motion',
                                        ),
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        tween: Tween<double>(begin: 0, end: 1),
                                        builder: (context, opacity, child) =>
                                            Opacity(
                                              opacity: opacity,
                                              child: child,
                                            ),
                                        child: openedGift,
                                      )
                                    : openedGift
                              : SpriteSheetPlayer(
                                  key: ValueKey<String>(
                                    'support_opening_${product.kind.name}',
                                  ),
                                  assetPath: openingAsset,
                                  size: 210,
                                  frameCount: 8,
                                  duration: const Duration(milliseconds: 2200),
                                  loop: false,
                                  holdTailFraction: 0.06,
                                  fallback: Padding(
                                    padding: const EdgeInsets.all(21),
                                    child: Image.asset(
                                      product.assetPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                  onComplete: () {
                                    if (mounted) {
                                      setState(() => _finished = true);
                                    }
                                  },
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    AppText(
                      finished ? '一份心意，慢慢收好' : '正在拆开礼物',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText(
                      finished ? product.thankYou : '不用着急，让它慢慢打开。',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PetopiaColors.mutedText,
                        height: 1.65,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const ValueKey<String>('support_gift_close'),
                        onPressed: finished
                            ? () => Navigator.of(context).pop()
                            : null,
                        child: const AppText('收好'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SupportPetReaction extends StatefulWidget {
  const _SupportPetReaction({required this.pet});

  final PetView pet;

  @override
  State<_SupportPetReaction> createState() => _SupportPetReactionState();
}

class _SupportPetReactionState extends State<_SupportPetReaction> {
  PetActionCue? _cue;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _cue = const PetActionCue('eat', 1));
    });
  }

  @override
  Widget build(BuildContext context) {
    final pet = widget.pet;
    return SizedBox.square(
      dimension: 190,
      child: PetSprite(
        assetPath: PetArt.stage(
          pet.speciesId,
          pet.stage,
          variantId: pet.variantId,
        ),
        width: 190,
        speciesId: pet.speciesId,
        variantId: pet.variantId,
        stage: pet.stage,
        cue: _cue,
        semanticLabel: context.tr('${pet.name}正在享用小点心'),
      ),
    );
  }
}
