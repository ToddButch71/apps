# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-01-05

### Removed
- Removed WireGuard VPN service from Docker Compose configuration
- Removed WireGuard setup documentation (WIREGUARD_SETUP.md)
- Removed public Dockerfile (frontend/Dockerfile.public) - using single Dockerfile with build args
- Cleaned up check-docs.sh script references to deleted WireGuard setup scripts
- Removed WireGuard from Grafana monitoring dependencies (grafana-compose-test.yml)

### Changed
- Updated backend Dockerfile with improved Python image specifications
- Updated file-watcher Dockerfile with dependency updates
- Reorganized Docker compose services for cleaner configuration

## [1.1.5] - 2025-11-11

### Fixed
- Fixed JavaScript error at line 1664 in `index.html` caused by orphaned duplicate code block
- Removed 138 lines of duplicate stats calculation code that was accidentally nested inside `animateValue` function
- Restored proper `animateValue` function structure
- Re-added missing multi-disc stats calculation to `updateStats` function
- Fixed media type analytics to normalize case (CD/cd, DVD/dvd counted separately) - now converts to lowercase before counting
- Removed trailing whitespaces from `index.html`, `index-public.html`, and `backend/app/main.py`

### Changed
- Media Type dropdown values changed from uppercase (CD, DVD, Vinyl, Digital) to lowercase (cd, dvd, vinyl, digital) for consistency
- Relocated stats section to top of page (before table) in both admin and public versions for better visibility
- Updated `index-public.html` header comments to correctly identify as "Public Read-Only Interface"
- Updated page title from "Music Catalog - Admin" to "Music Catalog - Public View" in public version
- Media type analytics now case-insensitive (applied to both `index.html` and `index-public.html`)

### Removed
- Removed all authentication elements from public interface (`index-public.html`):
  - Auth status indicator (login/logout buttons)
  - Login modal and form
  - Add/Edit album modal and form
  - Action buttons ("Add New Album" button)
  - Actions column header in table
  - All auth-related CSS (modal, form-group, btn classes, auth-status, action-buttons)
  - All auth-related JavaScript functions (checkAuthStatus, showLoginModal, handleLogin, logout, showAddRecordForm, showEditRecordForm, deleteRecord, handleAlbumSubmit, closeAlbumModal)
  - Auth state variables (authToken, editingSerial)
  - Edit/Delete buttons from table rows

### Added
- Enhanced cross-browser compatibility for Safari and Firefox:
  - Added `maximum-scale=5.0, user-scalable=yes` to viewport meta tag for better zoom control
  - Added `-webkit-` and `-moz-` vendor prefixes for box-sizing
  - Added text size adjustment properties for Safari and Firefox (`-webkit-text-size-adjust`, `-moz-text-size-adjust`)
  - Enhanced font stack with system fonts (`-apple-system`, `BlinkMacSystemFont`)
  - Added font smoothing for better rendering on Safari/macOS (`-webkit-font-smoothing`, `-moz-osx-font-smoothing`)
- Responsive typography using `clamp()` for fluid font sizes:
  - Headings scale from 1.5rem to 2rem based on viewport
  - Subtitles scale from 0.9rem to 1.1rem
  - Table text scales from 0.85rem to 1rem
- Flexible responsive layouts:
  - Container has 100% width with max-width constraint
  - Search bar uses `flex-wrap` with `min-width: 200px` for mobile wrapping
  - Table has proper overflow handling with `-webkit-overflow-scrolling: touch`
  - Added `word-wrap` and `overflow-wrap` for long text handling
- Responsive breakpoints:
  - Tablet (max-width: 768px): Reduced padding, touch-friendly scrolling
  - Mobile (max-width: 480px): Smaller fonts, compact padding
- Browser-specific improvements:
  - Added `-webkit-user-select` and `-moz-user-select` for consistent text selection behavior
  - Table display properties for proper rendering across browsers (thead/tbody as table with fixed layout)
  - Added `min-width: 320px` to body for minimum device support

## [1.1.4] - 2025-11-07

## Changed
- Updated genres totals 

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

[1.2.0]: https://github.com/ToddButch71/apps/releases/tag/v1.2.0
[1.1.0]: https://github.com/ToddButch71/apps/releases/tag/v1.1.0
[1.0.0]: https://github.com/ToddButch71/apps/releases/tag/v1.0.0
