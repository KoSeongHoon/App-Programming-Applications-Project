# ADR-0001: Riverpod vs Provider 상태 관리 라이브러리 선택

**상태**: ✅ 승인됨  
**일시**: 2026-05-18  
**의사결정자**: 고성훈

---

## 배경 (Context)

던전앤파이터 플래너 앱은 다음과 같은 상태 관리가 필요합니다:
- 캐릭터 정보 (검색 결과, 선택된 캐릭터)
- 타임라인 데이터 (API로부터 수신)
- 플래너 상태 (클리어 여부, 필터 설정)
- UI 상태 (로딩, 에러, 성공)

Flutter/Dart 진영에는 두 가지 주요 상태 관리 라이브러리가 있습니다:
- **Provider**: 성숙하고 커뮤니티 풍부, 널리 사용됨
- **Riverpod**: 더 현대적, 타입 안전성 강화, Provider의 후속작

---

## 의사결정 (Decision)

**Riverpod을 선택합니다.**

이유:
1. **타입 안전성**: Riverpod은 컴파일 타임에 의존성을 검증하므로 런타임 에러 감소
2. **API 설계**: Provider보다 직관적이고 테스트하기 쉬움
3. **현대성**: 2025년 기준 활발한 개발 중 (Flutter 커뮤니티 표준으로 이동 중)
4. **학습 가치**: 새로운 패턴을 배우므로 이후 프로젝트에 활용 가능

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

```dart
// Riverpod 기본 사용법
import 'package:riverpod/riverpod.dart';

// 1. 간단한 상태
final characterProvider = StateNotifierProvider<
  CharacterNotifier,
  Character?
>((ref) => CharacterNotifier());

// 2. API 호출
final timelineProvider = FutureProvider<List<Timeline>>((ref) async {
  final api = ref.watch(neopleApiProvider);
  return api.getTimeline();
});

// 3. 위젯에서 사용
class CharacterSearchScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeline = ref.watch(timelineProvider);
    return timeline.when(
      data: (data) => PlannerUI(data),
      loading: () => LoadingSpinner(),
      error: (err, st) => ErrorWidget(err),
    );
  }
}
```

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
