import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sonic_vault/features/player/viewmodels/player_viewmodel.dart';
import 'package:sonic_vault/features/player/views/player_page.dart';
import 'package:sonic_vault/shared/theme/app_colors.dart';

class MiniPlayerBar extends StatelessWidget {
  const MiniPlayerBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerViewModel>(
      builder: (context, vm, _) {
        final track = vm.currentTrack;
        if (track == null) return const SizedBox.shrink();

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PlayerPage()),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Cover
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.accentDim,
                    border: Border.all(
                        color: AppColors.accent.withOpacity(0.3)),
                  ),
                  child: track.imageUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(track.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.music_note_rounded,
                          color: AppColors.accent,
                          size: 18,
                        )),
                  )
                      : const Icon(Icons.music_note_rounded,
                      color: AppColors.accent, size: 18),
                ),
                const SizedBox(width: 12),
                // Info + progress
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title,
                          style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(track.artist,
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11)),
                      const SizedBox(height: 5),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: vm.progress,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Play/Pause
                GestureDetector(
                  onTap: () => vm.togglePlay(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                    ),
                    child: Icon(
                      vm.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
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