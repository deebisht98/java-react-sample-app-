# PostgreSQL Docker Setup

A complete Docker setup for PostgreSQL with docker-compose configuration.

## Files Included

- **Dockerfile** - PostgreSQL 16 Alpine-based image with health checks
- **docker-compose.yml** - Service orchestration with volume management
- **.env.example** - Environment variables template

## Quick Start

### 1. Clone/Create Environment File

```bash
cp .env.example .env
# Edit .env with your preferred credentials
```

### 2. Build and Start the Container

```bash
# Using docker-compose (recommended)
docker-compose up -d

# Or manually with Docker
docker build -t my-postgres .
docker run -d \
  --name postgres_db \
  -e POSTGRES_DB=myapp_db \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres_password \
  -p 5432:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  my-postgres
```

### 3. Verify It's Running

```bash
docker-compose ps
# or
docker ps | grep postgres_db
```

### 4. Connect to PostgreSQL

```bash
# From the host machine
psql -h localhost -U postgres -d myapp_db

# From another container
docker-compose exec postgres psql -U postgres -d myapp_db
```

## Useful Commands

### View Logs

```bash
docker-compose logs -f postgres
```

### Stop the Container

```bash
docker-compose down
```

### Stop and Remove Data

```bash
docker-compose down -v
```

### Connect with a Client

```bash
# Using psql
psql postgresql://postgres:password@localhost:5432/myapp_db

# Using pgAdmin (add to docker-compose.yml)
# Service runs on http://localhost:5050
```

## Advanced Configuration

### Add Initialization Scripts

Place SQL files in `init-scripts/` directory:

```bash
mkdir init-scripts
# Add your .sql files here
```

Then uncomment the volumes line in docker-compose.yml:

```yaml
volumes:
  - ./init-scripts:/docker-entrypoint-initdb.d
```

### Increase Memory/Performance

Uncomment the resources section in docker-compose.yml and adjust:

```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
```

### Enable Backup

Add a volume for backups:

```yaml
volumes:
  - postgres_data:/var/lib/postgresql/data
  - ./backups:/backups
```

## Connection Details

**Default Settings:**

- Host: `localhost` (or service name `postgres` from within Docker network)
- Port: `5432`
- Username: `postgres`
- Password: See `.env` file
- Database: `myapp_db`

## Security Notes

⚠️ **Important for Production:**

1. Change the default password in `.env`
2. Use strong, complex passwords
3. Don't commit `.env` to version control
4. Add `.env` to `.gitignore`
5. Consider using Docker secrets or HashiCorp Vault
6. Enable SSL/TLS connections
7. Implement proper backup strategy

## Troubleshooting

### Container won't start

```bash
docker-compose logs postgres
```

### Connection refused

- Ensure port 5432 is not in use
- Check if container is running: `docker-compose ps`

### Permission denied errors

- Verify volume permissions
- Run: `docker-compose down -v` to reset

### Data not persisting

- Ensure the named volume is defined in docker-compose.yml
- Check volume mount path matches the Dockerfile VOLUME directive

## Example: PostgreSQL + pgAdmin Stack

Add this to docker-compose.yml to include pgAdmin (web UI):

```yaml
pgadmin:
  image: dpage/pgadmin4:latest
  environment:
    PGADMIN_DEFAULT_EMAIL: admin@example.com
    PGADMIN_DEFAULT_PASSWORD: admin
  ports:
    - '5050:80'
  depends_on:
    - postgres
  networks:
    - postgres_network
```

Access pgAdmin at `http://localhost:5050`

## Resources

- [Official PostgreSQL Docker Image](https://hub.docker.com/_/postgres)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

chmod +x start.sh
./start.sh
That's it! The script will:

✅ Check if Docker is installed
✅ Create .env file with default credentials
✅ Generate docker-compose.yml with PostgreSQL + pgAdmin
✅ Create init-scripts/ directory
✅ Start both services
✅ Display all connection details

📊 What You'll Get
PostgreSQL:

Host: localhost:5432
User: postgres
Password: postgres_password
Database: myapp_db

pgAdmin (Web UI):

URL: http://localhost:5050
Email: admin@example.com
Password: admin

🔧 Other Commands
bash./start.sh logs # View logs
./start.sh stop # Stop services
./start.sh restart # Restart services
./start.sh clean # Remove everything
💡 Key Features

Zero config - Just run it!
Self-documenting - Shows all credentials and connection info
Health checks - Waits for services to be healthy
Data persistence - Uses Docker volumes
Easy customization - Just edit .env and restart
Init scripts - Drop SQL files in init-scripts/ to auto-run them

The script creates everything needed automatically and displays a nice summary with all connection details when done!
