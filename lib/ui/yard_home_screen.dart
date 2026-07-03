import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../config/game_config.dart';

/// 院子主屏（P2 响应式版）：满幅背景 + 宠物立绘 + 状态卡 + 4 照料动作（带冷却）。
/// 动作走真实服务链路（ExpEngine→审计→sqflite）。Flame 动画场景为后续。
class YardHomeScreen extends ConsumerWidget {
  const YardHomeScreen({super.key});

  static const _stageLetter = ['A', 'B', 'C', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(gameControllerProvider);
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
          body: Center(
              child: Padding(
                  padding: const EdgeInsets.all(24), child: Text('启动失败：$e')))),
      data: (view) {
        final pet = view.pet;
        final petAsset = pet == null
            ? null
            : 'assets/art/pets/cat/pet_cat_var01_stage${_stageLetter[pet.stage.index]}.png';
        return Scaffold(
          body: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset('assets/art/world/themes/yard_theme_meadow_bg.png',
                  fit: BoxFit.cover),
              if (petAsset != null)
                Align(
                  alignment: const Alignment(0, 0.4),
                  child: Image.asset(petAsset, width: 220,
                      errorBuilder: (_, _, _) => const SizedBox()),
                ),
              SafeArea(
                child: Column(
                  children: [
                    if (pet != null) _InfoCard(pet: pet, wallet: view.wallet),
                    const Spacer(),
                    _ActionBar(ref: ref, cooldown: view.cooldownSec),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${pet.name} · Lv ${pet.level}（${pet.stage.name.toUpperCase()} 档）',
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF6B5445))),
              Text('☁️ $wallet',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFE8A15C))),
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
          Text('经验 ${pet.exp} / ${GameConfig.graduationExp}    性格：${pet.personality.join(" · ")}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A7A6A))),
        ],
      ),
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
    final actions = [
      (CareAction.feed, Icons.restaurant, '喂食', GameConfig.feedExp, ctrl.feed),
      (CareAction.pat, Icons.pets, '摸头', GameConfig.patExp, ctrl.pat),
      (CareAction.toy, Icons.sports_baseball, '玩具', GameConfig.toyExp, ctrl.toy),
      (CareAction.bath, Icons.bathtub, '洗澡', GameConfig.bathExp, ctrl.bath),
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
          for (final (action, icon, label, exp, onTap) in actions)
            _ActionButton(
              icon: icon, label: label, exp: exp,
              cooldownSec: cooldown[action] ?? 0,
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int exp;
  final int cooldownSec;
  final VoidCallback onTap;
  const _ActionButton({
    required this.icon, required this.label, required this.exp,
    required this.cooldownSec, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final onCd = cooldownSec > 0;
    return GestureDetector(
      onTap: onCd ? null : onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: onCd ? const Color(0xFFE6DFD0) : const Color(0xFFE8A15C),
              shape: BoxShape.circle,
            ),
            child: Icon(onCd ? Icons.hourglass_bottom : icon,
                color: Colors.white, size: 26),
          ),
          const SizedBox(height: 4),
          Text(onCd ? '${cooldownSec}s' : '$label +$exp',
              style: TextStyle(
                  fontSize: 11,
                  color: onCd ? const Color(0xFFB0A090) : const Color(0xFF6B5445))),
        ],
      ),
    );
  }
}
