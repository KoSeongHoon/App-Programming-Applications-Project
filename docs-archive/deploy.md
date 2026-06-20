# 배포 가이드 (Deploy)

앱을 Google Play Store와 Apple App Store에 배포하는 방법입니다.

---

## 🎯 배포 체크리스트

배포 전에 다음을 확인하세요:

- [ ] 모든 테스트 통과 (`flutter test` 성공)
- [ ] 버전 번호 업데이트 (`pubspec.yaml`)
- [ ] 앱 아이콘 및 스플래시 이미지 준비
- [ ] 앱 서명 키 생성 (Android)
- [ ] 개발자 계정 생성 (Google Play, App Store)
- [ ] 프라이버시 정책 및 이용약관 작성
- [ ] 스크린샷 및 설명 준비

---

## 📱 Android 배포

### 1단계: 앱 서명 설정

#### 서명 키 생성

```bash
# 키스토어 생성 (처음 한 번만)
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10950 \
  -alias upload-key

# 입력 내용:
# - 키스토어 비밀번호: [안전한 비밀번호 입력]
# - 키 비밀번호: [위와 동일하게]
# - 이름: 고성훈
# - 조직 단위: 개발
# - 조직: 개인
# - 시/도: Seoul
# - 국가: KR
```

> **중요**: 키스토어 파일은 안전하게 보관하세요!

#### 빌드 설정에 서명 추가

```bash
# android/key.properties 생성
cat > android/key.properties << EOF
storePassword=[비밀번호]
keyPassword=[비밀번호]
keyAlias=upload-key
storeFile=[경로]/upload-keystore.jks
EOF
```

`android/app/build.gradle` 수정:

```gradle
android {
    // 기존 설정...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 2단계: 릴리스 빌드 생성

```bash
# APK 생성 (테스트용)
flutter build apk --release

# App Bundle 생성 (Google Play 권장)
flutter build appbundle --release

# 출력 위치
# APK: build/app/outputs/flutter-app/release/app-release.apk
# AAB: build/app/outputs/bundle/release/app-release.aab
```

### 3단계: Google Play Console에 업로드

1. **[Google Play Console](https://play.google.com/console)** 방문
2. **새 앱 만들기** 클릭
3. 기본 정보 입력:
   - 앱 이름: "던전앤파이터 플래너"
   - 카테고리: 도구
   - 등급: 모든 연령
4. **프로덕션 → 출시 → AAB/APK 업로드**
5. 스크린샷, 설명, 개인정보 보호정책 입력
6. **검토 및 출시**

---

## 🍎 iOS 배포

### 1단계: Apple Developer 계정 설정

```bash
# Xcode에서 개발 팀 설정
# ios/Runner.xcworkspace 열기
open ios/Runner.xcworkspace

# 또는 명령줄에서
cd ios
pod install
cd ..
```

### 2단계: 릴리스 빌드 생성

```bash
# iOS 빌드
flutter build ios --release

# 또는 Xcode로 빌드 (더 세밀한 제어)
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -derivedDataPath build/ios_release
```

### 3단계: App Store에 업로드

#### **Transporter 사용 (권장)**

```bash
# Transporter 설치
xcode-select --install

# IPA 생성
flutter build ipa --release

# App Store에 업로드
xcrun altool --upload-app \
  -f build/ios/ipa/*.ipa \
  -t ios \
  -u [Apple ID] \
  -p [App-specific password]
```

#### **App Store Connect에서 수동 업로드**

1. [App Store Connect](https://appstoreconnect.apple.com) 방문
2. **내 앱** → **새 앱**
3. 기본 정보 입력:
   - 앱 이름
   - 번들 ID: `com.example.dungeon_planner`
   - SKU: `dungeonplanner`
   - 사용자 액세스: 모든 사용자
4. IPA 파일 업로드
5. 앱 미리보기, 스크린샷, 설명 입력
6. **검토 신청**

---

## 📦 버전 관리

### 버전 번호 업데이트

`pubspec.yaml` 수정:

```yaml
version: 1.0.0+1

# 형식: major.minor.patch+buildNumber
# - major: 큰 기능 추가 (1.0.0)
# - minor: 새 기능 (1.1.0)
# - patch: 버그 수정 (1.0.1)
# - buildNumber: 빌드 번호 (1)
```

### 버전 히스토리

```
v1.0.0+1 (2026-05-20) - 초기 출시
  - 캐릭터 조회
  - 콘텐츠 플래너
  - 강화 계획 계산
  - 타임라인 자동 감지

v1.1.0+2 (2026-06-15) - 첫 업데이트
  - 아바타 강화 계획 추가
  - 통계 기능 추가
  - 성능 개선

...
```

---

## 🚀 배포 후 관리

### 릴리스 노트 작성

```markdown
# 버전 1.0.0 - 초기 출시

## 주요 기능
- ✨ 캐릭터 정보 조회 (Neople API)
- ✨ 콘텐츠 플래너 (자동 감지)
- ✨ 강화 계획 계산기

## 개선 사항
- 🚀 빠른 로딩 (캐싱 최적화)
- 🔒 보안 강화 (HTTPS)
- 📱 UI/UX 개선

## 버그 수정
- 🐛 타임라인 매칭 오류 수정
- 🐛 강화 계산 정확도 개선

## 알려진 문제
- 오프라인 모드에서 일부 기능 불가
- iOS 15 이하에서 성능 저하 가능
```

### 모니터링 및 피드백

```bash
# Google Play Console에서:
1. 통계 → 사용자 획득 추이 확인
2. 기술적 요소 → 크래시 및 ANR 모니터링
3. 리뷰 → 사용자 피드백 읽기

# App Store Connect에서:
1. 분석 → 다운로드 및 설치
2. 기술적 요소 → 크래시 로그
3. 리뷰 → 사용자 평점 및 의견
```

---

## 🔒 보안 체크리스트

배포 전 보안 확인:

- [ ] API Key를 `.env`에 저장 (.gitignore 적용)
- [ ] 민감한 정보가 하드코딩되지 않음
- [ ] HTTPS 통신만 사용
- [ ] 로그 출력에 민감 정보 없음
- [ ] 데이터베이스 암호화 활성화 (필요시)
- [ ] 앱 서명 키 안전 보관

---

## 📊 성능 최적화 (배포 전)

### 빌드 크기 최소화

```bash
# 릴리스 빌드 크기 확인
ls -lh build/app/outputs/flutter-app/release/

# 크기 분석
flutter build apk --split-debug-info build/debug-info --obfuscate

# 목표: APK < 50MB, AAB < 100MB
```

### 성능 프로파일링

```bash
# 성능 측정
flutter run --profile

# 또는 DevTools에서
flutter run --debug
# 그 후 DevTools → Timeline → CPU/Memory 확인
```

---

## 🔄 업데이트 배포 프로세스

기존 앱 업데이트 시:

```bash
# 1. 버전 번호 증가
# pubspec.yaml: version: 1.0.1+2

# 2. 릴리스 노트 작성

# 3. 릴리스 빌드 생성
flutter build appbundle --release
flutter build ipa --release

# 4. Google Play / App Store 업로드

# 5. 검토 대기 (보통 1-24시간)

# 6. 출시 및 모니터링
```

---

## 📝 배포 체크리스트 (최종)

### 출시 전 (1주일 전)

- [ ] 모든 기능 테스트 완료
- [ ] 버그 수정 완료
- [ ] 성능 최적화 완료
- [ ] 버전 번호 업데이트
- [ ] 릴리스 노트 작성
- [ ] 프라이버시 정책 최신화

### 출시 당일

- [ ] 최종 빌드 생성 및 테스트
- [ ] Google Play/App Store 업로드
- [ ] 검토 신청
- [ ] 모니터링 준비 (대시보드 열기)

### 출시 후 (1주일)

- [ ] 사용자 피드백 모니터링
- [ ] 크래시 로그 확인
- [ ] 성능 지표 확인
- [ ] 필요시 긴급 업데이트 준비

---

## 🆘 배포 문제 해결

### "Gradle build failed"

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### "Invalid App Bundle"

```bash
# 최소 SDK 버전 확인
# android/app/build.gradle: minSdkVersion 21 이상

# AAB 검증
bundletool validate --bundle-path=app-release.aab
```

### "App rejected by App Store"

```
일반적인 거부 이유:
1. 불완전한 기능 (테스트 버튼 남음)
2. 크래시 (테스트 기기에서 확인)
3. 개인정보 정책 없음
4. 과도한 권한 요청

해결: 리뷰 피드백 읽고 수정 후 재제출
```

---

## 📚 참고 자료

| 주제 | 링크 |
|------|------|
| Google Play Console | https://play.google.com/console |
| App Store Connect | https://appstoreconnect.apple.com |
| Flutter 배포 가이드 | https://flutter.dev/docs/deployment |
| Android 서명 | https://developer.android.com/studio/publish/app-signing |
| iOS 배포 | https://developer.apple.com/ios/submit/ |

---

**마지막 업데이트**: 2026-05-04  
**문서 버전**: 1.0
