import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseService {
  static const String dbName = 'planner.db';
  static const int dbVersion = 2;

  late Database _database;

  // 싱글톤 인스턴스
  static final DatabaseService _instance = DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final fullPath = '$dbPath${Platform.pathSeparator}$dbName';

    _database = await openDatabase(
      fullPath,
      version: dbVersion,
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // v1 → v2: serverId 칼럼 추가
          try {
            await db.execute('ALTER TABLE Character ADD COLUMN serverId TEXT DEFAULT "all"');
          } catch (e) {
            print('Migration 실패 (이미 존재할 수 있음): $e');
          }
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Character (
            id INTEGER PRIMARY KEY,
            characterId TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            server TEXT NOT NULL,
            serverId TEXT DEFAULT 'all',
            class TEXT NOT NULL,
            level INTEGER NOT NULL,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE(name, server)
          )
        ''');

        await db.execute('''
          CREATE TABLE Timeline (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            characterId TEXT NOT NULL,
            dungeonCode TEXT NOT NULL,
            dungeonName TEXT NOT NULL,
            clearedAt DATETIME NOT NULL,
            FOREIGN KEY(characterId) REFERENCES Character(characterId)
          )
        ''');

        await db.execute('''
          CREATE TABLE PlannerItem (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            characterId TEXT NOT NULL,
            contentName TEXT NOT NULL,
            isCompleted INTEGER DEFAULT 0,
            createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(characterId) REFERENCES Character(characterId)
          )
        ''');
      },
    );
  }

  Database get database => _database;

  Future<void> close() async {
    await _database.close();
  }
}
