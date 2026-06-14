import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

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

      if (kDebugMode) {
        print('[타임라인 API] characterId: $characterId');
      }

      final response = await _httpClient.get(url);

      if (kDebugMode) {
        print('[타임라인 API] 상태코드: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rows = data['rows'] as List?;
        return (rows ?? []).cast<Map<String, dynamic>>();
      }
      if (kDebugMode) {
        print('[타임라인 API] 오류: ${response.statusCode}');
      }
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('[타임라인 API] 예외: $e');
      }
      rethrow;
    }
  }

  /// 캐릭터 정보 조회 (adventureName 포함) - 기본 캐릭터 정보 엔드포인트 사용
  Future<Map<String, dynamic>?> getCharacterInfo(
    String characterId,
    String serverId,
  ) async {
    try {
      final url = Uri.https(
        'api.neople.co.kr',
        '/df/servers/$serverId/characters/$characterId',
        {'apikey': apiKey},
      );

      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return {
          'adventureName': data['adventureName'],
          'characterName': data['characterName'],
          'serverId': data['serverId'],
        };
      }
      if (kDebugMode) {
        print('[캐릭터 정보 API] 오류: ${response.statusCode}');
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('[캐릭터 정보 API] 예외: $e');
      }
      return null;
    }
  }

  /// 타임라인 조회 (일주일치 데이터)
  /// /df/servers/{serverId}/characters/{characterId}/timeline 엔드포인트 사용
  Future<List<Map<String, dynamic>>> getCharacterTimeline(
    String characterId,
    String serverId,
  ) async {
    try {
      final allRows = <Map<String, dynamic>>[];
      String? next;
      int pageCount = 0;

      // 페이지네이션: next 토큰이 있으면 계속 가져오기
      do {
        pageCount++;
        final params = {
          'apikey': apiKey,
          'limit': '100',
        };

        if (next != null) {
          params['next'] = next;
        }

        final url = Uri.https(
          'api.neople.co.kr',
          '/df/servers/$serverId/characters/$characterId/timeline',
          params,
        );

        print('[DF 타임라인 API] 페이지 $pageCount URL: $url');

        final response = await _httpClient.get(url);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;

          final timelineObj = data['timeline'] as Map<String, dynamic>?;
          if (timelineObj == null) break;

          final rows = timelineObj['rows'] as List?;
          if (rows != null && rows.isNotEmpty) {
            allRows.addAll(rows.cast<Map<String, dynamic>>());
            print('[DF 타임라인 API] 페이지 $pageCount: ${rows.length}개 추가 (총 ${allRows.length}개)');
          }

          next = timelineObj['next'] as String?;
          if (next == null || next.isEmpty) {
            print('[DF 타임라인 API] 마지막 페이지');
            break;
          }
        } else {
          print('[DF 타임라인 API] 페이지 $pageCount 오류: ${response.statusCode}');
          break;
        }
      } while (true);

      print('[DF 타임라인 API] 최종 수집: ${allRows.length}개 데이터');
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
