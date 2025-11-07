# Music Catalog

**Version 1.1.4**

A full-stack music catalog management system with Docker containerization, featuring both private admin and public read-only interfaces, secured remote access via WireGuard VPN, and automated synchronization.

## 🎵 Features

### Core Functionality
- **Music Catalog Management**: Track albums by media type, artist, title, year, ISRC code, media count, genre, and notes
- **Real-time Search**: Instant filtering across all fields
- **Dual Interfaces**:
  - **Admin Version** (localhost:5173 or localhost:8080): Full CRUD operations with authentication
  - **Public Version** (localhost:9000): Read-only catalog for public sharing (no authentication)
- **Genre Classification**: Categorized music collection
- **Media Type Display**: Media types displayed in lowercase (cd, dvd, vinyl)
- **ISRC Code Tracking**: Support for both numeric (676127505326) and alphanumeric (WIGLP456, v-8645) ISRC codes
- **Multi-disc Support**: Track albums with multiple discs/media
- **Year Range Statistics**: Display collection year range from oldest to newest album

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

### Version 1.1.3 (Latest)
- ✅ **Sortable Columns**: Click column headers to sort by Media Type, Artist, Album Title, Year, or Genre
- ✅ **Visual Sort Indicators**: Clear visual feedback (⇅ ↑ ↓) on sortable columns
- ✅ **Default Alphabetical Sort**: Albums now sorted by artist alphabetically on load
- ✅ **Extended Refresh Interval**: Auto-refresh reduced from 30 seconds to 12 hours for better performance

### Version 1.1.2
- ✅ **Year Range Display**: Shows collection year range (e.g., "1998-2025") instead of just latest year
- ✅ **Enhanced Public Interface**: Further cleanup to ensure public interface remains strictly read-only

### Version 1.1.1
- ✅ **ISRC Code Labels**: Changed all "Serial Number" labels to "ISRC Code" throughout both interfaces
- ✅ **Network Access Fixed**: Resolved CORS and nginx-proxy 503 errors when accessing by IP address
- ✅ **Universal CORS**: Backend now accepts requests from all origins for better accessibility

### Version 1.1.0
- ✅ **Functional Realtime Indicator**: Color-coded sync status (green/blue/orange/red)
- ✅ **Public Frontend Cleanup**: Removed all login/authentication UI from public interface
- ✅ **Docker Fixes**: Corrected Dockerfile configurations for reliable builds

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
- Realtime sync status indicator (12-hour refresh)
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

Update inventory via command line with alphanumeric ISRC codes:
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

The admin interface displays a realtime sync indicator with color-coded status:
- Green checkmark: Data is current
- Blue pulse: Actively syncing
- Orange warning: Data may be stale
- Red error: Sync failed

Auto-refresh interval: 12 hours

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
│   └── .secrets             # Admin credentials (gitignored)
├── frontend/
│   ├── index.html           # Admin interface
│   ├── index-public.html    # Public interface (auto-synced)
│   ├── Dockerfile           # Admin build
│   └── Dockerfile-public    # Public build
├── wireguard/               # WireGuard configs (gitignored)
├── scripts/                 # Health check utilities
├── VERSION                  # Current version (semantic versioning)
├── CHANGELOG.md             # Version history and changes
├── VERSION_MANAGEMENT.md    # Version management guide
├── WIREGUARD_SETUP.md       # WireGuard configuration guide
├── README.md                # This file
├── compose.yaml             # Docker Compose configuration
├── bump-version.sh          # Automated version & docs updater
├── check-docs.sh            # Documentation consistency validator
├── clean-smb-files.sh       # Remove macOS SMB temp files
├── sync-public.sh           # Manual sync script
├── watch-sync-container.sh  # Auto-sync watcher
├── health_check.sh          # Health monitoring
└── update_inventory.py      # CLI tool
```

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
- `./bump-version.sh [major|minor|patch]` - Automated version bumping with CHANGELOG integration
- `./check-docs.sh` - Validate documentation consistency across all files

**Maintenance:**
- `./health_check.sh` - Check health status of all services
- `./clean-smb-files.sh` - Remove macOS SMB temporary files (.smbdelete*)
- `./sync-public.sh` - Manually sync admin to public frontend

## 📊 API Endpoints

### Public Endpoints
- `GET /health` - Health check
- `GET /inventory` - Get all albums
- `GET /inventory?search=query` - Search albums
- `POST /token` - Authenticate and get token

### Protected Endpoints (Requires Auth)
- `POST /inventory` - Add new album
- `PUT /inventory/{isrc}` - Update album by ISRC code
- `DELETE /inventory/{isrc}` - Delete album by ISRC code

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

### 503 errors when accessing by IP address
- Use direct service ports instead of nginx-proxy (port 8080):
  - Admin: `http://YOUR_IP:5173`
  - Public: `http://YOUR_IP:9000`
  - Backend: `http://YOUR_IP:8000`
- Or add your IP to `VIRTUAL_HOST` in `compose.yaml` for nginx-proxy support

### macOS SMB temporary files
```bash
# Clean .smbdelete* files
./clean-smb-files.sh
```

## 🔖 Versioning

This project uses semantic versioning (MAJOR.MINOR.PATCH). The version is stored in the `VERSION` file and automatically synchronized across all documentation files using the `bump-version.sh` script.

**Current Version:** 1.1.3

For detailed version management workflows, see [VERSION_MANAGEMENT.md](VERSION_MANAGEMENT.md).

### Quick Version Management

**Check Documentation Consistency:**
```bash
./check-docs.sh
```

This validates that version numbers are consistent across:
- `VERSION` file
- `README.md` (app)
- `../README.md` (repository root)
- `frontend/package.json`
- `CHANGELOG.md`

**Bump Version (Automated):**
```bash
# Increment patch version (1.0.0 → 1.0.1)
./bump-version.sh patch

# Increment minor version (1.0.0 → 1.1.0)
./bump-version.sh minor

# Increment major version (1.0.0 → 2.0.0)
./bump-version.sh major
```

The `bump-version.sh` script automatically:
1. Updates version in all documentation files
2. Updates or creates CHANGELOG.md entry
3. Verifies all changes
4. Provides next steps for git commit and Docker rebuild

### Checking Version

**Via API:**
```bash
curl http://localhost:8000/
```

**Via file:**
```bash
cat VERSION
```

### Manual Version Update

If you need to update manually (not recommended):
1. Edit the `VERSION` file
2. Run `./check-docs.sh` to verify inconsistencies
3. Update version in `README.md` (header and Versioning section)
4. Update version in `../README.md` (Music Catalog section)
5. Update version in `frontend/package.json`
6. Update `CHANGELOG.md` with your changes
7. Rebuild containers:
   ```bash
   docker compose build
   docker compose up -d
   ```

**Recommended:** Use `./bump-version.sh` instead to avoid manual errors.

## 📝 License

[Your License Here]

## 👥 Contributors

Todd Butcher (Todd.Butcher71@gmail.com)

## 🙏 Acknowledgments

- FastAPI framework
- WireGuard Easy (wg-easy)
- Vite & React teams
