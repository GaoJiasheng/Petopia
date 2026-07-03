import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/game_controller.dart';
import '../audio/audio_service.dart';
import 'pet_art.dart';
import 'postcard_viewer_screen.dart';

/// 双相册：明信片相册（收到的每张卡）+ 旅行相册（已毕业漫游的伙伴）。
class AlbumScreen extends ConsumerWidget {
  const AlbumScreen({super.key});

  static const _ink = Color(0xFF6B5445);
  static const _muted = Color(0xFF8A7A6A);
  static const _accent = Color(0xFFE8A15C);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.watch(gameControllerProvider.notifier);
    ref.read(audioServiceProvider).playBgm(Bgm.albumBrowse);
    final cards = ctrl.postcards();
    final travel = ctrl.travelAlbum();
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBF5E9),
        appBar: AppBar(
          title: const Text('相册',
              style: TextStyle(color: _ink, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFFBF5E9),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: _ink),
          bottom: const TabBar(
            labelColor: _accent,
            unselectedLabelColor: _muted,
            indicatorColor: _accent,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [Tab(text: '明信片'), Tab(text: '旅行伙伴')],
          ),
        ),
        body: TabBarView(
          children: [
            _PostcardGrid(cards: cards),
            _TravelList(pets: travel),
          ],
        ),
      ),
    );
  }
}

class _PostcardGrid extends StatelessWidget {
  final List<PostcardView> cards;
  const _PostcardGrid({required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const _Empty(
        icon: Icons.mail_outline_rounded,
        text: '还没有明信片\n宠物毕业去旅行后，会隔些日子寄一张回来 💌',
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.82,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cards.length,
      itemBuilder: (context, i) => _PostcardThumb(card: cards[i]),
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
            builder: (_) => PostcardViewerScreen(card: card)),
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
                'assets/art/postcards/backgrounds/${card.photoBg}.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: const Color(0xFFDCEAD8),
                  child: const Icon(Icons.photo_rounded,
                      color: AlbumScreen._muted),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.locationName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AlbumScreen._ink)),
                  Text('${card.petName} · 第 ${card.seq + 1} 站',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11, color: AlbumScreen._muted)),
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
  const _TravelList({required this.pets});

  @override
  Widget build(BuildContext context) {
    if (pets.isEmpty) {
      return const _Empty(
        icon: Icons.card_travel_rounded,
        text: '还没有毕业的旅行伙伴\n把宠物养到毕业，它就会踏上旅途 🎒',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final p = pets[i];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF7),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: Image.asset(
                  PetArt.dexColor(p.speciesId),
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(Icons.pets_rounded,
                      size: 40, color: AlbumScreen._muted),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AlbumScreen._ink)),
                    const SizedBox(height: 4),
                    Text('旅程 ${p.stops} 站 · 已寄回 ${p.postcardCount} 张明信片',
                        style: const TextStyle(
                            fontSize: 12.5, color: AlbumScreen._muted)),
                    if (p.graduatedAt != null)
                      Text('毕业于 ${_date(p.graduatedAt!)}',
                          style: const TextStyle(
                              fontSize: 11.5, color: AlbumScreen._muted)),
                  ],
                ),
              ),
              const Text('🎒', style: TextStyle(fontSize: 22)),
            ],
          ),
        );
      },
    );
  }

  static String _date(DateTime t) =>
      '${t.year}.${t.month.toString().padLeft(2, '0')}.${t.day.toString().padLeft(2, '0')}';
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
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, height: 1.6, color: AlbumScreen._muted)),
          ],
        ),
      ),
    );
  }
}
