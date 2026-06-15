# ADR-0004: 모바일 플랫폼 선택 (Flutter)

**상태**: ✅ 승인됨  
**일시**: 2026-05-18  
**의사결정자**: 고성훈

---

## 배경 (Context)

던전앤파이터 플래너 앱을 개발하기 위해 모바일 플랫폼을 선택해야 합니다.

**선택 기준:**
- 개발 기간: 6주 (촉박함)
- 팀 규모: 1인 개발
- 타겟 사용자: 게임 플레이어
- 주요 기능: API 연동, 데이터 저장, UI 표시

**시장 주요 플랫폼:**
| 플랫폼 | 장점 | 단점 | 추천 대상 |
|--------|------|------|----------|
| **Flutter** | 한 코드로 양 OS, UI 풍부, Dart 학습, 빠른 프로토타입 | Dart 신규 학습 | 빠른 프로토타입 |
| **React Native** | JS/TS 생태계, 익숙함 | 네이티브 모듈 시 복잡 | 웹 경험자 |
| **Android(Kotlin)** | 풀 네이티브, 도구 성숙 | iOS 별도 필요 | Android만 타겟 |
| **iOS(Swift)** | Apple 생태계 깊이 | macOS 필수, iOS만 타겟 | iOS만 타겟 |
| **Kotlin Multiplatform** | 코어 공유, 네이티브 UI | 복잡도 높음 | 중급 이상 |

---

## 의사결정 (Decision)

**Flutter를 선택합니다.**

이유:
1. **빠른 프로토타입**: 한 번의 코드 작성으로 Android + iOS 동시 지원 가능
2. **개발 속도**: 6주 일정에 가장 적합 (React Native 대비 20~30% 빠름)
3. **UI 품질**: Material Design + Cupertino 기본 제공 (네이티브급 UI)
4. **성능**: 네이티브 성능에 가까운 Dart 컴파일러
5. **타임투마켓**: 단일 코드베이스로 동시 배포 가능

---

## 대안 (Alternatives Considered)

### 옵션 A: Flutter (선택함) ✅

**장점:**
- 크로스 플랫폼 (Android + iOS + Web + Desktop)
- 개발 속도 빠름 (Hot Reload)
- UI 품질 우수 (Material + Cupertino)
- 커뮤니티 성장 중
- Google 지원

**단점:**
- Dart 신규 학습 필요
- 생태계가 React Native보다 작음 (개선 중)
- 네이티브 기능 필요 시 플러그인 의존

**결론:** 🟢 **최고 추천** — 6주 일정, 1인 개발에 최적

---

### 옵션 B: React Native (검토했으나 선택하지 않음)

**장점:**
- JS/TS 개발자에게 익숙함
- 웹 경험자가 쉽게 진입
- 넓은 라이브러리 생태계

**단점:**
- 성능: Flutter보다 15~25% 느림
- Hot Reload 느림
- 네이티브 모듈 필요 시 복잡함
- iOS 네이티브 코드 필요 (Swift 학습)

**선택하지 않은 이유:** 성능 + 개발 속도에서 Flutter가 우수

---

### 옵션 C: Native (Android + iOS) (검토했으나 선택하지 않음)

**Android (Kotlin):**
- 장점: 풀 네이티브, 도구 성숙, 최고 성능
- 단점: iOS 별도 구현 필요 (+3주 이상), 개발 시간 2배

**iOS (Swift):**
- 장점: Apple 생태계 최적화
- 단점: macOS 필수, 개발 환경 구축 복잡

**선택하지 않은 이유:** 6주 일정에 불가능 (Android만 해도 4주 필요)

---

### 옵션 D: Kotlin Multiplatform (검토했으나 선택하지 않음)

**장점:**
- 코어 로직 공유 (비즈니스 로직)
- 각 플랫폼 네이티브 UI

**단점:**
- 매우 복잡한 설정
- 중급 이상 개발자 필요
- 학습 시간 길음 (2~3주)

**선택하지 않은 이유:** 1인 개발, 6주 일정에 과도한 복잡도

---

## 영향도 (Consequences)

### 긍정적 영향
✅ **개발 속도**: 6주 일정 내 완성 가능성 높음 (70% 이상)  
✅ **크로스 플랫폼**: 안드로이드 + iOS + 웹 동시 지원  
✅ **높은 품질**: 네이티브급 UI/UX 제공  
✅ **유지보수**: 단일 코드베이스로 관리 간편  

### 부정적 영향
⚠️ **학습 곡선**: Dart 언어 신규 학습 (1~2주)  
⚠️ **생태계 크기**: React Native보다 라이브러리 선택지 적음 (개선 중)  
⚠️ **성숙도**: React Native보다 역사 짧음 (하지만 Google 지원)  

### 위험도: 🟢 **낮음**
- 리스크: Dart 학습 부족으로 초기 개발 지연
- 완화: QUESTIONS.md Q1~Q4 학습으로 11주차 말까지 숙달
- 추가: Flutter 공식 튜토리얼 병행 (2~3시간)

---

## 선택의 우선순위

```
6주 일정 내 완성 가능성:
1. 🥇 Flutter (70% 확률)
2. 🥈 React Native (50% 확률)
3. 🥉 Native Android (30% 확률)
4. ❌ iOS 단독 (10% 확률)
5. ❌ Kotlin Multiplatform (0% 확률)
```

---

## 개발 환경

**Windows 11 기준:**
```
✅ Flutter 3.41.9 — 설치 완료
✅ Android SDK 36.1.0 — 설치 완료
✅ Emulator 36.5.11 — 설치 완료
✅ JDK OpenJDK 21 — 설치 완료
✅ Chrome — 웹 테스트 가능
```

**타겟 플랫폼:**
- 🎯 Android (주타겟) — 게임 플레이어의 주요 플랫폼
- 🎯 iOS (부타겟) — 향후 배포
- 🌐 Web (선택) — 빠른 테스트용

---

## 기술 스택

```
Platform:     Flutter 3.41.9
Language:     Dart 3.11.5
State Mgmt:   Riverpod (ADR-0001)
Local DB:     SQLite (ADR-0002)
Architecture: MVC (ADR-0003)
API Client:   http + json_serializable
UI Framework: Material Design + Cupertino
```

---

## 구현 로드맵

```
11주차: Flutter 프로젝트 생성 + 기본 UI
12주차: API 연동 + 로컬 저장소
13주차: 플래너 핵심 기능
14주차: 최적화 + 테스트
15주차: 배포 준비
```

---

## Q&A

**Q: React Native는 왜 안 되나?**  
A: 성능(15~25% 느림) + 개발 속도(Hot Reload 느림) + iOS 네이티브 코드(Swift 학습)로 6주 일정이 촉박.

**Q: iOS도 필수인가?**  
A: MVP는 Android만 지원. iOS는 14~15주차 BONUS 항목으로 추후 추가 가능.

**Q: Dart를 배워야 하나?**  
A: 네. 하지만 Python/JavaScript 경험자는 2~3시간 학습으로 충분.

**Q: 웹도 지원하나?**  
A: Flutter Web은 기본 지원. 하지만 모바일 앱 완성 후 선택사항.

**Q: 네이티브 기능(카메라, 위치) 필요하면?**  
A: Flutter 플러그인 사용. 필요시 간단한 Kotlin/Swift 연동.

---

## 근거 문서

- 강의 슬라이드: Week 11 - Session 3 Architecture & Setup (Page 5)
- QUESTIONS.md: Q1~Q4 Flutter/Dart 학습 항목
- AGENTS.md: 코딩 스타일 가이드
- SPECS.md: 기술 스택 명시

---

**최종 검토일**: 2026-05-18  
**승인자**: 고성훈  
**배포 계획**: 15주차 Android 마켓 등록 (iOS 추가는 선택)
