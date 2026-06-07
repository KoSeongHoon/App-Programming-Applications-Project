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

  /// 타임라인 조회 (일주일치, next 파라미터로 반복)
  /// /df/servers/{serverId}/characters/{characterId}/timeline 엔드포인트 사용
  Future<List<Map<String, dynamic>>> getCharacterTimeline(
    String characterId,
    String serverId,
  ) async {
    final allRows = <Map<String, dynamic>>[];
    String? nextToken;

    try {
      // 주간 범위 계산 알고리즘
      // 조회 날짜 기준: 전 목요일(startDate) ~ 현재 날짜(endDate)
      // 이렇게 하면 항상 존재하는 데이터만 조회 가능 (미래 데이터 조회 안 함)
      final now = DateTime.now();

      // 1단계: 지난 목요일 계산
      // weekday: 1=월, 2=화, 3=수, 4=목, 5=금, 6=토, 7=일
      // 금요일(5) 이상: weekday - 4일 전이 목요일
      // 목요일(4) 이하: weekday + 3일 전이 목요일
      final daysToLastThursday = now.weekday > 4 ? now.weekday - 4 : now.weekday + 3;
      final startDate = now.subtract(Duration(days: daysToLastThursday)); // 전 목요일

      // 2단계: endDate는 현재 날짜 (항상 존재하는 데이터)
      final endDate = now; // 현재 날짜

      // 3단계: API 형식으로 변환 (yyyyMMddTHHmm)
      // API 문서 예시: 20180901T0000, 20180930T2359
      // 초 단위는 자동 처리됨: startDate는 00초, endDate는 59초로 처리됨 (API 문서)
      String _formatDateForAPI(DateTime date, {bool isEnd = false}) {
        final year = date.year.toString().padLeft(4, '0');
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');

        if (isEnd) {
          // endDate: 현재 시간의 정각 분 (00분) - 미래 데이터 제외
          final hour = date.hour.toString().padLeft(2, '0');
          final minute = '00';
          return '${year}${month}${day}T${hour}${minute}';
        } else {
          // startDate: 00:00
          return '${year}${month}${day}T0000';
        }
      }

      final startDateStr = _formatDateForAPI(startDate, isEnd: false);
      final endDateStr = _formatDateForAPI(endDate, isEnd: true);

      print('[DF 타임라인 API] ========== 타임라인 조회 시작 ==========');
      print('[DF 타임라인 API] 조회 날짜: $startDate ~ $endDate');
      print('[DF 타임라인 API] 포맷된 날짜: $startDateStr ~ $endDateStr');
      print('[DF 타임라인 API] (${startDate.month}월 ${startDate.day}일 ~ ${endDate.month}월 ${endDate.day}일)');

      do {
        // 4단계: API 파라미터 구성
        final params = {
          'apikey': apiKey,
          'limit': '100',
          'startDate': startDateStr,
          'endDate': endDateStr,
          'code': '201,202,203,204,205,206,207,208,209,210',
        };

        if (nextToken != null) {
          params['next'] = nextToken;
        }

        final url = Uri.https(
          'api.neople.co.kr',
          '/df/servers/$serverId/characters/$characterId/timeline',
          params,
        );

        print('[DF 타임라인 API] 📍 요청 URL: $url');
        print('[DF 타임라인 API] 📍 파라미터: startDate=$startDateStr, endDate=$endDateStr, code=201,202,...,210');
        print('[DF 타임라인 API] 📍 현재까지 수집: ${allRows.length}개');

        final response = await _httpClient.get(url);

        print('[DF 타임라인 API] ✅ 상태코드: ${response.statusCode}');

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
