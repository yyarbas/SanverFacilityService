@echo off
setlocal

echo ============================================
echo  Sanver Facility Service - Deploy Pipeline
echo  GitHub main branch → Manitu Server
echo ============================================
echo.

REM ── Ziel wählen ─────────────────────────────
echo Wo soll deployed werden?
echo   [p] PRODUKTION  (sanver-facilityservice.de)
echo   [t] TEST        (sanver-facilityservice.de/test/)
echo.
set /p TARGET="Auswahl [p/t]: "
if /i "%TARGET%"=="t" (
    set DEPLOY_PATH=/sanver-facilityservice.de/test
    echo.
    echo [TEST-Modus] Ziel: /test/
) else (
    set DEPLOY_PATH=/sanver-facilityservice.de
    echo.
    echo [PRODUKTION] Ziel: /
)
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
if exist "%TMPDIR%\.git" (
    git -C "%TMPDIR%" fetch origin %BRANCH% --depth 1 --quiet
    git -C "%TMPDIR%" reset --hard origin/%BRANCH% --quiet
) else (
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
echo cd %DEPLOY_PATH%

if /i "%TARGET%"=="t" (
echo # Test-Umgebung: auch .htaccess und .htpasswd hochladen
echo put "%TMPDIR%\facility-service\test-env\.htaccess" .htaccess
echo put "%TMPDIR%\facility-service\test-env\.htpasswd" .htpasswd
) else (
echo put "%TMPDIR%\facility-service\.htaccess" .htaccess
)

echo lcd "%TMPDIR%\facility-service"
echo put index.html
echo put impressum.html
echo put datenschutz.html
echo put .htaccess
echo mirror -R media media
echo put public\robots.txt robots.txt
echo put public\sitemap.xml sitemap.xml
echo close
echo exit
) > "%TEMP%\sanver-winscp.txt"
echo [OK] Konfiguration erstellt.
echo.

REM ── Schritt 3: Upload ──────────────────────
echo [3/3] Lade hoch...
%WINSCP% /script="%TEMP%\sanver-winscp.txt" /log="%TEMP%\sanver-deploy.log"

if %ERRORLEVEL% == 0 (
    echo.
    echo ============================================
    if /i "%TARGET%"=="t" (
        echo  Test-Umgebung bereitgestellt!
        echo  URL: https://www.sanver-facilityservice.de/test/
        echo  Benutzer: test
        echo  Passwort: sanver2026
    ) else (
        echo  Erfolgreich deployed!
        echo  https://www.sanver-facilityservice.de
    )
    echo ============================================
    echo.
    set /p OPEN="Im Browser oeffnen? [j/n]: "
    if /i "%OPEN%"=="j" (
        if /i "%TARGET%"=="t" (
            start https://www.sanver-facilityservice.de/test/
        ) else (
            start https://www.sanver-facilityservice.de
        )
    )
) else (
    echo [FEHLER] Upload fehlgeschlagen.
    echo Log: %TEMP%\sanver-deploy.log
    start %TEMP%\sanver-deploy.log
)

del "%TEMP%\sanver-winscp.txt" >nul 2>&1
pause
endlocal
