@echo off
setlocal enabledelayedexpansion

echo.
echo ========================================
echo  Flutter APK 빌드 및 설치
echo ========================================
echo.

REM 환경 변수 설정
set FLUTTER_HOME=C:\Users\고성훈\flutter
set ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk
set PATH=%FLUTTER_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%

echo [1/4] 환경 변수 설정 완료
echo.

REM 프로젝트 디렉토리로 이동
cd /d C:\app

echo [2/4] 캐시 정리 및 의존성 설치...
call flutter clean
call flutter pub get

echo.
echo [3/4] APK 빌드 시작 (이 과정은 5-10분 걸립니다)
echo.

call flutter run

echo.
echo ========================================
if %ERRORLEVEL% EQU 0 (
    echo 빌드 및 설치 성공!
) else (
    echo 빌드 중 오류 발생
)
echo ========================================
echo.
pause
