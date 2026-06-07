# Flutter 앱 빌드 스크립트

Write-Host "🚀 Flutter 앱 빌드 시작!" -ForegroundColor Green
Write-Host ""

# 환경 변수 설정
$env:FLUTTER_HOME = "C:\Users\고성훈\flutter"
$env:ANDROID_HOME = "$env:LOCALAPPDATA\Android\Sdk"
$env:PATH = "$env:FLUTTER_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:PATH"

# 프로젝트 디렉토리로 이동
Set-Location "C:\app"

# 휴대폰 연결 확인
Write-Host "📱 연결된 기기 확인 중..." -ForegroundColor Cyan
& "$env:ANDROID_HOME\platform-tools\adb.exe" devices
Write-Host ""

# 캐시 정리
Write-Host "🧹 캐시 정리..." -ForegroundColor Yellow
& flutter clean

Write-Host ""
Write-Host "📦 의존성 설치..." -ForegroundColor Yellow
& flutter pub get

Write-Host ""
Write-Host "🔨 APK 빌드 및 설치 시작 (약 5-10분)..." -ForegroundColor Cyan
Write-Host ""

# 빌드 실행
& flutter run

Write-Host ""
if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ 빌드 및 설치 성공!" -ForegroundColor Green
    Write-Host "💡 휴대폰 화면을 확인하세요!" -ForegroundColor Green
} else {
    Write-Host "❌ 빌드 실패" -ForegroundColor Red
}

Write-Host ""
pause
