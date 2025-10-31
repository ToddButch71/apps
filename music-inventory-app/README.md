# Music Inventory Application

A full-stack music catalog management system with Docker containerization, featuring both private admin and public read-only interfaces, secured remote access via WireGuard VPN, and automated synchronization.

## 🎵 Features

### Core Functionality
- **Music Catalog Management**: Track albums by media type, artist, title, year, serial number, media count, and genre
- **Real-time Search**: Instant filtering across all fields
- **Dual Interfaces**:
  - **Admin Version** (localhost:5173 or localhost:8080): Full CRUD operations with authentication
  - **Public Version** (localhost:9000): Read-only catalog for public sharing
- **Genre Classification**: Categorized music collection with visual badges
- **Multi-disc Support**: Track albums with multiple discs/media

### Security & Access
- **User Authentication**: Token-based auth for admin users (admin/toddb only)
- **Access Logging**: Tracks login attempts and external IP access
- **WireGuard VPN**: Secure remote access to the application
- **Public/Private Separation**: Isolated public catalog without admin capabilities

### Automation
- **Auto-Sync**: File watcher automatically syncs changes from admin to public version
- **Container Orchestration**: Fully dockerized with Docker Compose
- **Health Monitoring**: Health check endpoints for all services

## 🏗️ Architecture

### Services

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose Stack                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │   Backend    │  │   Frontend   │  │ Public Frontend │   │
│  │  FastAPI     │  │  Vite+React  │  │  Static HTML    │   │
│  │  Port 8000   │  │  Port 5173   │  │   Port 9000     │   │
│  └──────────────┘  └──────────────┘  └─────────────────┘   │
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐   │
│  │ Nginx Proxy  │  │  WireGuard   │  │  File Watcher   │   │
│  │  Port 8080   │  │51820/51821   │  │  Auto-Sync      │   │
│  └──────────────┘  └──────────────┘  └─────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Technology Stack

**Backend:**
- FastAPI (Python 3.11)
- JSON file-based storage
- OAuth2 password bearer authentication
- CORS middleware for cross-origin requests

**Frontend (Admin):**
- Vite 7.1.12
- React 18.2.0
- TypeScript
- Nginx (production)

**Frontend (Public):**
- Static HTML/CSS/JavaScript
- No authentication or write capabilities
- Nginx Alpine

**Infrastructure:**
- Docker & Docker Compose
- WireGuard VPN (wg-easy)
- File system watcher with polling
- Nginx reverse proxy

## 📦 Installation

### Prerequisites
- Docker Desktop
- Git

### Setup

1. **Clone the repository:**
```bash
git clone <repository-url>
cd music-inventory-app
```

2. **Configure credentials:**
Edit `backend/.secrets` with your admin credentials:
```
admin:your_password
toddb:your_password
```

3. **Configure WireGuard (optional):**
Edit `backend/.secrets.env` with your WireGuard password hash:
```bash
# Generate hash
docker run --rm ghcr.io/wg-easy/wg-easy wgpw 'your_password'

# Add to .secrets.env
PASSWORD_HASH='$2a$12$...'
```

4. **Update WireGuard host IP:**
Edit `compose.yaml` and set your public IP:
```yaml
- WG_HOST=YOUR_PUBLIC_IP
```

5. **Build and start services:**
```bash
docker compose build
docker compose up -d
```

## 🚀 Usage

### Access Points

- **Admin Interface**: http://localhost:5173 or http://localhost:8080
- **Public Catalog**: http://localhost:9000
- **Backend API**: http://localhost:8000
- **API Docs**: http://localhost:8000/docs
- **WireGuard UI**: http://localhost:51821

### Admin Login
- Username: `admin` or `toddb`
- Password: As configured in `backend/.secrets`

### Managing Inventory

**Add Album:**
1. Log in to admin interface
2. Click "Add New Album"
3. Fill in details (media type, artist, title, year, serial, media count, genre)
4. Confirm addition

**Edit Album:**
1. Click "Edit" button on any album row
2. Modify fields as needed
3. Confirm update

**Delete Album:**
1. Click "Delete" button on any album row
2. Confirm deletion

**Search:**
- Type in search bar to filter by any field
- Results update in real-time

### CLI Tool

Update inventory via command line:
```bash
python update_inventory.py --media CD --artist "Artist Name" \
  --title "Album Title" --year 2024 --serial ABC123 \
  --media-count 2 --genre Rock
```

### Auto-Sync

The file-watcher service automatically:
1. Monitors `frontend/index.html` for changes
2. Syncs to `frontend/index-public.html` (removes admin features)
3. Rebuilds and restarts the public frontend

**Manual sync:**
```bash
./sync-public.sh
```

**Monitor sync activity:**
```bash
docker compose logs -f file-watcher
```

## 🔒 Security

### Authentication
- Token-based authentication using base64-encoded JSON
- Only `admin` and `toddb` users can perform CRUD operations
- Tokens stored in localStorage

### Logging
- Login attempts logged with IP addresses
- External (non-localhost) access logged separately
- Logs stored in `backend/logs/external_access.log`

### WireGuard VPN
- Secure remote access to entire application
- Encrypted tunnel via UDP port 51820
- Web UI on TCP port 51821
- Requires router port forwarding for external access

## 🌐 Public Deployment

### Port Forwarding
Configure your router to forward:
- **TCP 9000** → Your machine's local IP (for public catalog)
- **UDP 51820** → Your machine's local IP (for WireGuard VPN)
- **TCP 51821** → Your machine's local IP (for WireGuard UI)

### Access via VPN
1. Log into WireGuard UI at http://localhost:51821
2. Create a client configuration
3. Scan QR code or download config file
4. Connect to VPN
5. Access services at `10.8.0.1:<port>`

## 📁 Project Structure

```
music-inventory-app/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI application
│   │   ├── auth.py          # Authentication logic
│   │   └── crud.py          # CRUD operations
│   ├── data/
│   │   └── music_inventory.json  # Data storage
│   ├── logs/                # Access logs
│   ├── .secrets             # Admin credentials
│   └── .secrets.env         # WireGuard password hash
├── frontend/
│   ├── index.html           # Admin interface
│   ├── index-public.html    # Public interface
│   ├── Dockerfile           # Admin build
│   └── Dockerfile-public    # Public build
├── wireguard/               # WireGuard configs (gitignored)
├── compose.yaml             # Docker Compose configuration
├── sync-public.sh           # Manual sync script
├── watch-sync-container.sh  # Auto-sync watcher
├── health_check.sh          # Health monitoring
└── update_inventory.py      # CLI tool

```

## 🛠️ Maintenance

### View Logs
```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f backend
docker compose logs -f file-watcher
```

### Restart Services
```bash
# All services
docker compose restart

# Specific service
docker compose restart public-frontend
```

### Rebuild After Changes
```bash
# Rebuild all
docker compose build

# Rebuild specific service
docker compose build backend
docker compose up -d backend
```

### Health Checks
```bash
./health_check.sh
```

### Backup Data
```bash
cp backend/data/music_inventory.json backup/music_inventory_$(date +%Y%m%d).json
```

## 📊 API Endpoints

### Public Endpoints
- `GET /health` - Health check
- `GET /inventory` - Get all albums
- `GET /inventory?search=query` - Search albums
- `POST /token` - Authenticate and get token

### Protected Endpoints (Requires Auth)
- `POST /inventory` - Add new album
- `PUT /inventory/{serial}` - Update album
- `DELETE /inventory/{serial}` - Delete album

## 🐛 Troubleshooting

### Container won't start
```bash
docker compose logs <service-name>
docker compose ps
```

### File watcher not detecting changes
- Check if using polling method (works on macOS)
- Verify file-watcher logs: `docker compose logs file-watcher`

### 403 Forbidden on public frontend
```bash
docker compose build public-frontend
docker compose up -d public-frontend
```

### WireGuard login fails
- Verify PASSWORD_HASH in `backend/.secrets.env`
- Check hash format: `PASSWORD_HASH='$2a$12$...'`
- Regenerate hash if needed

### CORS errors
- Check backend CORS configuration in `main.py`
- Verify frontend URL matches allowed origins

## 📝 License

[Your License Here]

## 👥 Contributors

Todd Butcher (Todd.Butcher71@gmail.com)

## 🙏 Acknowledgments

- FastAPI framework
- WireGuard Easy (wg-easy)
- Vite & React teams
