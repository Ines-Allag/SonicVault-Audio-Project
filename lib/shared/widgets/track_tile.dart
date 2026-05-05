import 'package:flutter/material.dart';
import 'package:sonic_vault/shared/models/track_model.dart';
import 'package:sonic_vault/shared/theme/app_colors.dart';

class TrackTile extends StatelessWidget {
  final TrackModel track;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final bool showDeleteIcon;

  const TrackTile({
    super.key,
    required this.track,
    required this.onTap,
    required this.onFavorite,
    this.showDeleteIcon = false,
  });

  Color get _coverColor {
    if (track.source == 'quran') return const Color(0xFF0D1A0D);
    return const Color(0xFF1A0D2A);
  }

  Color get _iconColor {
    if (track.source == 'quran') return AppColors.accent;
    return const Color(0xFFC084FC);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        child: Row(
          children: [
            // Cover
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: _coverColor,
              ),
              child: track.imageUrl.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  track.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildIcon(),
                ),
              )
                  : _buildIcon(),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: AppTextStyles.trackTitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${track.artist} · ${track.durationFormatted}',
                    style: AppTextStyles.trackSub,
                  ),
                ],
              ),
            ),
            // Favorite / Delete button
            GestureDetector(
              onTap: onFavorite,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: track.isFavorite || showDeleteIcon
                      ? AppColors.accentDim
                      : const Color(0xFF111111),
                  border: Border.all(
                    color: track.isFavorite || showDeleteIcon
                        ? AppColors.accent.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: Icon(
                  showDeleteIcon
                      ? Icons.delete_outline_rounded
                      : track.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 15,
                  color: track.isFavorite || showDeleteIcon
                      ? AppColors.accent
                      : AppColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      track.source == 'quran' ? Icons.menu_book_rounded : Icons.music_note_rounded,
      color: _iconColor,
      size: 22,
    );
  }
}