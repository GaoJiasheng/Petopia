import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import '../audio/route_audio.dart';
import 'adaptive_layout.dart';
import 'pet_art.dart';
import 'petopia_theme.dart';

/// 领养流程：院子空出后迎接下一只。选物种 → 取名 → 领养。
/// 性格在领养时随机 2 个（终身，spec DESIGN）；变体随机。
class AdoptScreen extends ConsumerStatefulWidget {
  const AdoptScreen({super.key});

  @override
  ConsumerState<AdoptScreen> createState() => _AdoptScreenState();
}

class _AdoptScreenState extends ConsumerState<AdoptScreen>
    with RouteAudio<AdoptScreen> {
  static const _ink = PetopiaColors.ink;
  static const _muted = PetopiaColors.mutedText;
  static const _accent = PetopiaColors.actionAccent;
  static const _line = Color(0xFFE6DCC8);

  String? _selectedId;
  final _nameCtrl = TextEditingController();
  bool _adopting = false;

  @override
  Bgm get routeBgm => Bgm.adoption;

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
            final scaledBody = MediaQuery.textScalerOf(context).scale(14);
            final largeText = scaledBody >= 18;
            final accessibilityText = scaledBody >= 28;
            final regularColumns = constraints.maxWidth >= 840
                ? 4
                : (constraints.maxWidth >= 600 ? 3 : 2);
            final columns = accessibilityText
                ? (constraints.maxWidth >= 840 ? 2 : 1)
                : regularColumns;
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
                        gridDelegate: accessibilityText
                            ? SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 340,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              )
                            : SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: largeText ? 0.7 : 0.86,
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
    return Semantics(
      button: true,
      selected: selected,
      label: '${choice.name}，${choice.baseTone}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey<String>('adopt_choice_${choice.speciesId}'),
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: PetopiaMotion.duration(
              context,
              const Duration(milliseconds: 180),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFDF7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? _AdoptScreenState._accent
                    : _AdoptScreenState._line,
                width: selected ? 3 : 1.5,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Image.asset(
                    PetArt.portrait(choice.speciesId),
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _AdoptScreenState._ink,
                    fontSize: 15,
                  ),
                ),
                Text(
                  choice.baseTone,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _AdoptScreenState._muted,
                    fontSize: 12,
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
    final largeText = MediaQuery.textScalerOf(context).scale(14) >= 18;
    final confirm = FilledButton(
      key: const ValueKey<String>('adopt_confirm'),
      onPressed: enabled ? onConfirm : null,
      style: FilledButton.styleFrom(
        minimumSize: Size(largeText ? double.infinity : 104, 52),
        backgroundColor: _AdoptScreenState._accent,
        disabledBackgroundColor: const Color(0xFFE6DFD0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        adopting ? '正在迎接…' : '领养',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stackControls = largeText || constraints.maxWidth < 360;
          final field = TextField(
            controller: controller,
            maxLength: 12,
            enabled: enabled || adopting,
            textInputAction: TextInputAction.done,
            onSubmitted: enabled ? (_) => onConfirm() : null,
            decoration: InputDecoration(
              labelText: '伙伴名字',
              hintText: '给它取个名字',
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFFBF5E9),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          );
          if (stackControls) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [field, const SizedBox(height: 10), confirm],
            );
          }
          return Row(
            children: [
              Expanded(child: field),
              const SizedBox(width: 10),
              confirm,
            ],
          );
        },
      ),
    );
  }
}
