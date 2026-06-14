# 🚀 Flutter 앱 자동 설치 가이드

이 가이드는 던전앤파이터 플래너 앱을 Windows PC에서 Android 핸드폰으로 빌드하는 방법입니다.

---

## 📋 설치 순서

### ✅ Step 1: Flutter SDK 설치 (필수)

**방법 1: 자동 설치 (권장)**
```powershell
# 이 프로젝트 폴더에서:
.\setup_flutter.bat
```

**방법 2: 수동 설치**
1. https://flutter.dev/docs/get-started/install/windows 방문
2. Windows용 Flutter SDK 다운로드
3. `C:\Users\[당신의 계정]\flutter` 에 압축 해제
4. 환경 변수 PATH에 `C:\Users\[당신의 계정]\flutter\bin` 추가

**확인:**
```powershell
flutter --version
```

---

### ✅ Step 2: Android 개발 환경 설정 (필수)

**방법 1: 자동 설치 (권장, 관리자 권한 필요)**
```powershell
# 관리자로 실행 (마우스 우클릭 → "관리자로 실행")
.\setup_android.bat
```

**방법 2: 수동 설치**
1. Android Studio 다운로드: https://developer.android.com/studio
2. 설치 후 Android SDK & Emulator 설치
3. JDK 설치 (OpenJDK 17+ 권장)

**확인:**
```powershell
flutter doctor
```

출력:
```
✓ Flutter
✓ Android toolchain
✓ Android Studio
✓ Visual Studio Code
```

---

### ✅ Step 3: 프로젝트 설정

#### 3-1. Neople API 키 설정

`.env` 파일을 생성합니다:

**파일 위치:** `C:\AppProgramingAplicationProject\Planner\.env`

**내용:**
```
NEOPLE_API_KEY=your_api_key_here
FLUTTER_ENV=development
LOG_LEVEL=info
DATABASE_PATH=./data/planner.db
```

> 💡 API 키 발급: https://developers.neople.co.kr

#### 3-2. 의존성 설치

```powershell
cd C:\AppProgramingAplicationProject\Planner
flutter pub get
```

---

## 🎮 빌드 & 실행

### Android 핸드폰에 설치

#### 방법 1: 개발 모드 (권장)

```powershell
# 1. 핸드폰을 USB로 연결
# 2. 핸드폰에서 "개발자 옵션" → "USB 디버깅" 활성화

# 3. 프로젝트 폴더에서 실행
cd C:\AppProgramingAplicationProject\Planner
flutter run
```

#### 방법 2: APK 빌드 (앱 파일)

```powershell
# Release APK 생성
flutter build apk --release

# 생성된 파일:
# build/app/outputs/flutter-apk/app-release.apk
```

생성된 APK를 핸드폰에 옮겨서 설치하면 됩니다.

---

## 🔍 문제 해결

### Q1: `flutter: command not found`
**원인:** Flutter이 PATH에 설정되지 않음
**해결:**
```powershell
# 환경 변수 다시 설정
setx PATH "C:\Users\고성훈\flutter\bin;%PATH%"

# 터미널 재시작 후 확인
flutter --version
```

### Q2: `Android toolchain missing`
**원인:** Android SDK가 설치되지 않음
**해결:**
```powershell
flutter doctor --android-licenses
# 모든 라이선스에 y 입력
```

### Q3: 핸드폰이 인식되지 않음
**확인:**
```powershell
# 1. 핸드폰이 USB로 연결되었는지 확인
# 2. "개발자 옵션" → "USB 디버깅" 활성화
# 3. 아래 명령어로 확인

flutter devices
```

### Q4: `.env` 파일 오류
**원인:** NEOPLE_API_KEY가 없음
**해결:** API 키를 발급받아 `.env` 파일에 추가

---

## 📱 앱 빌드 완료 후

### 앱 테스트 항목

- [ ] **캐릭터 검색**: 닉네임 입력 후 검색 가능
- [ ] **타임라인 조회**: API에서 최근 활동 기록 조회
- [ ] **플래너 추가**: 캐릭터를 플래너에 추가
- [ ] **콘텐츠 표시**: 던전/레이드/레기온 표시
- [ ] **자동 감지**: 타임라인에서 클리어 자동 감지
- [ ] **로컬 저장**: DB에 데이터 저장

---

## 📚 추가 정보

### 유용한 명령어

```powershell
# 1. 설치 상태 확인 (가장 중요!)
flutter doctor -v

# 2. 의존성 업데이트
flutter pub upgrade

# 3. 캐시 정리
flutter clean

# 4. 빌드 재시작
flutter run -v

# 5. 핸드폰 목록 확인
flutter devices

# 6. 에뮬레이터 실행
flutter emulators --launch emulator-5554
```

### 폴더 구조

```
Planner/
├── lib/
│   ├── presentation/      # UI 계층
│   ├── application/       # 상태 관리
│   ├── domain/           # 비즈니스 로직
│   ├── data/             # 데이터 계층
│   └── main.dart         # 진입점
├── android/              # Android 관련 설정
├── ios/                  # iOS 관련 설정 (필요시)
├── pubspec.yaml          # 의존성 정의
└── .env                  # API 키 (⚠️ .gitignore에 포함)
```

---

## 🎯 다음 단계

1. ✅ SDK 설치 완료
2. ✅ 프로젝트 설정 완료
3. 🚀 앱 빌드 및 실행
4. 🧪 기능 테스트
5. 🐛 버그 수정 (필요시)

---

## ❓ 도움말

문제가 발생하면:
1. `flutter doctor` 실행해서 상태 확인
2. 오류 메시지 전체 복사
3. 관련 문서 확인

---

**작성일:** 2026-06-07  
**대상:** Windows 사용자 (Android)  
**상태:** 자동 설치 지원
