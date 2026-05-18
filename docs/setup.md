# SETUP.md — 개발 환경 구축 가이드

던전앤파이터 플래너 앱 개발을 위한 환경 구축 단계입니다.

> **⏱️ 5분 빠른 시작**: 아래 "🚀 5분 안에 시작하기" 섹션을 따라하세요.

---

## 🚀 5분 안에 시작하기

**새 개발자도 이 문서만 보고 5분 안에 실행할 수 있습니다.**

### Step 1: 저장소 클론
```bash
# 프로젝트 저장소 클론
git clone https://github.com/YOUR_USERNAME/dungeon-fighter-planner.git
cd dungeon-fighter-planner

# 또는 로컬 경로에서
cd App-Programming-Applications-Project
```

### Step 2: 의존성 설치
```bash
flutter pub get
```

### Step 3: 환경 변수 설정

**Windows (PowerShell):**
```powershell
# .env.example을 .env로 복사
Copy-Item .env.example .env

# .env 파일을 메모장으로 열기
notepad .env
# 또는 VS Code
code .env
```

**macOS/Linux (Terminal):**
```bash
# .env.example을 .env로 복사
cp .env.example .env

# .env 파일 수정 (nano 에디터)
nano .env
# 또는 vi
vi .env
# 또는 VS Code
code .env
```

> **참고**: NEOPLE_API_KEY=your_api_key_here 부분에 실제 API 키를 입력하세요.

### Step 4: 빌드 & 실행

**옵션 A: 웹 브라우저에서 테스트 (가장 빠름, 모든 OS)**
```bash
# Chrome에서 실행
flutter run -d chrome

# Firefox에서 실행
firefox run -d firefox
```

**옵션 B: Android 에뮬레이터에서 실행**

**Windows:**
```powershell
# 에뮬레이터 확인
flutter emulators

# 에뮬레이터 시작 (또는 Android Studio에서 시작)
flutter emulators --launch Pixel_6_API_36

# 앱 실행
flutter run
```

**macOS:**
```bash
# 에뮬레이터 확인
flutter emulators

# iOS 시뮬레이터에서 실행하기 (iOS는 Mac에서만 가능)
open -a Simulator

# 앱 실행
flutter run
```

**Linux:**
```bash
# Android 에뮬레이터 실행
flutter emulators --launch Pixel_6_API_36

# 앱 실행
flutter run
```

✅ **완료!** 앱이 실행되고 검색 화면이 나타나면 준비 완료입니다.

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

4-Layer Clean Architecture 구조:

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 루트 위젯 (MaterialApp)
│
├── presentation/                # 🎨 UI 계층
│   ├── screens/                 # 화면 (CharacterSearchScreen, PlannerScreen 등)
│   ├── widgets/                 # 재사용 위젯 (CharacterCard, SearchForm 등)
│   └── theme/                   # 테마 (colors.dart, app_theme.dart)
│
├── application/                 # 🔄 상태 관리 계층
│   ├── view_models/             # ViewModel (CharacterSearchVM, PlannerVM 등)
│   └── use_cases/               # UseCase (SearchCharacterUC, UpdatePlannerUC 등)
│
├── domain/                      # 💼 비즈니스 로직 계층
│   ├── entities/                # 데이터 모델 (Character, PlannedContent, Timeline)
│   └── services/                # 서비스 (CharacterService, TimelineService)
│
└── data/                        # 💾 외부 데이터 계층
    ├── repositories/            # Repository (CharacterRepository, PlannerRepository 등)
    ├── api/                     # API 통신
    │   ├── neople_api_client.dart
    │   ├── models/              # API 응답 모델 (CharacterModel, TimelineModel)
    │   └── services/            # HTTP 서비스
    └── local/                   # 로컬 저장소
        ├── database_service.dart
        ├── models/              # DB 모델 (PlannedContentModel)
        └── migrations/          # 스키마 마이그레이션
```

**설명**: ARCHITECTURE.md 참고 → [ARCHITECTURE.md](architecture.md)

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

# 웹 빌드 후 로컬 서버로 테스트 (포트 8001)
flutter build web
cd build/web
python -m http.server 8001

# 브라우저에서 열기
# http://localhost:8001
```

**참고**: 포트 8000은 다른 프로젝트용으로 예약되어 있으므로 로컬 웹 서버는 **포트 8001**을 고정으로 사용합니다.

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

### 6. ".env 파일을 찾을 수 없습니다"
```bash
# .env.example을 .env로 복사
cp .env.example .env
# (Windows PowerShell)
Copy-Item .env.example .env

# .env 파일 편집
# 텍스트 에디터로 열고 NEOPLE_API_KEY에 값 입력
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
