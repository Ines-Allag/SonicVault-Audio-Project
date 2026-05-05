import 'package:sonic_vault/features/stats/models/listening_stat.dart';
import 'package:sonic_vault/features/stats/models/top_track.dart';

class StatsData {
  final int totalMinutes;
  final List<ListeningStat> dailyStats;
  final List<TopTrack> topTracks;

  StatsData({
    required this.totalMinutes,
    required this.dailyStats,
    required this.topTracks,
  });

  // helpers
  int get totalHours => totalMinutes ~/ 60;
  int get remainingMinutes => totalMinutes % 60;
}