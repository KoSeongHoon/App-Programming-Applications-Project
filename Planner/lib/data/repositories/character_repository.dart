import 'package:sqflite/sqflite.dart';
import '../../domain/entities/character.dart';
import '../api/neople_api_client.dart';
import '../local/database_service.dart';

abstract class CharacterRepository {
  Future<Character?> searchCharacter(String name, String server);
  Future<List<Character>> getAllCharacters();
  Future<void> saveCharacter(Character character);
  Future<void> deleteCharacter(String characterId);
}

class CharacterRepositoryImpl implements CharacterRepository {
  final NeopleApiClient _apiClient;
  final DatabaseService _databaseService;

  CharacterRepositoryImpl({
    NeopleApiClient? apiClient,
    DatabaseService? databaseService,
  })  : _apiClient = apiClient ?? NeopleApiClient(apiKey: ''),
        _databaseService = databaseService ?? DatabaseService();

  @override
  Future<Character?> searchCharacter(String name, String server) async {
    try {
      // API에서 캐릭터 검색
      final apiResult = await _apiClient.searchCharacter(name, server);
      if (apiResult == null) return null;

      // API 응답을 Character 엔티티로 변환
      final character = Character(
        id: 0,
        characterId: apiResult['characterId'] ?? '',
        name: apiResult['characterName'] ?? name,
        server: server,
        class_: apiResult['characterClass'] ?? 'Unknown',
        level: apiResult['level'] ?? 0,
        createdAt: DateTime.now(),
      );

      // DB에 저장
      await saveCharacter(character);

      return character;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    try {
      final db = _databaseService.database;
      final maps = await db.query('Character');

      return maps
          .map((map) => Character(
                id: map['id'] as int,
                characterId: map['characterId'] as String,
                name: map['name'] as String,
                server: map['server'] as String,
                class_: map['class'] as String,
                level: map['level'] as int,
                createdAt: DateTime.parse(map['createdAt'] as String),
              ))
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
}
