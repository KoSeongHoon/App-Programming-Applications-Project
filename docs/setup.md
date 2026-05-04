# 개발 환경 설정 (Setup)

신입 개발자도 **5분 안에** 앱을 실행할 수 있도록 작성했습니다.

---

## 🚀 빠른 시작 (5분)

### 1단계: 사전 요구사항 확인 (1분)

```bash
# Flutter SDK 설치 확인
flutter --version

# Dart SDK 설치 확인
dart --version

# Android Studio 또는 Xcode 설치 (iOS 개발 시)
# VS Code + Flutter 확장 설치 (권장)
```

### 2단계: 프로젝트 준비 (2분)

```bash
# 프로젝트 디렉토리로 이동
cd App-Programming-Applications-Project

# 의존성 설치
flutter pub get

# 코드 생성 (필요시)
flutter pub run build_runner build
```

### 3단계: 앱 실행 (2분)

```bash
# 에뮬레이터 또는 실기기 준비 후
flutter run

# 또는 개발 모드로 실행
flutter run -d chrome  # 웹
flutter run -d emulator-5554  # 안드로이드 에뮬레이터
```

**완료!** 앱이 실행되었습니다. 🎉

---

## 📋 상세 설정 가이드

### **Windows**

#### 1. Flutter SDK 설치

```bash
# 1. flutter.dev에서 Windows SDK 다운로드
# https://flutter.dev/docs/get-started/install/windows

# 2. 압축 해제 (예: C:\src\flutter)

# 3. 환경 변수 추가
# 시스템 속성 → 환경 변수 → PATH에 추가
# C:\src\flutter\bin

# 4. 확인
flutter doctor
```

#### 2. Android 개발 환경

```bash
# Android Studio 설치 (flutter doctor로 확인)
flutter doctor -v

# Android 에뮬레이터 생성
# Android Studio → AVD Manager → Create Virtual Device
```

#### 3. IDE 설정 (VS Code)

```bash
# 확장 프로그램 설치
# - Flutter (Dart Code)
# - Dart (Dart Code)

# Flutter 프로젝트 생성 테스트
flutter create test_app
cd test_app
flutter run
```

---

### **macOS**

#### 1. Flutter SDK 설치

```bash
# Homebrew 사용
brew install flutter

# 또는 수동 설치
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
```

#### 2. Xcode 설정

```bash
# Xcode 명령줄 도구 설치
xcode-select --install

# Xcode 라이선스 동의
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

#### 3. iOS 개발 환경

```bash
# CocoaPods 설치
sudo gem install cocoapods

# iOS 시뮬레이터 실행
open -a Simulator
```

---

### **Linux**

#### 1. Flutter SDK 설치

```bash
# 의존성 설치
sudo apt-get update
sudo apt-get install -y git curl

# Flutter 설치
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$PWD/flutter/bin"
```

#### 2. Android 개발 환경

```bash
# Android SDK 설치 (Android Studio 사용 권장)
# 또는 명령줄 도구로 설치

# 환경 변수 설정
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/emulator
export PATH=$PATH:$ANDROID_SDK_ROOT/tools
```

---

## 🔧 프로젝트 초기화

### **1단계: 의존성 설치**

```bash
flutter pub get
```

### **2단계: 환경 변수 설정**

```bash
# .env 파일 생성
cat > .env << EOF
NEOPLE_API_KEY=your_api_key_here
NEOPLE_SERVER_ID=58
APP_ENV=development
EOF

# .gitignore에 추가 (이미 됨)
# .env
```

> **주의**: `.env` 파일을 커밋하지 마세요!

### **3단계: 코드 생성 (필요시)**

```bash
# Riverpod 또는 다른 생성기 실행
flutter pub run build_runner build --delete-conflicting-outputs
```

### **4단계: 앱 실행**

```bash
flutter run
```

---

## 🎮 에뮬레이터/디바이스 관리

### **Android 에뮬레이터**

```bash
# 에뮬레이터 목록 확인
flutter emulators

# 에뮬레이터 시작
flutter emulators --launch emulator-5554

# 앱 실행
flutter run -d emulator-5554
```

### **iOS 시뮬레이터 (macOS)**

```bash
# 시뮬레이터 시작
open -a Simulator

# 앱 실행
flutter run -d iphone
```

### **실기기 연결**

```bash
# 연결된 기기 목록
flutter devices

# 특정 기기에서 실행
flutter run -d <device-id>

# 핫 리로드 활성화
flutter run -d <device-id> -hot
```

---

## 🔍 개발 팁

### **핫 리로드/리스타트**

```bash
# 개발 중 코드 변경 시 즉시 반영
flutter run

# 핫 리로드 (앱 상태 유지)
Press 'r' to hot reload

# 핫 리스타트 (상태 초기화)
Press 'R' to hot restart

# 종료
Press 'q' to quit
```

### **디버그 모드**

```bash
# 디버그 정보 출력
flutter run -v

# 브라우저에서 DevTools 열기
flutter run --debug
```

### **프로덕션 빌드 테스트**

```bash
# 릴리스 모드로 실행 (성능 테스트)
flutter run --release

# 프로필 모드 (성능 프로파일링)
flutter run --profile
```

---

## 🧪 테스트 환경 설정

### **단위 테스트**

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트만 실행
flutter test test/services/api_service_test.dart

# 커버리지 생성
flutter test --coverage
```

### **통합 테스트**

```bash
# 통합 테스트 실행
flutter test integration_test

# 특정 통합 테스트
flutter test integration_test/app_test.dart
```

---

## 📦 패키지 관리

### **새 패키지 추가**

```bash
# 패키지 추가
flutter pub add package_name

# 또는 pubspec.yaml에 직접 추가 후
flutter pub get
```

### **패키지 업데이트**

```bash
# 모든 패키지 업데이트 (호환 범위 내)
flutter pub upgrade

# 패키지 업데이트 (최신 버전)
flutter pub upgrade --major-versions

# 특정 패키지만 업데이트
flutter pub upgrade riverpod
```

### **의존성 분석**

```bash
# 의존성 관계 확인
flutter pub deps

# 불필요한 패키지 찾기
flutter pub global activate pub_batch
```

---

## 🐛 문제 해결

### **"flutter: command not found"**

```bash
# PATH 환경 변수 확인
echo $PATH

# Flutter 경로 추가 (Linux/macOS)
export PATH="$PATH:$HOME/flutter/bin"

# Windows는 시스템 환경 변수에 Flutter\bin 추가
```

### **"Android SDK not found"**

```bash
# Android SDK 경로 설정
flutter config --android-sdk /path/to/android/sdk

# 또는 환경 변수 설정
export ANDROID_SDK_ROOT=/path/to/android/sdk
```

### **"Xcode not installed" (macOS)**

```bash
# Xcode 설치
xcode-select --install

# 또는 App Store에서 Xcode 설치
```

### **포트 충돌**

```bash
# 기본 포트 (8080) 변경
flutter run --observatory-port=8081
```

### **캐시 문제**

```bash
# Flutter 캐시 정리
flutter clean

# Pub 캐시 정리
flutter pub cache repair

# 전체 초기화
flutter clean && flutter pub get && flutter pub run build_runner build
```

---

## ✅ 체크리스트

신입 개발자가 처음 시작할 때 확인할 사항:

- [ ] Flutter SDK 설치 완료 (`flutter --version` 실행)
- [ ] IDE 설정 완료 (VS Code 또는 Android Studio)
- [ ] 프로젝트 디렉토리에서 `flutter pub get` 실행
- [ ] `.env` 파일 생성 및 API Key 설정
- [ ] 에뮬레이터 또는 실기기 연결
- [ ] `flutter run` 실행하여 앱 실행 확인
- [ ] 메인 화면 정상 표시 확인

---

## 📚 추가 자료

| 주제 | 링크 |
|------|------|
| Flutter 공식 문서 | https://flutter.dev/docs |
| Dart 가이드 | https://dart.dev/guides |
| Riverpod 문서 | https://riverpod.dev |
| SQLite Flutter | https://pub.dev/packages/sqflite |

---

## 💬 도움이 필요하신가요?

문제 발생 시:
1. `flutter doctor -v` 실행하여 환경 상태 확인
2. 에러 메시지 전체 복사
3. [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter) 검색
4. [Flutter GitHub Issues](https://github.com/flutter/flutter/issues) 확인

---

**마지막 업데이트**: 2026-05-04  
**문서 버전**: 1.0
