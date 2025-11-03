# Music Inventory Application

**Version 1.0.0**

A full-stack music catalog management system with Docker containerization, featuring both private admin and public read-only interfaces, secured remote access via WireGuard VPN, and automated synchronization.

## 🎵 Features

### Core Functionality
- **Music Catalog Management**: Track albums by media type, artist, title, year, serial number, media count, genre, and notes
- **Real-time Search**: Instant filtering across all fields
- **Dual Interfaces**:
  - **Admin Version** (localhost:5173 or localhost:8080): Full CRUD operations with authentication
  - **Public Version** (localhost:9000): Read-only catalog for public sharing (no authentication)
- **Genre Classification**: Categorized music collection
- **Media Type Display**: Media types displayed in lowercase (cd, dvd, vinyl)
- **Flexible Serial Numbers**: Support for both numeric (676127505326) and alphanumeric (WIGLP456, v-8645) serial numbers
- **Multi-disc Support**: Track albums with multiple discs/media

### Security & Access
- **User Authentication**: Token-based auth for admin users (admin/toddb only)
- **Access Logging**: Tracks login attempts and external IP access
- **VPN Access Options**: 
  - Use existing router WireGuard VPN (recommended)
  - Direct port forwarding for public access
  - Integrated WireGuard container (see WIREGUARD_SETUP.md)
- **Public/Private Separation**: Isolated public catalog without admin capabilities

### Automation
- **Auto-Sync**: File watcher automatically syncs changes from admin to public version
- **Container Orchestration**: Fully dockerized with Docker Compose
- **Health Monitoring**: Health check endpoints for all services
- **Automated Versioning**: Semantic versioning with automated bump script

## 📰 Recent Updates

### Version 1.1.0 (Latest)
- ✅ **Functional Realtime Indicator**: Replaced pulsating exclamation with color-coded sync status
  - Green checkmark: Data is current (updated within 30 seconds)
  - Blue pulse: Actively syncing
  - Orange warning: Data may be stale
  - Red error: Sync failed
- ✅ **Public Frontend Cleanup**: Removed all login/authentication UI from public interface
- ✅ **CORS Configuration**: Backend now accepts requests from all origins for better accessibility
- ✅ **Docker Fixes**: Corrected Dockerfile configurations for reliable builds

### Version 1.0.0
- Initial release with full CRUD functionality
- Dual interface architecture (admin + public)
- WireGuard VPN integration
- Automated file synchronization

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
- FastAPI (Python 3.13-alpine)
- JSON file-based storage
- OAuth2 password bearer authentication
- CORS middleware (configured for all origins)

**Frontend (Admin):**
- Vite 7.1.12
- React 18.2.0
- TypeScript
- Realtime sync status indicator (30-second refresh)
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
- Automated version management with semantic versioning

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

Update inventory via command line with alphanumeric serial numbers:
```bash
python update_inventory.py --media CD --artist "Artist Name" \
  --title "Album Title" --year 2024 --serial ABC123 \
  --media-count 2 --genre Rock --notes "Special edition"
```

The CLI tool prompts for confirmation before saving any changes.

### Auto-Sync

The file-watcher service automatically:
1. Monitors `frontend/index.html` for changes
2. Syncs to `frontend/index-public.html` (removes admin features)
3. Rebuilds and restarts the public frontend

The admin interface displays a realtime sync indicator that:
- Shows green checkmark when data is current (updated within 30 seconds)
- Shows blue "syncing" when actively checking
- Shows orange warning if data is stale
- Shows red error if sync fails
- Auto-refreshes every 30 seconds

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
- **Note**: If your router has built-in WireGuard VPN, use that instead (see WIREGUARD_SETUP.md)

## 🌐 Public Deployment

### Remote Access Options

See `WIREGUARD_SETUP.md` for detailed remote access configurations:

**Option 1: Use Router VPN (Recommended)**
- If your router has WireGuard VPN, use that to access the application
- No additional port forwarding needed
- Connect to VPN, then access services at local IP addresses

**Option 2: Direct Port Forwarding**
- Forward specific ports through your router
- Simpler but less secure for admin interface

**Option 3: Dockerized WireGuard**
- Use the included WireGuard container
- Full VPN access to all services

### Port Forwarding
Configure your router to forward:
- **TCP 9000** → Your machine's local IP (for public catalog)
- **TCP 8080** → Your machine's local IP (for admin interface - use VPN instead if possible)
- **UDP 51820** → Your machine's local IP (for WireGuard VPN, if using Option 3)
- **TCP 51821** → Your machine's local IP (for WireGuard UI, if using Option 3)

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
│   ├── index-public.html    # Public interface (auto-synced)
│   ├── Dockerfile           # Admin build
│   └── Dockerfile-public    # Public build
├── wireguard/               # WireGuard configs (gitignored)
├── scripts/                 # Utility scripts
├── VERSION                  # Current version (semantic versioning)
├── CHANGELOG.md             # Version history and changes
├── compose.yaml             # Docker Compose configuration
├── bump-version.sh          # Automated version bumping
├── get-version.sh           # Display current version
├── clean-smb-files.sh       # Remove macOS SMB temp files
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

### Utility Scripts

**Version Management:**
- `./get-version.sh` - Display current version
- `./bump-version.sh [major|minor|patch]` - Automated version bumping with CHANGELOG integration

**Maintenance:**
- `./health_check.sh` - Check health status of all services
- `./clean-smb-files.sh` - Remove macOS SMB temporary files (.smbdelete*)
- `./sync-public.sh` - Manually sync admin to public frontend

**WireGuard Setup:**
- `./setup_wireguard.sh` - Initial WireGuard VPN configuration
- `./generate_wg_password_hash.sh` - Generate password hash for WireGuard UI

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
- Backend allows all origins by default (`allow_origins=["*"]`)
- Check backend CORS configuration in `backend/app/main.py` if issues persist
- Verify frontend URL matches allowed origins

### macOS SMB temporary files
```bash
# Clean .smbdelete* files
./clean-smb-files.sh
```

## 🔖 Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH). The version is stored in the `VERSION` file at the root of the project and automatically synced to `README.md` and `frontend/package.json`.

**Current Version:** 1.0.0

### Checking Version

**Via script:**
```bash
./get-version.sh
```

**Via API:**
```bash
curl http://localhost:8000/
```

**Via file:**
```bash
cat VERSION
```

### Updating Version (Automated)

Use the `bump-version.sh` script to automatically update version across all files:

```bash
# Increment patch version (1.0.0 → 1.0.1)
./bump-version.sh patch

# Increment minor version (1.0.0 → 1.1.0)
./bump-version.sh minor

# Increment major version (1.0.0 → 2.0.0)
./bump-version.sh major
```

The script will:
1. Prompt you to update `CHANGELOG.md` with your changes
2. Optionally open `CHANGELOG.md` in your editor
3. Update `VERSION`, `README.md`, and `frontend/package.json`
4. Display next steps for git commit and container rebuild

### Manual Version Update

If you prefer to update manually:
1. Edit the `VERSION` file
2. Update version in `README.md` (line 3 and Versioning section)
3. Update version in `frontend/package.json`
4. Update `CHANGELOG.md` with your changes
5. Rebuild containers:
   ```bash
   docker compose build
   docker compose up -d
   ```

## 📝 License

[Your License Here]

## 👥 Contributors

Todd Butcher (Todd.Butcher71@gmail.com)

## 🙏 Acknowledgments

- FastAPI framework
- WireGuard Easy (wg-easy)
- Vite & React teams
