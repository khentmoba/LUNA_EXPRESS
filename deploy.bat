@echo off
echo ============================================
echo   Luna Bites & Delights — Build & Deploy
echo ============================================
echo.
echo Building from ROOT directory (active codebase)...
echo.

cd /d "%~dp0"
call flutter build web --release --base-href /kiosk/

if %errorlevel% neq 0 (
    echo.
    echo BUILD FAILED. Check errors above.
    exit /b 1
)

call dart run tool/assemble_site.dart

if %errorlevel% neq 0 (
    echo.
    echo SITE ASSEMBLY FAILED. Check errors above.
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
echo   https://lunabitesanddelights.web.app  (canonical)
echo   https://lunaexpress.web.app          (301 redirect)
echo ============================================
