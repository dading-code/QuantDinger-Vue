@echo off
REM QuantDinger Launcher
REM This script starts both backend and opens the frontend

setlocal

REM Get the directory where this script is located
set APP_DIR=%~dp0
set BACKEND_PORT=5000
set FRONTEND_URL=http://localhost:8000

echo ========================================
echo   QuantDinger Desktop Application
echo ========================================
echo.

REM Check if backend is already running
echo [INFO] Checking backend status...
curl -s http://localhost:%BACKEND_PORT%/health >nul 2>&1
if %errorlevel% equ 0 (
    echo [INFO] Backend is already running
) else (
    echo [INFO] Starting backend server...
    start "" /B "%APP_DIR%start-backend.bat"
    
    REM Wait for backend to start
    echo [INFO] Waiting for backend to be ready...
    timeout /t 5 /nobreak >nul
    
    REM Verify backend started
    curl -s http://localhost:%BACKEND_PORT%/health >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] Failed to start backend!
        pause
        exit /b 1
    )
    echo [SUCCESS] Backend started successfully
)

echo.
echo [INFO] Opening frontend in browser...
echo.

REM Open default browser
start "" "%FRONTEND_URL%"

echo ========================================
echo   Application is running!
echo   Frontend: %FRONTEND_URL%
echo   Backend:  http://localhost:%BACKEND_PORT%
echo.
echo   Close this window to stop the application
echo ========================================
echo.

REM Keep this window open
pause

REM Cleanup on exit
echo [INFO] Stopping backend...
taskkill /F /IM python.exe /FI "WINDOWTITLE eq QuantDinger*" >nul 2>&1
echo [INFO] Application stopped.

endlocal
