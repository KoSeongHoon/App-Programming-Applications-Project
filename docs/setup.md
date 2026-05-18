# SETUP.md — 개발 환경 구축 가이드

던전앤파이터 플래너 앱 개발을 위한 환경 구축 단계입니다.

---

## 📋 요구사항

### 개발 환경 (필수)
- **Flutter**: 3.41.9 이상
- **Dart**: 3.11.5 이상
- **Java**: OpenJDK 11 이상 (Android 개발)
- **Android SDK**: API Level 21 이상 (Android 5.0+)
- **Git**: 2.20 이상

### 개발 도구 (권장)
- **IDE**: VS Code 또는 Android Studio
- **Editor Extensions**:
  - Flutter (ID: Dart-Code.flutter)
  - Dart (ID: Dart-Code.dart-code)
  - Riverpod (ID: rrousselGit.riverpod_generator)

---

## ✅ 1단계: Flutter & Dart 설치 확인

```bash
# 버전 확인
flutter --version
dart --version

# 개발 환경 진단
flutter doctor -v
```

**예상 출력:**
```
✓ Flutter (Channel stable, 3.41.9)
✓ Dart version 3.11.5
✓ Android toolchain (Android SDK 36.1.0)
✓ Chrome (Web development)
✓ Connected device (3 available)
```

---

## 📦 2단계: 프로젝트 의존성 설치

```bash
# 프로젝트 디렉토리로 이동
cd planner_app

# 의존성 설치
flutter pub get

# (옵션) 최신 버전 확인
flutter pub outdated
```

**생성되는 것:**
- `pubspec.lock`: 정확한 버전 고정
- `.dart_tool/`: 빌드 캐시

---

## 🔨 3단계: 프로젝트 구조 확인

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 루트 위젯
├── presentation/
│   ├── screens/
│   │   ├── character_search_screen.dart
│   │   ├── planner_screen.dart
│   │   └── timeline_screen.dart
│   └── widgets/
├── application/
│   ├── view_models/
│   └── providers.dart          # Riverpod 선언
├── domain/
│   ├── entities/
│   ├── services/
│   └── use_cases/
├── data/
│   ├── repositories/
│   ├── data_sources/
│   └── models/
└── config/
    ├── constants.dart
    ├── theme.dart
    └── routes.dart
```

---

## 🚀 4단계: 빌드 & 실행

### Android 에뮬레이터 (권장)
```bash
# 에뮬레이터 시작 (Android Studio에서)
# Tools > Device Manager > 기존 에뮬레이터 실행

# 또는 명령줄에서
flutter emulators
flutter emulators launch [device_id]

# 앱 실행
flutter run

# 특정 에뮬레이터에서 실행
flutter run -d [device_id]
```

### 물리 기기 (Android)
```bash
# USB 디버깅 활성화 (설정 > 개발자 옵션)
# 기기를 컴퓨터에 USB 연결

# 연결된 기기 확인
flutter devices

# 앱 실행
flutter run
```

### 웹 브라우저
```bash
# Chrome에서 실행
flutter run -d chrome

# Firefox에서 실행
flutter run -d firefox
```

### Release 빌드 (배포용)
```bash
# Android APK 생성
flutter build apk

# APK 위치
build/app/outputs/apk/release/app-release.apk
```

---

## 🔍 5단계: 코드 검증

### Dart 코드 분석
```bash
flutter analyze
```

### 포맷팅
```bash
flutter format lib/
```

### 린트 규칙 확인
```bash
flutter analyze --no-pub-warnings
```

---

## 🧪 6단계: 테스트 실행

### 단위 테스트
```bash
flutter test
```

### 통합 테스트
```bash
flutter drive --target=test_driver/app.dart
```

### 커버리지 리포트
```bash
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## 📱 7단계: 개발 워크플로우

### 핫 리로드 (코드 변경 후 자동 반영)
```bash
# 앱 실행 후
# 수정 → Ctrl+S (또는 r 키 입력)
```

### 핫 재시작 (상태 초기화)
```bash
# 앱 실행 후
# R 키 입력 (상태 초기화 후 재시작)
```

### 디버그 정보 출력
```dart
print('DEBUG: $variable');
debugPrint('Label: $value');
```

---

## 🐛 트러블슈팅

### 1. "flutter: command not found"
```bash
# Flutter 경로 확인
which flutter

# PATH에 추가 (Unix/Mac)
export PATH="$PATH:$HOME/flutter/bin"

# PATH에 추가 (Windows PowerShell)
$env:Path += ";C:\flutter\bin"
```

### 2. "Gradle build failed"
```bash
# Gradle 캐시 삭제
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### 3. "CocoaPods" 에러 (iOS)
```bash
cd ios
pod install --repo-update
cd ..
```

### 4. "Android license not accepted"
```bash
flutter doctor --android-licenses
```

### 5. 에뮬레이터가 느린 경우
```bash
# GPU 가속화 활성화 (Android Studio)
# Settings > SDK Manager > SDK Tools
# ☑ Android Emulator > Apply
```

---

## 📚 학습 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Dart 가이드](https://dart.dev/guides)
- [Riverpod 문서](https://riverpod.dev/)
- [sqflite 예제](https://pub.dev/packages/sqflite)

---

## ✅ 개발 체크리스트

- [ ] Flutter 3.41.9+ 설치
- [ ] Dart 3.11.5+ 설치
- [ ] `flutter doctor` 모두 통과
- [ ] `flutter pub get` 완료
- [ ] `flutter analyze` 통과
- [ ] 웹 빌드 성공 (`flutter build web`)
- [ ] 에뮬레이터 또는 기기 준비
- [ ] `flutter run` 성공

---

**문서 작성일**: 2026-05-18  
**Flutter 버전**: 3.41.9  
**Dart 버전**: 3.11.5
