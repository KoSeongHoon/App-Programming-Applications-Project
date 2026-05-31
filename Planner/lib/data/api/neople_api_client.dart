import 'package:http/http.dart' as http;
import 'dart:convert';

class NeopleApiClient {
  static const String baseUrl = 'https://api.neople.co.kr';
  final String apiKey;
  late final http.Client _httpClient;

  NeopleApiClient({required this.apiKey}) {
    _httpClient = http.Client();
  }

  /// 캐릭터 검색
  Future<Map<String, dynamic>?> searchCharacter(
    String characterName,
    String server,
  ) async {
    try {
      final url = Uri.https(
        'api.neople.co.kr',
        '/dk/characters',
        {
          'characterName': characterName,
          'apikey': apiKey,
        },
      );
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rows = data['rows'] as List?;
        if (rows != null && rows.isNotEmpty) {
          return rows.first as Map<String, dynamic>;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  /// 타임라인 조회
  Future<List<Map<String, dynamic>>> getTimeline(String characterId) async {
    try {
      final url = Uri.https(
        'api.neople.co.kr',
        '/dk/characters/$characterId/timeline',
        {
          'apikey': apiKey,
          'limit': '100',
        },
      );
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rows = data['rows'] as List?;
        return (rows ?? []).cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  void close() {
    _httpClient.close();
  }
}
