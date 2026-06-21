# 🚀 빌드 & 배포 가이드

**목표**: Flutter 앱을 Release APK로 빌드하고 Google Play Store에 배포하기  
**예상 소요 시간**: 30분

---

## 📋 **1. 배포 프로세스 개요**

```
로컬 개발
  ↓
Release 빌드 (APK 생성)
  ↓
서명 (키스토어로 사인)
  ↓
테스트 (기기에서 설치/테스트)
  ↓
GitHub Release 배포
  ↓
Google Play Store 배포 (선택사항)
```

---

## 🔑 **2. 키스토어 생성 (한 번만)**

### **2-1. 로컬 개발용 키스토어**

```bash
# Windows에서 keytool 실행
cd Planner/android/app

# 디버그용 키스토어 (이미 있음)
ls ~/.android/debug.keystore
```

### **2-2. Release용 키스토어 생성**

```bash
# 1. keytool로 새 키스토어 생성
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload-key

# 프롬프트에 답변
# - 비밀번호: xxxxxxxx (기억해두기!)
# - 이름: 고성훈
# - 조직: DFO
# - 도시: Seoul
# - 국가: KR

# 2. 생성된 파일 확인
ls -la upload-keystore.jks
```

### **2-3. key.properties 파일 생성**

```bash
# Planner/android/app/ 에서
echo "keyAlias=upload-key" > key.properties
echo "keyPassword=YOUR_PASSWORD" >> key.properties
echo "storeFile=upload-keystore.jks" >> key.properties
echo "storePassword=YOUR_PASSWORD" >> key.properties
```

**.gitignore에 추가** (보안!)
```
android/app/upload-keystore.jks
android/app/key.properties
```

---

## 🏗️ **3. Release APK 빌드**

### **3-1. 로컬 빌드 (테스트용)**

```bash
cd Planner

# Release APK 생성
flutter build apk --release

# 또는 기기별로 분할 (권장)
flutter build apk --release --split-per-abi

# 생성 위치
# build/app/outputs/flutter-apk/
```

### **3-2. 빌드 결과 확인**

```bash
ls -lh build/app/outputs/flutter-apk/

# 예상 결과:
# app-arm64-v8a-release.apk (50MB)
# app-armeabi-v7a-release.apk (48MB)
# app-x86_64-release.apk (52MB)
```

### **3-3. 빌드 문제 해결**

```bash
# 문제: "Gradle build failed"
# 해결: 캐시 제거
flutter clean
flutter pub get
flutter build apk --release

# 문제: "Java version too old"
# 해결: Java 17 확인
java -version

# 문제: "keystore not found"
# 해결: key.properties 경로 확인
cd Planner/android/app
ls key.properties upload-keystore.jks
```

---

## 📱 **4. 기기에 설치 및 테스트**

### **4-1. USB 디버깅 활성화**

```bash
# 기기 설정 → 개발자 옵션 → USB 디버깅 ON
# USB로 PC에 연결

# 기기 확인
flutter devices
```

### **4-2. APK 설치**

```bash
# 방법 1: flutter install (권장)
flutter install

# 방법 2: adb로 수동 설치
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# 방법 3: 파일로 직접 설치
# APK 파일을 기기로 복사 → 파일 관리자에서 열기 → 설치
```

### **4-3. 테스트 시나리오**

```
1. 앱 실행
2. 캐릭터 검색 (예: "우르반")
3. 결과 확인 (이미지 로드, 정보 표시)
4. 플래너 추가
5. 모험단 검색
6. 앱 종료 및 재실행 → 데이터 유지 확인
```

### **4-4. 로그 확인**

```bash
# 실시간 로그
flutter logs

# 디버그 출력 확인
# kDebugMode 에서만 출력되므로 Release 빌드에서는 안 보임
```

---

## 🐙 **5. GitHub Release 배포**

### **5-1. GitHub Actions으로 자동 배포 (권장)**

#### **워크플로우 파일**
```yaml
# .github/workflows/build-apk.yml
name: Build and Release APK

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Java
        uses: actions/setup-java@v3
        with:
          java-version: '17'
          distribution: 'temurin'
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.0'
      
      - name: Create .env file
        run: |
          echo "NEOPLE_API_KEY=${{ secrets.NEOPLE_API_KEY }}" > Planner/.env
      
      - name: Create key.properties
        run: |
          echo "${{ secrets.KEYSTORE_JKS }}" | base64 -d > Planner/android/app/upload-keystore.jks
          echo "keyAlias=upload-key" > Planner/android/app/key.properties
          echo "keyPassword=${{ secrets.KEYSTORE_PASSWORD }}" >> Planner/android/app/key.properties
          echo "storeFile=upload-keystore.jks" >> Planner/android/app/key.properties
          echo "storePassword=${{ secrets.KEYSTORE_PASSWORD }}" >> Planner/android/app/key.properties
      
      - name: Build APK
        run: |
          cd Planner
          flutter pub get
          flutter build apk --release --split-per-abi
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            Planner/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
            Planner/build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
```

#### **GitHub Secrets 설정**

```
Settings → Secrets and variables → Actions

필수:
- NEOPLE_API_KEY (발급받은 API 키)
- KEYSTORE_PASSWORD (키스토어 비밀번호)
- KEYSTORE_JKS (base64 인코딩된 keystore 파일)
```

### **5-2. 수동으로 배포**

```bash
# 1. 로컬에서 APK 빌드
flutter build apk --release --split-per-abi

# 2. Release 생성
gh release create v1.0.0 --title "v1.0.0" --notes "Initial Release"

# 3. APK 업로드
gh release upload v1.0.0 build/app/outputs/flutter-apk/*.apk

# 4. 확인
gh release view v1.0.0
```

---

## 🎮 **6. Google Play Store 배포 (선택사항)**

### **6-1. Google Play Console 준비**

```
1. https://play.google.com/console 접속
2. "앱 만들기" 클릭
3. 앱 이름: "던파플래너"
4. 영문 설명, 스크린샷, 아이콘 업로드
5. 개인정보처리방침 작성
```

### **6-2. AAB (App Bundle) 빌드**

```bash
# APK 대신 AAB 빌드 (Google Play 권장)
flutter build appbundle --release

# 생성 위치
# build/app/outputs/bundle/release/app-release.aab
```

### **6-3. Play Console에 업로드**

```
1. 내 앱 → 구성 → 버전 → 프로덕션
2. AAB 파일 업로드
3. 스크린샷, 설명, 등급 작성
4. 검토 요청
5. 승인 후 배포
```

---

## 🔄 **7. 배포 프로세스 자동화**

### **GitHub Actions 트리거**

```bash
# 버전 태그 생성 (GitHub Actions 자동 실행)
git tag v1.0.0
git push origin v1.0.0

# 자동으로:
# 1. Release APK 빌드
# 2. GitHub Release 생성
# 3. APK 업로드
```

### **배포 확인**

```bash
# Release 확인
gh release list

# 다운로드 링크
https://github.com/KoSeongHoon/App-Programming-Applications-Project/releases/tag/v1.0.0
```

---

## ✅ **8. 배포 체크리스트**

```markdown
### 로컬 빌드
- [ ] flutter clean 실행
- [ ] flutter pub get 완료
- [ ] .env 파일에 API 키 설정
- [ ] key.properties 파일 생성
- [ ] flutter build apk --release 성공

### 테스트
- [ ] 기기에서 APK 설치
- [ ] 캐릭터 검색 기능 테스트
- [ ] 모험단 검색 기능 테스트
- [ ] 플래너 추가/제거 테스트
- [ ] 네트워크 없음 상태 테스트

### GitHub 배포
- [ ] 버전 태그 생성 (v1.0.0)
- [ ] GitHub Actions 빌드 성공
- [ ] Release 자동 생성 확인
- [ ] APK 다운로드 가능 확인

### Google Play (선택)
- [ ] Play Console 계정 생성
- [ ] 앱 등록
- [ ] AAB 파일 빌드
- [ ] Play Console에 업로드
- [ ] 검토 요청
```

---

## 📞 **9. 참고 링크**

- [Flutter 배포 가이드](https://flutter.dev/docs/deployment)
- [GitHub Actions Flutter](https://github.com/marketplace/actions/flutter-action)
- [Google Play Console](https://play.google.com/console)

**다음 단계**: [테스트 가이드](testing.md) 참고
