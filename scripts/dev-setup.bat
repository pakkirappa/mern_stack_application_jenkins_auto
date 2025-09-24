@echo off
REM Development setup script for MERN stack application (Windows)
REM This script helps start the application in development mode

echo.
echo ==========================================
echo    MERN Stack Development Setup
echo ==========================================
echo.

REM Check if Node.js is installed
echo Checking Node.js installation...
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js is not installed
    echo Please install Node.js from https://nodejs.org/
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
echo [OK] Node.js is installed: %NODE_VERSION%

REM Check if npm is installed
echo.
echo Checking npm installation...
npm --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] npm is not installed
    pause
    exit /b 1
)

for /f "tokens=*" %%i in ('npm --version') do set NPM_VERSION=%%i
echo [OK] npm is installed: v%NPM_VERSION%

REM Install backend dependencies
echo.
echo Installing backend dependencies...
cd backend
if not exist package.json (
    echo [ERROR] Backend package.json not found
    pause
    exit /b 1
)

call npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install backend dependencies
    pause
    exit /b 1
)
echo [OK] Backend dependencies installed

cd ..

REM Install frontend dependencies
echo.
echo Installing frontend dependencies...
cd frontend
if not exist package.json (
    echo [ERROR] Frontend package.json not found
    pause
    exit /b 1
)

call npm install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install frontend dependencies
    pause
    exit /b 1
)
echo [OK] Frontend dependencies installed

cd ..

REM Install root dependencies (if any)
echo.
echo Installing root dependencies...
if exist package.json (
    call npm install
    if %errorlevel% neq 0 (
        echo [WARNING] Failed to install root dependencies
    ) else (
        echo [OK] Root dependencies installed
    )
) else (
    echo [WARNING] No root package.json found
)

echo.
echo ==========================================
echo     Setup completed successfully!
echo ==========================================
echo.
echo Next Steps:
echo 1. Start MongoDB if not already running
echo 2. Start the backend server: cd backend ^&^& npm run dev
echo 3. In a new terminal, start the frontend: cd frontend ^&^& npm start
echo 4. Open http://localhost:3000 in your browser
echo.
echo Useful Commands:
echo Backend development: cd backend ^&^& npm run dev
echo Frontend development: cd frontend ^&^& npm start  
echo Build for production: cd frontend ^&^& npm run build
echo.
pause