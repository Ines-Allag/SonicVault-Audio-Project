import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonic_vault/shared/models/track_model.dart';

class AudioFirestoreService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── FAVORITES ─────────────────────────────────────────

  Future<void> addFavorite(TrackModel track) async {
    if (_uid == null) return;
    await _db
        .ref('users/$_uid/favorites/${track.id}')
        .set(track.toFavoriteMap());
  }

  Future<void> removeFavorite(String trackId) async {
    if (_uid == null) return;
    await _db
        .ref('users/$_uid/favorites/$trackId')
        .remove();
  }

  Future<List<TrackModel>> getFavorites() async {
    if (_uid == null) return [];
    final snap = await _db
        .ref('users/$_uid/favorites')
        .get();

    if (!snap.exists || snap.value == null) return [];

    final Map<dynamic, dynamic> data = snap.value as Map<dynamic, dynamic>;
    final List<TrackModel> favorites = data.values
        .map((v) => TrackModel.fromFavoriteMap(Map<String, dynamic>.from(v)))
        .toList();

    // Sort by addedAt descending
    favorites.sort((a, b) {
      final aTime = (data.values.firstWhere(
              (v) => v['trackId'] == a.id,
          orElse: () => {'addedAt': 0})['addedAt'] as int?) ?? 0;
      final bTime = (data.values.firstWhere(
              (v) => v['trackId'] == b.id,
          orElse: () => {'addedAt': 0})['addedAt'] as int?) ?? 0;
      return bTime.compareTo(aTime);
    });

    return favorites;
  }

  Future<bool> isFavorite(String trackId) async {
    if (_uid == null) return false;
    final snap = await _db
        .ref('users/$_uid/favorites/$trackId')
        .get();
    return snap.exists;
  }

  // ── LISTENING HISTORY ─────────────────────────────────

  Future<void> saveToHistory(TrackModel track) async {
    if (_uid == null) return;
    // push() generates a unique key like Firestore's .add()
    await _db
        .ref('listening_history/$_uid')
        .push()
        .set(track.toHistoryMap());
  }

  Future<List<Map<String, dynamic>>> getTopTracks({int limit = 5}) async {
    if (_uid == null) return [];
    final snap = await _db
        .ref('listening_history/$_uid')
        .get();

    if (!snap.exists || snap.value == null) return [];

    final Map<dynamic, dynamic> allHistory =
    snap.value as Map<dynamic, dynamic>;

    final Map<String, Map<String, dynamic>> counts = {};
    for (final entry in allHistory.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      final id = data['trackId'] as String? ?? '';
      if (id.isEmpty) continue;
      if (!counts.containsKey(id)) {
        counts[id] = {...data, 'count': 0};
      }
      counts[id]!['count'] = (counts[id]!['count'] as int) + 1;
    }

    final sorted = counts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return sorted.take(limit).toList();
  }

  Future<int> getTotalMinutesThisMonth() async {
    if (_uid == null) return 0;
    final snap = await _db
        .ref('listening_history/$_uid')
        .get();

    if (!snap.exists || snap.value == null) return 0;

    final Map<dynamic, dynamic> allHistory =
    snap.value as Map<dynamic, dynamic>;

    final now = DateTime.now();
    int totalSeconds = 0;

    for (final entry in allHistory.entries) {
      final data = Map<String, dynamic>.from(entry.value);
      final int playedAt = data['playedAt'] as int? ?? 0;
      final date = DateTime.fromMillisecondsSinceEpoch(playedAt);
      if (date.year == now.year && date.month == now.month) {
        totalSeconds += (data['durationSeconds'] as int? ?? 0);
      }
    }

    return totalSeconds ~/ 60;
  }
}