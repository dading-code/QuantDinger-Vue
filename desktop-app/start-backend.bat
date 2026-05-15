@echo off
REM QuantDinger Backend Launcher
REM This script starts the Python backend server

cd /d "%~dp0backend"

REM Check if virtual environment exists
if not exist "venv\Scripts\python.exe" (
    echo [ERROR] Virtual environment not found!
    echo Please run setup.bat first to initialize the environment.
    pause
    exit /b 1
)

REM Activate virtual environment and start backend
echo [INFO] Starting QuantDinger Backend...
call venv\Scripts\activate.bat
python app.py

pause
