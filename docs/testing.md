# 테스트 작성 및 실행 가이드

테스트는 단 한 줄의 명령어로 실행됩니다. 이 문서는 어떻게 작성하고 실행하는지를 설명합니다.

---

## ⚡ 한 줄 명령어

```bash
# 모든 테스트 실행 (가장 자주 사용)
flutter test

# 특정 테스트 파일만 실행
flutter test test/services/neople_api_service_test.dart

# 커버리지 생성 (coverage 폴더에 저장)
flutter test --coverage

# 지켜보기 모드 (파일 변경 시 자동 재실행)
flutter test --watch
```

---

## 📁 테스트 파일 구조

```
test/
├── unit/                           # 단위 테스트
│   ├── services/
│   │   ├── neople_api_service_test.dart
│   │   ├── database_service_test.dart
│   │   └── cache_service_test.dart
│   ├── models/
│   │   ├── character_test.dart
│   │   └── timeline_event_test.dart
│   └── utils/
│       └── validators_test.dart
│
├── widget/                         # 위젯 테스트
│   ├── screens/
│   │   ├── character_detail_screen_test.dart
│   │   └── planner_screen_test.dart
│   └── widgets/
│       ├── character_card_test.dart
│       └── progress_bar_test.dart
│
└── integration/                    # 통합 테스트
    ├── app_test.dart
    └── character_flow_test.dart
```

---

## 🎯 테스트 작성 규칙

### **1. 단위 테스트 (Unit Test)**

비즈니스 로직 검증 (API 클라이언트, 계산 함수 등)

```dart
// test/services/neople_api_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:dungeon_planner/services/neople_api_service.dart';

void main() {
  group('NeopleApiService', () {
    late NeopleApiService service;
    late MockHttpClient mockHttpClient;

    setUp(() {
      mockHttpClient = MockHttpClient();
      service = NeopleApiService(mockHttpClient);
    });

    // Arrange → Act → Assert 패턴
    test('캐릭터 정보 조회 성공', () async {
      // Arrange (준비)
      when(mockHttpClient.get(any)).thenAnswer(
        (_) async => http.Response('{"name": "고성훈", "level": 110}', 200),
      );

      // Act (실행)
      final character = await service.getCharacter('고성훈');

      // Assert (검증)
      expect(character.name, equals('고성훈'));
      expect(character.level, equals(110));
      verify(mockHttpClient.get(any)).called(1);
    });

    test('API 오류 시 예외 발생', () async {
      // Arrange
      when(mockHttpClient.get(any))
          .thenAnswer((_) async => http.Response('Error', 500));

      // Assert
      expect(
        () => service.getCharacter('고성훈'),
        throwsException,
      );
    });
  });
}
```

**실행**:
```bash
flutter test test/unit/services/neople_api_service_test.dart
```

---

### **2. 위젯 테스트 (Widget Test)**

UI 컴포넌트 검증

```dart
// test/widget/screens/character_detail_screen_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dungeon_planner/screens/character_detail_screen.dart';

void main() {
  group('CharacterDetailScreen', () {
    testWidgets('캐릭터 정보 표시', (WidgetTester tester) async {
      // Arrange & Act (위젯 빌드)
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterDetailScreen(characterId: 'char-123'),
        ),
      );

      // Assert (위젯 검증)
      expect(find.text('고성훈'), findsOneWidget);
      expect(find.text('Lv. 110'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('새로고침 버튼 클릭', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CharacterDetailScreen(characterId: 'char-123'),
        ),
      );

      // 새로고침 버튼 찾기 및 클릭
      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();  // 로딩 대기

      // 데이터 새로고침 확인
      expect(find.text('업데이트됨'), findsOneWidget);
    });
  });
}
```

**실행**:
```bash
flutter test test/widget/screens/character_detail_screen_test.dart
```

---

### **3. 통합 테스트 (Integration Test)**

전체 앱 흐름 검증

```dart
// test/integration/character_flow_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dungeon_planner/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('캐릭터 조회 플로우', () {
    testWidgets('캐릭터 검색부터 대시보드 표시까지', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. 검색 화면 찾기
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      // 2. 캐릭터 이름 입력
      await tester.enterText(searchField, '고성훈');
      await tester.pumpAndSettle();

      // 3. 검색 버튼 클릭
      final searchButton = find.byType(FloatingActionButton);
      await tester.tap(searchButton);
      await tester.pumpAndSettle();

      // 4. 대시보드 표시 확인
      expect(find.text('고성훈'), findsWidgets);
      expect(find.text('Lv. 110'), findsOneWidget);
    });
  });
}
```

**실행**:
```bash
flutter test integration_test
```

---

## 🛠️ 테스트 유틸리티

### **Mock 객체 생성**

```dart
// 간단한 Mock 생성
class MockCharacterRepository extends Mock implements CharacterRepository {}

// 또는 Mockito 사용
void main() {
  test('테스트', () {
    final mockRepo = MockCharacterRepository();
    
    when(mockRepo.getCharacter('고성훈')).thenAnswer(
      (_) async => Character(
        id: 'char-123',
        name: '고성훈',
        level: 110,
      ),
    );
    
    // 테스트 코드...
  });
}
```

### **Widget 테스트 팁**

```dart
// 위젯 찾기
find.byType(Text)                    // 타입으로 찾기
find.byIcon(Icons.search)            // 아이콘으로 찾기
find.byKey(ValueKey('myKey'))        // Key로 찾기
find.text('원하는 텍스트')            // 텍스트로 찾기
find.byWidgetPredicate((w) => true)  // 조건으로 찾기

// 위젯 상호작용
await tester.tap(find.byType(Button));
await tester.enterText(find.byType(TextField), '입력');
await tester.drag(find.byType(ListView), Offset(0, -300));
await tester.pumpAndSettle();  // 애니메이션 완료 대기
```

---

## 📊 테스트 커버리지

### **커버리지 생성**

```bash
# 커버리지 파일 생성
flutter test --coverage

# 커버리지 리포트 보기 (macOS/Linux)
lcov --list coverage/lcov.info
open coverage/index.html

# Windows
genhtml coverage/lcov.info -o coverage/html
start coverage/html/index.html
```

### **커버리지 목표**

```
전체: > 50%
- 서비스: > 80% (핵심 로직)
- 모델: > 70%
- 위젯: > 40%
- 유틸: > 60%
```

---

## 🔄 CI/CD 통합

### **GitHub Actions**

```yaml
# .github/workflows/test.yml

name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      
      - name: Get dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v2
```

**실행**: `git push` 시 자동으로 테스트 실행

---

## 📋 테스트 체크리스트

테스트 작성 시 확인할 사항:

- [ ] 모든 함수는 단위 테스트 포함
- [ ] 중요 위젯은 위젯 테스트 포함
- [ ] 메인 플로우는 통합 테스트 포함
- [ ] Mock 객체는 실제 동작과 일치
- [ ] Arrange-Act-Assert 패턴 따름
- [ ] 테스트명은 명확하고 간결
- [ ] 테스트는 독립적이고 재현 가능
- [ ] 커버리지는 > 50% 유지

---

## 🎯 테스트 우선순위

1. **필수 (P0)**
   - API 통신
   - 데이터 저장/로드
   - 강화 계산 로직
   - 타임라인 매칭

2. **중요 (P1)**
   - 대시보드 표시
   - 플래너 기능
   - 에러 처리

3. **선택 (P2)**
   - 캐싱 로직
   - UI 세부 사항

---

## 🐛 테스트 디버깅

### **테스트 실패 시**

```bash
# 자세한 출력
flutter test -v

# 특정 테스트만 실행
flutter test -k "캐릭터 정보"

# 지켜보기 모드
flutter test --watch

# 디버거 연결
flutter test --start-paused
```

### **일반적인 오류**

```dart
// ❌ MissingStubError: No stub found
// 해결: Mock 객체에 when() 설정

// ❌ StateError: setState() called after dispose()
// 해결: pumpAndSettle() 사용

// ❌ TimeoutException
// 해결: pump(Duration) 증가
```

---

## 📚 참고 자료

| 주제 | 링크 |
|------|------|
| Flutter 테스트 공식 | https://flutter.dev/docs/testing |
| Mockito | https://pub.dev/packages/mockito |
| Riverpod 테스트 | https://riverpod.dev/docs/essentials/testing |
| 테스트 작성 팁 | https://codewithandrea.com/articles/flutter-state-management-riverpod/ |

---

## 💡 빠른 참조

```bash
# 모든 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/services/api_test.dart

# 특정 테스트만 실행
flutter test -k "캐릭터"

# 커버리지 생성
flutter test --coverage

# 지켜보기 모드
flutter test --watch

# 상세 로그
flutter test -v

# 통합 테스트
flutter test integration_test
```

---

**마지막 업데이트**: 2026-05-04  
**문서 버전**: 1.0
