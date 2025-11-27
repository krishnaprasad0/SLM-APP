@echo off
echo =============================================
echo   FLUTTER + ANDROID + GRADLE RESET TOOL
echo =============================================
echo.

REM ---- Close processes ----
echo 🔄 Closing running processes...
taskkill /F /IM dart.exe >nul 2>&1
taskkill /F /IM flutter.exe >nul 2>&1
taskkill /F /IM gradle.exe >nul 2>&1
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM adb.exe >nul 2>&1
echo ✔ Done
echo.

REM ---- Clean Project Folders ----
echo 🧹 Cleaning project build folders...
rmdir /S /Q android\build 2>nul
rmdir /S /Q build 2>nul
rmdir /S /Q .dart_tool 2>nul
rmdir /S /Q .gradle 2>nul
echo ✔ Done
echo.

REM ---- Clean User Gradle Cache ----
echo 🧨 Deleting user Gradle cache...
rmdir /S /Q "%USERPROFILE%\.gradle\caches" 2>nul
rmdir /S /Q "%USERPROFILE%\.gradle\wrapper" 2>nul
echo ✔ Done
echo.

REM ---- Clean Android SDK Build Cache ----
echo 🧨 Clearing Android SDK build-cache...
rmdir /S /Q "%LOCALAPPDATA%\Android\Sdk\.android\build-cache" 2>nul
echo ✔ Done
echo.

REM ---- Clean Flutter Cache ----
echo 🧹 Flutter clean & cache repair...
flutter clean
flutter pub get
flutter precache
echo ✔ Done
echo.

REM ---- Final build restart ----
echo 🔁 Ready to rebuild your project!
echo Run:
echo flutter run
echo =============================================
echo        RESET COMPLETED SUCCESSFULLY
echo =============================================
pause
