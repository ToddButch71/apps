# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.3] - 2025-11-05

### Added
- Sortable table columns: Click column headers to sort by Media Type, Artist, Album Title, Year Released, or Genre
- Visual sort indicators (⇅ unsorted, ↑ ascending, ↓ descending) on sortable column headers
- Hover effects on sortable column headers for better UX
- Support for both ascending and descending sort with toggle functionality

### Changed
- Default sort changed to Artist (alphabetically, ascending) instead of unsorted
- Auto-refresh interval reduced from 30 seconds to 12 hours (43,200,000ms)
- Table data now sorted alphabetically by artist on initial load
- Sortable columns: Media Type, Artist, Album Title, Year Released, Genre
- Non-sortable columns: ISRC Code, Media Count, Notes

## [1.1.2] - 2025-11-04

### Changed
- Updated "Latest Release Year" stat to "Release Years" showing year range (e.g., "1998-2025")
- Modified stats calculation to display oldest-to-newest year range instead of just latest year
- Updated both admin and public interfaces with new year range display

### Removed
- Removed all login/authentication UI elements from public interface (recurring cleanup)
- Removed album add/edit modal dialog from public interface
- Removed all form-related CSS (modal, buttons, form-group styles) from public interface
- Ensured public interface is completely read-only with no edit/delete capabilities

## [1.1.1] - 2025-11-04

### Fixed
- CORS configuration now allows all origins (`allow_origins=["*"]`) to fix 403 errors when accessing by IP address
- Resolved 503 error when accessing nginx-proxy via IP address (added IP to VIRTUAL_HOST)
- Backend now properly handles requests from any network origin

### Changed
- Updated all "Serial Number" labels to "ISRC Code" in admin interface (`index.html`)
- Updated all "Serial Number" labels to "ISRC Code" in public interface (`index-public.html`)
- Changed search placeholder text from "serial number" to "ISRC code"
- Updated table headers from "Serial Number" to "ISRC Code"

## [1.1.0] - 2025-11-03

### Added
- Automated CHANGELOG.md updates: `bump-version.sh` now automatically inserts version templates
- Comprehensive utility scripts documentation in README.md
- Recent Updates section in README.md highlighting latest features

### Changed
- Realtime indicator now shows functional sync status with color-coded states (green/blue/orange/red)
- Public frontend cleaned up: removed all login/authentication UI elements
- CORS configuration now allows all origins for better accessibility
- `bump-version.sh` automatically updates VERSION, README.md, package.json, and CHANGELOG.md
- Improved version management workflow with automated file updates

### Fixed
- Backend Dockerfile: corrected Python version to 3.13-alpine (was incorrectly set to 3.14)
- Frontend Dockerfile: removed reference to non-existent nginx.conf file
- Docker build failures resolved for both backend and frontend containers
- README.md now accurately reflects Python 3.13-alpine in Technology Stack
- Duplicate versioning sections removed from README.md

## [1.0.0] - 2025-11-03

### Added
- Initial release
- Music catalog management with CRUD operations
- Dual interfaces (admin and public read-only)
- FastAPI backend with JSON file storage
- React/Vite frontend for admin interface
- Static HTML public interface
- Token-based authentication for admin users
- Real-time search functionality
- Support for alphanumeric serial numbers
- Genre classification
- Multi-disc support
- WireGuard VPN integration
- Auto-sync file watcher
- Docker containerization with Docker Compose
- External access logging
- Health check endpoints
- CLI tool for inventory management
- SMB cleanup script
- Versioning system with bump-version.sh

### Security
- OAuth2 password bearer authentication
- CORS middleware configuration
- Admin-only write operations
- VPN access for remote administration

---

## How to Update This File

The `./bump-version.sh` script **automatically** inserts version templates into this file.

### Automatic Process

When you run `./bump-version.sh [patch|minor|major]`, it will:

1. **Automatically insert** a new version entry at the top with the appropriate template:
   - **Patch** (bug fixes): Adds `### Fixed` section
   - **Minor** (new features): Adds `### Added` and `### Changed` sections  
   - **Major** (breaking changes): Adds `### Changed` (BREAKING) and `### Removed` sections

2. **Prompt you** to edit the file and replace placeholder text with your actual changes

3. The template format:
   ```markdown
   ## [X.Y.Z] - YYYY-MM-DD
   
   ### Section Header
   - Your description here
   ```

### Manual Updates (if needed)

You can also manually edit this file following the same format. The script will still work on your next version bump.

---

[1.1.0]: https://github.com/ToddButch71/apps/releases/tag/v1.1.0
[1.0.0]: https://github.com/ToddButch71/apps/releases/tag/v1.0.0
