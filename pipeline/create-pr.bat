@echo off
setlocal enabledelayedexpansion
title Sanver - Pull Request erstellen

echo.
echo  ============================================
echo   Sanver - Pull Request: dev -^> main
echo  ============================================
echo.

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

REM Lock entfernen falls vorhanden
if exist ".git\index.lock" del ".git\index.lock" >nul 2>&1

REM Aktuellen Branch pruefen
for /f "tokens=*" %%b in ('git branch --show-current 2^>nul') do set CURRENT_BRANCH=%%b
echo  Aktueller Branch: !CURRENT_BRANCH!

REM Pruefen ob uncommitted Changes vorhanden
git diff --quiet 2>nul
if !ERRORLEVEL! neq 0 (
    echo.
    echo  [HINWEIS] Es gibt uncommitted Aenderungen:
    git status --short
    echo.
    set /p COMMIT="Zuerst committen? [j/n]: "
    if /i "!COMMIT!"=="j" (
        set /p MSG="Commit-Nachricht: "
        git add .
        git commit -m "!MSG!"
        if !ERRORLEVEL! neq 0 (
            echo  [FEHLER] Commit fehlgeschlagen.
            pause & exit /b 1
        )
        echo  [OK] Committed.
    )
)

REM Sicherstellen dass wir auf dev sind
if /i not "!CURRENT_BRANCH!"=="dev" (
    echo.
    echo  [HINWEIS] Du bist auf Branch "!CURRENT_BRANCH!", nicht auf "dev".
    set /p SWITCH="Zu dev wechseln? [j/n]: "
    if /i "!SWITCH!"=="j" (
        git checkout dev
        if !ERRORLEVEL! neq 0 (
            echo  [FEHLER] Branch-Wechsel fehlgeschlagen.
            pause & exit /b 1
        )
    ) else (
        echo  Abgebrochen.
        pause & exit /b 0
    )
)

REM dev zu GitHub pushen
echo.
echo  [1/2] Pushe dev branch zu GitHub...
git push origin dev 2>&1
if !ERRORLEVEL! neq 0 (
    echo  [FEHLER] Push fehlgeschlagen. GitHub-Login pruefen.
    pause & exit /b 1
)
echo  [OK] dev branch aktuell auf GitHub.
echo.

REM GitHub CLI pruefen
gh --version >nul 2>&1
if !ERRORLEVEL! == 0 (
    REM ── GitHub CLI verfuegbar ──────────────────
    echo  [2/2] Erstelle Pull Request via GitHub CLI...
    echo.
    set /p PR_TITLE="PR-Titel (Enter fuer Standard): "
    if "!PR_TITLE!"=="" set PR_TITLE=Update: dev -> main

    set /p PR_BODY="Kurze Beschreibung (optional): "
    if "!PR_BODY!"=="" set PR_BODY=Zusammenfuehren von dev-Aenderungen in main.

    gh pr create ^
        --base main ^
        --head dev ^
        --title "!PR_TITLE!" ^
        --body "!PR_BODY!" ^
        --repo yyarbas/SanverFacilityService

    if !ERRORLEVEL! == 0 (
        echo.
        echo  [OK] Pull Request erstellt!
        set /p OPEN="PR im Browser oeffnen? [j/n]: "
        if /i "!OPEN!"=="j" gh pr view --web
    ) else (
        echo  [HINWEIS] PR existiert moeglicherweise bereits.
        echo  Oeffne GitHub im Browser...
        start https://github.com/yyarbas/SanverFacilityService/pulls
    )
) else (
    REM ── Kein GitHub CLI - Browser oeffnen ─────
    echo  [2/2] GitHub CLI nicht gefunden.
    echo       Oeffne PR-Erstellungsseite im Browser...
    echo.
    echo  Tipp: GitHub CLI installieren fuer vollautomatische PRs:
    echo  https://cli.github.com
    echo.
    start https://github.com/yyarbas/SanverFacilityService/compare/main...dev?expand=1
    echo  [OK] Browser geoeffnet. PR im Browser bestaetigen.
)

echo.
echo  ============================================
echo   Naechste Schritte:
echo   1. PR auf GitHub pruefen/bestaetigen
echo   2. Nach Merge: pipeline\deploy.bat [p]
echo      um main auf Produktion zu deployen
echo  ============================================
echo.
pause
endlocal
