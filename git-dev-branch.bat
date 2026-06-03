@echo off
echo ============================================
echo  Sanver - Dev Branch erstellen + pushen
echo ============================================
echo.

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

REM Lock entfernen falls vorhanden
if exist ".git\index.lock" del ".git\index.lock"

REM Aktuellen Branch pruefen
for /f %%i in ('git branch --show-current') do set CURRENT=%%i
echo Aktueller Branch: %CURRENT%
echo.

REM Dev-Branch erstellen (oder wechseln falls schon vorhanden)
git fetch origin 2>nul
git checkout dev 2>nul || git checkout -b dev
echo.

REM Alle Aenderungen stagen
echo Folgende Dateien werden hinzugefuegt:
git add .gitignore
git add .htaccess
git add index.html
git add impressum.html
git add datenschutz.html
git add agb.html
git add start-preview.bat
git add deploy.bat
git add deploy.env.example
git add git-push.bat
git add git-clean-history.bat
git add git-dev-branch.bat
git add public\robots.txt
git add public\sitemap.xml
git add public\favicon.svg
git add "media\sanver-logo-hero.png"
git add "media\sanver-logo-nav.png"
git add "media\sanver-logo-new.jpg"
git add "media\sanver-logo-wide.jpg"
git add test-env\.htaccess
git add src\
git add astro.config.mjs
git add package.json
git status --short
echo.

REM Commit
git commit -m "Dev: Cal.eu Integration, neues Logo, Frankfurt/Rhein-Main, Test-Umgebung, Kontaktdaten"

REM Push dev branch
echo.
echo Pushe dev branch zu GitHub...
git push origin dev

if %ERRORLEVEL% == 0 (
    echo.
    echo ============================================
    echo  Dev-Branch erfolgreich gepusht!
    echo  https://github.com/yyarbas/SanverFacilityService/tree/dev
    echo ============================================
    echo.
    start https://github.com/yyarbas/SanverFacilityService/tree/dev
) else (
    echo.
    echo [FEHLER] Push fehlgeschlagen - GitHub-Login pruefen.
)

pause
