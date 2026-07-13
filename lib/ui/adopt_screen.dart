import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import 'adaptive_layout.dart';
import 'pet_art.dart';

/// 领养流程：院子空出后迎接下一只。选物种 → 取名 → 领养。
/// 性格在领养时随机 2 个（终身，spec DESIGN）；变体随机。
class AdoptScreen extends ConsumerStatefulWidget {
  const AdoptScreen({super.key});

  @override
  ConsumerState<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends ConsumerState<AdoptScreen> {
  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);
  static const _line = Color(0xFFE6DCC8);

  String? _selectedId;
  final _nameCtrl = TextEditingController();
  bool _adopting = false;

  @override
  void initState() {
    super.initState();
    ref.read(audioServiceProvider).playBgm(Bgm.adoption);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final id = _selectedId;
    if (id == null || _adopting) return;
    setState(() => _adopting = true);
    await ref.read(gameControllerProvider.notifier).adopt(id, _nameCtrl.text);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final choices = ref.read(gameControllerProvider.notifier).adoptChoices();
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5E9),
      appBar: AppBar(
        title: const Text(
          '领养新伙伴',
          style: TextStyle(color: _ink, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFBF5E9),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _ink),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 840
                ? 4
                : (constraints.maxWidth >= 600 ? 3 : 2);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1040),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                      child: Text(
                        '挑一只想要陪伴的小伙伴，给它取个名字吧',
                        style: TextStyle(color: _muted, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: GridView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: PetopiaAdaptive.sideMargin(context),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: 0.86,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: choices.length,
                        itemBuilder: (context, i) {
                          final c = choices[i];
                          final selected = c.speciesId == _selectedId;
                          return _ChoiceCard(
                            choice: c,
                            selected: selected,
                            onTap: () {
                              setState(() {
                                _selectedId = c.speciesId;
                                if (_nameCtrl.text.trim().isEmpty) {
                                  _nameCtrl.text = c.name;
                                  _nameCtrl.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: _nameCtrl.text.length,
                                  );
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    _NameAndConfirm(
                      controller: _nameCtrl,
                      enabled: _selectedId != null && !_adopting,
                      adopting: _adopting,
                      onConfirm: _confirm,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final AdoptChoiceView choice;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceCard({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? _AdoptScreenState._accent
                : _AdoptScreenState._line,
            width: selected ? 3 : 1.5,
          ),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                PetArt.portrait(choice.speciesId),
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.pets_rounded,
                  size: 56,
                  color: _AdoptScreenState._muted,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              choice.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _AdoptScreenState._ink,
                fontSize: 15,
              ),
            ),
            Text(
              choice.baseTone,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _AdoptScreenState._muted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameAndConfirm extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final bool adopting;
  final VoidCallback onConfirm;
  const _NameAndConfirm({
    required this.controller,
    required this.enabled,
    required this.adopting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFDF7),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLength: 12,
              enabled: enabled || adopting,
              decoration: InputDecoration(
                hintText: '给它取个名字',
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFFBF5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: enabled ? onConfirm : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: enabled
                    ? _AdoptScreenState._accent
                    : const Color(0xFFE6DFD0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                adopting ? '…' : '领养',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
