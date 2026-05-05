import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sonic_vault/features/stats/models/listening_stat.dart';
import 'package:sonic_vault/features/stats/models/stats_data.dart';
import 'package:sonic_vault/features/stats/models/top_track.dart';
import 'package:sonic_vault/shared/models/track_model.dart';

class StatsViewModel extends ChangeNotifier {
  // ── STATE ──────────────────────────────────────
  bool _isLoading = false;
  StatsData? _statsData;
  int _monthlyGoalHours = 20;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  StatsData? get statsData => _statsData;
  int get monthlyGoalHours => _monthlyGoalHours;
  String? get errorMessage => _errorMessage;

  double get goalProgress {
    if (_statsData == null) return 0.0;
    final double progress = _statsData!.totalMinutes / (_monthlyGoalHours * 60);
    return progress.clamp(0.0, 1.0);
  }

  final List<int> goalOptions = [5, 10, 15, 20, 30, 40, 50, 60];

  // ── FIREBASE ────────────────────────────────────
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── INIT ────────────────────────────────────────
  Future<void> init() async {
    await _loadGoalFromPrefs();
    await loadStats();
  }

  // ── LOAD GOAL ───────────────────────────────────
  Future<void> _loadGoalFromPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _monthlyGoalHours = prefs.getInt('monthly_goal') ?? 20;
    notifyListeners();
  }

  // ── SET GOAL ────────────────────────────────────
  Future<void> setMonthlyGoal(int hours) async {
    _monthlyGoalHours = hours;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('monthly_goal', hours);
    notifyListeners();
  }

  // ── LOAD STATS (Realtime Database Version) ─────
  Future<void> loadStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String? uid = _auth.currentUser?.uid;
      if (uid == null) throw Exception("User not logged in");

      final DatabaseReference historyRef = _db.ref('listening_history/$uid');

      final DataSnapshot snapshot = await historyRef.get();

      if (!snapshot.exists || snapshot.value == null) {
        _statsData = StatsData(
          totalMinutes: 0,
          dailyStats: [],
          topTracks: [],
        );
        _isLoading = false;
        notifyListeners();
        return;
      }

      final Map<dynamic, dynamic> allHistory = snapshot.value as Map<dynamic, dynamic>;

      // ── CALCULATE TOTAL MINUTES ────────────────
      int totalMinutes = 0;
      final Map<String, int> dailyMap = {};
      final Map<String, Map<String, dynamic>> trackMap = {};

      for (var entry in allHistory.entries) {
        final Map<dynamic, dynamic> doc = entry.value as Map<dynamic, dynamic>;

        final int seconds = doc['durationSeconds'] ?? 0;
        final int minutes = seconds ~/ 60;
        totalMinutes += minutes;

        // ── Daily Stats ───────────────────────────
        if (doc['playedAt'] != null) {
          final int playedAtMillis = doc['playedAt'] as int;
          final DateTime date = DateTime.fromMillisecondsSinceEpoch(playedAtMillis);

          // Only count current month
          final now = DateTime.now();
          if (date.year == now.year && date.month == now.month) {
            final String dayKey = '${date.year}-${date.month}-${date.day}';
            dailyMap[dayKey] = (dailyMap[dayKey] ?? 0) + minutes;
          }
        }

        // ── Top Tracks ─────────────────────────────
        final String trackId = doc['trackId'] ?? '';
        if (trackId.isEmpty) continue;

        if (!trackMap.containsKey(trackId)) {
          trackMap[trackId] = {
            'trackId': trackId,
            'trackTitle': doc['trackTitle'] ?? '',
            'artist': doc['artist'] ?? '',
            'imageUrl': '',
            'audioUrl': '',
            'durationSeconds': doc['durationSeconds'] ?? 0,
            'category': doc['category'] ?? '',
            'source': doc['source'] ?? '',
            'playCount': 0,
            'totalSeconds': 0,
          };
        }
        trackMap[trackId]!['playCount'] = (trackMap[trackId]!['playCount'] as int) + 1;
        trackMap[trackId]!['totalSeconds'] = (trackMap[trackId]!['totalSeconds'] as int) + seconds;
      }

      // ── Convert Daily Stats ─────────────────────
      final List<ListeningStat> dailyStats = dailyMap.entries.map((e) {
        final List<String> parts = e.key.split('-');
        return ListeningStat(
          date: DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          ),
          minutes: e.value,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));

      // ── Convert Top Tracks ──────────────────────
      final List<TopTrack> topTracks = trackMap.values.map((data) {
        return TopTrack(
          track: TrackModel(
            id: data['trackId'],
            title: data['trackTitle'],
            artist: data['artist'],
            audioUrl: data['audioUrl'],
            imageUrl: data['imageUrl'],
            durationSeconds: data['durationSeconds'],
            category: data['category'],
            source: data['source'],
          ),
          playCount: data['playCount'],
          totalMinutes: (data['totalSeconds'] as int) ~/ 60,
        );
      }).toList()
        ..sort((a, b) => b.playCount.compareTo(a.playCount));

      final List<TopTrack> top5 = topTracks.take(5).toList();

      _statsData = StatsData(
        totalMinutes: totalMinutes,
        dailyStats: dailyStats,
        topTracks: top5,
      );
    } catch (e) {
      print("Stats Error: $e");
      _errorMessage = 'Failed to load stats. Please try again.';
    }

    _isLoading = false;
    notifyListeners();
  }
}