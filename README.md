# Full-Stack Todo Application

A modern, full-stack Todo application built with **Spring Boot**, **React**, and **PostgreSQL**. This project features a RESTful API backend and a responsive Vite-powered frontend, all orchestrated with Docker for the database.

## 🏗️ Project Structure

- **`backend/`**: Spring Boot 3.3 REST API with Spring Data JPA and PostgreSQL.
- **`frontend/`**: React 19 + Vite frontend using Axios for API communication.
- **`docker-compose.yml`**: Docker configuration for PostgreSQL 16 and pgAdmin 4.
- **`start.ps1` / `start.bat`**: Helper scripts to quickly set up the database environment on Windows.

## 🛠️ Tech Stack

- **Backend**: Java 17, Spring Boot 3.3, Spring Data JPA, Hibernate, Lombok.
- **Frontend**: React 19, Vite, Axios, CSS3.
- **Database**: PostgreSQL 16.
- **DevOps**: Docker, Docker Compose.

## 📋 Prerequisites

Ensure you have the following installed:
1. **Docker Desktop** - [Download for Windows](https://docs.docker.com/desktop/install/windows-install/) (Ensure it is running)
2. **Java 17 JDK** or higher
3. **Node.js** (LTS version recommended)
4. **Maven** (optional, uses `./mvnw` wrapper)

## 🚀 Quick Start

Follow these steps to get the application running:

### 1. Start the Database
From the project root, run the setup script to start PostgreSQL and pgAdmin:

```powershell
# Using PowerShell (Recommended)
.\start.ps1

# Or using Command Prompt
start.bat

# Manual (if not using scripts)
docker-compose up -d
```

### 2. Start the Backend API
Open a new terminal, navigate to the `backend` directory, and run the Spring Boot application:

```bash
cd backend
./mvnw spring-boot:run
```
The API will be available at: `http://localhost:8080/api/todos`

### 3. Start the Frontend
Open another terminal, navigate to the `frontend` directory, install dependencies, and start the development server:

```bash
cd frontend
npm install
npm run dev
```
The application will be available at: `http://localhost:5173`

---

## 🎯 Access Points

| Service | URL | Credentials (Default) |
| :--- | :--- | :--- |
| **Frontend** | [http://localhost:5173](http://localhost:5173) | N/A |
| **Backend API** | [http://localhost:8080/api/todos](http://localhost:8080/api/todos) | N/A |
| **pgAdmin (Web UI)** | [http://localhost:5050](http://localhost:5050) | `admin@example.com` / `admin` |
| **PostgreSQL** | `localhost:5432` | `postgres` / `postgres_password` |

### 🛠️ Connecting pgAdmin to PostgreSQL
Once logged into pgAdmin (http://localhost:5050), use these settings to register the server:
- **Hostname**: `host.docker.internal` (or `postgres` if within Docker network)
- **Port**: `5432`
- **Maintenance Database**: `postgres`
- **Username**: `postgres`
- **Password**: `postgres_password`

---

## 🔧 Database Management

The included helper scripts (`start.ps1` / `start.bat`) support several commands:

```powershell
.\start.ps1 stop      # Stop database services
.\start.ps1 logs      # View database logs
.\start.ps1 restart   # Restart services
.\start.ps1 clean     # Remove all containers and data (Be careful!)
```

### ⚙️ Custom Configuration
Edit the `.env` file (created automatically) to change passwords or database names:
```env
POSTGRES_PASSWORD=your_password
POSTGRES_DB=your_db_name
```
Then run `.\start.ps1 restart`.

### 🗄️ Auto-Initialize Database
Place `.sql` files in the `init-scripts/` folder. They will be executed automatically the first time the database is created.

---

## 💡 Tips & Troubleshooting

### Windows Specific Tips
- **Docker Desktop**: Must be running in the background. Check your system tray.
- **PowerShell Execution Policy**: If `.\start.ps1` fails, run:
  `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **WSL2**: For best performance, ensure Docker is configured to use the WSL2 backend.

### Common Issues
- **Port 5432 or 5050 already in use**: Stop any local PostgreSQL installations or change the ports in `docker-compose.yml`.
- **Can't connect**: Ensure you use `localhost` for host machine connections and `host.docker.internal` for pgAdmin-to-PostgreSQL connections.
- **View Logs**: If something isn't working, check the logs: `.\start.ps1 logs`.

## 🔐 Security Note

The default credentials are for **development only**. For production:
1. Update the `.env` file with strong passwords.
2. Ensure `.env` is listed in your `.gitignore`.
3. Use SSL/TLS for database connections.

---
Created with ❤️ for modern full-stack development.
