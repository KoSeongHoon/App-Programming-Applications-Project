@echo off
REM Flutter SDK 자동 설치 스크립트 (Windows)

setlocal enabledelayedexpansion

echo.
echo =====================================
echo   Flutter SDK 자동 설치 도구
echo =====================================
echo.

REM 설치 경로 설정
set INSTALL_PATH=%USERPROFILE%\flutter
set DOWNLOAD_URL=https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.19.5-stable.zip
set TEMP_ZIP=%TEMP%\flutter_sdk.zip

echo 설치 경로: %INSTALL_PATH%
echo 다운로드 URL: %DOWNLOAD_URL%
echo.

REM 1. PowerShell로 파일 다운로드
echo [*] Flutter SDK 다운로드 중...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
   $ProgressPreference = 'SilentlyContinue'; ^
   (New-Object System.Net.WebClient).DownloadFile('%DOWNLOAD_URL%', '%TEMP_ZIP%')"

if exist "%TEMP_ZIP%" (
    echo [OK] 다운로드 완료
) else (
    echo [ERROR] 다운로드 실패
    pause
    exit /b 1
)

REM 2. 기존 Flutter 디렉토리 제거
if exist "%INSTALL_PATH%" (
    echo [*] 기존 Flutter 제거 중...
    rmdir /s /q "%INSTALL_PATH%"
)

REM 3. 압축 해제
echo [*] 압축 해제 중... (이 작업은 1-2분 정도 걸립니다)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%USERPROFILE%' -Force"

if exist "%INSTALL_PATH%" (
    echo [OK] 압축 해제 완료
) else (
    echo [ERROR] 압축 해제 실패
    pause
    exit /b 1
)

REM 4. 임시 파일 삭제
del /q "%TEMP_ZIP%"

REM 5. 환경 변수 설정
echo [*] 환경 변수 설정 중...
setx PATH "%INSTALL_PATH%\bin;!PATH!"

REM 6. 확인
echo.
echo =====================================
echo   설치 완료!
echo =====================================
echo.
echo [OK] Flutter SDK 설치 완료
echo [OK] 경로: %INSTALL_PATH%
echo.
echo [*] 새로운 터미널을 열고 다음 명령어를 실행하세요:
echo     flutter --version
echo     flutter doctor
echo.
pause
