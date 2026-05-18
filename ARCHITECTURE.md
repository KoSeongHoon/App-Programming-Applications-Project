# 아키텍처 — 4-Layer Architecture

던전앤파이터 플래너 앱의 아키텍처는 Clean Architecture의 4-Layer 패턴을 따릅니다.

---

## 📐 4개 계층 구조

```
┌─────────────────────────────────────────────┐
│  Presentation Layer                         │
│  (UI, Screen, View, Widget)                 │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│  Application Layer                          │
│  (ViewModel, UseCase, Provider, State)      │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│  Domain Layer                               │
│  (Entity, Service, Rule, UseCase)           │
└────────────────┬────────────────────────────┘
                 ↓
┌─────────────────────────────────────────────┐
│  Data Layer                                 │
│  (Repository, API, DB, Model)               │
└─────────────────────────────────────────────┘
```

---

## 🏗️ 디렉토리 구조 (파일 위치로 구성)

```
lib/
├── main.dart                           # 앱 진입점
├── app.dart                            # 루트 위젯 (MaterialApp)
│
├── presentation/                       # 🎨 UI 계층 (screens/, widgets/, theme/)
│   ├── screens/
│   │   ├── character_search_screen.dart
│   │   ├── planner_screen.dart
│   │   └── timeline_screen.dart
│   │
│   ├── widgets/
│   │   ├── character_card.dart
│   │   ├── planner_list_item.dart
│   │   ├── timeline_list.dart
│   │   └── search_form.dart
│   │
│   └── theme/
│       ├── app_theme.dart
│       └── colors.dart
│
├── application/                        # 🔄 상태 관리 계층 (view_models/, use_cases/)
│   ├── view_models/
│   │   ├── character_search_vm.dart
│   │   ├── planner_vm.dart
│   │   └── timeline_vm.dart
│   │
│   └── use_cases/
│       ├── search_character_uc.dart
│       ├── update_planned_content_uc.dart
│       └── match_timeline_uc.dart
│
├── domain/                             # 💼 비즈니스 로직 계층 (entities/, services/)
│   ├── entities/
│   │   ├── character.dart
│   │   ├── planned_content.dart
│   │   └── timeline.dart
│   │
│   └── services/
│       ├── character_service.dart
│       └── timeline_service.dart
│
└── data/                               # 💾 외부 데이터 계층 (repositories/, api/, local/)
    ├── repositories/
    │   ├── character_repository.dart
    │   ├── planner_repository.dart
    │   └── timeline_repository.dart
    │
    ├── api/
    │   ├── neople_api_client.dart
    │   ├── models/
    │   │   ├── character_model.dart
    │   │   └── timeline_model.dart
    │   └── services/
    │       └── http_service.dart
    │
    └── local/
        ├── database_service.dart
        ├── models/
        │   └── planned_content_model.dart
        └── migrations/
            └── v1_schema.dart
```

---

## 📊 각 계층별 책임

### 1️⃣ Presentation Layer (UI만 담당)
- UI 렌더링
- 사용자 이벤트 감지
- ViewModel에 이벤트 전달
- 금지: 비즈니스 로직, API 호출, DB 접근

### 2️⃣ Application Layer (상태 관리)
- Riverpod Provider로 상태 관리
- ViewModel에서 UI 이벤트 처리
- Domain 계층(UseCase) 호출
- 로딩/에러 상태 관리

### 3️⃣ Domain Layer (비즈니스 로직)
- Entity 정의 (Character, PlannedContent, Timeline)
- UseCase 구현
- 타임라인 매칭 알고리즘
- 외부 라이브러리 최소화 (순수 Dart)

### 4️⃣ Data Layer (외부 데이터)
- Neople API 호출
- SQLite 읽고 쓰기
- Model ↔ Entity 변환
- Repository 구현

---

## 🔄 데이터 흐름

캐릭터 검색 예시:
```
User clicks "Search"
    ↓
Presentation calls ViewModel.searchCharacter()
    ↓
ViewModel calls UseCase.execute()
    ↓
UseCase calls Repository.searchCharacter()
    ↓
Repository calls ApiClient → Neople API
    ↓
Repository converts Model → Entity
    ↓
Repository saves to Database
    ↓
UseCase applies business logic (validation)
    ↓
ViewModel updates state
    ↓
UI displays Character data
```

---

**작성일**: 2026-05-18  
**패턴**: 4-Layer Clean Architecture  
**상태 관리**: Riverpod  
**DB**: SQLite  
**API**: Neople API
