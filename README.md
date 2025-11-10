# Applications Repository

This repository contains various applications and tools developed by Todd Butcher.

## Applications

### Music Catalog

**Version:** 1.1.4  
**Location:** `/music-inventory-app`

A containerized full-stack music catalog management system featuring dual interfaces: authenticated admin for full CRUD operations and public read-only catalog for sharing your collection.

**Key Features:**
- Dual interfaces (private admin + public read-only)
- Real-time search and sortable columns
- ISRC code tracking, year range statistics, genre classification
- FastAPI backend with React/Vite admin frontend
- Docker Compose orchestration with automated sync
- Optional WireGuard VPN integration for secure remote access

**Tech Stack:** Python 3.13-alpine, FastAPI, React, Vite, Docker, Nginx

**Quick Start:**
```bash
cd music-inventory-app
docker compose up -d
# Admin: http://localhost:5173
# Public: http://localhost:9000
```

For complete documentation, setup instructions, and API reference, see [music-inventory-app/README.md](music-inventory-app/README.md)

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
