# PostgreSQL + pgAdmin Starter Script for Windows PowerShell
# Usage: .\start.ps1 [optional: stop|logs|restart|clean]

param(
    [string]$Command = "start"
)

# Configuration
$PROJECT_NAME = "postgres-stack"
$POSTGRES_USER = "postgres"
$POSTGRES_PASSWORD = "postgres_password"
$POSTGRES_DB = "myapp_db"
$PGADMIN_EMAIL = "admin@example.com"
$PGADMIN_PASSWORD = "admin"

# Colors
$colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Cyan = "Cyan"
}

function Write-Status {
    param([string]$Message, [string]$Color = "Green")
    Write-Host $Message -ForegroundColor $Color
}

function Check-Docker {
    Write-Status "Checking Docker installation..." -Color Cyan
    try {
        $dockerVersion = docker --version 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Status "✓ Docker found: $dockerVersion" -Color Green
            return $true
        }
    } catch {
        Write-Status "✗ Docker not found" -Color Red
        Write-Status "Please install Docker from https://docs.docker.com/get-docker/" -Color Yellow
        exit 1
    }
}

function Check-DockerDaemon {
    Write-Status "Checking Docker daemon..." -Color Cyan
    try {
        docker info >$null 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Status "✓ Docker daemon is running" -Color Green
            return $true
        }
    } catch {
        Write-Status "✗ Docker daemon is not running" -Color Red
        Write-Status "Please start Docker Desktop and try again" -Color Yellow
        exit 1
    }
}

function Create-EnvFile {
    if (-not (Test-Path ".env")) {
        Write-Status "Creating .env file..." -Color Yellow
        $envContent = @"
# PostgreSQL Configuration
POSTGRES_DB=$POSTGRES_DB
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# pgAdmin Configuration
PGADMIN_DEFAULT_EMAIL=$PGADMIN_EMAIL
PGADMIN_DEFAULT_PASSWORD=$PGADMIN_PASSWORD

# Optional: PostgreSQL Performance Tuning
POSTGRES_INITDB_ARGS=-c max_connections=200 -c shared_buffers=256MB
"@
        Set-Content -Path ".env" -Value $envContent
        Write-Status "✓ .env file created" -Color Green
    } else {
        Write-Status "✓ .env file already exists" -Color Green
    }
}

function Create-DockerCompose {
    Write-Status "Creating docker-compose.yml..." -Color Yellow
    $composeContent = @'
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: postgres_db
    environment:
      POSTGRES_DB: ${POSTGRES_DB}
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_INITDB_ARGS: ${POSTGRES_INITDB_ARGS:-}
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    restart: unless-stopped
    networks:
      - postgres_network
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin_web
    environment:
      PGADMIN_DEFAULT_EMAIL: ${PGADMIN_DEFAULT_EMAIL}
      PGADMIN_DEFAULT_PASSWORD: ${PGADMIN_DEFAULT_PASSWORD}
    ports:
      - "5050:80"
    volumes:
      - pgadmin_data:/var/lib/pgadmin
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - postgres_network

volumes:
  postgres_data:
    driver: local
  pgadmin_data:
    driver: local

networks:
  postgres_network:
    driver: bridge
'@
    Set-Content -Path "docker-compose.yml" -Value $composeContent
    Write-Status "✓ docker-compose.yml created" -Color Green
}

function Create-InitScriptsDir {
    if (-not (Test-Path "init-scripts")) {
        New-Item -ItemType Directory -Path "init-scripts" -Force | Out-Null
        Write-Status "✓ init-scripts directory created" -Color Green
    }
}

function Start-Services {
    Write-Host ""
    Write-Status "Starting services..." -Color Yellow
    Write-Host ""
    
    docker-compose up -d
    
    if ($LASTEXITCODE -ne 0) {
        Write-Status "✗ Failed to start services" -Color Red
        docker-compose logs
        exit 1
    }
    
    Write-Status "Waiting for services to be ready..." -Color Yellow
    Start-Sleep -Seconds 5
    
    $postgresRunning = docker-compose ps | Select-String "postgres_db"
    $pgadminRunning = docker-compose ps | Select-String "pgadmin_web"
    
    if ($postgresRunning -and $pgadminRunning) {
        Write-Status "✓ Services started successfully" -Color Green
    } else {
        Write-Status "✗ Failed to start services" -Color Red
        docker-compose logs
        exit 1
    }
}

function Display-Info {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Status "✓ PostgreSQL + pgAdmin is running!" -Color Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Status "📊 PostgreSQL Information:" -Color Yellow
    Write-Host "  Host: localhost"
    Write-Host "  Port: 5432"
    Write-Host "  Username: $POSTGRES_USER"
    Write-Host "  Password: $POSTGRES_PASSWORD"
    Write-Host "  Database: $POSTGRES_DB"
    
    Write-Host ""
    Write-Status "🎨 pgAdmin Information:" -Color Yellow
    Write-Host "  URL: http://localhost:5050"
    Write-Host "  Email: $PGADMIN_EMAIL"
    Write-Host "  Password: $PGADMIN_PASSWORD"
    
    Write-Host ""
    Write-Status "📝 Connection String:" -Color Yellow
    Write-Host "  postgresql://$POSTGRES_USER:$POSTGRES_PASSWORD@localhost:5432/$POSTGRES_DB"
    
    Write-Host ""
    Write-Status "🔧 Useful Commands:" -Color Yellow
    Write-Host "  View logs:      .\start.ps1 logs"
    Write-Host "  Stop services:  .\start.ps1 stop"
    Write-Host "  Restart:        .\start.ps1 restart"
    Write-Host "  Clean up:       .\start.ps1 clean"
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Stop-Services {
    Write-Status "Stopping services..." -Color Yellow
    docker-compose down
    Write-Status "✓ Services stopped" -Color Green
}

function Show-Logs {
    docker-compose logs -f
}

function Restart-Services {
    Write-Status "Restarting services..." -Color Yellow
    docker-compose restart
    Start-Sleep -Seconds 3
    Write-Status "✓ Services restarted" -Color Green
    Display-Info
}

function Clean-Services {
    Write-Status "⚠️  This will remove all containers and volumes" -Color Red
    $response = Read-Host "Are you sure? (yes/no)"
    
    if ($response -eq "yes" -or $response -eq "y") {
        docker-compose down -v
        Write-Status "✓ Cleaned up" -Color Green
    } else {
        Write-Status "Cancelled" -Color Yellow
    }
}

# Main execution
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "PostgreSQL + pgAdmin Starter" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

switch ($Command.ToLower()) {
    "stop" {
        Stop-Services
    }
    "logs" {
        Show-Logs
    }
    "restart" {
        Restart-Services
    }
    "clean" {
        Clean-Services
    }
    default {
        Check-Docker
        Check-DockerDaemon
        Create-EnvFile
        Create-DockerCompose
        Create-InitScriptsDir
        Start-Services
        Display-Info
    }
}
