# ADR-0003: MVC 아키텍처 패턴 선택

**상태**: ✅ 결정됨  
**결정일**: 2026-05-04  
**작성자**: 고성훈

---

## 📌 컨텍스트

앱의 구조를 정하는 것은 중요한 결정입니다. 좋은 아키텍처는:
- 코드 이해하기 쉬워야 함
- 테스트 작성이 용이해야 함
- 팀 협업이 쉬워야 함
- 기능 추가 시 기존 코드 수정 최소화

### 고려 대상
- **MVC** (Model-View-Controller): 가장 간단
- **MVVM** (Model-View-ViewModel): 더 많은 제어
- **Clean Architecture**: 최고의 테스트성, 복잡함
- **BLoC Pattern**: 명확하지만 보일러플레이트 많음

---

## 🎯 결정

**MVC 아키텍처 패턴을 사용합니다.**

### 선택 이유

1. **간단함**
   - 신입 개발자도 이해하기 쉬움
   - 학습 곡선이 낮음

2. **빠른 개발**
   - 보일러플레이트 코드 최소
   - 빠른 프로토타이핑 가능

3. **명확한 역할 분담**
   - Model: 데이터
   - View: UI
   - Controller: 비즈니스 로직

4. **효율적인 협업**
   - View 담당자, Model 담당자 분리 가능
   - 충돌 최소화

5. **이 프로젝트에 적합**
   - 복잡도가 낮은 프로젝트
   - 팀 규모가 작음 (개인 프로젝트)

---

## 📊 MVC 구조

```
User Input
    ↓
[View/Screen]
    ↓ 이벤트 전달
[Controller] ← Riverpod Provider
    ↓ 요청
[Model/Repository]
    ↓ 데이터 접근
[Service] (API, DB, Cache)
    ↓ 데이터 반환
UI 업데이트
```

### **각 역할**

**Model (모델)**
- 데이터 정의
- 비즈니스 로직
- Repository 제공

**View (뷰)**
- UI 구성
- 사용자 입력 받기
- 데이터 표시

**Controller (컨트롤러)**
- View와 Model 연결
- 요청 처리
- Riverpod Provider로 구현

---

## 💻 코드 예시

### **Model**
```dart
class Character {
  final String id;
  final String name;
  final int level;

  Character({required this.id, required this.name, required this.level});
}

class CharacterRepository {
  Future<Character> getCharacter(String name) async {
    // API 또는 DB에서 조회
  }
}
```

### **Controller (Riverpod)**
```dart
final characterController = FutureProvider((ref) async {
  final repo = ref.watch(characterRepositoryProvider);
  return repo.getCharacter("고성훈");
});
```

### **View**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final character = ref.watch(characterController);
  
  return character.when(
    data: (char) => Text("${char.name} - Lv.${char.level}"),
    loading: () => CircularProgressIndicator(),
    error: (err, _) => Text("Error: $err"),
  );
}
```

---

## ✅ 긍정적 결과

- 코드 이해하기 쉬움
- 빠른 개발 속도
- 간단한 테스트
- 유연한 구조

---

## ⚠️ 부정적 결과

- 대규모 프로젝트에는 부족할 수 있음
- 테스트 격리가 완벽하지 않을 수 있음
- 비즈니스 로직이 Controller에 뭉쳐질 수 있음

### 대응 방안
- Controller 코드는 간결하게 유지
- 복잡한 로직은 Service로 분리
- 테스트는 Service 단위로 작성

---

## 🔄 대안 검토

### **MVVM**
- ✅ View와 Logic 분리 더 명확
- ❌ ViewModel 추가로 복잡도 증가
- ❌ 이 프로젝트에는 과도함

### **Clean Architecture**
- ✅ 최고의 테스트성
- ❌ 복잡함
- ❌ 과도한 boilerplate
- ❌ 개인 프로젝트로는 오버엔지니어링

### **BLoC**
- ✅ 명확한 패턴
- ❌ 보일러플레이트 많음
- ❌ 학습 곡선 높음

---

## 📝 결론

**MVC**는 간단함과 강력함의 균형을 제공하며, 이 프로젝트의 규모와 요구사항에 가장 적합합니다.

### 관련 파일
- `docs/architecture.md`: 자세한 설명
- `lib/providers/`: Controller 구현
- `lib/models/`: Model 정의
- `lib/screens/`: View 구현

---

**팁**: MVC를 엄격하게 적용하지 말고, 상황에 따라 유연하게 사용하세요!
