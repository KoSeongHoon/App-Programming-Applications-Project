@echo off
REM Android SDK 및 JDK 자동 설치 스크립트 (Windows)

setlocal enabledelayedexpansion

echo.
echo =====================================
echo   Android SDK & JDK 설치 도구
echo =====================================
echo.

REM 관리자 권한 확인
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] 이 스크립트는 관리자 권한으로 실행해야 합니다!
    echo 해결책: setup_android.bat 를 마우스 우클릭 후 "관리자로 실행"을 선택하세요.
    pause
    exit /b 1
)

echo [OK] 관리자 권한 확인됨
echo.

REM 1. Chocolatey 확인
echo [*] Chocolatey 설치 확인 중...
choco --version >nul 2>&1

if %errorLevel% neq 0 (
    echo [*] Chocolatey 설치 중...
    @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

    if %errorLevel% neq 0 (
        echo [WARNING] Chocolatey 설치 실패. 수동 설치가 필요합니다.
        pause
        exit /b 1
    )
    echo [OK] Chocolatey 설치 완료
) else (
    echo [OK] Chocolatey 이미 설치됨
)

echo.

REM 2. JDK 설치 확인
echo [*] JDK(Java Development Kit) 설치 확인 중...
java -version >nul 2>&1

if %errorLevel% neq 0 (
    echo [*] OpenJDK 17 설치 중... (이 작업은 몇 분 정도 걸립니다)
    choco install openjdk17 -y

    if %errorLevel% neq 0 (
        echo [ERROR] OpenJDK 설치 실패
        pause
        exit /b 1
    )
    echo [OK] OpenJDK 설치 완료
) else (
    echo [OK] JDK 이미 설치됨
    java -version
)

echo.

REM 3. Android SDK 설치 확인 및 설정
set ANDROID_HOME=%USERPROFILE%\AppData\Local\Android\Sdk

echo [*] Android SDK 경로: %ANDROID_HOME%

if not exist "%ANDROID_HOME%" (
    echo [*] Android SDK 설치 중... (이 작업은 5-10분 정도 걸립니다)
    choco install android-sdk -y

    if %errorLevel% neq 0 (
        echo [ERROR] Android SDK 설치 실패
        pause
        exit /b 1
    )
    echo [OK] Android SDK 설치 완료
) else (
    echo [OK] Android SDK 이미 설치됨
)

echo.

REM 4. 환경 변수 설정
echo [*] 환경 변수 설정 중...
setx ANDROID_HOME "%ANDROID_HOME%"
setx PATH "%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools;!PATH!"

echo [OK] 환경 변수 설정 완료

echo.
echo =====================================
echo   설치 완료!
echo =====================================
echo.

echo [OK] JDK 설치됨
echo [OK] Android SDK 설치됨

echo.
echo [*] 새로운 터미널을 열고 다음 명령어를 실행하세요:
echo     flutter doctor
echo.

pause
