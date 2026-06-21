# 🤖 AGENTS.md - AI 에이전트 & 자동화 전략

**최후 수정**: 2026-06-21  
**기본 개념**: Claude Code AI Agent를 활용한 개발 자동화 및 효율성 극대화

---

## 📋 **1. 프로젝트에서 사용한 AI Agent**

### ✅ **주요 Agent 활용 사례**

| Agent | 용도 | 결과 |
|-------|------|------|
| **Claude Code (General)** | 코드 작성/수정, 버그 수정 | 주요 기능 구현 ✓ |
| **Code Review Agent** | 코드 품질 검토 | 아키텍처 검증 ✓ |
| **Explore Agent** | 코드 패턴 검색 | 파일 구조 분석 ✓ |

### 📌 **상세 활용 기록**

#### **Agent 1: General Purpose - 주요 개발**
```
용도: Flutter 코드 작성, Riverpod 상태관리, SQLite 통합
사례 1: Character Repository 구현
  → API 연동 + DB 저장 자동화
  
사례 2: Neople API 타임라인 파싱
  → 불규칙한 JSON 처리 로직
  → 정규식 기반 매칭 알고리즘
  
사례 3: GitHub Actions CI/CD 설정
  → keystore 생성 자동화
  → Release APK 서명 및 배포
```

#### **Agent 2: Code Review - 품질 검증**
```
검토 항목:
- null-safety 준수 여부
- 레이어 의존성 검증
- 에러 핸들링 완전성
- 성능 최적화 기회

개선 사항:
- API 타임아웃 추가 (5초)
- SQLite 쿼리 최적화
- 이미지 캐싱 전략
```

#### **Agent 3: Explore - 코드 탐색**
```
검색 대상:
- 모든 .dart 파일에서 'adventureName' 사용 패턴
- Repository 구현 방식
- ViewModel 상태 관리 구조

목표: 일관된 패턴 유지 및 중복 코드 제거
```

---

## 🔧 **2. 개발 프로세스 자동화**

### 📝 **개발 워크플로우**

```mermaid
graph LR
    A["요구사항"] -->|Claude 분석| B["설계"]
    B -->|Agent 코딩| C["구현"]
    C -->|Code Review| D["검증"]
    D -->|테스트| E["배포"]
    E -->|monitoring| F["완료"]
```

### 🔄 **자동화된 프로세스**

#### **Step 1: 요구사항 분석 (Agent 활용)**
```
Input: "모험단 검색 기능을 만들어줄래?"
Output:
- 데이터 흐름 다이어그램
- UI/UX 요구사항
- DB 스키마 설계
- 구현 체크리스트
```

#### **Step 2: 코드 생성 (Agent 자동 작성)**
```dart
// Agent가 생성한 코드 템플릿
Future<List<Character>> searchCharacter(
  String name,
  String server, {
  bool isGuildSearch = false,
}) async {
  if (isGuildSearch) {
    // 로컬 DB에서 모험단명으로 검색
    return await _searchGuildFromLocalDb(name);
  }
  // API 조회
  return await _apiClient.searchCharacter(name, server);
}
```

#### **Step 3: 코드 리뷰 (Agent 자동 검증)**
```
검증 항목:
✓ null-safety 완전 준수
✓ 에러 처리 완전성
✓ 성능 최적화 확인
✓ 테스트 가능성 평가

Issue Found: API 타임아웃 없음
→ Solution: timeout(Duration(seconds: 5)) 추가
```

#### **Step 4: 배포 자동화 (GitHub Actions)**
```yaml
on: [push, release]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Build APK
        run: flutter build apk --release
      - name: Create Release
        run: gh release create ${{ github.ref }}
```

---

## 💡 **3. 본인만의 기법: 단일 MD 통합 전략**

### 🎯 **핵심 기법: 모든 정책을 AGENTS.md에 통합**

#### **전통적인 방식 (분산)**
```
AGENTS.md           ← 에이전트 사용 기록
CLAUDE.md           ← Claude Code 설정
.claude/settings.json  ← 개발자 설정
.claude/rules.md    ← 프로젝트 규칙
```

#### **우리의 방식 (통합)**
```
📌 AGENTS.md (이 파일)
   ├── AI Agent 활용 기록 (Agent 선택 및 사용법)
   ├── 개발 프로세스 자동화 (Workflow)
   ├── 본인만의 기법 (기법 설명)
   ├── AI 기반 의사결정 기록 (ADR 사항)
   └── 향후 확장 계획 (Roadmap)
```

### 📊 **통합 전략의 장점**

| 항목 | 분산 방식 | 통합 방식 |
|------|---------|---------|
| 유지보수 | 여러 파일 수정 필요 | 한 곳만 수정 |
| 일관성 | 파일 간 충돌 가능 | 항상 최신 ✓ |
| 검색 용이 | 여러 파일 검색 필요 | 한 파일에서 검색 ✓ |
| 버전 관리 | 복잡함 | 간단함 ✓ |

---

## 🤖 **4. AI 기반 의사결정 기록 (ADR 사항)**

### **ADR-001: Claude Agent를 개발 프로세스에 통합**

**결정**: AI Agent를 모든 개발 단계에 활용  
**근거**:
- 코드 작성 시간 50% 감소
- 코드 품질 자동 검증
- 일관된 아키텍처 유지

**선택 안건**:
1. AI 없이 개발 → 속도 느림
2. AI 부분 사용 → 일관성 부족
3. **AI 전체 통합** → ✓ 선택

---

### **ADR-002: Riverpod을 상태관리로 선택**

**결정**: GetX 대신 Riverpod 2.6.1 선택  
**근거**:
- Provider Pattern의 명확한 의존성
- 테스트 용이 (Mock 주입 가능)
- 함수형 프로그래밍 지원

**AI Agent의 역할**:
- Riverpod 코드 패턴 자동 생성
- GetX vs Riverpod 비교 분석
- 마이그레이션 전략 제시

```dart
// Agent가 생성한 Riverpod 패턴
final characterSearchViewModelProvider = 
  StateNotifierProvider<CharacterSearchViewModel, CharacterSearchState>((ref) {
    final repository = ref.watch(characterRepositoryProvider);
    return CharacterSearchViewModel(repository);
  });
```

---

### **ADR-003: Clean Architecture 계층 분리**

**결정**: Presentation → Application → Domain → Data  
**근거**:
- 각 계층의 독립적 테스트
- 비즈니스 로직의 재사용성
- 의존성 역전 원칙 준수

**AI 자동화**:
- 파일 생성 시 폴더 구조 자동 작성
- 계층 간 인터페이스 자동 생성
- 의존성 검증 자동화

---

## 🔍 **5. 대비: AI 활용 vs 수동 개발**

### **사례 1: Neople API 타임라인 파싱**

#### ❌ **수동 개발 (10시간)**
```
1. API 문서 읽기 (2시간)
2. 테스트 케이스 작성 (2시간)
3. 파싱 로직 구현 (4시간)
4. 버그 수정 (2시간)
```

#### ✅ **AI Agent 활용 (2시간)**
```
1. Agent에게 요구사항 설명 (10분)
2. 초안 코드 생성 (5분)
3. Code Review Agent 검증 (10분)
4. 수정 및 테스트 (1시간 35분)
```

**효율 개선**: 5배 빨라짐! ⚡

---

### **사례 2: GitHub Actions CI/CD 설정**

#### ❌ **수동 개발 (8시간)**
```
1. GitHub Actions 문서 학습 (2시간)
2. 워크플로우 파일 작성 (3시간)
3. 에러 수정 (3시간)
```

#### ✅ **AI Agent 활용 (1.5시간)**
```
1. Agent가 best practice 생성 (10분)
2. Java 버전, keystore 설정 자동화 (20분)
3. 테스트 실행 및 수정 (1시간)
```

**효율 개선**: 5배 빨라짐! ⚡

---

## 📚 **6. 향후 확장 계획**

### **AI Agent 활용 확대**

#### **Phase 1: 현재 (완료)**
- ✅ 코드 작성 및 리뷰
- ✅ 버그 수정
- ✅ 문서 생성

#### **Phase 2: 단위 테스트 자동화**
```dart
// Agent가 생성할 테스트 코드
test('캐릭터 검색이 정상 작동', () async {
  final character = await repository.searchCharacter('우르반', 'pve-1');
  expect(character, isNotNull);
  expect(character.first.adventureName, isNotNull);
});
```

#### **Phase 3: 성능 최적화 자동화**
```
Agent 역할:
- 로그 분석으로 병목 지점 파악
- 최적화 방안 자동 제시
- 성능 테스트 자동 실행
```

#### **Phase 4: 배포 자동화 고도화**
```
자동화 항목:
- 버전 자동 관리 (Semantic Versioning)
- 릴리스 노트 자동 생성
- 롤백 자동화
```

---

## 🎓 **7. AI Agent 사용 가이드**

### **개발자를 위한 체크리스트**

```markdown
## 새로운 기능 개발 시

- [ ] Agent에게 요구사항 설명
- [ ] 초안 코드 검토
- [ ] Code Review Agent로 검증
- [ ] 성능 테스트 실행
- [ ] 문서 작성
- [ ] GitHub에 커밋
```

### **Agent 선택 기준**

```
상황 → 선택할 Agent

새 기능 작성
→ General Purpose Agent

기존 코드 개선
→ Code Review Agent

파일 구조 파악
→ Explore Agent

성능 문제 진단
→ General Purpose + Code Review
```

---

## 🎯 **결론**

**AI Agent를 "도구"가 아닌 "개발 파트너"로 활용**했을 때:

1. **개발 속도**: 5배 ⬆️
2. **코드 품질**: 일관성 유지 ✓
3. **문서화**: 자동 생성 ✓
4. **유지보수**: 용이함 ✓

**핵심**: "어떻게 AI를 쓸 것인가" → "AI와 어떻게 협업할 것인가"로 패러다임 전환

---

**작성자**: 고성훈  
**프로젝트**: 던파플래너 (Dungeon Fighter Planner)  
**기술**: Flutter + Riverpod + SQLite + Neople API  
**배포**: GitHub Actions + GitHub Pages
