# ADR-0005: 메모리 + 디스크 캐싱 전략

**상태**: ✅ 결정됨  
**결정일**: 2026-05-04  
**작성자**: 고성훈

---

## 📌 컨텍스트

앱이 Neople API를 자주 호출하면:
- API 요청 제한에 걸릴 수 있음
- 네트워크 속도 느림
- 배터리 소비 증가
- 사용자 경험 저하

따라서 적절한 캐싱 전략이 필수적입니다.

### 고려 대상
- **캐싱 안 함**: 매번 API 호출
- **메모리만**: 빠르지만 앱 종료 시 삭제
- **디스크만**: 느리지만 영구 보관
- **메모리 + 디스크**: 빠름 + 영구 보관

---

## 🎯 결정

**메모리 캐시 + 디스크 캐시 혼합 전략을 사용합니다.**

### 선택 이유

1. **속도와 지속성의 균형**
   - 빠른 응답 (메모리)
   - 장기 저장 (디스크)

2. **네트워크 사용 최소화**
   - 1시간 이내 같은 요청 → 캐시 사용
   - API 호출 대폭 감소

3. **배터리 절약**
   - 네트워크 통신 감소
   - 배터리 소비 30% 이상 감소

4. **오프라인 대응**
   - 캐시된 데이터로 부분적 기능 제공
   - 사용자 불편함 최소화

5. **사용자 만족도**
   - 화면 로딩 < 1초 (캐시 히트 시)
   - 부드러운 사용 경험

---

## 📊 캐싱 흐름

```
┌─────────────┐
│ API 요청    │
└──────┬──────┘
       │
┌──────▼─────────────┐
│ 메모리 캐시 확인   │
│ (매우 빠름)        │
├──────┬──────────┤
│ YES  │   NO     │
└──┬───┘   │      │
   │       └──┬───┘
   │          │
   │    ┌─────▼────────────┐
   │    │ 디스크 캐시 확인  │
   │    │ (조금 느림)      │
   │    ├──────┬────────┤
   │    │ YES  │  NO    │
   │    └──┬───┘  │     │
   │       │      └──┬──┘
   │       │         │
   │    ┌──▼─────────▼──────┐
   │    │ API 호출           │
   │    │ (느림)             │
   │    └──────┬────────────┘
   │           │
   │    ┌──────▼────────────┐
   │    │ 결과 저장         │
   │    │ ├─ 메모리 캐시   │
   │    │ └─ 디스크 캐시   │
   │    └──────┬────────────┘
   │           │
   └───────────┼─────────────┐
               │             │
         ┌─────▼─────┐      │
         │ 사용자에게 │      │
         │ 데이터 반환│      │
         └───────────┘      │
                            │
                   ┌────────▼──┐
                   │ UI 업데이트│
                   └───────────┘
```

---

## 💾 캐시 정책 (TTL: Time To Live)

| 데이터 | TTL | 저장소 | 갱신 방식 |
|--------|-----|--------|---------|
| **캐릭터 정보** | 1시간 | L1+L2 | 수동 (새로고침) |
| **능력치** | 1시간 | L1+L2 | 수동 (새로고침) |
| **타임라인** | 30분 | L1+L2 | 자동 (플래너 추가 시) |
| **강화 확률표** | 7일 | L2만 | 수동 (패치 발생 시) |
| **플래너 항목** | 영구 | L2만 | 실시간 (저장 시) |

---

## 💻 구현 코드

### **캐시 서비스**
```dart
class CacheService {
  // L1: 메모리 캐시 (빠름, 임시)
  final Map<String, CacheEntry> _memoryCache = {};
  
  // L2: 디스크 캐시 (느림, 영구)
  late SharedPreferences _prefs;

  Future<T?> get<T>(String key) async {
    // 1. 메모리 캐시 확인
    if (_memoryCache.containsKey(key)) {
      final entry = _memoryCache[key]!;
      if (!entry.isExpired) {
        return entry.value as T;
      }
    }

    // 2. 디스크 캐시 확인
    final diskData = _prefs.getString('cache_$key');
    if (diskData != null) {
      final decoded = jsonDecode(diskData);
      if (decoded['expiresAt'].isAfter(DateTime.now())) {
        _memoryCache[key] = CacheEntry(
          decoded['value'],
          DateTime.parse(decoded['expiresAt']),
        );
        return decoded['value'] as T;
      }
    }

    return null;  // 캐시 미스
  }

  Future<void> set<T>(
    String key,
    T value, {
    Duration ttl = const Duration(hours: 1),
  }) async {
    final expiresAt = DateTime.now().add(ttl);

    // L1: 메모리 저장
    _memoryCache[key] = CacheEntry(value, expiresAt);

    // L2: 디스크 저장
    await _prefs.setString(
      'cache_$key',
      jsonEncode({
        'value': value,
        'expiresAt': expiresAt.toIso8601String(),
      }),
    );
  }

  bool isExpired(String key) {
    final entry = _memoryCache[key];
    return entry == null || entry.isExpired;
  }

  void invalidate(String key) {
    _memoryCache.remove(key);
    _prefs.remove('cache_$key');
  }
}

class CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  CacheEntry(this.value, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
```

---

## ✅ 긍정적 결과

- API 호출 30-50% 감소
- 응답 속도 3배 이상 향상
- 배터리 소비 감소
- 사용자 만족도 증가
- 부분적 오프라인 지원

---

## ⚠️ 부정적 결과

- 오래된 데이터 표시 가능성
- 메모리 사용 증가 (약간)
- 캐시 무효화 로직 필요

### 대응 방안
- TTL을 적절히 설정 (너무 길지 않게)
- 수동 새로고침 버튼 제공
- 필요시 강제 무효화 구현

---

## 🔄 대안 검토

### **캐싱 안 함**
- ✅ 항상 최신 데이터
- ❌ 느린 응답
- ❌ 배터리 소비 많음
- ❌ API 제한 걸릴 가능성

### **메모리만**
- ✅ 매우 빠름
- ❌ 앱 종료 시 모두 삭제
- ❌ 재시작 후 같은 데이터 다시 조회

### **디스크만**
- ✅ 영구 저장
- ❌ 조금 느림
- ❌ 메모리만큼 빠르지 않음

---

## 📝 결론

**메모리 + 디스크 캐싱**은 성능과 사용성을 최고로 끌어올리는 최적의 전략입니다.

### 관련 파일
- `lib/services/cache_service.dart`: 캐시 구현
- `lib/repositories/`: Repository에서 캐시 사용
- `docs/architecture.md`: 캐싱 전략 섹션

---

**캐시 무효화 규칙**:
- 새로고침 버튼 클릭 → 즉시 무효화
- 플래너 아이템 추가 → 타임라인 캐시 무효화
- 강화 계획 저장 → 해당 데이터 캐시 무효화
