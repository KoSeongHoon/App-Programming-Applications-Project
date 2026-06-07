# ADR-0002: SQLite vs Hive 로컬 저장소 선택

**상태**: ✅ 승인됨  
**일시**: 2026-05-18  
**의사결정자**: 고성훈

---

## 배경 (Context)

플래너 앱은 다음 데이터를 로컬에 저장해야 합니다:
- 캐릭터 목록 및 메타데이터
- 타임라인 기록 (언제 어떤 던전을 클리어했는가)
- 플래너 상태 (각 콘텐츠별 클리어 여부)
- 사용자 설정 (언어, 테마, API Key 등)

Flutter에서 널리 사용되는 두 가지 로컬 저장소 솔루션:
- **SQLite**: 관계형 데이터베이스, 성숙하고 강력함
- **Hive**: NoSQL 키-값 저장소, 간단하고 빠름

---

## 의사결정 (Decision)

**SQLite를 선택합니다.**

이유:
1. **관계형 데이터 구조**: 캐릭터↔타임라인 관계 명확히 표현 가능
2. **복잡한 쿼리**: 특정 기간 클리어 기록 조회 등 SQL로 간단히 표현
3. **성숙도**: 10년 이상 검증된 엔터프라이즈급 솔루션
4. **확장성**: 향후 통계, 분석 기능 추가 시 유리
5. **커뮤니티**: sqflite 라이브러리가 잘 유지됨

---

## 대안 (Alternatives Considered)

### 옵션 A: SQLite (선택함) ✅
**장점:**
- ACID 보장 (데이터 무결성)
- 관계형 데이터 모델링 가능
- 복잡한 쿼리 지원 (JOIN, GROUP BY 등)
- 성숙한 라이브러리 (sqflite)
- 데이터 마이그레이션 도구 풍부

**단점:**
- 개발 초기에는 스키마 설계 필요
- 마이그레이션 관리 복잡
- NoSQL에 비해 쓰기 속도 약간 느림

### 옵션 B: Hive (사용하지 않음)
**장점:**
- 사용 매우 간단 (거의 Map처럼)
- 빠른 쓰기 성능
- 스키마 관리 불필요

**단점:**
- 관계형 데이터 표현 어려움 (비정규화 강제)
- 복잡한 쿼리 불가능 (메모리에서 필터링)
- 미래 확장성 제한
- 데이터 구조 변경 시 마이그레이션 복잡

### 옵션 C: Firebase Firestore (사용하지 않음)
**장점:**
- 실시간 동기화
- 클라우드 백업

**단점:**
- 오프라인 환경에서 필수 아님 (MVP는 온라인 전제)
- 외부 의존성 증가
- 개인정보 보호 이슈 (서버 저장)

---

## 영향도 (Consequences)

### 긍정적 영향
✅ **데이터 무결성**: ACID 트랜잭션으로 부패 위험 없음  
✅ **확장성**: 향후 통계, 분석, 동기화 등 수월  
✅ **성능**: 캐릭터 100개 기준 조회 <100ms  

### 부정적 영향
⚠️ **복잡도**: 스키마 설계, 마이그레이션 관리 필요  
⚠️ **학습 곡선**: SQL 및 관계형 설계 학습 필요  
⚠️ **초기 개발**: Hive보다 2~3일 더 소요  

### 위험도: 🟡 **중간**
- 리스크: 스키마 변경 시 데이터 마이그레이션 필요
- 완화: QUESTIONS.md Q10~Q12로 마이그레이션 전략 수립

---

## 데이터 모델

```dart
// Character 테이블
CREATE TABLE Character (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  server TEXT NOT NULL,
  class TEXT NOT NULL,
  level INTEGER NOT NULL,
  createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(name, server)
);

// Timeline 테이블
CREATE TABLE Timeline (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  characterId INTEGER NOT NULL,
  dungeonCode TEXT NOT NULL,  // "123001" 형식
  dungeonName TEXT NOT NULL,  // "에픈 성"
  clearedAt DATETIME NOT NULL,
  difficulty TEXT,            // "보통", "어려움" 등
  FOREIGN KEY(characterId) REFERENCES Character(id) ON DELETE CASCADE
);

// Planner 테이블
CREATE TABLE PlannedContent (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  characterId INTEGER NOT NULL,
  contentCode TEXT NOT NULL,
  contentName TEXT NOT NULL,
  isCleared INTEGER DEFAULT 0,
  clearedDate DATE,
  FOREIGN KEY(characterId) REFERENCES Character(id) ON DELETE CASCADE
);
```

---

## 마이그레이션 전략

```dart
// 버전 관리 (Database 클래스)
static const int dbVersion = 1;

Future<Database> initDB() async {
  return openDatabase(
    'planner.db',
    version: dbVersion,
    onCreate: (db, version) {
      // 초기 스키마 생성
      db.execute('CREATE TABLE Character (...)');
    },
    onUpgrade: (db, oldVersion, newVersion) {
      // v1→v2: 새 컬럼 추가 (ALTER TABLE)
      // v2→v3: 테이블 재구성 (임시 테이블 사용)
    },
  );
}
```

---

## 관련 문서

- `.planning/QUESTIONS.md` — Q9~Q12. SQLite 관련 질문들
- `SPECS.md` — 데이터 저장 규칙, 테이블 정의
- `RISK.md` — #4 SQLite 마이그레이션 위험

---

## 구현 가이드

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static const String _dbName = 'planner.db';
  static const int _dbVersion = 1;
  static final DatabaseService _instance = DatabaseService._();
  
  late Database _database;
  
  DatabaseService._();
  
  factory DatabaseService() => _instance;
  
  Future<void> init() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), _dbName),
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Character (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        server TEXT NOT NULL,
        class TEXT NOT NULL,
        level INTEGER NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(name, server)
      )
    ''');
    
    await db.execute('''
      CREATE TABLE Timeline (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        characterId INTEGER NOT NULL,
        dungeonCode TEXT NOT NULL,
        dungeonName TEXT NOT NULL,
        clearedAt DATETIME NOT NULL,
        FOREIGN KEY(characterId) REFERENCES Character(id)
      )
    ''');
  }
  
  Future<void> _onUpgrade(Database db, int oldVer, int newVer) async {
    // 마이그레이션 로직
  }
}
```

---

## Q&A

**Q: Hive보다 얼마나 느린가?**  
A: 대부분 애플리케이션에서는 무시할 수준 (<10ms 차이).

**Q: 스키마 변경 시 데이터가 사라지나?**  
A: 아니오. 마이그레이션 로직으로 기존 데이터 보존 가능.

**Q: 백업은?**  
A: 데이터베이스 파일을 직접 백업하거나 Firebase로 동기화 가능 (향후 기능).

**Q: 개발 중 테이블 수정하려면?**  
A: DBVersion을 증가시키고 onUpgrade에 로직 추가.

---

**최종 검토일**: 2026-05-18  
**승인자**: 고성훈  
**다음 리뷰**: 13주차 구현 완료 후
