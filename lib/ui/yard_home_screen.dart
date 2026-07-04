import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import '../config/game_config.dart';
import 'app_icons.dart';
import 'pet_action_cue.dart';
import 'pet_art.dart';
import 'yard_art.dart';
import 'widgets/pet_sprite.dart';
import 'achievements_screen.dart';
import 'adopt_screen.dart';
import 'album_screen.dart';
import 'graduation_ceremony_screen.dart';
import 'growth_journal_screen.dart';
import 'pet_dex_screen.dart';
import 'settings_screen.dart';
import 'shop_screen.dart';
import 'visitor_dex_screen.dart';

/// 触发一次宠物动作动画（自增 seq 以便重复播同一动作）。
void _fireCue(WidgetRef ref, String pose) {
  final prev = ref.read(petActionCueProvider);
  ref.read(petActionCueProvider.notifier).state =
      PetActionCue(pose, (prev?.seq ?? 0) + 1);
}

/// 院子主屏（P2 响应式版）：满幅背景 + 宠物立绘 + 状态卡 + 4 照料动作（带冷却）。
/// 动作走真实服务链路（ExpEngine→审计→sqflite）。Flame 动画场景为后续。
class YardHomeScreen extends ConsumerWidget {
  const YardHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('启动失败：$e'),
          ),
        ),
      ),
      data: (view) {
        final pet = view.pet;
        final ctrl = ref.read(gameControllerProvider.notifier);
        // 院子 BGM 按时段切换（幂等，已在播则忽略）。
        final hour = DateTime.now().hour;
        final yardBgm = (hour >= 19 || hour < 6)
            ? Bgm.yardNight
            : (hour >= 16 ? Bgm.yardDusk : Bgm.yardDay);
        ref.read(audioServiceProvider).playBgm(yardBgm);
        final petAsset =
            pet == null ? null : PetArt.stage(pet.speciesId, pet.stage);
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                YardArt.themeBg(view.activeThemeId),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Image.asset(
                  'assets/art/world/themes/yard_theme_meadow_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
              // 摆件中景层（渲染在宠物之下）：邮箱呼应明信片主题 + 食盆 + 花坛。
              const _YardDecor(
                align: Alignment(-0.78, 0.02),
                asset: 'deco_mailbox_wood.png',
                width: 96,
              ),
              const _YardDecor(
                align: Alignment(0.42, 0.66),
                asset: 'deco_food_bowl_full.png',
                width: 84,
              ),
              const _YardDecor(
                align: Alignment(0.74, 0.34),
                asset: 'deco_flowerbed_small.png',
                width: 110,
              ),
              if (petAsset != null)
                Align(
                  alignment: const Alignment(0, 0.4),
                  child: PetSprite(
                    assetPath: petAsset,
                    width: 220,
                    speciesId: pet!.speciesId,
                    cue: ref.watch(petActionCueProvider),
                    onTap: () {
                      ctrl.pat(); // 点宠物 = 摸头（带冷却）
                      _fireCue(ref, 'pat');
                    },
                  ),
                ),
              SafeArea(
                child: Column(
                  children: [
                    if (pet != null)
                      _InfoCard(pet: pet, wallet: view.wallet)
                    else
                      const _TopMenuOnly(),
                    const Spacer(),
                    if (pet == null)
                      const _AdoptCta()
                    else ...[
                      if (view.canGraduate)
                        _GraduateBanner(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => GraduationCeremonyScreen(
                                petName: pet.name,
                                speciesId: pet.speciesId,
                              ),
                            ),
                          ),
                        ),
                      _ActionBar(ref: ref, cooldown: view.cooldownSec),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 院子摆件（中景静态层）。轻微投影让它「落」在草地上。
class _YardDecor extends StatelessWidget {
  final Alignment align;
  final String asset;
  final double width;
  const _YardDecor({
    required this.align,
    required this.asset,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: align,
      child: Image.asset(
        'assets/art/world/decor/$asset',
        width: width,
        errorBuilder: (_, _, _) => const SizedBox(),
      ),
    );
  }
}

/// 毕业提示横幅（达到毕业线时出现在动作栏上方）。
class _GraduateBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _GraduateBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
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
              Text('它准备好去看世界了 · 举行毕业典礼',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('院子空着呢',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B5445))),
          const SizedBox(height: 6),
          const Text('迎接下一只小伙伴，开启新的陪伴',
              style: TextStyle(fontSize: 13, color: Color(0xFF8A7A6A))),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AdoptScreen()),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A15C),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text('领养新伙伴  🐾',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
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
  const _InfoCard({required this.pet, required this.wallet});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${pet.name} · Lv ${pet.level}（${pet.stage.name.toUpperCase()} 档）',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B5445),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
              const SizedBox(width: 4),
              const _HomeMenuButton(),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: pet.exp / GameConfig.graduationExp,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDE4D3),
              color: const Color(0xFFA7C4A0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '经验 ${pet.exp} / ${GameConfig.graduationExp}    性格：${pet.personality.join(" · ")}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8A7A6A)),
          ),
        ],
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

enum _HomeMenuTarget { journal, album, dex, achievements, shop, settings, visitorDex }

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
      child: PopupMenuButton<_HomeMenuTarget>(
        tooltip: '手账菜单',
        color: const Color(0xFFFFFDF7),
        icon: const Icon(Icons.menu_book_rounded, color: Color(0xFF6B5445)),
        iconSize: 21,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (target) {
          final screen = switch (target) {
            _HomeMenuTarget.journal => const GrowthJournalScreen(),
            _HomeMenuTarget.album => const AlbumScreen(),
            _HomeMenuTarget.dex => const PetDexScreen(),
            _HomeMenuTarget.achievements => const AchievementsScreen(),
            _HomeMenuTarget.shop => const ShopScreen(),
            _HomeMenuTarget.settings => const SettingsScreen(),
            _HomeMenuTarget.visitorDex => const VisitorDexScreen(),
          };
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => screen));
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: _HomeMenuTarget.journal,
            child: _MenuRow(icon: Icons.auto_stories_rounded, label: '成长手账'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.album,
            child: _MenuRow(icon: Icons.photo_album_rounded, label: '相册'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.dex,
            child: _MenuRow(icon: Icons.pets_rounded, label: '宠物图鉴'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.achievements,
            child: _MenuRow(icon: Icons.emoji_events_rounded, label: '成就'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.shop,
            child: _MenuRow(icon: Icons.storefront_rounded, label: '商店'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.settings,
            child: _MenuRow(icon: Icons.settings_rounded, label: '设置'),
          ),
          PopupMenuItem(
            value: _HomeMenuTarget.visitorDex,
            child: _MenuRow(icon: Icons.people_alt_rounded, label: '来客图鉴'),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFE8A15C), size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B5445),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ActionBar extends StatelessWidget {
  final WidgetRef ref;
  final Map<CareAction, int> cooldown;
  const _ActionBar({required this.ref, required this.cooldown});

  @override
  Widget build(BuildContext context) {
    final ctrl = ref.read(gameControllerProvider.notifier);
    // 动作按钮：调用照料 + 触发对应序列帧动画（feed→eat/toy→play）。
    void run(VoidCallback care, String pose) {
      care();
      _fireCue(ref, pose);
    }
    final actions = [
      (CareAction.feed, 'act_feed', '喂食', GameConfig.feedExp, () => run(ctrl.feed, 'eat')),
      (CareAction.pat, 'act_pat', '摸头', GameConfig.patExp, () => run(ctrl.pat, 'pat')),
      (CareAction.toy, 'act_toy', '玩具', GameConfig.toyExp, () => run(ctrl.toy, 'play')),
      (CareAction.bath, 'act_bath', '洗澡', GameConfig.bathExp, () => run(ctrl.bath, 'bath')),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF7).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (final (action, iconName, label, exp, onTap) in actions)
            _ActionButton(
              iconName: iconName,
              label: label,
              exp: exp,
              cooldownSec: cooldown[action] ?? 0,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String iconName;
  final String label;
  final int exp;
  final int cooldownSec;
  final VoidCallback onTap;
  const _ActionButton({
    required this.iconName,
    required this.label,
    required this.exp,
    required this.cooldownSec,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onCd = cooldownSec > 0;
    return GestureDetector(
      onTap: onCd ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: onCd ? 0.45 : 1,
            child: Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF6E6),
                shape: BoxShape.circle,
              ),
              child: AppIcon(
                onCd ? 'hourglass_wc' : iconName,
                size: 38,
                fallback: Icons.pets,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            onCd ? '${cooldownSec}s' : '$label +$exp',
            style: TextStyle(
              fontSize: 11,
              color: onCd ? const Color(0xFFB0A090) : const Color(0xFF6B5445),
            ),
          ),
        ],
      ),
    );
  }
}
