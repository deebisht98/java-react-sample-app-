@echo off
REM PostgreSQL + pgAdmin Starter Script for Windows Command Prompt
REM Usage: start.bat [optional: stop|logs|restart|clean]

setlocal enabledelayedexpansion

REM Configuration
set PROJECT_NAME=postgres-stack
set POSTGRES_USER=postgres
set POSTGRES_PASSWORD=postgres_password
set POSTGRES_DB=myapp_db
set PGADMIN_EMAIL=admin@example.com
set PGADMIN_PASSWORD=admin

echo.
echo ========================================
echo PostgreSQL + pgAdmin Starter
echo ========================================
echo.

REM Get command argument
set "COMMAND=%~1"
if "!COMMAND!"=="" set "COMMAND=start"

REM Convert to lowercase
for %%A in (stop logs restart clean) do (
    if /I "!COMMAND!"=="%%A" goto :!COMMAND!
)

REM Default: Start services
goto :start

:start
call :checkDocker
call :checkDockerDaemon
call :createEnv
call :createDockerCompose
call :createInitScriptsDir
call :startServices
call :displayInfo
goto :end

:stop
call :stopServices
goto :end

:logs
call :showLogs
goto :end

:restart
call :restartServices
goto :end

:clean
call :cleanServices
goto :end

REM Check if Docker is installed
:checkDocker
echo Checking Docker installation...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed
    echo Please install Docker from https://docs.docker.com/get-docker/
    exit /b 1
)
echo [OK] Docker found
exit /b 0

REM Check if Docker daemon is running
:checkDockerDaemon
echo Checking Docker daemon...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker daemon is not running
    echo Please start Docker Desktop and try again
    exit /b 1
)
echo [OK] Docker daemon is running
exit /b 0

REM Create .env file
:createEnv
if exist .env (
    echo [OK] .env file already exists
    exit /b 0
)
echo Creating .env file...
(
    echo # PostgreSQL Configuration
    echo POSTGRES_DB=%POSTGRES_DB%
    echo POSTGRES_USER=%POSTGRES_USER%
    echo POSTGRES_PASSWORD=%POSTGRES_PASSWORD%
    echo.
    echo # pgAdmin Configuration
    echo PGADMIN_DEFAULT_EMAIL=%PGADMIN_EMAIL%
    echo PGADMIN_DEFAULT_PASSWORD=%PGADMIN_PASSWORD%
    echo.
    echo # Optional: PostgreSQL Performance Tuning
    echo POSTGRES_INITDB_ARGS=-c max_connections=200 -c shared_buffers=256MB
) > .env
echo [OK] .env file created
exit /b 0

REM Create docker-compose.yml
:createDockerCompose
echo Creating docker-compose.yml...
(
    echo version: '3.8'
    echo.
    echo services:
    echo   postgres:
    echo     image: postgres:16-alpine
    echo     container_name: postgres_db
    echo     environment:
    echo       POSTGRES_DB: ${POSTGRES_DB}
    echo       POSTGRES_USER: ${POSTGRES_USER}
    echo       POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    echo       POSTGRES_INITDB_ARGS: ${POSTGRES_INITDB_ARGS:-}
    echo     ports:
    echo       - "5432:5432"
    echo     volumes:
    echo       - postgres_data:/var/lib/postgresql/data
    echo       - ./init-scripts:/docker-entrypoint-initdb.d
    echo     restart: unless-stopped
    echo     networks:
    echo       - postgres_network
    echo     healthcheck:
    echo       test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
    echo       interval: 10s
    echo       timeout: 5s
    echo       retries: 5
    echo.
    echo   pgadmin:
    echo     image: dpage/pgadmin4:latest
    echo     container_name: pgadmin_web
    echo     environment:
    echo       PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
    echo       PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
    echo     ports:
    echo       - "5050:80"
    echo     volumes:
    echo       - pgadmin_data:/var/lib/pgadmin
    echo     restart: unless-stopped
    echo     depends_on:
    echo       postgres:
    echo         condition: service_healthy
    echo     networks:
    echo       - postgres_network
    echo.
    echo volumes:
    echo   postgres_data:
    echo     driver: local
    echo   pgadmin_data:
    echo     driver: local
    echo.
    echo networks:
    echo   postgres_network:
    echo     driver: bridge
) > docker-compose.yml
echo [OK] docker-compose.yml created
exit /b 0

REM Create init-scripts directory
:createInitScriptsDir
if exist init-scripts (
    exit /b 0
)
mkdir init-scripts
echo [OK] init-scripts directory created
exit /b 0

REM Start services
:startServices
echo.
echo Starting services...
echo.
docker-compose up -d
if errorlevel 1 (
    echo [ERROR] Failed to start services
    docker-compose logs
    exit /b 1
)
echo Waiting for services to be ready...
timeout /t 5 /nobreak
echo [OK] Services started successfully
exit /b 0

REM Stop services
:stopServices
echo Stopping services...
docker-compose down
echo [OK] Services stopped
exit /b 0

REM Show logs
:showLogs
docker-compose logs -f
exit /b 0

REM Restart services
:restartServices
echo Restarting services...
docker-compose restart
timeout /t 3 /nobreak
echo [OK] Services restarted
call :displayInfo
exit /b 0

REM Clean up everything
:cleanServices
echo [WARNING] This will remove all containers and volumes
set /p response="Are you sure? (yes/no): "
if /I "!response!"=="yes" (
    docker-compose down -v
    echo [OK] Cleaned up
) else (
    echo Cancelled
)
exit /b 0

REM Display connection information
:displayInfo
echo.
echo ========================================
echo [OK] PostgreSQL + pgAdmin is running!
echo ========================================
echo.
echo 📊 PostgreSQL Information:
echo   Host: localhost
echo   Port: 5432
echo   Username: %POSTGRES_USER%
echo   Password: %POSTGRES_PASSWORD%
echo   Database: %POSTGRES_DB%
echo.
echo 🎨 pgAdmin Information:
echo   URL: http://localhost:5050
echo   Email: %PGADMIN_EMAIL%
echo   Password: %PGADMIN_PASSWORD%
echo.
echo 📝 Connection String:
echo   postgresql://%POSTGRES_USER%:%POSTGRES_PASSWORD%@localhost:5432/%POSTGRES_DB%
echo.
echo 🔧 Useful Commands:
echo   View logs:      start.bat logs
echo   Stop services:  start.bat stop
echo   Restart:        start.bat restart
echo   Clean up:       start.bat clean
echo.
echo ========================================
echo.
exit /b 0

:end
endlocal
