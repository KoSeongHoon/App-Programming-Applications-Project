# ADR-0001: Riverpod을 상태 관리 라이브러리로 선택

**상태**: ✅ 결정됨  
**결정일**: 2026-05-04  
**작성자**: 고성훈

---

## 📌 컨텍스트

Flutter 앱에서 여러 화면 간에 데이터를 공유하고, 데이터 변경 시 UI를 자동으로 업데이트해야 합니다. 이를 위해 상태 관리 라이브러리가 필수적입니다.

### 고려 대상
- **Provider**: 간단하고 배우기 쉬움
- **Riverpod**: Provider의 개선판, 타입 안전성 높음
- **GetX**: 강력하지만 복잡
- **BLoC**: 엄격한 구조, 테스트 용이하지만 학습 곡선 높음

---

## 🎯 결정

**Riverpod을 상태 관리 라이브러리로 선택합니다.**

### 선택 이유

1. **타입 안전성**
   - 컴파일 타임에 타입 오류 감지
   - IDE 자동완성 지원

2. **간단한 문법**
   - Provider보다 직관적
   - 2-3줄의 코드로 상태 관리 가능

3. **테스트 용이**
   - Mock 생성이 간단
   - 단위 테스트 작성 쉬움

4. **성능**
   - 불필요한 재빌드 방지
   - 효율적인 의존성 추적

5. **커뮤니티**
   - 활발한 커뮤니티
   - 풍부한 예제와 문서

---

## 📊 사용 예시

### **데이터 제공 (Provider)**
```dart
// 간단한 데이터
final nameProvider = StateProvider((ref) => "고성훈");

// 비동기 데이터 (API 호출)
final characterProvider = FutureProvider((ref) async {
  return await api.getCharacter("고성훈");
});

// 상태 관리 (수정 가능)
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});
```

### **UI에서 사용**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  // 데이터 읽기
  final name = ref.watch(nameProvider);
  
  // 비동기 데이터
  final character = ref.watch(characterProvider);
  
  return character.when(
    data: (char) => Text("${char.name} - Lv.${char.level}"),
    loading: () => CircularProgressIndicator(),
    error: (err, stack) => Text("Error: $err"),
  );
}
```

---

## ✅ 긍정적 결과

- 개발 속도 향상 (보일러플레이트 코드 감소)
- 버그 감소 (타입 안전성)
- 테스트 작성 용이
- 코드 유지보수성 증대

---

## ⚠️ 부정적 결과

- Provider보다 학습 곡선이 가파름
- 일부 고급 기능 이해에 시간 필요

### 대응 방안
- 초기에 튜토리얼 충분히 학습
- 기본 패턴만 먼저 사용 (고급 기능은 필요시)

---

## 🔄 대안 검토

### **Provider**
- ✅ 더 간단함
- ❌ 타입 안전성 낮음
- ❌ 기능 제한적

### **GetX**
- ✅ 강력함
- ❌ 복잡함
- ❌ 큰 프레임워크 의존

### **BLoC**
- ✅ 명확한 구조
- ❌ 너무 많은 보일러플레이트
- ❌ 학습 곡선 가팜

---

## 📝 결론

**Riverpod**은 간단함과 강력함의 균형을 제공하므로, 이 프로젝트의 요구사항에 가장 적합합니다.

### 관련 파일
- `pubspec.yaml`: riverpod 의존성 추가
- `lib/providers/`: Riverpod Provider 정의
- `docs/architecture.md`: 아키텍처 가이드

---

**참고 자료**: https://riverpod.dev
