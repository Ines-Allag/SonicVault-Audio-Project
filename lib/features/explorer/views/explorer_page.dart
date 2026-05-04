import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/core/services/biometric_service.dart';
import 'package:sonic_vault/core/services/deezer_service.dart';
import 'package:sonic_vault/core/services/quran_service.dart';
import 'package:sonic_vault/features/explorer/viewmodels/explorer_viewmodel.dart';
import 'package:sonic_vault/features/player/viewmodels/player_viewmodel.dart';
import 'package:sonic_vault/features/player/views/player_page.dart';
import 'package:sonic_vault/shared/models/track_model.dart';
import 'package:sonic_vault/shared/theme/app_colors.dart';
import 'package:sonic_vault/shared/widgets/mini_player_bar.dart';
import 'package:sonic_vault/shared/widgets/track_tile.dart';

class ExplorerPage extends StatelessWidget {
  const ExplorerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExplorerViewModel(),
      child: const _ExplorerContent(),
    );
  }
}

class _ExplorerContent extends StatelessWidget {
  const _ExplorerContent();

  void _openPlayer(BuildContext context, TrackModel track, List<TrackModel> queue) {
    context.read<PlayerViewModel>().playTrack(track, queue: queue);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PlayerPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExplorerViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explorer', style: AppTextStyles.h1),
                        const SizedBox(height: 2),
                        const Text('Bonne écoute aujourd\'hui',
                            style: AppTextStyles.body),
                      ],
                    ),
                  ),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                    child: const Center(
                      child: Text('YA',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Rechercher...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: AppColors.textMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onChanged: (q) => vm.search(q),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Row(
                children: [
                  _Tab(label: 'Quran', active: vm.tab == ExplorerTab.quran,
                      onTap: () => vm.setTab(ExplorerTab.quran)),
                  const SizedBox(width: 8),
                  _Tab(label: 'Musique', active: vm.tab == ExplorerTab.music,
                      onTap: () {
                        vm.setTab(ExplorerTab.music);
                        vm.loadMusic();
                      }),
                  const SizedBox(width: 8),
                  _Tab(label: 'Favoris', active: vm.tab == ExplorerTab.favorites,
                      onTap: () => vm.setTab(ExplorerTab.favorites)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent, strokeWidth: 2))
                  : _buildTabContent(context, vm),
            ),
            // Mini player
            const MiniPlayerBar(),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ExplorerViewModel vm) {
    switch (vm.tab) {
      case ExplorerTab.quran:
        return _QuranTab(vm: vm,
            onPlay: (t) => _openPlayer(context, t, vm.quranTracks));
      case ExplorerTab.music:
        return _MusicTab(vm: vm,
            onPlay: (t) => _openPlayer(context, t, vm.musicTracks));
      case ExplorerTab.favorites:
        return _FavoritesTab(vm: vm,
            onPlay: (t, q) => _openPlayer(context, t, q));
    }
  }
}

// ── TAB CHIP ──────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.black : AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── QURAN TAB ─────────────────────────────────────────────────────────────────

class _QuranTab extends StatelessWidget {
  final ExplorerViewModel vm;
  final void Function(TrackModel) onPlay;

  const _QuranTab({required this.vm, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Category chips
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: Text('Catégories', style: AppTextStyles.h2),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: [
              _QuranCategoryCard(
                label: 'Toutes',
                icon: Icons.all_inclusive_rounded,
                color: AppColors.accent,
                selected: vm.selectedQuranCategory == null,
                onTap: () => vm.setQuranCategory(null),
              ),
              const SizedBox(width: 10),
              _QuranCategoryCard(
                label: 'Courtes',
                icon: Icons.layers_rounded,
                color: AppColors.accent,
                selected: vm.selectedQuranCategory == 'Courtes',
                onTap: () => vm.setQuranCategory('Courtes'),
              ),
              const SizedBox(width: 10),
              _QuranCategoryCard(
                label: 'Moyennes',
                icon: Icons.nightlight_round,
                color: const Color(0xFF818CF8),
                selected: vm.selectedQuranCategory == 'Moyennes',
                onTap: () => vm.setQuranCategory('Moyennes'),
              ),
              const SizedBox(width: 10),
              _QuranCategoryCard(
                label: 'Longues',
                icon: Icons.star_rounded,
                color: const Color(0xFFFB923C),
                selected: vm.selectedQuranCategory == 'Longues',
                onTap: () => vm.setQuranCategory('Longues'),
              ),
            ],
          ),
        ),
        // Récitateurs
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
          child: Text('Récitateurs', style: AppTextStyles.h2),
        ),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            children: QuranService.reciters.keys.map((name) {
              final selected = vm.selectedReciter == name;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: GestureDetector(
                  onTap: () => vm.setReciter(name),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentDim,
                          border: Border.all(
                            color: selected
                                ? AppColors.accent
                                : AppColors.border,
                            width: selected ? 2 : 1.5,
                          ),
                          image: DecorationImage(
                            image: AssetImage(
                                QuranService.reciters[name]!),
                            fit: BoxFit.cover,
                            onError: (_, __) {},
                          ),
                        ),
                        child: selected
                            ? null
                            : const Icon(Icons.mic_rounded,
                                color: AppColors.accent, size: 22),
                      ),
                      const SizedBox(height: 5),
                      Text(name.split('-').last,
                          style: TextStyle(
                              color: selected
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // Track list
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
          child: Text('Sourates', style: AppTextStyles.h2),
        ),
        ...vm.quranTracks.map((t) => Column(
              children: [
                TrackTile(
                  track: t,
                  onTap: () => onPlay(t),
                  onFavorite: () => vm.toggleFavorite(t),
                ),
                const Divider(
                    color: AppColors.surface, height: 1, indent: 22, endIndent: 22),
              ],
            )),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _QuranCategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _QuranCategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.15) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── MUSIC TAB ─────────────────────────────────────────────────────────────────

class _MusicTab extends StatelessWidget {
  final ExplorerViewModel vm;
  final void Function(TrackModel) onPlay;

  const _MusicTab({required this.vm, required this.onPlay});

  Color _genreColor(String genre) {
    switch (genre) {
      case 'Pop': return AppColors.pop;
      case 'Rap': return AppColors.rap;
      case 'R&B': return AppColors.rnb;
      case 'Rock': return AppColors.rock;
      case 'Electro': return AppColors.electro;
      default: return AppColors.nasheed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
          child: Row(
            children: [
              Text('Genres', style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Text('via Deezer',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ],
          ),
        ),
        // Genre pills
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            children: DeezerService.genres.keys.map((genre) {
              final color = _genreColor(genre);
              final selected = vm.selectedGenre == genre;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => vm.loadMusic(genre: genre),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withOpacity(0.15)
                          : AppColors.card,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: selected
                              ? color.withOpacity(0.5)
                              : AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: color),
                        ),
                        const SizedBox(width: 8),
                        Text(genre,
                            style: TextStyle(
                                color: selected ? color : AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 12),
          child: Text('Tendances', style: AppTextStyles.h2),
        ),
        if (vm.musicTracks.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.music_off_rounded,
                      color: AppColors.textMuted, size: 40),
                  const SizedBox(height: 12),
                  const Text('Sélectionne un genre pour charger les morceaux',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => vm.loadMusic(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.accentDim,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                            color: AppColors.accent.withOpacity(0.3)),
                      ),
                      child: const Text('Charger',
                          style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...vm.musicTracks.map((t) => Column(
                children: [
                  TrackTile(
                    track: t,
                    onTap: () => onPlay(t),
                    onFavorite: () => vm.toggleFavorite(t),
                  ),
                  const Divider(
                      color: AppColors.surface,
                      height: 1,
                      indent: 22,
                      endIndent: 22),
                ],
              )),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ── FAVORITES TAB ─────────────────────────────────────────────────────────────

class _FavoritesTab extends StatelessWidget {
  final ExplorerViewModel vm;
  final void Function(TrackModel, List<TrackModel>) onPlay;

  const _FavoritesTab({required this.vm, required this.onPlay});

  Future<void> _handleDelete(
      BuildContext context, ExplorerViewModel vm, TrackModel track) async {
    final biometricService = BiometricService();
    await vm.removeFavoriteWithBiometric(
      track,
      () => biometricService.authenticate(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final qFavs = vm.quranFavorites;
    final mFavs = vm.musicFavorites;

    if (qFavs.isEmpty && mFavs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded,
                color: AppColors.textMuted, size: 48),
            SizedBox(height: 16),
            Text('Aucun favori pour l\'instant',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            SizedBox(height: 8),
            Text('Appuie sur le ♡ pour sauvegarder un morceau',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ],
        ),
      );
    }

    return ListView(
      children: [
        // Security banner
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.accentDim,
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppColors.accent.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, color: AppColors.accent, size: 16),
                SizedBox(width: 8),
                Text('Suppression protégée par empreinte digitale',
                    style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ),
        // Quran favorites
        if (qFavs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: Row(
              children: [
                Text('Quran', style: AppTextStyles.h2),
                const SizedBox(width: 8),
                Text('(${qFavs.length})',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          ...qFavs.map((t) => TrackTile(
                track: t,
                onTap: () => onPlay(t, qFavs),
                onFavorite: () => _handleDelete(context, vm, t),
                showDeleteIcon: true,
              )),
        ],
        // Music favorites
        if (mFavs.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            child: Row(
              children: [
                Text('Musique', style: AppTextStyles.h2),
                const SizedBox(width: 8),
                Text('(${mFavs.length})',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
              ],
            ),
          ),
          ...mFavs.map((t) => TrackTile(
                track: t,
                onTap: () => onPlay(t, mFavs),
                onFavorite: () => _handleDelete(context, vm, t),
                showDeleteIcon: true,
              )),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}