# Version Management Scripts

This directory contains automated tooling for version management and documentation consistency.

## Scripts

### bump-version.sh
**Purpose:** Automated version bumping with documentation synchronization

**Usage:**
```bash
./bump-version.sh [major|minor|patch]
```

**What it does:**
- Increments version number (semantic versioning)
- Updates VERSION file
- Updates all README files
- Updates frontend/package.json
- Updates CHANGELOG.md
- Verifies all changes
- Provides next steps for git commit and Docker rebuild

**Example:**
```bash
./bump-version.sh patch  # 1.1.3 → 1.1.4
```

---

### check-docs.sh
**Purpose:** Validate documentation consistency across all files

**Usage:**
```bash
./check-docs.sh
```

**What it validates:**
- Version number consistency across all files
- CHANGELOG format and structure
- References to deleted/missing scripts
- Multiple version references in documentation

**Exit codes:**
- `0` - All checks passed
- `1` - Inconsistencies found

**Example:**
```bash
./check-docs.sh
# Use in CI/CD: returns non-zero on failure
```

---

## Workflows

### Before Committing
```bash
# Check documentation consistency
./check-docs.sh
```

### Creating a Release
```bash
# 1. Update CHANGELOG.md with [Unreleased] section
# 2. Bump version
./bump-version.sh patch

# 3. Verify
./check-docs.sh

# 4. Commit and tag
git add .
git commit -m "Bump version to 1.1.4"
git tag -a v1.1.4 -m "Release v1.1.4"
git push origin master --tags

# 5. Rebuild containers
docker compose build
docker compose up -d
```

## Documentation

For comprehensive version management guide, see [VERSION_MANAGEMENT.md](../VERSION_MANAGEMENT.md)

## Requirements

- bash
- sed (macOS/Linux)
- grep
- Git (for version tagging)

## Author

Todd Butcher (Todd.Butcher71@gmail.com)
