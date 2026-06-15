# ADR-0003: MVC vs MVP vs MVVM 아키텍처 패턴 선택

**상태**: ✅ 승인됨  
**일시**: 2026-05-18  
**의사결정자**: 고성훈

---

## 배경 (Context)

플래너 앱의 코드 구조를 결정해야 합니다:
- 검색 화면: 캐릭터 검색 → API 호출 → 결과 표시
- 플래너 화면: 콘텐츠 리스트 → 체크박스 토글 → DB 저장
- 통계 화면: 데이터 조회 → 계산 → 차트 렌더링

아키텍처 패턴의 선택은 다음에 영향을 미칩니다:
- 코드 조직화
- 테스트 용이성
- 유지보수 난이도
- 팀의 학습 곡선

---

## 의사결정 (Decision)

**MVC (Model-View-Controller) 패턴을 선택합니다.**

정확히는 **Flutter/Dart 관점의 MVC**:
- **Model**: Riverpod StateNotifier (상태 + 비즈니스 로직)
- **View**: Flutter Widget (UI 렌더링)
- **Controller**: 없음 (Riverpod이 상태 관리 담당)

이유:
1. **단순성**: MVP/MVVM보다 개념이 명확하고 학습 곡선 낮음
2. **Riverpod 적합성**: StateNotifier는 MVC의 Model 역할에 최적
3. **Flutter 생태계**: 많은 예제와 튜토리얼이 MVC 패턴 사용
4. **빠른 개발**: 6주 일정에 맞춤

---

## 대안 (Alternatives Considered)

### 옵션 A: MVC (선택함) ✅
**구조:**
```
lib/
├── models/           # 데이터 모델 + 비즈니스 로직
│   ├── character.dart
│   ├── timeline.dart
│   └── planner_state.dart (StateNotifier)
├── views/            # UI 화면
│   ├── character_search_screen.dart
│   ├── planner_screen.dart
│   └── statistics_screen.dart
└── providers.dart    # Riverpod 선언
```

**장점:**
- 가장 단순한 패턴
- Riverpod과 자연스러운 조화
- 신입 개발자도 쉽게 이해
- 보일러플레이트 적음

**단점:**
- Model이 커질 수 있음 (뚱뚱한 model 방지 필요)
- Controller가 명시적이지 않음

### 옵션 B: MVP (사용하지 않음)
**구조:**
```
- Model: 데이터
- View: 순수 UI (로직 없음)
- Presenter: UI 이벤트 처리 + 상태 업데이트
```

**장점:**
- View와 로직의 명확한 분리
- 테스트 매우 용이

**단점:**
- Presenter 클래스 필요 (보일러플레이트 증가)
- Riverpod과의 조화 어려움
- 간단한 앱에는 오버엔지니어링

### 옵션 C: MVVM (사용하지 않음)
**구조:**
```
- Model: 데이터
- View: UI (로직 없음)
- ViewModel: 상태 + 비즈니스 로직
```

**장점:**
- WPF/Xamarin 개발자에게 친숙
- 양방향 바인딩 가능

**단점:**
- Flutter는 양방향 바인딩 미지원
- ViewModel 구현이 복잡
- Riverpod이 이미 상태 관리하는데 중복

---

## 영향도 (Consequences)

### 긍정적 영향
✅ **학습 용이**: 아키텍처 이해에 1~2시간만 필요  
✅ **빠른 개발**: 간단한 구조로 비즈니스 로직에 집중  
✅ **테스트 가능**: Model 로직만 단위 테스트 하면 됨  

### 부정적 영향
⚠️ **Model 비대화**: 시간이 지나면서 Model 클래스가 커질 수 있음  
⚠️ **관심사 분리**: 데이터 로직과 UI 로직 경계가 명확하지 않을 수 있음  

### 위험도: 🟢 **낮음**
- 리스크: Model이 비대해질 수 있음
- 완화: 명확한 책임 분리 가이드 (AGENTS.md 참고)

---

## 구현 가이드

### 1. Model 계층 (데이터 + 비즈니스 로직)

```dart
// models/character.dart
class Character {
  final int id;
  final String name;
  final String server;
  final String characterClass;
  final int level;
  
  Character({
    required this.id,
    required this.name,
    required this.server,
    required this.characterClass,
    required this.level,
  });
  
  // 비즈니스 로직은 Model에 포함
  bool isHighLevel() => level >= 50;
  String displayName() => '$name ($server)';
}

// models/character_state.dart (Riverpod StateNotifier)
class CharacterNotifier extends StateNotifier<Character?> {
  final NeopleApiClient _apiClient;
  
  CharacterNotifier(this._apiClient) : super(null);
  
  Future<void> searchCharacter(String name, String server) async {
    try {
      final character = await _apiClient.searchCharacter(name, server);
      state = character;
    } catch (e) {
      // 에러 처리
      state = null;
    }
  }
}

// providers.dart
final neopleApiProvider = Provider<NeopleApiClient>((ref) {
  return NeopleApiClient();
});

final characterProvider = StateNotifierProvider<CharacterNotifier, Character?>(
  (ref) => CharacterNotifier(ref.watch(neopleApiProvider)),
);
```

### 2. View 계층 (UI만)

```dart
// views/character_search_screen.dart
class CharacterSearchScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final character = ref.watch(characterProvider);
    
    return Scaffold(
      appBar: AppBar(title: Text('캐릭터 검색')),
      body: Column(
        children: [
          SearchForm(onSearch: (name, server) {
            ref.read(characterProvider.notifier)
                .searchCharacter(name, server);
          }),
          if (character != null)
            CharacterCard(character: character),
        ],
      ),
    );
  }
}
```

### 3. 디렉토리 구조

```
lib/
├── models/
│   ├── character.dart         # Character 데이터 + 로직
│   ├── timeline.dart          # Timeline 데이터 + 로직
│   ├── planner_content.dart   # PlannedContent 데이터 + 로직
│   └── notifiers/
│       ├── character_notifier.dart
│       ├── timeline_notifier.dart
│       └── planner_notifier.dart
├── services/
│   ├── database_service.dart  # SQLite
│   └── api_service.dart       # Neople API
├── views/
│   ├── character_search_screen.dart
│   ├── planner_screen.dart
│   ├── statistics_screen.dart
│   └── widgets/
│       ├── character_card.dart
│       ├── planner_list.dart
│       └── search_form.dart
├── providers.dart             # 모든 Riverpod 선언
├── app.dart                   # 루트 위젯
└── main.dart
```

---

## 관심사 분리 원칙

| 계층 | 책임 | 예시 |
|------|------|------|
| **Model** | 데이터 + 비즈니스 로직 | Character 검증, Timeline 필터링 |
| **StateNotifier** | 상태 변경 + API 호출 | searchCharacter(), saveTimeline() |
| **View** | UI 렌더링만 | 레이아웃, 색상, 애니메이션 |
| **Widget** | UI 조각 | Button, Card, TextField |

**금지 사항:**
- ❌ View에서 API 호출 (State에서만)
- ❌ Model에 Widget import
- ❌ StateNotifier에 BuildContext 사용

---

## 마이그레이션 전략 (MVP→MVC)

향후 다른 패턴으로 바꾸려면:
1. Model/StateNotifier는 그대로 유지 (재사용 가능)
2. View 레이어만 교체

---

## Q&A

**Q: Model이 비대해지면?**  
A: 로직을 여러 StateParts로 분리하거나, 별도 Service 클래스 생성.

**Q: MVP/MVVM이 더 테스트하기 좋지 않나?**  
A: Riverpod StateNotifier도 충분히 테스트 가능. 메리트 비슷함.

**Q: 이 패턴을 언제까지 유지?**  
A: MVP 규모 앱까지 충분. 초대형 앱은 MVVM/Clean Architecture 고려.

---

**최종 검토일**: 2026-05-18  
**승인자**: 고성훈  
**다음 리뷰**: 12주차 UI 구현 시작
