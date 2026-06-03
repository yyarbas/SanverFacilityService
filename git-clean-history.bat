@echo off
echo ============================================
echo  Git Historie komplett bereinigen
echo  Alle bisherigen Commits werden geloescht
echo  und durch einen einzigen sauberen ersetzt.
echo ============================================
echo.
echo ACHTUNG: Diese Aktion kann nicht rueckgaengig
echo gemacht werden. GitHub-Historie wird ueberschrieben.
echo.
set /p CONFIRM="Fortfahren? [j/n]: "
if /i not "%CONFIRM%"=="j" (
    echo Abgebrochen.
    pause & exit /b 0
)

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

echo.
echo [1/5] Pruefe Git-Status...
git status --short

echo.
echo [2/5] Erstelle neuen verwaisten Branch ohne Historie...
git checkout --orphan clean-start

echo.
echo [3/5] Alle sauberen Dateien stagen...
git add index.html
git add impressum.html
git add datenschutz.html
git add agb.html
git add .htaccess
git add .gitignore
git add deploy.bat
git add deploy.env.example
git add git-push.bat
git add start-preview.bat
git add public\robots.txt
git add public\sitemap.xml
git add public\favicon.svg
git add media\
git add astro.config.mjs
git add package.json
git add src\
REM Sensible/interne Dateien werden NICHT hinzugefuegt:
REM - deploy.env (gitignored)
REM - deploy-commands.txt (gitignored)
REM - preview.html (gitignored)
REM - nginx.conf (gitignored)
REM - MANITU-UPLOAD-ANLEITUNG.html (gitignored)
REM - CHECKLISTE-LIVE-GANG.html (gitignored)
REM - DEPLOYMENT.md (gitignored)

echo.
echo [4/5] Sauberer initialer Commit...
git commit -m "Initial commit - Sanver Facility Service"

echo.
echo [5/5] Alten main-Branch loeschen und ersetzen...
git branch -D main
git branch -m main
git push origin main --force

if %ERRORLEVEL% == 0 (
    echo.
    echo ============================================
    echo  Fertig! Historie ist bereinigt.
    echo  GitHub zeigt nur noch einen sauberen Commit.
    echo  https://github.com/yyarbas/SanverFacilityService
    echo ============================================
) else (
    echo.
    echo [FEHLER] Push fehlgeschlagen - GitHub-Login pruefen.
)

pause
