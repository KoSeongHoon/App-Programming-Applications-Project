import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'data/local/database_service.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env 파일 로드
  await dotenv.load();

  // 데이터베이스 초기화
  final databaseService = DatabaseService();
  await databaseService.initialize();

  runApp(const PlannerApp());
}
