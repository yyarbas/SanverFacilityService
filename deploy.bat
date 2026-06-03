@echo off
setlocal

echo ============================================
echo  Sanver Facility Service - Deploy Pipeline
echo  GitHub main branch → Manitu Server
echo ============================================
echo.

REM ── Feste Konfiguration ────────────────────
set REPO=https://github.com/yyarbas/SanverFacilityService.git
set BRANCH=main
set TMPDIR=%TEMP%\sanver-deploy
set WINSCP="C:\Program Files (x86)\WinSCP\WinSCP.com"
if not exist %WINSCP% set WINSCP="C:\Program Files\WinSCP\WinSCP.com"
REM ───────────────────────────────────────────

REM ── Server-Zugangsdaten aus deploy.env laden ──
set SCRIPTDIR=%~dp0
if not exist "%SCRIPTDIR%deploy.env" (
    echo [FEHLER] deploy.env nicht gefunden.
    echo Bitte deploy.env.example in deploy.env umbenennen
    echo und mit den Manitu-Zugangsdaten befuellen.
    pause & exit /b 1
)
for /f "tokens=1,2 delims==" %%a in (%SCRIPTDIR%deploy.env) do set %%a=%%b

REM ── Passwort abfragen (wird NICHT gespeichert) ──
echo Manitu FTP-Passwort eingeben:
set /p FTP_PASS="Passwort: "
echo.

REM WinSCP pruefen
if not exist %WINSCP% (
    echo [FEHLER] WinSCP nicht gefunden.
    echo Bitte installieren: https://winscp.net/eng/download.php
    pause & exit /b 1
)

REM Git pruefen
git --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [FEHLER] Git nicht gefunden.
    echo Bitte installieren: https://git-scm.com/download/win
    pause & exit /b 1
)

REM ── Schritt 1: GitHub → lokal ──────────────
echo [1/3] Lade aktuellen Stand von GitHub...
echo       Branch: %BRANCH%
echo       Repo:   %REPO%
echo.

if exist "%TMPDIR%\.git" (
    echo Repo bereits vorhanden - pull...
    git -C "%TMPDIR%" fetch origin %BRANCH% --depth 1 --quiet
    git -C "%TMPDIR%" reset --hard origin/%BRANCH% --quiet
) else (
    echo Klone Repository...
    git clone --depth 1 --branch %BRANCH% %REPO% "%TMPDIR%" --quiet
)

if %ERRORLEVEL% neq 0 (
    echo [FEHLER] GitHub konnte nicht erreicht werden.
    pause & exit /b 1
)
echo [OK] Dateien von GitHub geladen.
echo.

REM ── Schritt 2: WinSCP-Skript generieren ────
echo [2/3] Erstelle Upload-Konfiguration...
(
echo option batch abort
echo option confirm off
echo open sftp://%FTP_USER%:%FTP_PASS%@%FTP_HOST%:%FTP_PORT% -hostkey=*
echo cd /sanver-facilityservice.de
echo lcd "%TMPDIR%\facility-service"
echo put index.html
echo put impressum.html
echo put datenschutz.html
echo put agb.html
echo put .htaccess
echo mirror -R media media
echo put public\robots.txt robots.txt
echo put public\sitemap.xml sitemap.xml
echo close
echo exit
) > "%TEMP%\sanver-winscp.txt"
echo [OK] Konfiguration erstellt.
echo.

REM ── Schritt 3: Upload zu Manitu ────────────
echo [3/3] Lade auf Manitu hoch...
echo       Server: %FTP_HOST% (SFTP Port %FTP_PORT%)
echo.

%WINSCP% /script="%TEMP%\sanver-winscp.txt" /log="%TEMP%\sanver-deploy.log"

if %ERRORLEVEL% == 0 (
    echo.
    echo ============================================
    echo  Erfolgreich deployed!
    echo  https://www.sanver-facilityservice.de
    echo ============================================
    echo.
    set /p OPEN="Seite im Browser oeffnen? [j/n]: "
    if /i "%OPEN%"=="j" start https://www.sanver-facilityservice.de
) else (
    echo.
    echo [FEHLER] Upload fehlgeschlagen.
    echo Log-Datei: %TEMP%\sanver-deploy.log
    start %TEMP%\sanver-deploy.log
)

REM Temp-Skript sofort loeschen (Passwort-Sicherheit)
del "%TEMP%\sanver-winscp.txt" >nul 2>&1

pause
endlocal
