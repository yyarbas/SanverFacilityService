@echo off
echo ============================================
echo  Root-Ordner bereinigen
echo  Alte Pipeline-Dateien loeschen
echo ============================================
echo.

cd /d "C:\Users\yakup\Documents\Claude\Projects\Facility Service website\facility-service"

REM deploy.env sichern falls noch nicht in pipeline/
if exist "deploy.env" (
    if not exist "pipeline\deploy.env" (
        copy "deploy.env" "pipeline\deploy.env" >nul
        echo [OK] deploy.env nach pipeline\ gesichert.
    )
)

REM Alte Dateien loeschen
echo Loesche alte Root-Dateien...

for %%f in (
    "deploy.bat"
    "deploy.env"
    "deploy.env.example"
    "deploy-commands.txt"
    "deploy.prod.env"
    "deploy.test.env"
    "git-push.bat"
    "git-clean-history.bat"
    "git-dev-branch.bat"
    "start-preview.bat"
    "nginx.conf"
    "MANITU-UPLOAD-ANLEITUNG.html"
    "CHECKLISTE-LIVE-GANG.html"
    "DEPLOYMENT.md"
    "preview.html"
) do (
    if exist %%f (
        del %%f
        echo   Geloescht: %%f
    )
)

REM test-env/ Ordner loeschen
if exist "test-env\" (
    rmdir /s /q "test-env"
    echo   Geloescht: test-env\
)

echo.
echo Root-Ordner jetzt:
dir /b /a:-h
echo.
echo ============================================
echo  Fertig! Alle alten Dateien entfernt.
echo  Pipeline befindet sich in: pipeline\
echo ============================================
pause
