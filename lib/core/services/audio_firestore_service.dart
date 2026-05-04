import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sonic_vault/shared/models/track_model.dart';

class AudioFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  // ── FAVORITES ─────────────────────────────────────────

  Future<void> addFavorite(TrackModel track) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(track.id)
        .set(track.toFavoriteMap());
  }

  Future<void> removeFavorite(String trackId) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(trackId)
        .delete();
  }

  Future<List<TrackModel>> getFavorites() async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .orderBy('addedAt', descending: true)
        .get();
    return snap.docs
        .map((d) => TrackModel.fromFavoriteMap(d.data()))
        .toList();
  }

  Future<bool> isFavorite(String trackId) async {
    if (_uid == null) return false;
    final doc = await _db
        .collection('users')
        .doc(_uid)
        .collection('favorites')
        .doc(trackId)
        .get();
    return doc.exists;
  }

  // ── LISTENING HISTORY ─────────────────────────────────

  Future<void> saveToHistory(TrackModel track) async {
    if (_uid == null) return;
    await _db
        .collection('users')
        .doc(_uid)
        .collection('listening_history')
        .add(track.toHistoryMap());
  }

  // Récupère les morceaux les plus écoutés
  Future<List<Map<String, dynamic>>> getTopTracks({int limit = 5}) async {
    if (_uid == null) return [];
    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('listening_history')
        .orderBy('playedAt', descending: true)
        .limit(100)
        .get();

    // Compte les écoutes par trackId
    final Map<String, Map<String, dynamic>> counts = {};
    for (final doc in snap.docs) {
      final data = doc.data();
      final id = data['trackId'] as String;
      if (!counts.containsKey(id)) {
        counts[id] = {...data, 'count': 0};
      }
      counts[id]!['count'] = (counts[id]!['count'] as int) + 1;
    }

    final sorted = counts.values.toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return sorted.take(limit).toList();
  }

  // Total minutes écoutées ce mois
  Future<int> getTotalMinutesThisMonth() async {
    if (_uid == null) return 0;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snap = await _db
        .collection('users')
        .doc(_uid)
        .collection('listening_history')
        .where('playedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    int totalSeconds = 0;
    for (final doc in snap.docs) {
      totalSeconds += (doc.data()['durationSeconds'] as int? ?? 0);
    }
    return totalSeconds ~/ 60;
  }
}