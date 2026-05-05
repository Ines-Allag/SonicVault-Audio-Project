import 'package:sonic_vault/shared/models/track_model.dart';

class TopTrack {
  final TrackModel track;
  final int playCount;
  final int totalMinutes;

  TopTrack({
    required this.track,
    required this.playCount,
    required this.totalMinutes,
  });
}