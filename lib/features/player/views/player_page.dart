import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/player/viewmodels/player_viewmodel.dart';
import 'package:sonic_vault/shared/theme/app_colors.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayerViewModel>();
    final track = vm.currentTrack;

    if (track == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text('Aucun morceau en cours',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── BACKGROUND IMAGE ──────────────────────────────
          if (track.imageUrl.isNotEmpty)
            Positioned.fill(
              child: Image.network(
                track.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppColors.background),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color: track.source == 'quran'
                    ? const Color(0xFF0A1A0A)
                    : const Color(0xFF140820),
              ),
            ),

          // ── GRADIENT OVERLAY ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.7),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.75],
                ),
              ),
            ),
          ),

          // ── CONTENT ───────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1)),
                          ),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white, size: 22),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'En lecture',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.1)),
                        ),
                        child: const Icon(Icons.more_vert_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // ── TRACK INFO ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              track.source == 'quran'
                                  ? '${track.artist} · ${track.category}'
                                  : track.artist,
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Favorite button
                      GestureDetector(
                        onTap: () {
                          // Toggle favorite — géré par ExplorerViewModel
                          // Ici juste visuel, la logique est dans ExplorerPage
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: track.isFavorite
                                ? AppColors.accentDim
                                : Colors.white.withOpacity(0.08),
                            border: Border.all(
                              color: track.isFavorite
                                  ? AppColors.accent.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Icon(
                            track.isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: track.isFavorite
                                ? AppColors.accent
                                : Colors.white54,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── PROGRESS BAR ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14),
                          activeTrackColor: AppColors.accent,
                          inactiveTrackColor: Colors.white12,
                          thumbColor: AppColors.accent,
                          overlayColor: AppColors.accentDim,
                        ),
                        child: Slider(
                          value: vm.progress.clamp(0.0, 1.0),
                          onChanged: (v) => vm.seekTo(v),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(vm.positionFormatted,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            Text(vm.durationFormatted,
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── CONTROLS ────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Shuffle / Repeat
                      _ControlBtn(
                        icon: track.source == 'music'
                            ? Icons.shuffle_rounded
                            : Icons.repeat_rounded,
                        color: (track.source == 'music'
                                ? vm.isShuffle
                                : vm.repeatMode != RepeatMode.none)
                            ? AppColors.accent
                            : Colors.white38,
                        onTap: track.source == 'music'
                            ? vm.toggleShuffle
                            : vm.toggleRepeat,
                        size: 22,
                      ),
                      // Previous
                      _ControlBtn(
                        icon: Icons.skip_previous_rounded,
                        color: Colors.white,
                        onTap: vm.skipPrevious,
                        size: 28,
                      ),
                      // Play/Pause
                      GestureDetector(
                        onTap: vm.togglePlay,
                        child: Container(
                          width: 66,
                          height: 66,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accent,
                          ),
                          child: Icon(
                            vm.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.black,
                            size: 32,
                          ),
                        ),
                      ),
                      // Next
                      _ControlBtn(
                        icon: Icons.skip_next_rounded,
                        color: Colors.white,
                        onTap: vm.skipNext,
                        size: 28,
                      ),
                      // Repeat (one)
                      _ControlBtn(
                        icon: vm.repeatMode == RepeatMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: vm.repeatMode != RepeatMode.none
                            ? AppColors.accent
                            : Colors.white38,
                        onTap: vm.toggleRepeat,
                        size: 22,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // ── EXTRA BUTTONS ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _TextBtn(
                        icon: Icons.queue_music_rounded,
                        label: 'File d\'attente',
                      ),
                      _TextBtn(
                        icon: Icons.share_rounded,
                        label: 'Partager',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── QUEUE ────────────────────────────────────
                if (vm.queue.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Suivant',
                            style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5)),
                        const SizedBox(height: 10),
                        ...vm.queue
                            .where((t) => t.id != track.id)
                            .take(2)
                            .map((t) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: AppColors.surface,
                                        ),
                                        child: t.imageUrl.isNotEmpty
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Image.network(
                                                    t.imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (_, __, ___) =>
                                                        const Icon(
                                                            Icons.music_note_rounded,
                                                            color: AppColors.accent,
                                                            size: 18)))
                                            : const Icon(
                                                Icons.music_note_rounded,
                                                color: AppColors.accent,
                                                size: 18),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(t.title,
                                                style: const TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 13,
                                                    fontWeight:
                                                        FontWeight.w500),
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            Text(t.artist,
                                                style: const TextStyle(
                                                    color: Colors.white24,
                                                    fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                      Text(t.durationFormatted,
                                          style: const TextStyle(
                                              color: Colors.white24,
                                              fontSize: 11)),
                                    ],
                                  ),
                                )),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final double size;

  const _ControlBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _TextBtn extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TextBtn({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white24, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: Colors.white24, fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }
}