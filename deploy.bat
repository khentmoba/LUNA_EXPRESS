@echo off
echo ============================================
echo   Luna Express — Build & Deploy
echo ============================================
echo.
echo Building from ROOT directory (active codebase)...
echo.

cd /d "%~dp0"
call flutter build web --release

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED. Check errors above.
    exit /b 1
)

echo.
echo Deploying to Firebase Hosting...
echo.

call npx --no-install firebase deploy --only hosting

if %errorlevel% neq 0 (
    echo.
    echo DEPLOY FAILED. Check errors above.
    exit /b 1
)

echo.
echo ============================================
echo   Deploy complete!
echo   https://lunaexpress.web.app
echo ============================================
