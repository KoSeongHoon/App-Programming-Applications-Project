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
  Future<Map<String, dynamic>?> getCharacterInfo(String characterId, String serverId);
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
      if (isGuildSearch) {
        // ===== 모험단 검색: 로컬 DB에서만 검색 =====
        return await _searchGuildFromLocalDb(name);
      } else {
        // ===== 일반 캐릭터 검색: API에서 검색 + 기본정보 조회 =====
        final serverId = _convertServerNameToId(server);
        final apiResults = await _apiClient.searchCharacter(name, serverId, false);

        if (apiResults == null || apiResults.isEmpty) return [];

        final characters = <Character>[];

        for (final apiResult in apiResults) {
          try {
            // 서버 필터링: 선택한 서버와 일치하는 캐릭터만 추가
            if (server != '전체') {
              final apiServerId = apiResult['serverId'] as String? ?? '';
              final selectedServerId = _convertServerNameToId(server);
              if (apiServerId.toLowerCase() != selectedServerId.toLowerCase()) {
                continue;
              }
            }

            // 기본 Character 객체 생성
            var character = _convertApiResultToCharacter(apiResult, server);
            if (character == null) continue;

            // 캐릭터 기본정보 조회 (adventureName 포함)
            final characterId = apiResult['characterId'] as String? ?? '';
            final characterServerId = apiResult['serverId'] as String? ?? 'pve-1';

            final info = await _apiClient.getCharacterInfo(characterId, characterServerId).timeout(
              const Duration(seconds: 3),
              onTimeout: () => null,
            );

            if (info != null) {
              final adventureName = info['adventureName'] as String?;

              // adventureName을 포함한 새로운 Character 객체 생성
              character = Character(
                id: character.id,
                characterId: character.characterId,
                name: character.name,
                server: character.server,
                serverId: character.serverId,
                class_: character.class_,
                level: character.level,
                imageUrl: character.imageUrl,
                createdAt: character.createdAt,
                adventureName: adventureName,
                timeline: character.timeline,
              );
            }

            characters.add(character);
          } catch (e) {
            print('캐릭터 정보 조회 실패: $e');
            continue;
          }
        }

        return characters;
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 로컬 DB에서 모험단명으로 검색
  Future<List<Character>> _searchGuildFromLocalDb(String guildName) async {
    try {
      final db = _databaseService.database;
      final maps = await db.query(
        'Character',
        where: 'adventureName = ?',
        whereArgs: [guildName],
      );

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
              adventureName: map['adventureName'] as String?,
            );
          })
          .toList();
    } catch (e) {
      print('로컬 DB 모험단 검색 오류: $e');
      return [];
    }
  }

  /// API 응답을 Character 엔티티로 변환 (공통 메소드)
  Character? _convertApiResultToCharacter(
    Map<String, dynamic> apiResult,
    String? serverName, [
    String? adventureName,
  ]) {
    try {
      final characterId = apiResult['characterId'] as String? ?? '';
      final characterServerId = apiResult['serverId'] as String? ?? 'pve-1';
      final imageUrl =
          'https://img-api.neople.co.kr/df/servers/$characterServerId/characters/$characterId?zoom=1';

      final className = apiResult['characterClass'] ??
          apiResult['jobName'] ??
          apiResult['characterJob'] ??
          apiResult['job'] ??
          '알 수 없음';

      final finalServerName = serverName ?? _getServerName(characterServerId);

      return Character(
        id: 0,
        characterId: characterId,
        name: apiResult['characterName'] ?? '',
        server: finalServerName,
        serverId: characterServerId,
        class_: className.toString(),
        level: (apiResult['level'] as num?)?.toInt() ?? 0,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
        adventureName: adventureName,
      );
    } catch (e) {
      print('캐릭터 변환 오류: $e');
      return null;
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
              adventureName: map['adventureName'] as String?,
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
          'adventureName': character.adventureName,
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

  /// 캐릭터 기본정보 조회 (adventureName 포함)
  @override
  Future<Map<String, dynamic>?> getCharacterInfo(
    String characterId,
    String serverId,
  ) async {
    try {
      return await _apiClient.getCharacterInfo(characterId, serverId);
    } catch (e) {
      print('캐릭터 정보 조회 오류: $e');
      return null;
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
