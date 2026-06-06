# PostgreSQL + pgAdmin on Windows - One Command Setup

Get PostgreSQL and pgAdmin running with a single command on Windows!

## 🚀 Quick Start

### Option 1: PowerShell (Recommended)

```powershell
.\start.ps1
```

### Option 2: Command Prompt

```cmd
start.bat
```

### Option 3: Manual (No script needed)

```powershell
docker-compose up -d
```

That's it! Both PostgreSQL and pgAdmin will be running.

## 📋 Prerequisites

1. **Docker Desktop for Windows** installed and running
   - Download: https://docs.docker.com/desktop/install/windows-install/
   - Make sure Docker is running (check system tray)

## 🎯 Access Points

### PostgreSQL Database

```
Host:     localhost
Port:     5432
User:     postgres
Password: postgres_password
Database: myapp_db
```

**Connect using any PostgreSQL client:**

```powershell
# Using psql (if installed)
psql -h localhost -U postgres -d myapp_db

# Or use the connection string in your app:
postgresql://postgres:postgres_password@localhost:5432/myapp_db
```

### pgAdmin (Web UI) - Easiest!

```
URL:      http://localhost:5050
Email:    admin@example.com
Password: admin
```

Inside PgAdmin-
hostname=host.docker.internal
port=5432
maintenance_database=postgres
Username=postgres
Password=postgres_password

Simply open your browser and go to **http://localhost:5050** - no command line needed!

## 🔧 Available Commands

### PowerShell

```powershell
.\start.ps1              # Start everything
.\start.ps1 logs         # View logs
.\start.ps1 stop         # Stop services
.\start.ps1 restart      # Restart services
.\start.ps1 clean        # Remove everything
```

### Command Prompt

```cmd
start.bat                # Start everything
start.bat logs           # View logs
start.bat stop           # Stop services
start.bat restart        # Restart services
start.bat clean          # Remove everything
```

## ⚙️ Customize Settings

Edit the `.env` file (created automatically) to change:

```env
POSTGRES_PASSWORD=your_password_here
PGADMIN_DEFAULT_PASSWORD=your_pgadmin_password
POSTGRES_DB=your_database_name
```

Then restart:

```powershell
.\start.ps1 restart
```

## 🗄️ Auto-Initialize Database

Place SQL files in the `init-scripts/` folder to run them automatically on startup:

```powershell
# Create a sample setup script
@"
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@ | Out-File init-scripts\01-create-users-table.sql

# Restart to run it
.\start.ps1 restart
```

## 🔐 Security

⚠️ **Important:**

1. The default passwords are for **development only**
2. For production, edit `.env` with strong passwords
3. Don't commit `.env` to version control (`.gitignore` is included)

## 🐛 Troubleshooting

### Docker Desktop isn't running

- Open Docker Desktop from Start menu
- Wait for it to fully load (icon in system tray)
- Try again

### Port 5432 or 5050 already in use

Edit `docker-compose.yml` and change the port mappings:

```yaml
# Change "5432:5432" to another port like "5433:5432"
ports:
  - '5433:5432' # PostgreSQL now on 5433
```

### Can't connect to database

- Ensure Docker containers are running: `docker ps`
- Check logs: `.\start.ps1 logs`
- Verify you're using `localhost`, not `postgres`

### Data not persisting

- Don't run `.\start.ps1 clean` unless you want to delete data
- Use `.\start.ps1 stop` to pause without losing data

### PowerShell execution policy error

If you get an execution policy error, run:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try again.

## 💡 Tips for Windows Users

1. **Use pgAdmin Web UI** - Click the link in terminal, no command line needed!
2. **Docker Desktop** - Keep it running in background
3. **Port forwarding** - If using WSL2, localhost works fine
4. **WSL2 backend** - Docker Desktop on Windows uses WSL2 (recommended)
5. **Performance** - File performance is best with Windows drives, not network locations

## 📁 Project Structure

After running the script:

```
.
├── start.ps1                 # PowerShell starter (use this on Windows!)
├── start.bat                 # Batch file (alternative)
├── docker-compose.yml        # Generated automatically
├── .env                      # Your settings (auto-generated)
├── .gitignore               # Git settings (don't commit passwords!)
└── init-scripts/            # Place .sql files here
    └── (empty - add your SQL here)
```

## 🎯 Next Steps

1. Run `.\start.ps1` (or `start.bat`)
2. Wait for "PostgreSQL + pgAdmin is running!"
3. Open http://localhost:5050 in your browser
4. Log in with email: `admin@example.com` and password: `admin`
5. Create a server connection to PostgreSQL
6. Start using pgAdmin to manage your database!

## 📚 Learning Path

- **Just getting started?** Use pgAdmin web UI - no SQL knowledge needed
- **Want to write SQL?** Use the Query Tool in pgAdmin
- **Using in your code?** Connection string: `postgresql://postgres:postgres_password@localhost:5432/myapp_db`

## 🆘 Getting Help

Check logs to see what's happening:

```powershell
.\start.ps1 logs
```

Common log messages:

- `port already allocated` → Another app using port 5432/5050
- `image not found` → Docker couldn't download the image (check internet)
- `permission denied` → Run PowerShell as Administrator

## 🗑️ Cleanup

**Stop without losing data:**

```powershell
.\start.ps1 stop
```

**Delete everything (be careful!):**

```powershell
.\start.ps1 clean
```

---

**Ready? Run:** `.\start.ps1`

That's all you need! 🎉
