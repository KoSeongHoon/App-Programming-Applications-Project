# ADR-0002: SQLite를 로컬 저장소로 선택

**상태**: ✅ 결정됨  
**결정일**: 2026-05-04  
**작성자**: 고성훈

---

## 📌 컨텍스트

앱이 캐릭터 정보, 플래너 항목, 강화 계획 등 여러 데이터를 저장해야 합니다. 이 데이터는:
- 앱 재시작 후에도 유지되어야 함
- 복잡한 쿼리 지원 필요
- 대량의 데이터 처리 가능해야 함

### 고려 대상
- **Hive**: 키-값 저장, 빠름, 간단함
- **SQLite**: 관계형 DB, 강력한 쿼리, 복잡한 데이터 처리
- **SharedPreferences**: 간단한 설정 저장만 가능
- **GetStorage**: Hive와 유사

---

## 🎯 결정

**SQLite를 로컬 저장소로 선택합니다.**

### 선택 이유

1. **복잡한 데이터 구조**
   - 여러 테이블 간 관계 설정 가능
   - 조인(JOIN) 쿼리 가능

2. **강력한 쿼리 지원**
   - WHERE, ORDER BY, GROUP BY 등
   - 데이터 필터링 및 정렬 용이

3. **스케일 가능성**
   - 대량의 데이터 처리 가능
   - 인덱싱으로 성능 최적화 가능

4. **표준 기술**
   - 많은 프로젝트에서 사용
   - 풍부한 문서 및 커뮤니티 지원

5. **데이터 무결성**
   - FOREIGN KEY 제약 조건
   - 트랜잭션 지원

---

## 📊 테이블 설계

```sql
-- 기본 정보
CREATE TABLE characters (
  id INTEGER PRIMARY KEY,
  characterId TEXT UNIQUE NOT NULL,
  nickname TEXT NOT NULL,
  level INTEGER
);

-- 관계형 데이터
CREATE TABLE planner_items (
  id INTEGER PRIMARY KEY,
  characterId TEXT NOT NULL,
  contentName TEXT NOT NULL,
  isCompleted BOOLEAN,
  FOREIGN KEY (characterId) REFERENCES characters(characterId)
);

-- 복잡한 쿼리
SELECT c.nickname, COUNT(p.id) as itemCount
FROM characters c
LEFT JOIN planner_items p ON c.characterId = p.characterId
WHERE p.isCompleted = 0
GROUP BY c.characterId
ORDER BY itemCount DESC;
```

---

## ✅ 긍정적 결과

- 관계형 데이터 관리 용이
- 복잡한 쿼리 작성 가능
- 데이터 무결성 보장
- 확장성 높음

---

## ⚠️ 부정적 결과

- Hive보다 조금 느림
- 초기 설정이 복잡함
- 마이그레이션 관리 필요

### 대응 방안
- 초기에 충분한 테스트로 성능 확인
- 데이터베이스 마이그레이션 도구 사용 (moor 또는 drift)

---

## 🔄 대안 검토

### **Hive**
- ✅ 매우 빠름
- ✅ 간단함
- ❌ 관계형 쿼리 불가
- ❌ 복잡한 데이터 처리 어려움

### **SharedPreferences**
- ✅ 가장 간단함
- ❌ 간단한 설정만 저장 가능
- ❌ 대량 데이터 불가능

---

## 📝 결론

**SQLite**는 이 프로젝트의 복잡한 데이터 요구사항을 충족시키는 최고의 선택입니다.

### 관련 파일
- `pubspec.yaml`: sqflite 의존성 추가
- `lib/services/database_service.dart`: SQLite 관리
- `.planning/decisions/03-architecture.md`: 테이블 설계

---

**참고 자료**: https://pub.dev/packages/sqflite
