import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import 'adaptive_layout.dart';
import 'pet_art.dart';
import 'postcard_viewer_screen.dart';

/// 双相册：明信片相册（收到的每张卡）+ 旅行相册（已毕业漫游的伙伴）。
class AlbumScreen extends ConsumerStatefulWidget {
  const AlbumScreen({super.key});

  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);

  @override
  ConsumerState<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends ConsumerState<AlbumScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      ref.read(gameControllerProvider.notifier).trackAlbumOpened();
      ref.read(audioServiceProvider).playBgm(Bgm.albumBrowse);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(gameControllerProvider);
    final ctrl = ref.read(gameControllerProvider.notifier);
    final cards = ctrl.postcards();
    final travel = ctrl.travelAlbum();
    final background = _albumBackground(ctrl.activeAlbumSkinId);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          title: const Text(
            '相册',
            style: TextStyle(
              color: AlbumScreen._ink,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: background,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: AlbumScreen._ink),
          actions: [
            IconButton(
              tooltip: '相册装帧',
              onPressed: () => _openSkinPicker(ctrl),
              icon: const Icon(Icons.palette_outlined),
            ),
            const SizedBox(width: 6),
          ],
          bottom: const TabBar(
            labelColor: AlbumScreen._accent,
            unselectedLabelColor: AlbumScreen._muted,
            indicatorColor: AlbumScreen._accent,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: '明信片'),
              Tab(text: '旅行伙伴'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _PostcardGrid(cards: cards),
            _TravelList(pets: travel, cards: cards),
          ],
        ),
      ),
    );
  }

  Future<void> _openSkinPicker(GameController ctrl) async {
    final skins = ctrl.albumSkins();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _albumBackground(ctrl.activeAlbumSkinId),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '相册装帧',
                    style: TextStyle(
                      color: AlbumScreen._ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...skins.map(
                    (skin) => ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      leading: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: _albumBackground(skin.id),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AlbumScreen._ink.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_stories_rounded,
                          size: 20,
                          color: AlbumScreen._ink,
                        ),
                      ),
                      title: Text(
                        skin.name,
                        style: const TextStyle(
                          color: AlbumScreen._ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      trailing: skin.active
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AlbumScreen._accent,
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: AlbumScreen._muted,
                            ),
                      onTap: skin.active
                          ? null
                          : () {
                              ctrl.applyAlbumSkin(skin.id);
                              Navigator.of(sheetContext).pop();
                            },
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

Color _albumBackground(String skinId) {
  return switch (skinId) {
    'paper' => const Color(0xFFF2E3CA),
    'picnic' => const Color(0xFFE7F1F2),
    'dried_flower' => const Color(0xFFF7E8E5),
    'star_chart' => const Color(0xFFE7EAF3),
    'old_ticket' => const Color(0xFFF0E0C4),
    'global_courier' => const Color(0xFFE1EEE9),
    'years_journal' => const Color(0xFFECE3F1),
    _ => const Color(0xFFFBF5E9),
  };
}

class _PostcardGrid extends StatefulWidget {
  final List<PostcardView> cards;
  const _PostcardGrid({required this.cards});

  @override
  State<_PostcardGrid> createState() => _PostcardGridState();
}

class _PostcardGridState extends State<_PostcardGrid> {
  String? _pet;
  String? _location;

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const _Empty(
        icon: Icons.mail_outline_rounded,
        text: '还没有明信片\n宠物毕业去旅行后，会隔些日子寄一张回来 💌',
      );
    }
    final pets = widget.cards.map((card) => card.petName).toSet().toList()
      ..sort();
    final locations =
        widget.cards.map((card) => card.locationName).toSet().toList()..sort();
    final cards = widget.cards
        .where((card) {
          return (_pet == null || card.petName == _pet) &&
              (_location == null || card.locationName == _location);
        })
        .toList(growable: false);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = PetopiaAdaptive.postcardGridColumns(
          constraints.maxWidth,
        );
        final margin = PetopiaAdaptive.sideMargin(context);
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1180),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(margin, 14, margin, 2),
                  child: _AlbumFilters(
                    total: widget.cards.length,
                    visible: cards.length,
                    pets: pets,
                    locations: locations,
                    selectedPet: _pet,
                    selectedLocation: _location,
                    onPetChanged: (value) => setState(() => _pet = value),
                    onLocationChanged: (value) =>
                        setState(() => _location = value),
                    onClear: () => setState(() {
                      _pet = null;
                      _location = null;
                    }),
                  ),
                ),
                Expanded(
                  child: cards.isEmpty
                      ? const _Empty(
                          icon: Icons.filter_alt_off_rounded,
                          text: '这组筛选还没有明信片\n换一位伙伴或地点看看',
                        )
                      : GridView.builder(
                          padding: EdgeInsets.fromLTRB(margin, 12, margin, 24),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: columns >= 4 ? 0.88 : 0.82,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                          itemCount: cards.length,
                          itemBuilder: (context, i) =>
                              _PostcardThumb(card: cards[i]),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AlbumFilters extends StatelessWidget {
  final int total;
  final int visible;
  final List<String> pets;
  final List<String> locations;
  final String? selectedPet;
  final String? selectedLocation;
  final ValueChanged<String?> onPetChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback onClear;

  const _AlbumFilters({
    required this.total,
    required this.visible,
    required this.pets,
    required this.locations,
    required this.selectedPet,
    required this.selectedLocation,
    required this.onPetChanged,
    required this.onLocationChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = selectedPet != null || selectedLocation != null;
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _AlbumFilterMenu(
                  icon: Icons.pets_rounded,
                  label: selectedPet ?? '全部伙伴',
                  values: pets,
                  onChanged: onPetChanged,
                ),
                const SizedBox(width: 8),
                _AlbumFilterMenu(
                  icon: Icons.place_rounded,
                  label: selectedLocation ?? '全部地点',
                  values: locations,
                  onChanged: onLocationChanged,
                ),
                if (filtered) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: '清除筛选',
                    onPressed: onClear,
                    icon: const Icon(Icons.filter_alt_off_rounded),
                    color: AlbumScreen._muted,
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          filtered ? '$visible / $total' : '$total 张',
          style: const TextStyle(
            color: AlbumScreen._muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _AlbumFilterMenu extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<String> values;
  final ValueChanged<String?> onChanged;

  const _AlbumFilterMenu({
    required this.icon,
    required this.label,
    required this.values,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: label,
      onSelected: (value) => onChanged(value.isEmpty ? null : value),
      itemBuilder: (context) => [
        const PopupMenuItem(value: '', child: Text('全部')),
        for (final value in values)
          PopupMenuItem(value: value, child: Text(value)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE6DCC8)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AlbumScreen._accent),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AlbumScreen._ink,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: AlbumScreen._muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _PostcardThumb extends StatelessWidget {
  final PostcardView card;
  const _PostcardThumb({required this.card});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PostcardViewerScreen(card: card),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF7),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                'assets/art/postcards/backgrounds/${card.photoBg}.jpg',
                fit: BoxFit.cover,
                cacheWidth: 520,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFDCEAD8),
                  child: const Icon(
                    Icons.photo_rounded,
                    color: AlbumScreen._muted,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AlbumScreen._ink,
                    ),
                  ),
                  Text(
                    '${card.petName} · 第 ${card.seq + 1} 站',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AlbumScreen._muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelList extends StatelessWidget {
  final List<TravelPetView> pets;
  final List<PostcardView> cards;
  const _TravelList({required this.pets, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return const _Empty(
        icon: Icons.card_travel_rounded,
        text: '还没有毕业的旅行伙伴\n把宠物养到毕业，它就会踏上旅途 🎒',
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = PetopiaAdaptive.travelColumns(constraints.maxWidth);
        final margin = PetopiaAdaptive.sideMargin(context);
        if (columns > 1) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1040),
              child: GridView.builder(
                padding: EdgeInsets.fromLTRB(margin, 16, margin, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 126,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: pets.length,
                itemBuilder: (context, i) => _TravelPetCard(
                  pet: pets[i],
                  onTap: () => _showJourney(context, pets[i]),
                ),
              ),
            ),
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(margin, 16, margin, 24),
              itemCount: pets.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _TravelPetCard(
                pet: pets[i],
                onTap: () => _showJourney(context, pets[i]),
              ),
            ),
          ),
        );
      },
    );
  }

  static String _date(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';

  void _showJourney(BuildContext context, TravelPetView pet) {
    final petCards = cards
        .where((card) => card.petId == pet.petId)
        .toList(growable: false);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFDF7),
      constraints: const BoxConstraints(maxWidth: 900),
      builder: (context) => _TravelJourneySheet(pet: pet, cards: petCards),
    );
  }
}

class _TravelPetCard extends StatelessWidget {
  final TravelPetView pet;
  final VoidCallback onTap;
  const _TravelPetCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFDF7),
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _TravelAvatar(pet: pet),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AlbumScreen._ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已走过 ${pet.completedStops} / ${pet.stops} 站 · 已寄回 ${pet.postcardCount} 张',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AlbumScreen._muted,
                      ),
                    ),
                    if (pet.graduatedAt != null)
                      Text(
                        '毕业于 ${_TravelList._date(pet.graduatedAt!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AlbumScreen._muted,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AlbumScreen._muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TravelJourneySheet extends StatelessWidget {
  final TravelPetView pet;
  final List<PostcardView> cards;

  const _TravelJourneySheet({required this.pet, required this.cards});

  @override
  Widget build(BuildContext context) {
    final height = (MediaQuery.sizeOf(context).height * 0.78).clamp(
      430.0,
      760.0,
    );
    final progress = pet.stops == 0
        ? 0.0
        : (pet.completedStops / pet.stops).clamp(0.0, 1.0);
    return SafeArea(
      top: false,
      child: SizedBox(
        height: height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 12, 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 82,
                    height: 82,
                    child: _TravelAvatar(pet: pet),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${pet.name}的旅程',
                          style: const TextStyle(
                            color: AlbumScreen._ink,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${pet.completedStops} / ${pet.stops} 站 · 已寄回 ${pet.postcardCount} 张',
                          style: const TextStyle(
                            color: AlbumScreen._muted,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 9),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: const Color(0xFFEDE4D3),
                            color: AlbumScreen._accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '关闭',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    color: AlbumScreen._muted,
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFEDE4D3)),
            Expanded(
              child: cards.isEmpty
                  ? const _Empty(
                      icon: Icons.mark_email_unread_outlined,
                      text: '它已经在路上了\n第一封信会在合适的时候寄回来',
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 760
                            ? 4
                            : (constraints.maxWidth >= 520 ? 3 : 2);
                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                childAspectRatio: 0.84,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                          itemCount: cards.length,
                          itemBuilder: (context, index) =>
                              _PostcardThumb(card: cards[index]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TravelAvatar extends StatelessWidget {
  final TravelPetView pet;
  const _TravelAvatar({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1DF).withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(8),
      ),
      child: _GraduationStageImage(
        paths: _graduationStagePaths(pet.speciesId, pet.variantId),
        fallback: Image.asset(
          PetArt.portrait(pet.speciesId),
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const Icon(
            Icons.pets_rounded,
            size: 40,
            color: AlbumScreen._muted,
          ),
        ),
      ),
    );
  }
}

class _GraduationStageImage extends StatelessWidget {
  final List<String> paths;
  final Widget fallback;
  const _GraduationStageImage({required this.paths, required this.fallback});

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) return fallback;
    final path = paths.first;
    return Image.asset(
      path,
      fit: BoxFit.contain,
      cacheWidth: 220,
      errorBuilder: (_, _, _) =>
          _GraduationStageImage(paths: paths.sublist(1), fallback: fallback),
    );
  }
}

List<String> _graduationStagePaths(String speciesId, String variantId) {
  final species = _speciesSlug(speciesId);
  final variant = _variantSlug(variantId);
  return <String>[
    if (variant != null)
      'assets/runtime/pets/$species/pet_${species}_${variant}_stageD.png',
    'assets/runtime/pets/$species/pet_${species}_var01_stageD.png',
  ];
}

String _speciesSlug(String speciesId) {
  final id = speciesId.replaceFirst('pet_', '');
  return switch (id) {
    'cham' => 'chameleon',
    _ => id,
  };
}

String? _variantSlug(String variantId) {
  final match = RegExp(r'(?:^|_)v(?:ar)?0?([1-5])$').firstMatch(variantId);
  final value = match == null ? null : int.tryParse(match.group(1)!);
  if (value == null) return null;
  return 'var${value.toString().padLeft(2, '0')}';
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Empty({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: const Color(0xFFCBBEA8)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AlbumScreen._muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
