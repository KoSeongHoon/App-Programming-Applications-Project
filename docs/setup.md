# 🛠️ 개발 환경 설정 가이드

**목표**: 로컬 개발 환경에서 던파플래너 앱 실행하기  
**예상 소요 시간**: 30분 ~ 1시간

---

## 📋 **1. 시스템 요구사항**

### **최소 사양**
```
OS: Windows 10 / macOS 12 / Linux (Ubuntu 20.04+)
RAM: 8GB 이상
저장공간: 10GB 이상
```

### **필수 설치 항목**

| 항목 | 버전 | 용도 |
|------|------|------|
| **Flutter SDK** | 3.0 이상 | 앱 프레임워크 |
| **Dart** | 3.0 이상 | 프로그래밍 언어 |
| **Android SDK** | API 28+ | Android 빌드 |
| **Java JDK** | 17 이상 | Gradle 빌드 |
| **Git** | 최신 | 버전 관리 |

---

## 🚀 **2. 단계별 설치**

### **Step 1: Flutter SDK 설치**

#### Windows
```bash
# 1. flutter_windows_3.24.0-stable.zip 다운로드
# https://flutter.dev/docs/get-started/install/windows

# 2. C:\src\flutter 에 압축 해제
cd C:\src\flutter
flutter --version

# 3. PATH에 추가 (환경변수 설정)
# 시스템 환경변수 → Path → 추가
# C:\src\flutter\bin
```

#### macOS
```bash
# Homebrew를 사용한 설치 (권장)
brew install flutter

# 또는 직접 설치
cd ~/development
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$HOME/development/flutter/bin"
```

### **Step 2: Android SDK 설치**

```bash
# Android Studio 설치 후 자동 구성
flutter config --android-studio-dir="/Applications/Android Studio.app"

# 또는 수동으로 ANDROID_SDK_ROOT 설정
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/tools:$ANDROID_SDK_ROOT/platform-tools
```

### **Step 3: Java JDK 설치**

```bash
# Windows에서 Java 17 설치
# https://www.oracle.com/java/technologies/downloads/#java17

# 설치 후 버전 확인
java -version
# openjdk version "17.0.x"

# JAVA_HOME 환경변수 설정
# (이미 설치되면 자동 감지)
```

### **Step 4: Flutter doctor 실행**

```bash
flutter doctor

# 출력 예시:
# ✓ Flutter (Channel stable, 3.24.0)
# ✓ Android toolchain
# ✓ Android Studio
# ✓ VS Code
# ✓ Connected device
```

모든 항목이 ✓ 표시가 되어야 합니다!

---

## 📁 **3. 프로젝트 구조**

```
App-Programming-Applications-Project/
├── Planner/                          # Flutter 앱 소스
│   ├── lib/
│   │   ├── presentation/             # UI 계층
│   │   │   ├── screens/              # 화면들
│   │   │   ├── theme/                # 디자인 시스템
│   │   │   └── widgets/              # 공통 컴포넌트
│   │   ├── application/              # 상태관리
│   │   │   └── view_models/          # ViewModel (Riverpod)
│   │   ├── domain/                   # 비즈니스 로직
│   │   │   ├── entities/             # 데이터 모델
│   │   │   └── utils/                # 유틸리티
│   │   ├── data/                     # 데이터 계층
│   │   │   ├── api/                  # API 클라이언트
│   │   │   ├── local/                # DB 서비스
│   │   │   └── repositories/         # Repository
│   │   ├── main.dart                 # 앱 진입점
│   │   └── app.dart                  # 앱 설정
│   ├── android/                      # Android 네이티브
│   ├── ios/                          # iOS 네이티브
│   ├── pubspec.yaml                  # 의존성 정의
│   └── .env.example                  # 환경변수 예시
├── docs/                             # 문서
│   ├── setup.md                      # 이 파일
│   ├── deploy.md                     # 배포 가이드
│   ├── testing.md                    # 테스트 가이드
│   └── planning/                     # 기획 문서
├── README.md                         # 프로젝트 개요
└── AGENTS.md                         # AI 활용 가이드
```

---

## ⚙️ **4. 환경 변수 설정**

### **.env 파일 생성**

```bash
# 프로젝트 루트에서
cd Planner
cp .env.example .env
```

### **.env 파일 작성**

```bash
# Neople API 키
# https://developers.neople.co.kr 에서 발급
NEOPLE_API_KEY=your_api_key_here
```

### **Flutter에서 .env 읽기**

```dart
// main.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

---

## 🎯 **5. 프로젝트 초기화**

### **의존성 설치**

```bash
cd Planner
flutter pub get

# 또는 상세 버전
flutter pub upgrade
```

### **코드 생성 (Riverpod)**

```bash
# Riverpod 코드 생성
flutter pub run build_runner build

# 변경사항 자동 감지
flutter pub run build_runner watch
```

### **Dart 분석 실행**

```bash
# Lint 체크
flutter analyze

# 형식 확인
flutter format --set-exit-if-changed lib/
```

---

## ▶️ **6. 로컬 실행**

### **디버그 모드 실행**

```bash
# USB 연결된 기기에서 실행
flutter run

# 또는 특정 기기 선택
flutter devices          # 기기 목록 보기
flutter run -d R3CY20ZAQYV  # 특정 기기 ID로 실행
```

### **핫 리로드 활용**

```
실행 중에 코드 수정 후 저장
→ 자동으로 앱이 새로고침됨
→ 개발 속도 극대화!
```

### **로그 보기**

```bash
# 실시간 로그 출력
flutter logs

# 특정 패턴만 필터링
flutter logs | grep "모험단"
```

---

## 🧪 **7. 테스트 환경**

### **단위 테스트 작성**

```dart
// test/repositories/character_repository_test.dart
void main() {
  test('캐릭터 검색이 정상 작동', () async {
    final repository = CharacterRepositoryImpl();
    final characters = await repository.searchCharacter('우르반', 'pve-1');
    expect(characters, isNotEmpty);
  });
}
```

### **테스트 실행**

```bash
# 모든 테스트 실행
flutter test

# 특정 파일 테스트
flutter test test/repositories/character_repository_test.dart

# 커버리지 리포트
flutter test --coverage
lcov --list coverage/lcov.info
```

---

## 🔍 **8. 문제 해결**

### **문제 1: "flutter not found" 에러**

```bash
# 해결: PATH에 Flutter 추가
echo $PATH | grep flutter

# 또는 전체 경로로 실행
/usr/local/bin/flutter run
```

### **문제 2: "Android SDK not found" 에러**

```bash
# 확인
flutter config --android-sdk-path

# 설정
flutter config --android-sdk-path=/path/to/android-sdk
```

### **문제 3: "java version" 에러**

```bash
# Java 17 확인
java -version

# 없으면 설치
brew install openjdk@17
```

### **문제 4: Riverpod 코드 생성 실패**

```bash
# 캐시 제거
flutter clean

# 다시 빌드
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ **9. 체크리스트**

개발 환경 설정 완료 확인:

```markdown
- [ ] Flutter SDK 설치 (flutter --version)
- [ ] Android SDK 설치 (android --version)
- [ ] Java 17 설치 (java -version)
- [ ] flutter doctor 모두 ✓
- [ ] 프로젝트 git clone
- [ ] .env 파일 생성 및 API 키 설정
- [ ] flutter pub get 완료
- [ ] flutter run 성공
- [ ] 앱 홈 화면 렌더링 확인
```

---

## 📞 **10. 참고 링크**

- [Flutter 공식 설치 가이드](https://flutter.dev/docs/get-started/install)
- [Android Studio 설치](https://developer.android.com/studio)
- [Neople API 문서](https://developers.neople.co.kr)
- [Riverpod 공식 문서](https://riverpod.dev)

**다음 단계**: [배포 가이드](deploy.md) 참고
