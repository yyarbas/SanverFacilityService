@echo off
echo Starting Sanver Facility Service preview...
echo.

REM Try Python 3 first
python --version >nul 2>&1
IF %ERRORLEVEL% == 0 (
    echo Running on http://localhost:8080
    start "" http://localhost:8080/preview.html
    python -m http.server 8080
    goto :end
)

REM Try py launcher
py --version >nul 2>&1
IF %ERRORLEVEL% == 0 (
    echo Running on http://localhost:8080
    start "" http://localhost:8080/preview.html
    py -m http.server 8080
    goto :end
)

REM Try Node.js npx
npx --version >nul 2>&1
IF %ERRORLEVEL% == 0 (
    echo Running on http://localhost:8080
    start "" http://localhost:8080/preview.html
    npx serve . -l 8080
    goto :end
)

REM Nothing found
echo.
echo ERROR: Python or Node.js not found on this machine.
echo Please install Python from https://www.python.org
echo Or just double-click preview.html to open it directly in your browser.
echo.
pause

:end
