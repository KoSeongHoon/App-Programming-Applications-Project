# 던파플래너 (Dungeon Fighter Planner)

던전 앤 파이터 캐릭터의 주간 컨텐츠 클리어 현황을 한눈에 관리하는 모바일 앱입니다.

## 🎮 주요 기능

- **캐릭터 검색**: Neople API를 통해 실시간 캐릭터 정보 조회
- **모험단(길드) 검색**: 캐릭터명 검색 후 동일 모험단 멤버 자동 추출
- **플래너**: 플래너에 추가한 캐릭터의 주간 컨텐츠 클리어 현황 추적
  - 상급 던전 (최후의 과업, 배교자의 성 등 7종)
  - 레이드 (노멀/하드 난이도 구분)
  - 레기온 (아포칼립스, 비너스 등)
- **실시간 동기화**: API 타임라인 파싱으로 최신 클리어 기록 자동 반영

## 📱 스크린샷

| 검색 화면 | 플래너 화면 |
|-----------|-----------|
| 캐릭터/모험단 검색 | 주간 컨텐츠 현황 |

## 🛠️ 기술 스택

- **프레임워크**: Flutter (Dart)
- **상태 관리**: Riverpod 2.4.0
- **API 통신**: http 1.1.0 (Neople API)
- **로컬 저장**: SQLite (sqflite 2.3.0)
- **환경 설정**: flutter_dotenv 5.1.0
- **아이콘**: flutter_launcher_icons 0.13.0

## 🚀 빠른 시작

### 설치 및 실행
```bash
# 의존성 설치
flutter pub get

# 개발 모드 실행
flutter run

# Release APK 생성
flutter build apk --release --split-per-abi
```

**자세한 설치 가이드**: [docs/setup.md](docs/setup.md)

## 📐 아키텍처

Clean Architecture 기반 계층 분리:
- **Presentation Layer**: Flutter UI (화면, 테마)
- **Application Layer**: Riverpod 상태 관리 (ViewModel)
- **Domain Layer**: 비즈니스 로직 (Entity, UseCase)
- **Data Layer**: API/DB 접근 (Repository, DataSource)

**자세한 내용**: [docs/architecture.md](docs/architecture.md)

## 🔧 배포 / 빌드

### Release APK 생성 및 배포
```bash
flutter build apk --release --split-per-abi
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk
```

**자세한 배포 가이드**: [docs/deploy.md](docs/deploy.md)

## 🧪 테스트

```bash
# 모든 테스트 실행
flutter test

# 커버리지 리포트 생성
flutter test --coverage
```

**자세한 테스트 가이드**: [docs/testing.md](docs/testing.md)

## 📚 문서

- [docs/setup.md](docs/setup.md) - 개발 환경 설정 가이드
- [docs/architecture.md](docs/architecture.md) - 앱 아키텍처 및 구조
- [docs/deploy.md](docs/deploy.md) - 배포 및 릴리스 가이드
- [docs/testing.md](docs/testing.md) - 테스트 작성 및 실행 가이드

## 🔒 보안

- API 키는 `.env` 파일에서 관리 (git 제외)
- 모든 통신은 HTTPS 사용
- 민감한 로그는 Debug 모드에서만 출력
- 사용자 입력 유효성 검사 구현

## 📦 환경 설정

```bash
# 개발 환경 (로컬)
export NEOPLE_API_KEY=your_api_key

# Release 빌드 시
flutter build apk --release --verbose
```

`.env` 파일 예제: [.env.example](.env.example)

## 👤 작성자

- 고성훈

## 📄 라이선스

본 프로젝트는 Vibe Coding Project(앱 프로그래밍 응용) 학과 과제입니다.

---

**더 자세한 정보는 [docs/](docs/) 폴더를 참고하세요.**
