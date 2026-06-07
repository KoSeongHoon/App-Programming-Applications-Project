import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/local/database_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드 (없으면 무시)
  try {
    await dotenv.load();
  } catch (e) {
    print('Note: .env file not found, using defaults');
  }

  // 데이터베이스 초기화
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(const PlannerApp());
}
