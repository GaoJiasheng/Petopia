import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../l10n/petopia_localizations.dart';
import '../l10n/petopia_text.dart';
import '../purchases/support_benefits.dart';
import '../purchases/support_catalog.dart';
import '../purchases/support_purchase_controller.dart';
import 'pet_action_cue.dart';
import 'pet_art.dart';
import 'petopia_theme.dart';
import 'widgets/pet_sprite.dart';

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
      barrierLabel: '收下感谢',
      barrierColor: Colors.black.withValues(alpha: 0.32),
      transitionDuration: PetopiaMotion.duration(context, PetopiaMotion.modal),
      pageBuilder: (_, _, _) =>
          _SupportThankYouDialog(delivery: delivery, pet: widget.pet),
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
                      '给小院留一点温暖',
                      style: TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const AppText(
                      '所有回礼都只是装饰和感谢，不会改变成长速度、阳光、冷却或稀有概率。',
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              mainAxisExtent: 224,
                            ),
                        itemCount: SupportCatalog.all.length,
                        itemBuilder: (_, index) => _SupportProductCard(
                          product: SupportCatalog.all[index],
                          state: state,
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
                      '购买由 App Store 安全处理。普通支持可以重复购买；小院守护者为一次性永久权益。',
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
      label: context.tr(guardian ? '你已经是小院守护者' : '支持小院'),
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
                      guardian ? '小院的灯一直亮着' : '谢谢你愿意走到这里',
                      style: const TextStyle(
                        color: PetopiaColors.ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AppText(
                      guardian
                          ? '守护者徽章已经收好，特别来信也会一直留在这里。'
                          : '这里没有付费加速，也没有限定宠物。每一份支持，只会给院子留下一点温柔的回礼。',
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
  const _SupportProductCard({required this.product, required this.state});

  final SupportProductSpec product;
  final SupportPurchaseState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offer = state.offers[product.id];
    final busy = state.busyProductId == product.id;
    final owned =
        product.kind == SupportProductKind.guardian && state.benefits.guardian;
    final activeLabel = _activeLabel(product, state.benefits);
    final canBuy =
        state.storeAvailable &&
        offer != null &&
        !owned &&
        !state.restoring &&
        state.busyProductId == null;
    return Semantics(
      container: true,
      label: '${context.tr(product.title)}, ${context.tr(product.subtitle)}',
      child: SizedBox(
        height: 224,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFFFFFCF6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: owned ? const Color(0xFFA7C4A0) : PetopiaColors.line,
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
                        product.title,
                        maxLines: 2,
                        style: const TextStyle(
                          color: PetopiaColors.ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      AppText(
                        product.subtitle,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: PetopiaColors.mutedText,
                          height: 1.35,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (activeLabel != null) ...[
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
                            'support_purchase_${product.kind.name}',
                          ),
                          onPressed: canBuy
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
                                  owned
                                      ? '已经守护'
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

  String? _activeLabel(SupportProductSpec product, SupportBenefits benefits) {
    final now = DateTime.now().toUtc();
    return switch (product.kind) {
      SupportProductKind.treat when benefits.treatActive(now) => '点心正在院子里',
      SupportProductKind.lantern when benefits.lanternActive(now) =>
        benefits.guardian ? '守护灯已经永久点亮' : '守护灯会亮到明天',
      SupportProductKind.bouquet when benefits.bouquetActive(now) =>
        '鲜花正在院子里盛开',
      SupportProductKind.guardian when benefits.guardian => '永久权益已经保存',
      _ => null,
    };
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
                      '谢谢你让院子里的灯一直亮着。我们会替你照顾花，也会记得每天等你回来。',
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
                      delivery.restored ? '欢迎回来，小院守护者' : '小院收到了你的心意',
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
                        child: const AppText('收下这份感谢'),
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
