
class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;
  final int durationSeconds;
  final String category; // 'Courtes' | 'Moyennes' | 'Longues' | genre Deezer
  final String source;   // 'quran' | 'music'
  bool isFavorite;

  TrackModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.audioUrl,
    required this.imageUrl,
    required this.durationSeconds,
    required this.category,
    required this.source,
    this.isFavorite = false,
  });

  String get durationFormatted {
    final m = durationSeconds ~/ 60;
    final s = durationSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  // For saving to Firestore (favorites)
  Map<String, dynamic> toFavoriteMap() => {
    'trackId': id,
    'trackTitle': title,
    'artist': artist,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'durationSeconds': durationSeconds,
    'category': category,
    'source': source,
    'addedAt': DateTime.now().millisecondsSinceEpoch, // ← no more Timestamp
  };

  // For saving to Firestore (listening history)
  Map<String, dynamic> toHistoryMap() => {
    'trackId': id,
    'trackTitle': title,
    'artist': artist,
    'durationSeconds': durationSeconds,
    'playedAt': DateTime.now().millisecondsSinceEpoch, // ← no more Timestamp
    'source': source,
    'category': category,
  };
  factory TrackModel.fromFavoriteMap(Map<String, dynamic> map) => TrackModel(
    id: map['trackId'] ?? '',
    title: map['trackTitle'] ?? '',
    artist: map['artist'] ?? '',
    audioUrl: map['audioUrl'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    durationSeconds: map['durationSeconds'] ?? 0,
    category: map['category'] ?? '',
    source: map['source'] ?? '',
    isFavorite: true,
  );

  // From Deezer API JSON
  factory TrackModel.fromDeezer(Map<String, dynamic> json) => TrackModel(
    id: 'deezer_${json['id']}',
    title: json['title'] ?? '',
    artist: json['artist']?['name'] ?? '',
    audioUrl: json['preview'] ?? '',
    imageUrl: json['album']?['cover_medium'] ?? '',
    durationSeconds: json['duration'] ?? 0,
    category: 'music',
    source: 'music',
  );

  // From Quran API JSON
  factory TrackModel.fromQuran({
    required Map<String, dynamic> json,
    required String category,
    required String reciterImageUrl,
  }) =>
      TrackModel(
        id: 'quran_${json['id']}',
        title: json['name'] ?? json['transliteration'] ?? '',
        artist: json['reciter'] ?? 'Al-Sudais',
        audioUrl: json['audio'] ?? '',
        imageUrl: reciterImageUrl,
        durationSeconds: json['totalSeconds'] ?? 0,
        category: category,
        source: 'quran',
      );
}