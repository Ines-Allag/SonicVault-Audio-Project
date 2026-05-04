import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sonic_vault/shared/models/track_model.dart';

class QuranService {
  static const String _baseUrl = 'https://quran.yousefheiba.com/en';

  // Récitateurs et leurs images locales (dans assets/reciters/)
  static const Map<String, String> reciters = {
    'Al-Sudais': 'assets/reciters/al_sudais.jpg',
    'Al-Ghamdi': 'assets/reciters/al_ghamdi.jpg',
    'Al-Husary': 'assets/reciters/al_husary.jpg',
    'Menchawi': 'assets/reciters/menchawi.jpg',
  };

  // Durées approximatives pour classer les sourates
  static String _getCategory(int totalSeconds) {
    if (totalSeconds <= 120) return 'Courtes';
    if (totalSeconds <= 600) return 'Moyennes';
    return 'Longues';
  }

  Future<List<TrackModel>> getSourates({
    String reciter = 'Al-Sudais',
    String? filterCategory,
  }) async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode != 200) return [];

      final List<dynamic> data = jsonDecode(response.body);
      final String imageUrl = reciters[reciter] ?? reciters['Al-Sudais']!;

      final List<TrackModel> tracks = data.map((item) {
        final int duration = item['totalSeconds'] ?? 0;
        final String category = _getCategory(duration);
        return TrackModel.fromQuran(
          json: {...item, 'reciter': reciter},
          category: category,
          reciterImageUrl: imageUrl,
        );
      }).toList();

      if (filterCategory != null) {
        return tracks.where((t) => t.category == filterCategory).toList();
      }
      return tracks;
    } catch (e) {
      return [];
    }
  }
}