import 'package:sqflite/sqflite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/content_timeline.dart';
import '../../domain/utils/content_utils.dart';
import '../api/neople_api_client.dart';
import '../local/database_service.dart';

abstract class CharacterRepository {
  Future<List<Character>> searchCharacter(
    String name,
    String server, {
    bool isGuildSearch = false,
  });
  Future<List<Character>> getAllCharacters();
  Future<void> saveCharacter(Character character);
  Future<void> deleteCharacter(String characterId);
  Future<ContentTimeline> parseContentTimeline(Character character);
}

class CharacterRepositoryImpl implements CharacterRepository {
  final NeopleApiClient _apiClient;
  final DatabaseService _databaseService;

  CharacterRepositoryImpl({
    NeopleApiClient? apiClient,
    DatabaseService? databaseService,
  })  : _apiClient = apiClient ?? NeopleApiClient(apiKey: dotenv.env['NEOPLE_API_KEY'] ?? ''),
        _databaseService = databaseService ?? DatabaseService();

  @override
  Future<List<Character>> searchCharacter(
    String name,
    String server, {
    bool isGuildSearch = false,
  }) async {
    try {
      // 서버명을 serverId로 변환
      final serverId = _convertServerNameToId(server);

      // API에서 캐릭터/모험단 검색
      final apiResults =
          await _apiClient.searchCharacter(name, serverId, isGuildSearch);

      if (apiResults == null || apiResults.isEmpty) return [];

      // 모든 결과를 Character로 변환
      final characters = <Character>[];

      for (final apiResult in apiResults) {
        // 서버 필터링: 선택한 서버와 일치하는 캐릭터만 추가
        if (server != '전체') {
          final apiServerId = apiResult['serverId'] as String? ?? '';
          final selectedServerId = _convertServerNameToId(server);
          if (apiServerId.toLowerCase() != selectedServerId.toLowerCase()) {
            // 서버가 일치하지 않으면 스킵
            continue;
          }
        }

        // API 응답에서 서버 정보 추출
        String serverName = server;
        String imageServerId = 'pve-1'; // 기본값: 온라인 1서

        if (apiResult.containsKey('serverId')) {
          final apiServerId = apiResult['serverId'] as String?;
          if (apiServerId != null) {
            serverName = _getServerName(apiServerId);
            imageServerId = apiServerId;
          }
        } else if (apiResult.containsKey('server')) {
          serverName = apiResult['server'] as String? ?? server;
        }

        // API 응답을 Character 엔티티로 변환
        final characterId = apiResult['characterId'] as String? ?? '';
        final imageUrl =
            'https://img-api.neople.co.kr/df/servers/$imageServerId/characters/$characterId?zoom=1';

        // 클래스명 추출 (여러 필드명 시도)
        final className = apiResult['characterClass'] ??
            apiResult['jobName'] ??
            apiResult['characterJob'] ??
            apiResult['job'] ??
            '알 수 없음';

        // 모험단 검색 시: characterInfo에서 추가 정보 조회
        String? adventureName;
        List<Map<String, dynamic>> timeline = [];

        if (isGuildSearch) {
          try {
            final characterServerId = apiResult['serverId'] as String? ?? 'all';

            // 캐릭터 정보 조회 (모험단 정보, 타임라인 데이터)
            final info = await _apiClient.getCharacterInfo(characterId, characterServerId).timeout(
              const Duration(seconds: 3),
              onTimeout: () => null,
            );

            if (info != null) {
              adventureName = info['adventureName'] as String?;

              // adventureName 확인 - 일치하지 않으면 스킵
              if (adventureName == null || adventureName.toLowerCase() != name.toLowerCase()) {
                continue;
              }
            } else {
              continue;
            }
          } catch (e) {
            // 캐릭터 정보 조회 실패 시 스킵
            continue;
          }
        }

        final character = Character(
          id: 0,
          characterId: characterId,
          name: apiResult['characterName'] ?? name,
          server: serverName,
          serverId: imageServerId, // 실제 서버 ID 저장 (검색 필터가 아닌)
          class_: className.toString(),
          level: (apiResult['level'] as num?)?.toInt() ?? 0,
          imageUrl: imageUrl,
          createdAt: DateTime.now(),
          adventureName: adventureName,
          timeline: timeline,
        );

        // DB에 저장하지 않음 (검색 결과만 표시, "플래너에 추가"할 때만 저장)
        characters.add(character);
      }

      return characters;
    } catch (e) {
      rethrow;
    }
  }

  /// 서버명을 serverId로 변환
  String _convertServerNameToId(String serverName) {
    switch (serverName) {
      // 특수 케이스
      case '전체':
      case '모험단':
        return 'all';

      // 온라인 서버
      case '온라인 1서':
        return 'pve-1';
      case '온라인 2서':
        return 'pve-2';
      case '온라인 3서':
        return 'pve-3';

      // Neople API 공식 서버 ID (한글명)
      case '안톤':
        return 'anton';
      case '바칼':
        return 'bakal';
      case '카인':
        return 'cain';
      case '카시야스':
        return 'casillas';
      case '디레지에':
        return 'diregie';
      case '힐더':
        return 'hilder';
      case '프레이':
        return 'prey';
      case '시로코':
        return 'siroco';

      default:
        return 'all';
    }
  }

  /// 서버 ID를 한글 서버명으로 변환
  String _getServerName(String? serverId) {
    if (serverId == null) return '알 수 없음';

    switch (serverId.toLowerCase()) {
      // ===== Neople API 공식 서버 ID =====
      case 'anton':
        return '안톤';
      case 'bakal':
        return '바칼';
      case 'cain':
        return '카인';
      case 'casillas':
        return '카시야스';
      case 'diregie':
        return '디레지에';
      case 'hilder':
        return '힐더';
      case 'prey':
        return '프레이';
      case 'siroco':
        return '시로코';

      // ===== 기타 변형 =====
      case 'all':
      case 'all-server':
      case 'allserver':
        return '전체';

      default:
        return serverId;
    }
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    try {
      final db = _databaseService.database;
      final maps = await db.query('Character');

      return maps
          .map((map) {
            final characterId = map['characterId'] as String;
            final serverId = map['serverId'] as String? ?? 'all';
            final imageUrl =
                'https://img-api.neople.co.kr/df/servers/$serverId/characters/$characterId?zoom=1';

            return Character(
              id: map['id'] as int,
              characterId: characterId,
              name: map['name'] as String,
              server: map['server'] as String,
              serverId: serverId,
              class_: map['class'] as String,
              level: map['level'] as int,
              imageUrl: imageUrl,
              createdAt: DateTime.parse(map['createdAt'] as String),
            );
          })
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> saveCharacter(Character character) async {
    try {
      final db = _databaseService.database;
      await db.insert(
        'Character',
        {
          'characterId': character.characterId,
          'name': character.name,
          'server': character.server,
          'serverId': character.serverId,
          'class': character.class_,
          'level': character.level,
          'createdAt': character.createdAt.toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteCharacter(String characterId) async {
    try {
      final db = _databaseService.database;
      await db.delete(
        'Character',
        where: 'characterId = ?',
        whereArgs: [characterId],
      );
    } catch (e) {
      rethrow;
    }
  }

  /// 타임라인에서 컨텐츠 클리어 정보 파싱
  @override
  Future<ContentTimeline> parseContentTimeline(Character character) async {
    try {
      // DF 타임라인 API 호출 (올바른 엔드포인트 사용)
      final timeline = await _apiClient
          .getCharacterTimeline(character.characterId, character.serverId)
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () => [],
          );

      // 🔍 디버깅: API 응답 출력
      print('=== 타임라인 파싱 [${character.name}] ===');
      print('응답 개수: ${timeline.length}');
      if (timeline.isNotEmpty) {
        print('첫 번째 응답: ${timeline[0]}');
        print('응답 키: ${timeline[0].keys}');
      }

      if (timeline.isEmpty) {
        print('[경고] 타임라인이 비어있습니다');
        return _createEmptyContentTimeline();
      }

      // 주간 범위 계산
      final weekRange = calculateWeeklyRange(DateTime.now());
      final startDate = weekRange['start']!;
      final endDate = weekRange['end']!;

      // 컨텐츠별 클리어 상태 추적
      final dungeonClears = <String, DungeonClear>{};
      final legionClears = <String, LegionClear>{};
      final raidClears = <String, RaidClear>{};

      // 모든 컨텐츠 초기화
      for (final dungeonName in getAllDungeons()) {
        dungeonClears[dungeonName] = DungeonClear(
          name: dungeonName,
          cleared: false,
        );
      }

      for (final legionName in getAllLegions()) {
        legionClears[legionName] = LegionClear(
          name: legionName,
          cleared: false,
        );
      }

      for (final raidName in getAllRaids()) {
        raidClears[raidName] = RaidClear(
          name: raidName,
          normalCleared: false,
          hardCleared: false,
        );
      }

      // 타임라인 레코드 파싱
      for (final record in timeline) {
        try {
          final raidName = record['raidName'] as String? ?? '';
          final dateStr = record['date'] as String? ?? '';
          final mode = record['mode'] as String? ?? 'normal';
          final isClear = record['clear'] == true;

          // 날짜 파싱
          if (dateStr.isEmpty) continue;

          DateTime clearDate;
          try {
            clearDate = DateTime.parse(dateStr);
          } catch (e) {
            continue;
          }

          // 주간 범위 체크
          if (clearDate.isBefore(startDate) || clearDate.isAfter(endDate)) {
            continue;
          }

          // ===== 상급던전 매칭 =====
          final matchedDungeon = matchDungeonName(raidName);
          if (matchedDungeon != null && dungeonClears.containsKey(matchedDungeon)) {
            if (isClear) {
              dungeonClears[matchedDungeon] = DungeonClear(
                name: matchedDungeon,
                cleared: true,
                clearedDate: clearDate,
                difficulty: mode,
              );
            }
            continue;
          }

          // ===== 레기온 매칭 =====
          final matchedLegion = matchLegionName(raidName);
          if (matchedLegion != null && legionClears.containsKey(matchedLegion)) {
            if (isClear) {
              legionClears[matchedLegion] = LegionClear(
                name: matchedLegion,
                cleared: true,
                clearedDate: clearDate,
              );
            }
            continue;
          }

          // ===== 레이드 매칭 =====
          final matchedRaid = matchRaidName(raidName);
          if (matchedRaid != null && raidClears.containsKey(matchedRaid)) {
            final isHard = mode.toLowerCase() == 'hard';

            final existing = raidClears[matchedRaid]!;
            raidClears[matchedRaid] = RaidClear(
              name: matchedRaid,
              normalCleared: isHard ? existing.normalCleared : (isClear || existing.normalCleared),
              hardCleared: isHard ? (isClear || existing.hardCleared) : existing.hardCleared,
              normalClearedDate: !isHard && isClear ? clearDate : existing.normalClearedDate,
              hardClearedDate: isHard && isClear ? clearDate : existing.hardClearedDate,
            );
            continue;
          }
        } catch (e) {
          // 개별 레코드 파싱 오류는 무시하고 계속
          continue;
        }
      }

      // ContentTimeline 반환
      return ContentTimeline(
        dungeons: dungeonClears.values.toList(),
        legions: legionClears.values.toList(),
        raids: raidClears.values.toList(),
      );
    } catch (e) {
      // 전체 실패 시 빈 timeline 반환
      return _createEmptyContentTimeline();
    }
  }

  /// 모든 컨텐츠가 미클리어 상태인 ContentTimeline 생성
  ContentTimeline _createEmptyContentTimeline() {
    final dungeons = getAllDungeons()
        .map((name) => DungeonClear(name: name, cleared: false))
        .toList();

    final legions = getAllLegions()
        .map((name) => LegionClear(name: name, cleared: false))
        .toList();

    final raids = getAllRaids()
        .map(
          (name) => RaidClear(
            name: name,
            normalCleared: false,
            hardCleared: false,
          ),
        )
        .toList();

    return ContentTimeline(
      dungeons: dungeons,
      legions: legions,
      raids: raids,
    );
  }
}
