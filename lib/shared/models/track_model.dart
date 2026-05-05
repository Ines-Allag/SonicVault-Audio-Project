class TrackModel {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final String imageUrl;
  final int durationSeconds;
  final String category;
  final String source;
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

  Map<String, dynamic> toMap() => {
    'trackId': id,
    'trackTitle': title,
    'artist': artist,
    'audioUrl': audioUrl,
    'imageUrl': imageUrl,
    'durationSeconds': durationSeconds,
    'category': category,
    'source': source,
    'isFavorite': isFavorite,
  };

  factory TrackModel.fromMap(Map<String, dynamic> map) => TrackModel(
    id: map['trackId'] ?? '',
    title: map['trackTitle'] ?? '',
    artist: map['artist'] ?? '',
    audioUrl: map['audioUrl'] ?? '',
    imageUrl: map['imageUrl'] ?? '',
    durationSeconds: map['durationSeconds'] ?? 0,
    category: map['category'] ?? '',
    source: map['source'] ?? '',
    isFavorite: map['isFavorite'] ?? false,
  );
}