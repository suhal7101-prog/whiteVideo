@echo off
chcp 65001 >nul
setlocal
set ROOT=%~dp0

echo ============================================
echo   White Bear Anime Platform - Installer
echo ============================================
echo.

where node >nul 2>nul || (echo [ERROR] Node.js not found in PATH & goto :err)
where npm >nul 2>nul  || (echo [ERROR] npm not found in PATH     & goto :err)
where python >nul 2>nul || (where py >nul 2>nul || (echo [ERROR] Python not found in PATH & goto :err))
where java >nul 2>nul  || (echo [ERROR] Java not found in PATH    & goto :err)
where mvn >nul 2>nul   || (echo [WARN]  mvn not in PATH, Spring Boot resolve may fail)

echo [1/3] Installing frontend dependencies (Vue 3 + Vite + Element Plus + Tailwind + ECharts)...
cd /d "%ROOT%white-bear-anime"
call npm install
if errorlevel 1 goto :err
echo.

echo [2/3] Installing Python dependencies (FastAPI + Uvicorn + Requests + ChromaDB)...
cd /d "%ROOT%white-bear-anime\server"
python -m pip install -r requirements.txt
if errorlevel 1 goto :err
echo.

echo [3/3] Resolving Spring Boot dependencies (Java 17 + MyBatis-Plus + MinIO + Knife4j)...
cd /d "%ROOT%white-bear-anime-spring-boot"
call mvn dependency:resolve -q
if errorlevel 1 goto :err

echo.
echo ============================================
echo   All dependencies installed successfully!
echo ============================================
echo   Next:
echo     1) Create MySQL database (utf8mb4): white_bear_anime
echo     2) (Optional) Set env var DEEPSEEK_API_KEY for AI features
echo     3) Start services:
echo          - Java backend (8088) :  start-boot.bat
echo          - Python data API (8082): python -m uvicorn main:app --port 8082
echo          - Vue frontend (5174) :   npm run dev
echo.
echo   See README.md for the full setup guide.
echo ============================================
pause
exit /b 0

:err
echo.
echo *** Installation failed. Please check the errors above. ***
pause
exit /b 1