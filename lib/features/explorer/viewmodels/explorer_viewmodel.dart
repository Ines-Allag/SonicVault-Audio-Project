import 'package:flutter/material.dart';
import 'package:sonic_vault/core/services/quran_service.dart';
import 'package:sonic_vault/core/services/deezer_service.dart';
import 'package:sonic_vault/core/services/audio_firestore_service.dart';
import 'package:sonic_vault/shared/models/track_model.dart';

enum ExplorerTab { quran, music, favorites }

class ExplorerViewModel extends ChangeNotifier {
  final QuranService _quranService = QuranService();
  final DeezerService _deezerService = DeezerService();
  final AudioFirestoreService _firestoreService = AudioFirestoreService();

  ExplorerTab _tab = ExplorerTab.quran;
  ExplorerTab get tab => _tab;

  // Quran
  String _selectedReciter = 'Al-Sudais';
  String get selectedReciter => _selectedReciter;
  String? _selectedQuranCategory; // null = tous
  String? get selectedQuranCategory => _selectedQuranCategory;
  List<TrackModel> _quranTracks = [];
  List<TrackModel> get quranTracks => _quranTracks;

  // Music
  String _selectedGenre = 'Pop';
  String get selectedGenre => _selectedGenre;
  List<TrackModel> _musicTracks = [];
  List<TrackModel> get musicTracks => _musicTracks;

  // Favorites
  List<TrackModel> _favorites = [];
  List<TrackModel> get favorites => _favorites;
  List<TrackModel> get quranFavorites =>
      _favorites.where((t) => t.source == 'quran').toList();
  List<TrackModel> get musicFavorites =>
      _favorites.where((t) => t.source == 'music').toList();

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Set<String> _favoriteIds = {};

  ExplorerViewModel() {
    loadQuran();
    loadFavorites();
  }

  void setTab(ExplorerTab t) {
    _tab = t;
    if (t == ExplorerTab.favorites) loadFavorites();
    notifyListeners();
  }

  // ── QURAN ─────────────────────────────────────────────

  Future<void> loadQuran() async {
    _isLoading = true;
    notifyListeners();
    _quranTracks = await _quranService.getSourates(
      reciter: _selectedReciter,
      filterCategory: _selectedQuranCategory,
    );
    _applyFavoriteStatus(_quranTracks);
    _isLoading = false;
    notifyListeners();
  }

  void setReciter(String reciter) {
    _selectedReciter = reciter;
    loadQuran();
  }

  void setQuranCategory(String? category) {
    _selectedQuranCategory = category;
    loadQuran();
  }

  // ── MUSIC ─────────────────────────────────────────────

  Future<void> loadMusic({String? genre}) async {
    _isLoading = true;
    notifyListeners();
    _selectedGenre = genre ?? _selectedGenre;
    _musicTracks = await _deezerService.getTracksByGenre(_selectedGenre);
    _applyFavoriteStatus(_musicTracks);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      if (_tab == ExplorerTab.music) loadMusic();
      return;
    }
    _isLoading = true;
    notifyListeners();
    if (_tab == ExplorerTab.quran) {
      _quranTracks = (await _quranService.getSourates(reciter: _selectedReciter))
          .where((t) =>
              t.title.toLowerCase().contains(query.toLowerCase()) ||
              t.artist.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      _musicTracks = await _deezerService.search(query);
      _applyFavoriteStatus(_musicTracks);
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── FAVORITES ─────────────────────────────────────────

  Future<void> loadFavorites() async {
    _favorites = await _firestoreService.getFavorites();
    _favoriteIds = _favorites.map((t) => t.id).toSet();
    _applyFavoriteStatus(_quranTracks);
    _applyFavoriteStatus(_musicTracks);
    notifyListeners();
  }

  Future<void> toggleFavorite(TrackModel track) async {
    if (_favoriteIds.contains(track.id)) {
      await _firestoreService.removeFavorite(track.id);
      _favoriteIds.remove(track.id);
      track.isFavorite = false;
      _favorites.removeWhere((t) => t.id == track.id);
    } else {
      await _firestoreService.addFavorite(track);
      _favoriteIds.add(track.id);
      track.isFavorite = true;
      _favorites.add(track);
    }
    notifyListeners();
  }

  // Suppression avec confirmation empreinte (appelée par la vue)
  Future<void> removeFavoriteWithBiometric(
      TrackModel track, Future<bool> Function() biometricAuth) async {
    final confirmed = await biometricAuth();
    if (!confirmed) return;
    await _firestoreService.removeFavorite(track.id);
    _favoriteIds.remove(track.id);
    track.isFavorite = false;
    _favorites.removeWhere((t) => t.id == track.id);
    notifyListeners();
  }

  void _applyFavoriteStatus(List<TrackModel> tracks) {
    for (final t in tracks) {
      t.isFavorite = _favoriteIds.contains(t.id);
    }
  }
}