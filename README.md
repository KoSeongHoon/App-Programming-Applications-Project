# 던전앤파이터 플래너 앱

Neople API를 활용하여 던전앤파이터 플레이어의 타임라인을 자동 감지하고, 일일·주간 콘텐츠 진행도를 체크리스트로 관리하는 모바일 플래너 앱입니다.

---

## 📱 프로젝트 개요

- **플랫폼**: Flutter (iOS / Android)
- **API**: Neople Open API
- **언어**: Dart
- **상태 관리**: Riverpod (StateNotifier)
- **로컬 저장소**: SQLite (sqflite)

**프로젝트 기간**: 10주차 ~ 15주차 (6주)

---

## 🚀 빠른 시작

### 사전 요구사항
- Flutter SDK 3.10+ 설치
- Android Studio 또는 Xcode
- Git

### 개발 환경 설정
```bash
# 1. 저장소 클론
git clone <repo-url>
cd App-Programming-Applications-Project

# 2. 의존성 설치
flutter pub get

# 3. 개발 서버 실행
flutter run
```

더 자세한 설정은 [docs/setup.md](docs/setup.md)를 참조하세요.

---

## 📂 프로젝트 구조

```
├── .planning/              # 계획·설계 문서
├── docs/                   # 사용자 문서
├── src/                    # Flutter 소스 코드
├── test/                   # 테스트 코드
└── .github/                # CI/CD, 에이전트, 프롬프트
```

---

## 📖 주요 문서

| 문서 | 설명 |
|------|------|
| [.planning/00-vision.md](.planning/00-vision.md) | 프로젝트 비전 및 목표 |
| [.planning/01-requirements.md](.planning/01-requirements.md) | 요구사항 및 기능 명세 |
| [.planning/02-wbs.md](.planning/02-wbs.md) | Work Breakdown Structure |
| [.planning/04-schedule.md](.planning/04-schedule.md) | 프로젝트 일정 |
| [docs/architecture.md](docs/architecture.md) | 시스템 아키텍처 |
| [docs/setup.md](docs/setup.md) | 개발 환경 설정 |
| [docs/testing.md](docs/testing.md) | 테스트 작성 및 실행 |
| [AGENTS.md](AGENTS.md) | AI Agent 운영 가이드 |

---

## 🔧 주요 기능

### MVP (6주 내 완성)
- ✅ 캐릭터 검색 (Neople API)
- ✅ 타임라인 자동 감지 (로컬 저장소)
- ✅ 일일·주간 콘텐츠 플래너 (체크리스트)
- ✅ 콘텐츠 진행도 추적

### 향후 확장 (BONUS)
- 멀티 서버 지원 (미국, 중국, 일본)
- 강화 계획 계산기
- 알림 기능
- 다크 모드

---

## 🧪 테스트 실행

```bash
# 모든 테스트 실행
flutter test

# 특정 테스트만 실행
flutter test test/widgets/dashboard_test.dart
```

---

## 📦 빌드 및 배포

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

자세한 내용은 [docs/deploy.md](docs/deploy.md)를 참조하세요.

---

## 📅 프로젝트 일정

- **10주차**: 기획 및 문서 (비전, 요구사항, WBS, 일정)
- **11주차**: 설계 및 환경 구축 (아키텍처, Flutter 환경)
- **12주차**: API 클라이언트 및 기본 UI 구현
- **13주차**: 타임라인 매칭 알고리즘 구현
- **14주차**: 플래너 UI 및 로컬 저장소 통합
- **15주차**: 테스트 및 최종 발표

---

## 📞 문의

프로젝트에 대한 질문이나 피드백은 [AGENTS.md](AGENTS.md)를 참조하여 AI Agent에게 요청하세요.

---

## 📄 라이선스

개인 프로젝트용 - 배포 전 라이선스 결정 예정
