# ADR-0004: 타임라인 하이브리드 매칭 방식

**상태**: ✅ 결정됨  
**결정일**: 2026-05-04  
**작성자**: 고성훈

---

## 📌 컨텍스트

사용자가 플래너에 "상급던전", "레이드" 같은 콘텐츠를 추가하면, 앱이 자동으로 타임라인 데이터에서 해당 활동을 찾아서 체크해야 합니다.

### 고려 대상
- **코드 매칭**: 타임라인의 "code" 필드로 비교 (정확하지만 데이터 필요)
- **텍스트 매칭**: 메시지 필드에서 "상급던전" 텍스트 검색 (간단하지만 부정확)
- **하이브리드**: 코드 우선, 없으면 텍스트 (최고의 균형)

---

## 🎯 결정

**하이브리드 매칭 방식을 사용합니다. (코드 우선 → 텍스트)**

### 선택 이유

1. **정확도 높음**
   - 코드 매칭으로 거의 100% 정확
   - 코드가 없으면 텍스트로 폴백

2. **유연함**
   - API 응답 형식이 바뀌어도 대응 가능
   - 여러 상황에 대응

3. **신뢰성**
   - 실수로 다른 것을 감지할 가능성 낮음
   - 사용자 만족도 높음

4. **확장성**
   - 새로운 콘텐츠 타입 추가 용이
   - 매칭 로직 개선 가능

---

## 📊 매칭 알고리즘

```
타임라인 데이터: {code: "123001", message: "상급던전 - 마법사의 성"}

사용자 추가: "상급던전"

┌─────────────────────────────────┐
│ 1단계: 코드 매칭               │
│ code == "상급던전의 코드"?     │
│ YES → 자동 체크              │
│ NO → 2단계로                │
└─────────────────────────────────┘
           또는
┌─────────────────────────────────┐
│ 2단계: 텍스트 매칭            │
│ message.contains("상급던전")?  │
│ YES → 자동 체크              │
│ NO → 미감지              │
└─────────────────────────────────┘
```

### **구현 코드**

```dart
class TimelineMatcherService {
  // 1단계: 타임라인 코드 매칭 (정확도 높음)
  bool matchByCode(TimelineEvent event, PlannerItem item) {
    final codeMapping = {
      'dungeon_advanced': ['123001', '123002', '123003'],
      'raid_normal': ['124001', '124002'],
      'legion': ['125001'],
      // ... 추가
    };
    
    final codes = codeMapping[item.contentType] ?? [];
    return codes.contains(event.code);
  }

  // 2단계: 메시지 텍스트 매칭 (폴백)
  bool matchByMessage(TimelineEvent event, PlannerItem item) {
    final keywords = {
      'dungeon_advanced': ['상급던전', '마법사의 성', '카르페'],
      'raid_normal': ['레이드', 'Normal'],
      'legion': ['레기온'],
      // ... 추가
    };
    
    final keywords_list = keywords[item.contentType] ?? [];
    return keywords_list.any(
      (keyword) => event.message.contains(keyword)
    );
  }

  // 하이브리드: 코드 우선, 없으면 텍스트
  bool matches(TimelineEvent event, PlannerItem item) {
    return matchByCode(event, item) || matchByMessage(event, item);
  }
}
```

---

## ✅ 긍정적 결과

- 매칭 정확도 높음 (거의 오류 없음)
- 사용자 신뢰도 높음
- API 변경에 대응 가능
- 유연한 확장성

---

## ⚠️ 부정적 결과

- 타임라인 코드 데이터 수집 필요
- 텍스트 패턴 관리 필요
- 초기 설정 복잡도 있음

### 대응 방안
- 1주차에 충분한 타임라인 데이터 수집
- 매칭 규칙 정기적으로 검증
- 사용자 피드백 반영

---

## 🔄 대안 검토

### **코드 매칭만**
- ✅ 가장 정확
- ❌ 타임라인 코드 데이터 필수
- ❌ API 응답 형식 변경 시 문제

### **텍스트 매칭만**
- ✅ 간단함
- ❌ 정확도 낮음
- ❌ 다른 내용을 실수로 감지할 수 있음

---

## 📝 결론

**하이브리드 방식**은 정확도와 유연성을 모두 제공하므로, 자동 감지 기능의 핵심 요구사항을 충족합니다.

### 관련 파일
- `lib/services/timeline_matcher_service.dart`: 매칭 로직 구현
- `docs/architecture.md`: 타임라인 매칭 섹션
- 타임라인 코드 매핑 (JSON 또는 상수)

---

**우선 순위**: 
1. 코드 매칭 구현 (높은 우선순위)
2. 텍스트 패턴 추가 (필요시)
3. 사용자 피드백으로 개선
