import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sonic_vault/shared/models/track_model.dart';

class DeezerService {
  static const String _baseUrl = 'https://api.deezer.com';

  // Genres Deezer avec leurs IDs officiels
  static const Map<String, int> genres = {
    'Pop': 132,
    'Rap': 116,
    'R&B': 165,
    'Rock': 152,
    'Electro': 106,
    'Nasheed': 169, // Islamic / World
  };

  // Recherche de tracks par genre
  Future<List<TrackModel>> getTracksByGenre(String genreName) async {
    try {
      // On cherche via le chart du genre
      final int? genreId = genres[genreName];
      final String url = genreId != null
          ? '$_baseUrl/chart/$genreId/tracks'
          : '$_baseUrl/search?q=$genreName&limit=20';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['data'] ?? [];

      return items
          .map((item) => TrackModel.fromDeezer(item)
            ..isFavorite = false)
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Recherche libre
  Future<List<TrackModel>> search(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search?q=${Uri.encodeComponent(query)}&limit=20'),
      );
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['data'] ?? [];

      return items.map((item) => TrackModel.fromDeezer(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Top tracks tendances
  Future<List<TrackModel>> getTrending() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/chart/0/tracks'));
      if (response.statusCode != 200) return [];

      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> items = data['data'] ?? [];

      return items.take(20).map((item) => TrackModel.fromDeezer(item)).toList();
    } catch (e) {
      return [];
    }
  }
}