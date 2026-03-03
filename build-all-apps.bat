@echo off
REM ============================================================================
REM Script de Build Automatisé - Apps Flutter (Windows)
REM Soso Delivery - Apps Mobiles
REM ============================================================================

setlocal enabledelayedexpansion

echo ╔════════════════════════════════════════════════════════╗
echo ║   Build Automatisé - Apps Flutter Soso Delivery       ║
echo ╚════════════════════════════════════════════════════════╝

REM Vérifier Flutter
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ❌ Flutter n'est pas installé
    echo Installer Flutter: https://flutter.dev/docs/get-started/install
    pause
    exit /b 1
)

echo ✅ Flutter installé
flutter --version | findstr /C:"Flutter"

REM Menu
echo.
echo Quelle(s) app(s) voulez-vous builder ?
echo 1) User App (Client)
echo 2) Restaurant App
echo 3) Delivery Man App
echo 4) Toutes les apps
echo 5) Quitter
echo.
set /p choice="Choix (1-5): "

if "%choice%"=="1" goto user_app
if "%choice%"=="2" goto restaurant_app
if "%choice%"=="3" goto delivery_app
if "%choice%"=="4" goto all_apps
if "%choice%"=="5" goto end
goto invalid

:user_app
echo.
echo ═══ BUILD USER APP ═══
cd "main-app-v10\User app and web"
call :build_app "User App"
cd ..\..
goto end

:restaurant_app
echo.
echo ═══ BUILD RESTAURANT APP ═══
cd "restaurant-app-v10\Restaurant app"
call :build_app "Restaurant App"
cd ..\..
goto end

:delivery_app
echo.
echo ═══ BUILD DELIVERY MAN APP ═══
cd "delivery-man-app-v10\Delivery man app"
call :build_app "Delivery Man App"
cd ..\..
goto end

:all_apps
echo.
echo ═══ BUILD TOUTES LES APPS ═══

echo.
echo [1/3] User App
cd "main-app-v10\User app and web"
call :build_app "User App"
cd ..\..

echo.
echo [2/3] Restaurant App
cd "restaurant-app-v10\Restaurant app"
call :build_app "Restaurant App"
cd ..\..

echo.
echo [3/3] Delivery Man App
cd "delivery-man-app-v10\Delivery man app"
call :build_app "Delivery Man App"
cd ..\..

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║   ✅ TOUS LES BUILDS TERMINÉS !                       ║
echo ╚════════════════════════════════════════════════════════╝
goto end

:build_app
echo.
echo 🧹 Nettoyage...
flutter clean
flutter pub get

echo.
echo 📦 Build Android App Bundle...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo ❌ Erreur build Android
    pause
    exit /b 1
)

echo.
echo 📦 Build Android APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ❌ Erreur build APK
    pause
    exit /b 1
)

echo.
echo ✅ Build %~1 terminé
echo    App Bundle: build\app\outputs\bundle\release\app-release.aab
echo    APK: build\app\outputs\flutter-apk\app-release.apk
goto :eof

:invalid
echo Choix invalide
pause
exit /b 1

:end
echo.
echo ═══════════════════════════════════════════════════════
echo ✅ Build terminé avec succès !
echo.
echo Prochaines étapes:
echo 1. Tester les APKs sur des appareils Android
echo 2. Uploader sur Google Play Console
echo 3. Pour iOS: utiliser un Mac avec Xcode
echo ═══════════════════════════════════════════════════════
pause
