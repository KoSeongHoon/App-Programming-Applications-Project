import 'package:http/http.dart' as http;
import 'dart:convert';

class NeopleApiClient {
  static const String baseUrl = 'https://api.neople.co.kr';
  final String apiKey;
  late final http.Client _httpClient;

  NeopleApiClient({required this.apiKey}) {
    _httpClient = http.Client();
  }

  /// 캐릭터/모험단 검색 (여러 결과 반환)
  Future<List<Map<String, dynamic>>?> searchCharacter(
    String name,
    String serverId,
    bool isGuildSearch,
  ) async {
    try {
      // serverId 기본값: "all" (전체 서버)
      final finalServerId = serverId == '전체' ? 'all' : serverId;

      // 캐릭터 검색 엔드포인트
      const endpoint = '/df/servers/{serverId}/characters';
      final finalEndpoint = endpoint.replaceFirst('{serverId}', finalServerId);

      // 모험단 검색일 때: 와일드카드 * 사용 (모든 캐릭터 조회)
      // 일반 검색일 때: 입력된 이름으로 검색
      final searchName = isGuildSearch ? '*' : name;
      final wordType = isGuildSearch ? 'partial' : 'match';
      final limit = '100';

      final url = Uri.https(
        'api.neople.co.kr',
        finalEndpoint,
        {
          'characterName': searchName,
          'limit': limit,
          'wordType': wordType,
          'apikey': apiKey,
        },
      );

      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rows = data['rows'] as List?;
        if (rows != null && rows.isNotEmpty) {
          return rows.cast<Map<String, dynamic>>();
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

      print('[타임라인 API] URL: $url');
      print('[타임라인 API] characterId: $characterId');

      final response = await _httpClient.get(url);

      print('[타임라인 API] 상태코드: ${response.statusCode}');
      print('[타임라인 API] 응답 길이: ${response.body.length}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('[타임라인 API] 파싱된 데이터: $data');
        final rows = data['rows'] as List?;
        print('[타임라인 API] rows 개수: ${rows?.length ?? 0}');
        return (rows ?? []).cast<Map<String, dynamic>>();
      }
      print('[타임라인 API] 오류: 상태코드 ${response.statusCode}');
      print('[타임라인 API] 응답 본문: ${response.body}');
      return [];
    } catch (e) {
      print('[타임라인 API] 예외: $e');
      rethrow;
    }
  }

  /// 캐릭터 정보 조회 (adventureName 포함)
  Future<Map<String, dynamic>?> getCharacterInfo(
    String characterId,
    String serverId,
  ) async {
    try {
      final url = Uri.https(
        'api.neople.co.kr',
        '/df/servers/$serverId/characters/$characterId/timeline',
        {'apikey': apiKey, 'limit': '1'},
      );

      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        // adventureName을 포함한 전체 응답 반환
        return {
          'adventureName': data['adventureName'],
          'characterName': data['characterName'],
          'serverId': data['serverId'],
        };
      }
      return null;
    } catch (e) {
      return null; // 예외 발생 시 null 반환
    }
  }

  /// 타임라인 조회 (모든 데이터, next 파라미터로 반복)
  /// /df/servers/{serverId}/characters/{characterId}/timeline 엔드포인트 사용
  Future<List<Map<String, dynamic>>> getCharacterTimeline(
    String characterId,
    String serverId,
  ) async {
    final allRows = <Map<String, dynamic>>[];
    String? nextToken;

    try {
      do {
        final params = {
          'apikey': apiKey,
          'limit': '100', // 최대 100개씩
        };

        if (nextToken != null) {
          params['next'] = nextToken;
        }

        final url = Uri.https(
          'api.neople.co.kr',
          '/df/servers/$serverId/characters/$characterId/timeline',
          params,
        );

        print('[DF 타임라인 API] URL: $url');
        print('[DF 타임라인 API] 현재까지 수집된 행: ${allRows.length}');

        final response = await _httpClient.get(url);

        print('[DF 타임라인 API] 상태코드: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          // timeline.rows에서 실제 데이터 추출
          final timelineObj = data['timeline'] as Map<String, dynamic>?;
          if (timelineObj == null) {
            print('[DF 타임라인 API] timeline이 null입니다!');
            break;
          }

          final rows = timelineObj['rows'] as List?;
          if (rows == null || rows.isEmpty) {
            print('[DF 타임라인 API] 이번 호출에서 rows가 비어있습니다');
            break;
          }

          allRows.addAll(rows.cast<Map<String, dynamic>>());
          print('[DF 타임라인 API] 이번 호출: ${rows.length}개 추가, 총: ${allRows.length}개');

          // 다음 페이지 토큰 확인
          nextToken = timelineObj['next'] as String?;
          if (nextToken == null) {
            print('[DF 타임라인 API] 모든 데이터 수집 완료');
            break;
          }

          print('[DF 타임라인 API] 다음 페이지 있음, 계속 호출...');
        } else {
          print('[DF 타임라인 API] 오류: 상태코드 ${response.statusCode}');
          break;
        }
      } while (nextToken != null);

      print('[DF 타임라인 API] 최종 수집된 행: ${allRows.length}개');
      return allRows;
    } catch (e) {
      print('[DF 타임라인 API] 예외: $e');
      rethrow;
    }
  }

  void close() {
    _httpClient.close();
  }
}
