@echo off
REM Quick start script for MERN stack development (Windows)

title MERN Stack - Starting Services

echo.
echo ==========================================
echo      Starting MERN Stack Application
echo ==========================================
echo.

REM Check if the setup has been run
if not exist "backend\node_modules" (
    echo [WARNING] Backend dependencies not found. Running setup first...
    call scripts\dev-setup.bat
    if %errorlevel% neq 0 (
        echo [ERROR] Setup failed
        pause
        exit /b 1
    )
)

if not exist "frontend\node_modules" (
    echo [WARNING] Frontend dependencies not found. Running setup first...
    call scripts\dev-setup.bat  
    if %errorlevel% neq 0 (
        echo [ERROR] Setup failed
        pause
        exit /b 1
    )
)

echo [INFO] Starting MongoDB (if not already running)...
REM Try to start MongoDB service (Windows service)
sc query MongoDB >nul 2>&1
if %errorlevel% equ 0 (
    net start MongoDB >nul 2>&1
    if %errorlevel% equ 0 (
        echo [OK] MongoDB service started
    ) else (
        echo [INFO] MongoDB service was already running or failed to start
    )
) else (
    echo [WARNING] MongoDB service not found. Please start MongoDB manually.
    echo   You can download it from: https://www.mongodb.com/try/download/community
    echo   Or use MongoDB Atlas cloud database
)

echo.
echo [INFO] Starting Backend Server (Express - Port 5000)...
start "MERN Backend" cmd /k "cd /d backend && npm run dev"

echo.
echo [INFO] Waiting for backend to start...
timeout /t 5 /nobreak >nul

echo.
echo [INFO] Starting Frontend Server (React - Port 3000)...
start "MERN Frontend" cmd /k "cd /d frontend && npm start"

echo.
echo ==========================================
echo       MERN Stack Started Successfully!
echo ==========================================
echo.
echo Services running:
echo - Backend API: http://localhost:5000
echo - Frontend App: http://localhost:3000
echo - API Endpoints: http://localhost:5000/api
echo - Health Check: http://localhost:5000/health
echo.
echo Two new command windows should have opened:
echo 1. Backend server (Express on port 5000)
echo 2. Frontend server (React on port 3000)
echo.
echo The React app should automatically open in your browser.
echo If not, manually open: http://localhost:3000
echo.
echo To stop the servers, close the respective command windows.
echo.
pause