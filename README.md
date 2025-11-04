# Applications Repository

This repository contains various applications and tools developed by Todd Butcher.

## Applications

### Music Inventory App

**Version:** 1.1.2  
**Location:** `/music-inventory-app`

A full-stack music catalog management system with Docker containerization, featuring both private admin and public read-only interfaces.

**Key Features:**
- Music catalog management with CRUD operations (admin interface)
- Public read-only catalog interface for sharing your collection
- Real-time search and filtering across all fields
- ISRC code tracking with support for alphanumeric codes
- Year range statistics displaying collection span (e.g., "1998-2025")
- FastAPI backend with JSON file storage
- React/Vite admin frontend with authentication
- Static HTML public frontend (strictly read-only, no login/edit capabilities)
- Docker Compose orchestration
- WireGuard VPN integration for secure remote access
- Automated file synchronization between admin and public versions
- Support for multiple media types (CD, DVD, Vinyl, Digital)
- Genre classification and statistics
- Multi-disc support
- Network access via IP address with universal CORS support

**Tech Stack:**
- Backend: FastAPI (Python 3.13-alpine)
- Frontend: Vite + React (admin), Static HTML (public)
- Infrastructure: Docker, Docker Compose, Nginx
- VPN: WireGuard (wg-easy)
- Data: JSON file-based storage

**Access Points:**
- Admin Interface: Port 5173 or 8080 (requires authentication)
- Public Catalog: Port 9000 (read-only, no authentication)
- Backend API: Port 8000
- WireGuard VPN: Ports 51820 (UDP) and 51821 (TCP)

For detailed documentation, see [music-inventory-app/README.md](music-inventory-app/README.md)

---

## Repository Structure

```
apps/
├── README.md                    # This file
└── music-inventory-app/         # Music catalog management system
    ├── backend/                 # FastAPI backend
    ├── frontend/                # Admin and public frontends
    ├── wireguard/               # VPN configuration
    ├── scripts/                 # Utility scripts
    ├── compose.yaml             # Docker Compose configuration
    └── README.md                # Detailed documentation
```

## Getting Started

Each application contains its own README with detailed setup and usage instructions. Navigate to the specific application directory for more information.

## Author

Todd Butcher  
Email: Todd.Butcher71@gmail.com

## License

[Your License Here]
