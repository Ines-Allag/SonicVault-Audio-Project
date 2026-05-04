import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sonic_vault/shared/models/track_model.dart';
import 'package:sonic_vault/core/services/audio_firestore_service.dart';

enum RepeatMode { none, one, all }

class PlayerViewModel extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  final AudioFirestoreService _firestoreService = AudioFirestoreService();

  TrackModel? _currentTrack;
  TrackModel? get currentTrack => _currentTrack;

  List<TrackModel> _queue = [];
  List<TrackModel> get queue => _queue;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  RepeatMode _repeatMode = RepeatMode.none;
  RepeatMode get repeatMode => _repeatMode;

  bool _isShuffle = false;
  bool get isShuffle => _isShuffle;

  double get progress {
    if (_duration.inMilliseconds == 0) return 0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  String get positionFormatted => _formatDuration(_position);
  String get durationFormatted => _formatDuration(_duration);

  PlayerViewModel() {
    _player.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      // Sauvegarde historique quand le morceau se termine
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
      notifyListeners();
    });
  }

  Future<void> playTrack(TrackModel track, {List<TrackModel>? queue}) async {
    _currentTrack = track;
    if (queue != null) _queue = queue;
    notifyListeners();

    try {
      await _player.setUrl(track.audioUrl);
      await _player.play();
    } catch (e) {
      debugPrint('Player error: $e');
    }
  }

  Future<void> togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seekTo(double value) async {
    final ms = (value * _duration.inMilliseconds).round();
    await _player.seek(Duration(milliseconds: ms));
  }

  Future<void> skipNext() async {
    if (_queue.isEmpty || _currentTrack == null) return;
    final idx = _queue.indexWhere((t) => t.id == _currentTrack!.id);
    if (idx < _queue.length - 1) {
      await playTrack(_queue[idx + 1], queue: _queue);
    }
  }

  Future<void> skipPrevious() async {
    if (_queue.isEmpty || _currentTrack == null) return;
    // Si on est à plus de 3s, on revient au début du morceau
    if (_position.inSeconds > 3) {
      await _player.seek(Duration.zero);
      return;
    }
    final idx = _queue.indexWhere((t) => t.id == _currentTrack!.id);
    if (idx > 0) {
      await playTrack(_queue[idx - 1], queue: _queue);
    }
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  Future<void> _onTrackCompleted() async {
    if (_currentTrack != null) {
      await _firestoreService.saveToHistory(_currentTrack!);
    }
    if (_repeatMode == RepeatMode.one) {
      await _player.seek(Duration.zero);
      await _player.play();
    } else if (_repeatMode == RepeatMode.all || _isShuffle) {
      await skipNext();
    }
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}