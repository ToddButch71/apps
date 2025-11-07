# Version Management Guide

This guide explains the automated version management system for the Music Catalog application.

## Overview

The application uses **semantic versioning** (MAJOR.MINOR.PATCH) with automated tooling to ensure consistency across all documentation files.

### Versioned Files

The version number is maintained in these files:
- `VERSION` - Single source of truth
- `README.md` - Application documentation (header and versioning section)
- `../README.md` - Repository root documentation
- `frontend/package.json` - Frontend package version
- `CHANGELOG.md` - Version history

## Tools

### 1. check-docs.sh - Documentation Consistency Validator

**Purpose:** Validates that all version numbers are synchronized across documentation.

**Usage:**
```bash
./check-docs.sh
```

**What it checks:**
- ✓ Version consistency across all files
- ✓ CHANGELOG format and entries
- ✓ References to deleted scripts
- ✓ Multiple version references in docs

**Example Output:**
```
╔════════════════════════════════════════════╗
║   Documentation Consistency Checker        ║
╚════════════════════════════════════════════╝

Version Information:
─────────────────────────────────────────
VERSION file:     1.1.3
App README:       1.1.3
Root README:      1.1.3
package.json:     1.1.3
CHANGELOG.md:     1.1.3

✓ All version numbers are consistent!

CHANGELOG Validation:
─────────────────────────────────────────
✓ No unreleased changes
✓ CHANGELOG contains version entries

╔════════════════════════════════════════════╗
║  ✓ Documentation is consistent            ║
╚════════════════════════════════════════════╝
```

**When to use:**
- Before creating a pull request
- After manual documentation edits
- As part of CI/CD pipeline
- When troubleshooting version inconsistencies

### 2. bump-version.sh - Automated Version Bumper

**Purpose:** Increments version and updates all documentation files automatically.

**Usage:**
```bash
./bump-version.sh [major|minor|patch]
```

**Bump Types:**
- `major` - Breaking changes (1.0.0 → 2.0.0)
- `minor` - New features, backward compatible (1.0.0 → 1.1.0)
- `patch` - Bug fixes, backward compatible (1.0.0 → 1.0.1)

**What it does:**
1. Calculates new version number
2. Prompts for confirmation
3. Updates all versioned files:
   - `VERSION`
   - `README.md` (app)
   - `../README.md` (root)
   - `frontend/package.json`
   - `CHANGELOG.md`
4. Verifies all updates succeeded
5. Provides next steps

**Example Workflow:**
```bash
$ ./bump-version.sh patch

╔════════════════════════════════════════════╗
║     Music Catalog - Version Bump Script   ║
╚════════════════════════════════════════════╝

Current version: 1.1.3
New version:     1.1.4

Proceed with version bump? [y/N] y

Updating files...
✓ Updated VERSION to 1.1.4
✓ Updated README.md
✓ Updated ../README.md
✓ Updated frontend/package.json
✓ Updated CHANGELOG.md (converted [Unreleased] to [1.1.4])

Verifying updates...
✓ VERSION file: 1.1.4
✓ App README: 1.1.4
✓ Root README: 1.1.4
✓ package.json: 1.1.4
✓ CHANGELOG.md: 1.1.4

All files updated successfully!

╔════════════════════════════════════════════╗
║            Next Steps                      ║
╚════════════════════════════════════════════╝

1. Review and edit CHANGELOG.md to document changes
2. Commit changes:
   git add .
   git commit -m "Bump version to 1.1.4"

3. Rebuild Docker containers:
   docker compose build
   docker compose up -d

4. Tag the release:
   git tag -a v1.1.4 -m "Release v1.1.4"
   git push origin v1.1.4
```

## Workflows

### Standard Release Workflow

1. **Make your changes** to the codebase

2. **Document changes** in CHANGELOG.md under `[Unreleased]` section:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - New sortable columns feature
   
   ### Changed
   - Updated refresh rate to 12 hours
   
   ### Fixed
   - Fixed CORS configuration
   ```

3. **Run bump-version.sh:**
   ```bash
   ./bump-version.sh patch  # or minor/major
   ```

4. **Review CHANGELOG.md** - The [Unreleased] section is now [1.1.4] with today's date

5. **Verify consistency:**
   ```bash
   ./check-docs.sh
   ```

6. **Commit and tag:**
   ```bash
   git add .
   git commit -m "Bump version to 1.1.4"
   git tag -a v1.1.4 -m "Release v1.1.4"
   git push origin master
   git push origin v1.1.4
   ```

7. **Rebuild Docker containers:**
   ```bash
   docker compose build
   docker compose up -d
   ```

### Hotfix Workflow

For urgent fixes that need immediate release:

1. **Make the fix** in your code

2. **Bump version** (patch level):
   ```bash
   ./bump-version.sh patch
   ```

3. **Edit CHANGELOG.md** to document the fix:
   ```markdown
   ## [1.1.4] - 2025-11-06
   
   ### Fixed
   - Critical security vulnerability in authentication
   ```

4. **Deploy immediately:**
   ```bash
   git add .
   git commit -m "Hotfix: Security vulnerability (v1.1.4)"
   git tag -a v1.1.4 -m "Hotfix v1.1.4"
   git push origin master --tags
   docker compose build
   docker compose up -d
   ```

### Feature Release Workflow

For new features (minor version bump):

1. **Develop feature** on feature branch

2. **Merge to master:**
   ```bash
   git checkout master
   git merge feature/sortable-columns
   ```

3. **Update CHANGELOG** under [Unreleased]:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - Sortable table columns with visual indicators
   - Click column headers to sort data
   ```

4. **Bump minor version:**
   ```bash
   ./bump-version.sh minor
   ```

5. **Commit and deploy:**
   ```bash
   git add .
   git commit -m "Release v1.2.0: Add sortable columns"
   git tag -a v1.2.0 -m "Release v1.2.0"
   git push origin master --tags
   docker compose build
   docker compose up -d
   ```

## Best Practices

### ✅ Do's

- **Always use bump-version.sh** for version updates
- **Run check-docs.sh** before committing documentation changes
- **Update CHANGELOG.md** before bumping version
- **Use semantic versioning** correctly:
  - Patch: Bug fixes only
  - Minor: New features, backward compatible
  - Major: Breaking changes
- **Tag releases** in git
- **Rebuild containers** after version bump

### ❌ Don'ts

- **Don't manually edit version numbers** in multiple files
- **Don't skip CHANGELOG updates**
- **Don't forget to rebuild containers**
- **Don't mix version types** (e.g., features in patch release)
- **Don't commit without verifying** with check-docs.sh

## Troubleshooting

### Version Inconsistency Detected

**Problem:** `check-docs.sh` reports version mismatches

**Solution:**
```bash
# Option 1: Use bump-version.sh to fix
./bump-version.sh patch  # This will sync all files

# Option 2: Manual fix (not recommended)
# Edit each file manually, then verify:
./check-docs.sh
```

### CHANGELOG [Unreleased] Not Found

**Problem:** bump-version.sh creates empty version section

**Solution:**
1. Before running bump-version.sh, add [Unreleased] section to CHANGELOG.md:
   ```markdown
   ## [Unreleased]
   
   ### Added
   - Your changes here
   ```

2. Run bump-version.sh - it will convert [Unreleased] to the new version

### References to Deleted Scripts

**Problem:** check-docs.sh warns about deleted script references

**Solution:**
Remove references to deleted scripts from documentation:
- `setup_wireguard.sh`
- `generate_wg_password_hash.sh`
- `get-version.sh`

## CI/CD Integration

### Pre-commit Hook

Add to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
cd music-inventory-app
./check-docs.sh
if [ $? -ne 0 ]; then
    echo "Documentation consistency check failed!"
    echo "Run ./bump-version.sh to fix"
    exit 1
fi
```

### GitHub Actions Example

```yaml
name: Documentation Check

on: [push, pull_request]

jobs:
  check-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Check Documentation Consistency
        run: |
          cd music-inventory-app
          chmod +x check-docs.sh
          ./check-docs.sh
```

## Version History

All version changes are tracked in `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/) format.

### CHANGELOG Format

```markdown
# Changelog

## [Unreleased]

### Added
- New features not yet released

## [1.1.4] - 2025-11-06

### Added
- New features in this release

### Changed
- Changes to existing functionality

### Deprecated
- Features marked for removal

### Removed
- Removed features

### Fixed
- Bug fixes

### Security
- Security improvements
```

## Support

For questions or issues with version management:
- Check this guide
- Run `./check-docs.sh` for diagnostics
- Review `CHANGELOG.md` for version history
- Contact: Todd.Butcher71@gmail.com
