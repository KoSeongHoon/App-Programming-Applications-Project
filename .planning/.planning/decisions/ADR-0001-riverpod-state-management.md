# ADR-0001: Flutter 상태 관리 라이브러리 선택 (Riverpod vs Provider)

**상태**: ✅ 승인됨  
**일시**: 2026-05-18  
**의사결정자**: 고성훈

---

## 배경 (Context)

### Flutter의 상태 관리란?
Flutter 앱이 실행되면서 데이터가 변합니다. 예를 들어:
- 사용자가 검색 버튼을 클릭 → 로딩 상태로 변경
- API가 데이터를 반환 → 캐릭터 정보로 변경
- 사용자가 체크박스를 체크 → 플래너 상태로 변경

**Flutter의 상태 관리 라이브러리**는 이런 데이터 변화를 추적하고, 화면을 자동으로 업데이트합니다.

### 우리 앱이 필요한 상태
던전앤파이터 플래너 앱은 다음과 같은 상태 관리가 필요합니다:
- 캐릭터 정보 (검색 결과, 선택된 캐릭터)
- 타임라인 데이터 (API로부터 수신)
- 플래너 상태 (클리어 여부, 필터 설정)
- UI 상태 (로딩, 에러, 성공)

Flutter/Dart 진영의 주요 상태 관리 라이브러리:
- **Provider**: Flutter 상태 관리 라이브러리 (성숙, 널리 사용)
- **Riverpod**: Flutter 상태 관리 라이브러리 (현대적, 타입 안전)

---

## 의사결정 (Decision)

**Flutter의 상태 관리 라이브러리 Riverpod을 선택합니다.**

이유:
1. **타입 안전성**: Flutter의 상태 관리 라이브러리 Riverpod은 컴파일 타임에 의존성을 검증하므로 런타임 에러 감소
2. **API 설계**: Provider보다 직관적이고 테스트하기 쉬움
3. **현대성**: 2025년 기준 활발한 개발 중 (Flutter 커뮤니티 표준으로 이동 중)
4. **학습 가치**: 새로운 패턴을 배우므로 이후 Flutter 프로젝트에 활용 가능

---

## 대안 (Alternatives Considered)

### 옵션 A: Provider (사용하지 않음)
**장점:**
- 더 많은 예제와 튜토리얼
- 성숙한 라이브러리 (버그 적음)
- 팀 경험자가 많을 가능성

**단점:**
- 컴파일 타임 검증 부족
- API 설계가 구식 (Consumer, build context 의존)
- 신규 프로젝트는 Riverpod로 이동 추세

### 옵션 B: GetX (사용하지 않음)
**장점:**
- 매우 간단한 API

**단점:**
- 추가 기능이 많아 학습 곡선 가파름
- 명시성 부족 (암묵적 동작)
- 타입 안전성 약함

### 옵션 C: BLoC 패턴 (사용하지 않음)
**장점:**
- 명확한 아키텍처 패턴

**단점:**
- 과도한 보일러플레이트 코드
- 간단한 앱에는 오버엔지니어링

---

## 영향도 (Consequences)

### 긍정적 영향
✅ **타입 안전성 향상**: 컴파일 타임 에러 감지로 버그 감소  
✅ **테스트 용이성**: 함수형 API로 유닛 테스트 작성 간편  
✅ **미래 대비**: Flutter 커뮤니티 표준 학습  

### 부정적 영향
⚠️ **학습 곡선**: 기존 Provider 경험자도 재학습 필요  
⚠️ **생태계 크기**: Provider보다 예제/튜토리얼 적음  
⚠️ **초기 속도**: 새로운 패턴 습득에 1~2일 소요  

### 위험도: 🟡 **중간**
- 리스크: 학습 부족으로 초기 개발 속도 저하
- 완화: QUESTIONS.md Q1 학습 목표로 11주차 말까지 숙달

---

## 관련 문서

- `.planning/QUESTIONS.md` — Q1. Provider vs Riverpod 상태 관리
- `AGENTS.md` — 상태 관리 규칙 및 코딩 스타일
- `SPECS.md` — 기능별 도메인 규칙

---

## 구현 가이드

### Riverpod 사용 위치 (우리 프로젝트)

```
┌─────────────────────────────────────────┐
│ Presentation (화면)                     │
│ ← Riverpod 상태를 구독하고 화면 재그리기 │
└──────────────┬──────────────────────────┘
               ↑
               │ ref.watch(characterProvider)
               ↓
┌──────────────┴──────────────────────────┐
│ Application (상태 관리)                  │
│ → Riverpod이 상태 변화를 감지            │
│   (로딩/성공/에러)                       │
└──────────────┬──────────────────────────┘
               ↑
               │ Repository 호출
               ↓
┌──────────────┴──────────────────────────┐
│ Domain/Data (비즈니스 로직 & API)        │
│ 실제 데이터 처리                         │
└─────────────────────────────────────────┘
```

### 구현 예시

```dart
// 1️⃣ Application 계층: 상태 정의 (Riverpod Provider)
import 'package:riverpod/riverpod.dart';

final characterProvider = StateNotifierProvider<
  CharacterNotifier,
  Character?
>((ref) => CharacterNotifier());

// 2️⃣ Presentation 계층: 상태 구독
class CharacterSearchScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Riverpod이 이 상태를 감시
    final character = ref.watch(characterProvider);
    
    return character != null
        ? CharacterCard(character: character)
        : const Text('캐릭터를 검색하세요');
  }
}

// 3️⃣ 상태 변경 (자동으로 화면 업데이트됨)
class CharacterNotifier extends StateNotifier<Character?> {
  CharacterNotifier() : super(null);

  void updateCharacter(Character character) {
    state = character;  // ← 여기서 상태 변경
    // Riverpod이 자동으로 감지하고 화면 재그리기 (rebuild)
  }
}
```

### 핵심 개념

**Riverpod이 하는 일:**
1. 상태를 중앙에서 관리 (Application 계층)
2. 상태 변화를 감지
3. 상태를 구독한 화면(Widget)을 자동으로 재그리기

**우리 프로젝트 구조:**
- `lib/application/view_models/` → Riverpod Provider 정의 위치
- `lib/presentation/screens/` → Provider를 구독하는 위치

---

## Q&A

**Q: Provider에서 마이그레이션할 수 있나?**  
A: 부분 마이그레이션 가능. 신규 코드는 Riverpod, 기존 코드는 Provider 유지 후 점진적 전환.

**Q: 성능 차이는?**  
A: Riverpod이 약간 더 효율적 (불필요한 리빌드 감소).

**Q: 팀원이 모르면?**  
A: QUESTIONS.md 학습 자료로 2~3시간 학습 충분.

---

**최종 검토일**: 2026-05-18  
**승인자**: 고성훈  
**다음 리뷰**: 13주차 구현 완료 후
