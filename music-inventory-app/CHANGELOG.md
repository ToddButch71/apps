# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.0] - 2025-11-03
 
### Changed
- The pulsating exclamation point is now a green check or red x, updated every 30 seconds showing data is current.
- Removed the login button from the public facing page.

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

When bumping versions using `./bump-version.sh`, update this file with:

### For Patch Releases (bug fixes)
```markdown
## [X.Y.Z] - YYYY-MM-DD

### Fixed
- Bug description
```

### For Minor Releases (new features)
```markdown
## [X.Y.0] - YYYY-MM-DD

### Added
- New feature description

### Changed
- Modified feature description
```

### For Major Releases (breaking changes)
```markdown
## [X.0.0] - YYYY-MM-DD

### Changed
- BREAKING: Description of breaking change

### Removed
- Deprecated feature removed
```

[1.0.0]: https://github.com/ToddButch71/apps/releases/tag/v1.0.0
