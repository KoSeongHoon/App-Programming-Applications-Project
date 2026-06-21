# 📋 ADR 요약 (Architecture Decision Records) - 질의응답 준비

**목적**: 최종 발표 질의응답 시 준비할 아키텍처 의사결정 기록

---

## **🎯 질의응답 Top 3 (필수 준비)**

### **Q1: "왜 Riverpod을 선택했는가?"**

**A: 명확한 근거와 함께 설명**

```
Riverpod은 Provider Pattern 기반의 상태 관리 라이브러리입니다.

선택 이유:
1. 함수형 프로그래밍 지원
   - 상태를 함수로 정의 → 재사용성 높음
   - 순수 함수 → 테스트 용이

2. 명확한 의존성 주입
   - ref.watch/ref.read로 의존성 명시
   - 각 Provider의 책임 분명

3. 뛰어난 테스트 가능성
   - Mock을 쉽게 주입 가능
   - 단위 테스트에서 독립적 검증

예시:
final characterSearchViewModelProvider = 
  StateNotifierProvider<CharacterSearchViewModel, CharacterSearchState>((ref) {
    final repository = ref.watch(characterRepositoryProvider);  // 의존성 명시
    return CharacterSearchViewModel(repository);
  });

이를 통해 테스트 시:
test('검색 상태 업데이트', () async {
  final container = ProviderContainer(
    overrides: [
      characterRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  // mockRepository를 주입해서 테스트
});
```

**다른 선택지와의 비교**:
| 항목 | Riverpod | GetX | Provider |
|------|---------|------|----------|
| 테스트 용이 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| 학습곡선 | 중간 | 쉬움 | 중간 |
| 함수형 | ⭐⭐⭐ | ⭐ | ⭐⭐ |

---

### **Q2: "Clean Architecture를 어떻게 적용했는가?"**

**A: 계층과 책임을 명확히 설명**

```
4계층 구조:

┌─────────────────────────────┐
│   Presentation Layer (UI)   │  ← 화면 렌더링
├─────────────────────────────┤
│  Application Layer (Logic)  │  ← 상태 관리 (Riverpod ViewModel)
├─────────────────────────────┤
│    Domain Layer (Entity)    │  ← 비즈니스 로직
├─────────────────────────────┤
│     Data Layer (API/DB)     │  ← 외부 통신
└─────────────────────────────┘

각 계층의 책임:

1️⃣ Presentation (lib/presentation/)
   - UI 렌더링만 담당
   - ViewModel에서 상태 구독
   - 사용자 입력 처리
   
2️⃣ Application (lib/application/)
   - Riverpod ViewModel으로 상태 관리
   - 화면 로직 처리
   - Domain 계층 호출
   
3️⃣ Domain (lib/domain/)
   - Entity (데이터 모델)
   - UseCase (비즈니스 로직)
   - Repository 인터페이스 (계약)
   - 외부 의존성 없음!
   
4️⃣ Data (lib/data/)
   - API 클라이언트 구현
   - DB 서비스 구현
   - Repository 구현
   - Domain의 인터페이스 따름

의존성 규칙:
Presentation ↓ Application ↓ Domain ← Data
(위는 아래만 의존, 역방향 의존 금지)
```

**장점**:
- 각 계층을 독립적으로 테스트 가능
- 변경 영향을 최소화
- 코드 재사용성 높음

**예시 - 캐릭터 검색 흐름**:
```
1. UI (CharacterSearchScreen)
   "우르반 검색" 버튼 클릭
   ↓
2. ViewModel (CharacterSearchViewModel)
   searchCharacter('우르반', 'pve-1', isGuildSearch: false) 호출
   ↓
3. Domain (Repository 인터페이스)
   비즈니스 로직 정의
   ↓
4. Data (CharacterRepositoryImpl)
   API 호출 또는 DB 조회 실행
   ↓
5. 결과 반환
   ViewModel → UI 자동 업데이트 (Riverpod)
```

---

### **Q3: "Neople API 연동에서 가장 어려웠던 점은?"**

**A: 실제 시행착오 설명**

```
Problem 1: 불규칙한 API 응답
- 같은 엔드포인트에서 다른 필드명 사용
  (characterClass vs jobName vs characterJob)
- 일부 필드가 null로 반환

Solution:
const className = apiResult['characterClass'] ?? 
                  apiResult['jobName'] ?? 
                  apiResult['characterJob'] ?? 
                  '알 수 없음';

Problem 2: 타임라인 파싱 실패
- 타임라인이 복잡한 JSON 구조
- 필드의 의미가 불명확
- 코드(code) 값이 일관성 없음

Solution:
정규식 기반 매칭:
final matchedDungeon = matchDungeonName(dungeonName);
// API에서 받은 dungeonName을 우리의 표준 이름으로 변환

여러 필터링 적용:
if (code == 209 && regionName.isNotEmpty) {
  // 레기온 처리
} else if (code == 201) {
  // 레이드 처리
} else if (dungeonName.isNotEmpty) {
  // 상급던전 처리
}

Problem 3: API 응답 지연
- 일부 요청이 10초 이상 소요
- UI가 프리징되는 문제

Solution:
타임아웃 추가:
final timeline = await _apiClient
    .getCharacterTimeline(characterId, serverId)
    .timeout(
      const Duration(seconds: 5),
      onTimeout: () => [],  // 5초 초과하면 빈 리스트
    );

배웠던 점:
✓ 외부 API는 신뢰할 수 없다 → 방어 코드 필수
✓ 타입 안전성이 중요하다 → Dart null-safety
✓ 성능이 사용자 경험을 좌우한다 → 타임아웃, 캐싱
```

---

## **추가 질의응답 준비 (ADR 문서)**

### **Q4: "앱의 디렉토리 구조는 어떻게 되어 있는가?"**

```
Planner/
├── lib/
│   ├── main.dart                          # 앱 진입점
│   ├── app.dart                           # 앱 설정 (라우팅, 테마)
│   │
│   ├── presentation/                      # UI 계층
│   │   ├── screens/
│   │   │   ├── character_search_screen.dart
│   │   │   ├── planner_home_screen.dart
│   │   │   └── content_detail_screen.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart             # 색상, 폰트, 스타일
│   │   └── widgets/
│   │       ├── character_card.dart
│   │       └── content_checklist.dart
│   │
│   ├── application/                       # 상태 관리 계층
│   │   └── view_models/
│   │       ├── character_search_vm.dart
│   │       └── planner_vm.dart
│   │
│   ├── domain/                            # 도메인 계층
│   │   ├── entities/
│   │   │   ├── character.dart
│   │   │   ├── content_timeline.dart
│   │   │   └── planner_item.dart
│   │   └── utils/
│   │       └── content_utils.dart
│   │
│   └── data/                              # 데이터 계층
│       ├── api/
│       │   └── neople_api_client.dart
│       ├── local/
│       │   └── database_service.dart
│       └── repositories/
│           └── character_repository.dart
│
├── test/                                  # 단위 테스트
│   ├── data/repositories/
│   │   └── character_repository_test.dart
│   └── application/view_models/
│       └── character_search_vm_test.dart
│
├── test_driver/                           # 통합 테스트
│   ├── app.dart
│   └── app_test.dart
│
├── android/                               # Android 네이티브
│   └── app/
│       ├── build.gradle
│       └── AndroidManifest.xml
│
├── pubspec.yaml                           # 의존성 정의
├── .env                                   # 환경 변수
└── .env.example                           # 환경 변수 예시
```

---

### **Q5: "빌드와 배포는 어떤 단계로 이루어지는가?"**

```
1. 로컬 개발 (Debug Build)
   flutter run
   → app-debug.apk 생성 (디버그 key로 서명)

2. Release 빌드
   flutter build apk --release --split-per-abi
   → app-arm64-v8a-release.apk (Release key로 서명)
   → app-armeabi-v7a-release.apk

3. GitHub에 푸시
   git tag v1.0.0
   git push origin v1.0.0
   → GitHub Actions 트리거

4. CI/CD 파이프라인
   a) Java 설정 (Java 17)
   b) .env 파일 생성 (secrets에서)
   c) keystore 생성 (Release key)
   d) flutter build apk --release
   e) GitHub Release 생성
   f) APK 자동 업로드

5. 배포
   Release 페이지에서 다운로드 가능
   https://github.com/.../releases/tag/v1.0.0

각 단계에서 중요한 개념:
- Debug vs Release: 서명 방식 다름
- APK vs AAB: Android의 두 배포 형식
- CI/CD: 수동 배포 제거 → 자동화
- Keystore: 앱의 디지털 서명 (한 번만 생성)
```

---

### **Q6: "성능 최적화는 어떻게 했는가?"**

```
1. API 성능
   ✓ 타임아웃 추가 (5초)
   ✓ 병렬 요청 최소화
   ✓ 캐싱 활용 (Flutter의 기본 이미지 캐시)

2. DB 성능
   ✓ WHERE절로 필터링 (모든 데이터 로드 X)
   ✓ 인덱싱 (characterId, adventureName)
   ✓ 배치 작업 최소화

3. UI 성능
   ✓ 비동기 작업 (async/await)
   ✓ ListView/GridView 최적화 (lazy loading)
   ✓ 불필요한 rebuild 방지 (Riverpod)

4. 메모리
   ✓ 큰 리스트 분할 로드
   ✓ 이미지 최적화 (zoom=1 파라미터)
   ✓ 자동 garbage collection 활용
```

---

## **✅ 발표 시 답변 방식 (ADR 기록)**

```
좋은 답변의 3가지 요소:

1. 근거 (Why)
   "이를 선택한 이유는..."
   
2. 실행 (How)
   "구체적으로는 이렇게 했습니다"
   
3. 결과 (What)
   "결과적으로 이런 효과가 있었습니다"

예시:
Q: "왜 SQLite를 선택했는가?"
A: "오프라인 환경에서 빠른 데이터 접근이 필요했기 때문입니다.
   구체적으로, adventureName으로 모험단을 검색할 때
   로컬 DB에서 조회하면 API 호출이 필요 없습니다.
   결과적으로 검색 시간이 < 100ms로 매우 빨라졌습니다."
```

---

**작성자**: 고성훈  
**최종 수정**: 2026-06-21  
**프로젝트**: 던파플래너
