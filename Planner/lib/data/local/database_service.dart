import 'package:sqflite/sqflite.dart';
import 'dart:io';

class DatabaseService {
  static const String dbName = 'planner.db';
  static const int dbVersion = 1;

  late Database _database;

  Future<void> initialize() async {
    final dbPath = await getDatabasesPath();
    final fullPath = '$dbPath${Platform.pathSeparator}$dbName';

    _database = await openDatabase(
      fullPath,
      version: dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE Character (
            id INTEGER PRIMARY KEY,
            characterId TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            server TEXT NOT NULL,
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
