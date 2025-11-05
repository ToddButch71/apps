#!/bin/bash
# Script to bump version numbers
# Usage: ./bump-version.sh [major|minor|patch]

VERSION_FILE="$(dirname "$0")/VERSION"
PACKAGE_JSON="$(dirname "$0")/frontend/package.json"
README="$(dirname "$0")/README.md"
CHANGELOG="$(dirname "$0")/CHANGELOG.md"

if [ ! -f "$VERSION_FILE" ]; then
    echo "Error: VERSION file not found!"
    exit 1
fi

# Read current version
CURRENT_VERSION=$(cat "$VERSION_FILE")
echo "Current version: $CURRENT_VERSION"

# Parse version parts
IFS='.' read -r -a parts <<< "$CURRENT_VERSION"
MAJOR="${parts[0]:-0}"
MINOR="${parts[1]:-0}"
PATCH="${parts[2]:-0}"

# Determine bump type
BUMP_TYPE="${1:-patch}"

case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
    *)
        echo "Usage: $0 [major|minor|patch]"
        echo "  major - Increment major version (e.g., 1.0.0 -> 2.0.0)"
        echo "  minor - Increment minor version (e.g., 1.0.0 -> 1.1.0)"
        echo "  patch - Increment patch version (e.g., 1.0.0 -> 1.0.1)"
        exit 1
        ;;
esac

# Build new version
NEW_VERSION="${MAJOR}.${MINOR}.${PATCH}"
TODAY=$(date +%Y-%m-%d)

echo "New version: $NEW_VERSION"
echo ""

# Prepare CHANGELOG template based on bump type
if [ "$BUMP_TYPE" = "patch" ]; then
    CHANGELOG_TEMPLATE="## [$NEW_VERSION] - $TODAY

### Fixed
- Bug fix description here

"
elif [ "$BUMP_TYPE" = "minor" ]; then
    CHANGELOG_TEMPLATE="## [$NEW_VERSION] - $TODAY

### Added
- New feature description here

### Changed
- Changes here (if any)

"
elif [ "$BUMP_TYPE" = "major" ]; then
    CHANGELOG_TEMPLATE="## [$NEW_VERSION] - $TODAY

### Changed
- BREAKING: Breaking change description here

### Removed
- Deprecated features removed (if any)

"
fi

# Automatically insert new version entry into CHANGELOG.md
if [ -f "$CHANGELOG" ]; then
    # Create a temp file
    TEMP_CHANGELOG=$(mktemp)
    
    # Insert new version after line 8 (after the header section)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS - use awk to insert after line 8
        awk -v template="$CHANGELOG_TEMPLATE" 'NR==8{print; print template; next}1' "$CHANGELOG" > "$TEMP_CHANGELOG"
    else
        # Linux
        awk -v template="$CHANGELOG_TEMPLATE" 'NR==8{print; print template; next}1' "$CHANGELOG" > "$TEMP_CHANGELOG"
    fi
    
    # Replace original with temp
    mv "$TEMP_CHANGELOG" "$CHANGELOG"
    
    echo "✓ Inserted version $NEW_VERSION template into CHANGELOG.md"
    echo ""
fi

# Prompt for changelog update
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CHANGELOG UPDATE - Edit Details"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "A template for version $NEW_VERSION has been added to CHANGELOG.md"
echo "Please edit it to add specific details about your changes."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Offer to open changelog in editor
read -p "Open CHANGELOG.md in editor to edit details now? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Try different editors
    if [ -n "$EDITOR" ]; then
        $EDITOR "$CHANGELOG"
    elif command -v code &> /dev/null; then
        code "$CHANGELOG"
    elif command -v nano &> /dev/null; then
        nano "$CHANGELOG"
    elif command -v vi &> /dev/null; then
        vi "$CHANGELOG"
    else
        echo "No editor found. Please manually edit: $CHANGELOG"
    fi
    echo ""
fi

read -p "Have you finalized the CHANGELOG.md details? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please update CHANGELOG.md before proceeding."
    echo "Run this script again when ready."
    exit 0
fi

echo ""
read -p "Update version to $NEW_VERSION? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Version update cancelled."
    exit 0
fi

# Update VERSION file
echo "$NEW_VERSION" > "$VERSION_FILE"
echo "✓ Updated VERSION file"

# Update package.json if it exists
if [ -f "$PACKAGE_JSON" ]; then
    # Use sed to update version in package.json
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$PACKAGE_JSON"
    else
        # Linux
        sed -i "s/\"version\": \".*\"/\"version\": \"$NEW_VERSION\"/" "$PACKAGE_JSON"
    fi
    echo "✓ Updated package.json"
fi

# Update README.md if it exists
if [ -f "$README" ]; then
    # Use sed to update version in README.md (both occurrences)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/\*\*Version [0-9]\+\.[0-9]\+\.[0-9]\+\*\*/\*\*Version $NEW_VERSION\*\*/" "$README"
        sed -i '' "s/\*\*Current Version:\*\* [0-9]\+\.[0-9]\+\.[0-9]\+/\*\*Current Version:\*\* $NEW_VERSION/" "$README"
    else
        # Linux
        sed -i "s/\*\*Version [0-9]\+\.[0-9]\+\.[0-9]\+\*\*/\*\*Version $NEW_VERSION\*\*/" "$README"
        sed -i "s/\*\*Current Version:\*\* [0-9]\+\.[0-9]\+\.[0-9]\+/\*\*Current Version:\*\* $NEW_VERSION/" "$README"
    fi
    echo "✓ Updated README.md"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  VERSION BUMPED: $CURRENT_VERSION → $NEW_VERSION"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Next steps:"
echo ""
echo "1. Review changes:"
echo "   git diff"
echo ""
echo "2. Commit all version files:"
echo "   git add VERSION frontend/package.json README.md CHANGELOG.md"
echo "   git commit -m 'Bump version to $NEW_VERSION'"
echo ""
echo "3. Create git tag:"
echo "   git tag -a v$NEW_VERSION -m 'Release v$NEW_VERSION'"
echo ""
echo "4. Rebuild containers:"
echo "   docker compose build && docker compose up -d"
echo ""
echo "5. Push to remote:"
echo "   git push && git push --tags"
echo ""
