# 메이플스토리 플래너 앱

Nexon API를 활용하여 메이플스토리 플레이어의 캐릭터 진행 상황을 관리하고, 장비 강화, 일일 콘텐츠 계획을 세울 수 있는 모바일 플래너 앱입니다.

---

## 📱 프로젝트 개요

- **플랫폼**: Flutter (iOS / Android)
- **API**: Nexon Open API
- **언어**: Dart
- **상태 관리**: Provider / Riverpod (선택 예정)
- **로컬 저장소**: SQLite / Hive

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
- ✅ 캐릭터 조회 (Nexon API)
- ✅ 대시보드 (기본 정보 표시)
- ✅ 강화 계획 (확률/비용 계산)
- ✅ 일일 체크리스트

### 향후 배포 시
- 멀티 캐릭터 관리
- 알림 기능
- 커뮤니티 공유

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

- **10주차**: 설계 및 환경 설정
- **11주차**: 기본 UI 및 API 연동
- **12주차**: 중간 발표 (MVP 50%)
- **13~14주차**: 기능 고도화 및 테스트
- **15주차**: 최종 발표 (완성도 100%)

---

## 📞 문의

프로젝트에 대한 질문이나 피드백은 [AGENTS.md](AGENTS.md)를 참조하여 AI Agent에게 요청하세요.

---

## 📄 라이선스

개인 프로젝트용 - 배포 전 라이선스 결정 예정
