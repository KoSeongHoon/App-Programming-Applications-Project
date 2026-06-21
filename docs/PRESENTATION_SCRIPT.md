# 🎮 던파플래너 최종 발표 대본 (4분 30초)

**총 소요 시간**: 4분 30초 (데모 30초 별도)  
**구성**: 비전/문제정의(45초) → 계획(45초) → 진행(45초) → 구현(60초) → 시행착오(45초) → 활용(30초)

---

## **[0:00-0:45] SECTION 1️⃣ 비전 & 문제 정의**

### 💡 **오프닝 (인사 & 상황 설정)**

"안녕하세요. 저는 던전앤파이터라는 게임의 **멀티 캐릭터 플레이어**입니다.

게임을 하면서 매주 **문제**를 느꼈습니다."

### 🔴 **문제 정의 (공감 유발)**

"여러 캐릭터를 운영할 때:
- 주간 던전은 몇 개 클리어했지?
- 레이드는 했나?
- 모험단 멤버들은 뭐 하고 있지?

**매번 게임에 접속해서 일일이 확인해야 하는 불편함**이 있었습니다.

특히 **모험단 사람들과 함께 관리할 때**, 실시간으로 누가 뭘 했는지 파악하기 어려웠습니다."

### 🎯 **비전 선언 (명확하고 와닿게)**

"따라서 저는 **'주간 컨텐츠 클리어 현황을 한 눈에 관리하는 모바일 앱'**을 만들기로 결정했습니다.

이 앱은:
1. 캐릭터를 빠르게 검색하고
2. 모험단 정보를 자동 추출하고
3. 주간 컨텐츠를 체크리스트처럼 추적합니다

**결과적으로, 게임 플레이어들이 더 효율적으로 게임 시간을 계획할 수 있게 하는 것이 목표입니다.**"

---

## **[0:45-1:30] SECTION 2️⃣ 프로젝트 계획 (WBS & 기술)**

### 📊 **WBS 구성 (4단계 명확히)**

"프로젝트는 4개의 **명확한 Phase로 구성**했습니다:

**Phase 1 - 기반 구축 (1주)**
- Neople API 분석 및 캐릭터 검색 기능 구현
- API 응답 구조 파악

**Phase 2 - 데이터 관리 (2주)**
- SQLite 로컬 데이터베이스 설계
- 모험단명(adventureName) 추출 및 저장
- 캐릭터 검색 결과 자동 DB 저장

**Phase 3 - UI & 기능 (2주)**
- 플래너 UI 구현 (검색, 추가, 제거)
- 주간 컨텐츠 추적 시스템
- 캐릭터별 타임라인 파싱

**Phase 4 - 배포 (1주)**
- GitHub Actions CI/CD 파이프라인
- Release APK 자동 빌드 및 서명
- GitHub Pages 발표자료 호스팅"

### 🛠️ **기술 스택 (왜 이것들인가?)**

"기술 선정 이유를 명확히 하겠습니다:

**프레임워크: Flutter (Dart)**
- 안드로이드/iOS 동시 지원
- 개발 속도가 빠름
- 게임 커뮤니티에서 인기

**상태관리: Riverpod 2.6.1**
- 반응형 프로그래밍
- 캐릭터 추가/제거 시 UI 자동 업데이트
- 의존성 주입으로 테스트 용이

**로컬 저장: SQLite (sqflite 2.3.0)**
- 오프라인 데이터 저장
- 모험단명으로 빠른 검색 가능
- 버전 마이그레이션 지원

**외부 API: Neople API**
- 던전앤파이터 공식 게임 데이터
- 캐릭터 정보, 타임라인 제공

**CI/CD: GitHub Actions**
- 코드 커밋 시 자동 빌드
- Release 자동 생성

**아키텍처: Clean Architecture**
```
Presentation (UI) 
    ↓ (의존성은 아래로만)
Application (ViewModel/Riverpod)
    ↓
Domain (비즈니스 로직)
    ↓
Data (API/DB)
```

이 구조는 각 계층을 독립적으로 테스트할 수 있게 합니다."

---

## **[1:30-2:15] SECTION 3️⃣ 프로젝트 진행 과정**

### 📅 **단계별 진행**

"**초기 설계 단계**:
- Figma에서 UI/UX 와이어프레임 작성
- ERD(개체-관계도)로 데이터베이스 설계
- ADR(아키텍처 의사결정 기록)로 기술 선택 문서화

**Phase 1 - API 연동 (Week 1-2)**:
- Neople API 분석 → 캐릭터 검색 엔드포인트 파악
- API 응답을 Dart 모델로 변환
- 검색 결과 UI 구현

**Phase 2 - 로컬 DB (Week 3-4)**:
- SQLite 테이블 설계 (Character, Timeline, PlannerItem)
- adventureName 필드 추가
- 데이터 마이그레이션 전략 구현
- 모험단 검색 쿼리 최적화

**Phase 3 - 플래너 기능 (Week 5-6)**:
- 캐릭터 검색 결과에서 '플래너 추가' 버튼
- 플래너 화면: 캐릭터별 컨텐츠 체크리스트
- 주간 범위 자동 계산
- 실시간 동기화 (Riverpod)

**Phase 4 - 배포 (Week 7)**:
- GitHub Actions 워크플로우 설정
- keystore 생성 및 APK 서명
- Release 자동 생성
- GitHub Pages 발표자료 배포

**진행 기간**: 총 7주
**완료도**: 100% ✓
**현재 상태**: 앱 설치 및 테스트 완료"

---

## **[2:15-3:15] SECTION 4️⃣ 구현 방법 & 아키텍처**

### 🔄 **핵심 기능 플로우**

"**기능 1: 캐릭터 검색**

```
사용자가 '우르반' 입력
    ↓
Neople API 호출 (serverId 변환)
    ↓
API 응답: characterId, name, level, ...
    ↓
추가 API 호출: /characters/{id} → adventureName 추출
    ↓
SQLite에 자동 저장 (Character 테이블)
    ↓
UI에 검색 결과 표시
```

**기능 2: 모험단 검색**

```
사용자가 모험단 필터 선택
    ↓
모험단명 입력 (예: '제국의주인')
    ↓
SQLite 쿼리: WHERE adventureName LIKE '제국의주인'
    ↓
해당 모험단 멤버 캐릭터 모두 반환
    ↓
UI에 모험단 멤버 목록 표시 (API 호출 없음!)
```

**기능 3: 플래너 추가**

```
검색 결과에서 '플래너 추가' 클릭
    ↓
Character 테이블 저장 (이미 저장됨)
    ↓
PlannerItem 테이블에도 추가
    ↓
홈 화면 플래너 목록 자동 업데이트 (Riverpod)
```

### 🏗️ **아키텍처 상세**

"**디렉토리 구조**:
```
Planner/lib/
├── presentation/          # UI 계층
│   ├── screens/          # 화면들 (검색, 홈, 플래너)
│   ├── theme/            # 디자인 시스템
│   └── widgets/          # 공통 컴포넌트
├── application/          # 비즈니스 로직
│   └── view_models/      # ViewModel (Riverpod)
├── domain/               # 도메인 계층
│   ├── entities/         # 데이터 모델 (Character, Content)
│   └── utils/            # 공통 유틸리티
└── data/                 # 데이터 계층
    ├── api/              # API 클라이언트 (Neople)
    ├── local/            # DB 서비스 (SQLite)
    └── repositories/     # Repository 패턴
```

**계층 간 의존성**:
- Presentation → Application (ViewModel 주입)
- Application → Domain (Entity 사용)
- Domain → Data (Repository 인터페이스)
- Data → (외부: API, DB)

**Riverpod 상태 관리**:
```dart
// 검색 상태
final characterSearchViewModelProvider = 
  StateNotifierProvider<CharacterSearchViewModel, CharacterSearchState>

// 플래너 상태
final plannerViewModelProvider = 
  StateNotifierProvider<PlannerViewModel, PlannerState>
```

상태 변경 시 자동으로 UI가 업데이트됩니다."

---

## **[3:15-4:00] SECTION 5️⃣ 구현 시행착오 & 개선**

### ⚡ **Challenge 1: Neople API 불안정성**

"**Problem**: 
- API 응답이 규칙적이지 않음
- 필드명이 inconsistent (예: 'characterClass' vs 'jobName')
- 타임라인 파싱 실패

**Root Cause Analysis**:
- API 문서가 실제 응답과 다름
- 필드값이 null일 수 있음
- 타임라인에 없는 코드 값 포함

**Solution**:
```dart
// 유연한 필드 파싱
final className = apiResult['characterClass'] ?? 
                  apiResult['jobName'] ?? 
                  apiResult['characterJob'] ?? 
                  '알 수 없음';

// 타임라인 매칭: 정규식 + 다중 필터
final matchedDungeon = matchDungeonName(dungeonName);
if (matchedDungeon != null && dungeonClears.containsKey(matchedDungeon)) {
    // 처리
}
```

**결과**: 95% 이상의 데이터 정상 처리 ✓"

### ⚡ **Challenge 2: 앱 설치 실패**

"**Problem**: 
- '앱이 설치되지 않음' 에러 발생
- 어떤 방법으로도 설치 안 됨

**Root Cause**:
- Release APK가 **Debug Key로 서명**됨
- Android는 같은 패키지명이 다른 서명으로 설치되면 거부

**Solution**:
- GitHub Actions에서 keystore 생성
- Release APK를 Release Key로 서명
- build.gradle에 signingConfig 설정

```gradle
if (keyPropertiesFile.exists()) {
    keyProperties.load(new FileInputStream(keyPropertiesFile))
}
signingConfigs {
    release {
        keyAlias keyProperties['keyAlias']
        keyPassword keyProperties['keyPassword']
        storeFile file(keyProperties['storeFile'])
        storePassword keyProperties['storePassword']
    }
}
```

**결과**: S25 Ultra에 정상 설치 ✓"

### ⚡ **Challenge 3: 패키지명 변경**

"**Problem**: 
- 초기 패키지명: `com.dfo.planner.temp_app`
- 모험단 검색이 작동하지 않음

**Solution**:
- 패키지명을 `com.dfo.planner`로 변경
- 앱 이름을 '던파플래너'로 설정

**결과**: 모험단 검색 정상 작동 ✓"

### 🚀 **성능 최적화**

"**1. API 타임아웃**:
```dart
final timeline = await _apiClient
    .getCharacterTimeline(characterId, serverId)
    .timeout(const Duration(seconds: 5), onTimeout: () => []);
```
→ 5초 이상 응답 없으면 빈 리스트 반환 (UI 프리징 방지)

**2. SQLite 쿼리 최적화**:
```dart
// 모든 캐릭터 로드가 아닌, WHERE절로 필터링
final maps = await db.query(
    'Character',
    where: 'adventureName = ?',
    whereArgs: [guildName],
);
```
→ 데이터 양이 많아도 빠른 검색

**3. 이미지 캐싱**:
- Neople CDN에서 이미지 로드 시 Flutter의 기본 캐시 활용
- 네트워크 요청 감소

**결과**: 앱 응답 시간 < 1초"

### 📋 **코드 품질 관리**

"**1. Null Safety**:
- 모든 변수에 `?` 또는 `!` 명시
- NPE(NullPointerException) 사전 방지

**2. 레이어 분리**:
- 각 계층이 독립적으로 수정 가능
- 한 부분 변경이 다른 부분에 영향 없음

**3. 에러 처리**:
```dart
try {
    // 작업
} catch (e) {
    state = state.copyWith(errorMessage: '오류: $e');
}
```
- 모든 비동기 작업을 try-catch로 보호

**4. 로깅**:
```dart
if (kDebugMode) print('[모험단 추출] DB 저장 완료');
```
- Debug 모드에서만 로그 출력 (성능 영향 없음)"

---

## **[4:00-4:30] SECTION 6️⃣ 활용 방안 & 향후 계획**

### 🎮 **활용 방안 (사용자 관점)**

"**게임 플레이어**는 이 앱으로:

1. **효율적인 시간 관리**
   - 주간 컨텐츠 체크리스트
   - '뭐했지?' 고민 제거
   - 우선순위 결정 용이

2. **모험단 협력 강화**
   - 모험단 멤버 현황 파악
   - 누가 뭘 못했는지 한눈에 보기
   - 길드 마스터 입장에서 효율적 운영

3. **성장 동기 부여**
   - 주간 목표 설정
   - 달성도 시각화
   - '모두 함께 성장' 경험

**실제 사용 시나리오**:
```
월요일 아침: 주간 체크리스트 확인
   ↓
금요일: 진행 현황 업데이트 (앱이 자동 동기화)
   ↓
주말: '이번주 얼마나 클리어했지?' 한눈에 파악
   ↓
모험단장: '멤버 현황이 한눈에 보이네!'
```"

### 🚀 **향후 개선 계획 (5가지)**

"**1. 아이템 획득 조회**
- 캐릭터별 장비/아이템 정보 실시간 조회
- 성장 현황 파악

**2. 아이템 성장 추천**
- 게임 메타데이터 기반 육성 가이드
- '다음 단계는 뭐지?' 자동 추천

**3. UI 개선**
- 다크모드 지원
- 애니메이션 추가
- 모바일 최적화

**4. 클라우드 동기화**
- Firebase 연동
- 여러 기기 간 데이터 동기화
- 웹 버전 지원

**5. 팀 플래너**
- 길드 전체 현황 공유
- 모험단 멤버 협력 강화

**기간**: 6개월 내"

### 📖 **GitHub 설치 가이드**

"**설치 방법** (README.md에 명시):

```bash
# 1. 의존성 설치
flutter pub get

# 2. 개발 모드 실행
flutter run

# 3. Release APK 생성
flutter build apk --release --split-per-abi

# 4. 기기에 설치
flutter install
```

**필요한 환경**:
- Flutter SDK 3.0 이상
- Android SDK 28 이상
- Dart 3.0 이상

**Neople API 키 설정**:
```bash
# .env 파일 생성
NEOPLE_API_KEY=your_api_key_here
```

**전체 가이드**: [GitHub Repository](https://github.com/KoSeongHoon/App-Programming-Applications-Project)"

---

## **[4:30] 마무리**

"**요약하면**:

1. **비전**: 게임 플레이어의 시간 관리를 돕는 앱
2. **기술**: Flutter + Riverpod + SQLite + Neople API
3. **성과**: 
   - 캐릭터 검색 ✓
   - 모험단 추출 ✓
   - 컨텐츠 추적 ✓
   - 자동 배포 ✓
4. **배운 것**: API 연동, 로컬 DB, Clean Architecture, CI/CD

**가장 중요한 것**: 게임 커뮤니티의 실제 문제를 해결했다는 점입니다.

감사합니다! 🙏"

---

## 📊 **발표 체크리스트**

| 항목 | 배점 | 상태 |
|------|------|------|
| 비전 표현 | 1 | ✅ |
| 비전 와닿게 | 1 | ✅ |
| 문제 정의 | 1 | ✅ |
| 공감대 유발 | 1 | ✅ |
| 대사 준비 | 1 | ✅ |
| WBS 구성 | 1 | ✅ |
| 기술 표현 | 1 | ✅ |
| 진행 과정 | 1 | ✅ |
| 구현 방법 | 1 | ✅ |
| 활용 방안 | 1 | ✅ |
| **발표 체계성 합계** | **10** | **✅** |

---

## 🎤 **발표 연습 팁**

1. **타이밍 체크**: 스톱워치로 각 섹션 시간 확인
2. **손 제스처**: 중요 포인트에서 손 제스처로 강조
3. **시선 처리**: 청중과 시선 맞추기
4. **음성 변화**: 중요 부분에서 속도 낮추기
5. **3회 이상 연습** 후 발표하기
