import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import 'package:sonic_vault/core/services/audio_firestore_service.dart';
import 'package:sonic_vault/core/services/biometric_service.dart';
import 'package:sonic_vault/features/player/viewmodels/player_viewmodel.dart';
import 'package:sonic_vault/shared/models/track_model.dart';
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
          child: Text('No track playing',
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
                errorBuilder: (_, __, ___) =>
                    Container(color: AppColors.background),
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
                // ── TOP BAR ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 22, vertical: 14),
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
                          child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.white,
                              size: 22),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          'Now Playing',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 38), // balance the back button
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

                      // ── FAVORITE BUTTON ─────────────────
                      _FavoriteButton(track: track),
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
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500)),
                            Text(vm.durationFormatted,
                                style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
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

                      // Repeat
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

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAVORITE BUTTON ───────────────────────────────────────────────────────────
// Handles add + biometric-protected remove directly from the player

class _FavoriteButton extends StatefulWidget {
  final TrackModel track;

  const _FavoriteButton({required this.track});

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton> {
  final AudioFirestoreService _service = AudioFirestoreService();
  final BiometricService _biometric = BiometricService();
  bool _loading = false;

  Future<void> _toggle() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      if (widget.track.isFavorite) {
        // Removing → biometric required
        final confirmed = await _biometric.authenticate();
        if (!confirmed) {
          setState(() => _loading = false);
          return;
        }
        await _service.removeFavorite(widget.track.id);
        widget.track.isFavorite = false;
      } else {
        // Adding → no biometric needed
        await _service.addFavorite(widget.track);
        widget.track.isFavorite = true;
      }
    } catch (e) {
      debugPrint('Favorite error: $e');
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.track.isFavorite
              ? AppColors.accentDim
              : Colors.white.withOpacity(0.08),
          border: Border.all(
            color: widget.track.isFavorite
                ? AppColors.accent.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: _loading
            ? const Padding(
          padding: EdgeInsets.all(10),
          child: CircularProgressIndicator(
              color: AppColors.accent, strokeWidth: 2),
        )
            : Icon(
          widget.track.isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: widget.track.isFavorite
              ? AppColors.accent
              : Colors.white54,
          size: 18,
        ),
      ),
    );
  }
}

// ── CONTROL BUTTON ────────────────────────────────────────────────────────────

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