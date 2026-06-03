@echo off
echo ============================================
echo  Sanver - Git Commit + Push zu GitHub
echo ============================================
echo.

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

REM Lock-Datei entfernen falls vorhanden
if exist ".git\index.lock" (
    del ".git\index.lock"
    echo [OK] Git lock entfernt.
)

REM Interne Dateien aus Git-Tracking entfernen
echo Entferne interne Dateien aus Git-Tracking...
git rm --cached preview.html 2>nul
git rm --cached CHECKLISTE-LIVE-GANG.html 2>nul
git rm --cached MANITU-UPLOAD-ANLEITUNG.html 2>nul
git rm --cached DEPLOYMENT.md 2>nul
git rm --cached nginx.conf 2>nul
git rm --cached deploy-commands.txt 2>nul

REM Neue Dateien hinzufuegen
echo Fuege neue Dateien hinzu...
git add .gitignore
git add index.html
git add impressum.html
git add datenschutz.html
git add agb.html
git add .htaccess
git add deploy.bat
git add public/robots.txt
git add public/sitemap.xml
git add src/
git add media/
git add package.json
git add astro.config.mjs

REM Status anzeigen
echo.
echo Folgende Aenderungen werden committet:
git status --short
echo.

REM Commit
git commit -m "Update: Sicherheit, Deployment, Rechtliches, .gitignore bereinigt"

REM Push
echo.
echo Pushe zu GitHub...
git push origin main

if %ERRORLEVEL% == 0 (
    echo.
    echo ============================================
    echo  Erfolgreich gepusht!
    echo  https://github.com/yyarbas/SanverFacilityService
    echo ============================================
) else (
    echo.
    echo [FEHLER] Push fehlgeschlagen.
    echo Moegliche Ursache: GitHub-Login erforderlich.
    echo Loesung: GitHub Desktop oeffnen oder
    echo  git config --global credential.helper manager
    echo  dann nochmal ausfuehren.
)

pause
