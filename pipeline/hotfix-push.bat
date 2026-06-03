@echo off
setlocal
echo Hotfix: Aenderungen direkt auf main pushen + Prod deployen
echo.

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

if exist ".git\index.lock" del ".git\index.lock" >nul 2>&1

REM Auf main wechseln
git checkout main
if %ERRORLEVEL% neq 0 ( echo [FEHLER] Branch-Wechsel fehlgeschlagen. & pause & exit /b 1 )

REM Alle Aenderungen committen
git add index.html .htaccess pipeline\test-env\.htaccess
git status --short
echo.
set /p MSG="Commit-Nachricht: "
git commit -m "%MSG%"

REM Push zu GitHub main
git push origin main
if %ERRORLEVEL% neq 0 ( echo [FEHLER] Push fehlgeschlagen. & pause & exit /b 1 )

echo.
echo [OK] main aktuell auf GitHub. Starte jetzt deploy.bat [p]...
echo.
call "%~dp0deploy.bat"

pause
endlocal
