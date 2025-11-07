#!/bin/bash

# Music Catalog - Version Bump Script
# Automatically updates version across all documentation files
# Usage: ./bump-version.sh [major|minor|patch]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# File paths
VERSION_FILE="VERSION"
CHANGELOG_FILE="CHANGELOG.md"
APP_README="README.md"
ROOT_README="../README.md"
PACKAGE_JSON="frontend/package.json"

# Function to display usage
usage() {
    echo -e "${BLUE}Usage:${NC} $0 [major|minor|patch]"
    echo ""
    echo "  major - Increment major version (1.0.0 -> 2.0.0)"
    echo "  minor - Increment minor version (1.0.0 -> 1.1.0)"
    echo "  patch - Increment patch version (1.0.0 -> 1.0.1)"
    echo ""
    echo "Example: $0 patch"
    exit 1
}

# Function to get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Function to calculate new version
calculate_new_version() {
    local current=$1
    local bump_type=$2
    
    IFS='.' read -r -a version_parts <<< "$current"
    local major="${version_parts[0]}"
    local minor="${version_parts[1]}"
    local patch="${version_parts[2]}"
    
    case $bump_type in
        major)
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        minor)
            minor=$((minor + 1))
            patch=0
            ;;
        patch)
            patch=$((patch + 1))
            ;;
        *)
            echo "Invalid bump type: $bump_type"
            usage
            ;;
    esac
    
    echo "$major.$minor.$patch"
}

# Function to update VERSION file
update_version_file() {
    local new_version=$1
    echo "$new_version" > "$VERSION_FILE"
    echo -e "${GREEN}✓${NC} Updated $VERSION_FILE to $new_version"
}

# Function to update app README
update_app_readme() {
    local new_version=$1
    
    # Update version in header
    sed -i '' "s/^\*\*Version [0-9]\+\.[0-9]\+\.[0-9]\+\*\*/**Version $new_version**/" "$APP_README"
    
    # Update version in Recent Updates (mark as Latest)
    sed -i '' "s/### Version [0-9]\+\.[0-9]\+\.[0-9]\+ (Latest)/### Version $new_version (Latest)/" "$APP_README"
    
    # Remove (Latest) from previous version if it exists - capture the version number
    sed -i '' "s/### Version \([0-9]\+\.[0-9]\+\.[0-9]\+\) (Latest)/### Version \1/" "$APP_README"
    
    # Update Current Version in Versioning section
    sed -i '' "s/\*\*Current Version:\*\* [0-9]\+\.[0-9]\+\.[0-9]\+/**Current Version:** $new_version/" "$APP_README"
    
    echo -e "${GREEN}✓${NC} Updated $APP_README"
}

# Function to update root README
update_root_readme() {
    local new_version=$1
    
    # Update version for Music Catalog
    sed -i '' "/### Music Catalog/,/\*\*Version:\*\*/s/\*\*Version:\*\* [0-9]\+\.[0-9]\+\.[0-9]\+/**Version:** $new_version/" "$ROOT_README"
    
    echo -e "${GREEN}✓${NC} Updated $ROOT_README"
}

# Function to update package.json
update_package_json() {
    local new_version=$1
    
    if [ -f "$PACKAGE_JSON" ]; then
        sed -i '' "s/\"version\": \"[0-9]\+\.[0-9]\+\.[0-9]\+\"/\"version\": \"$new_version\"/" "$PACKAGE_JSON"
        echo -e "${GREEN}✓${NC} Updated $PACKAGE_JSON"
    fi
}

# Function to update CHANGELOG
update_changelog() {
    local new_version=$1
    local current_date=$(date +%Y-%m-%d)
    
    # Check if there's an [Unreleased] section
    if grep -q "\[Unreleased\]" "$CHANGELOG_FILE"; then
        # Replace [Unreleased] with new version
        sed -i '' "s/## \[Unreleased\]/## [$new_version] - $current_date/" "$CHANGELOG_FILE"
        echo -e "${GREEN}✓${NC} Updated CHANGELOG.md (converted [Unreleased] to [$new_version])"
    else
        # Insert new version section after header
        local temp_file=$(mktemp)
        local header_end=$(grep -n "^## \[" "$CHANGELOG_FILE" | head -1 | cut -d: -f1)
        
        if [ -z "$header_end" ]; then
            # No versions yet, add after introduction
            header_end=$(grep -n "^#" "$CHANGELOG_FILE" | tail -1 | cut -d: -f1)
        fi
        
        # Create new version entry
        {
            head -n "$header_end" "$CHANGELOG_FILE"
            echo ""
            echo "## [$new_version] - $current_date"
            echo ""
            echo "### Added"
            echo "- "
            echo ""
            echo "### Changed"
            echo "- "
            echo ""
            echo "### Fixed"
            echo "- "
            echo ""
            tail -n +$((header_end + 1)) "$CHANGELOG_FILE"
        } > "$temp_file"
        
        mv "$temp_file" "$CHANGELOG_FILE"
        echo -e "${YELLOW}⚠${NC}  Added new version section to CHANGELOG.md"
        echo -e "${YELLOW}⚠${NC}  Please edit CHANGELOG.md to document your changes"
    fi
}

# Function to verify all updates
verify_updates() {
    local new_version=$1
    local all_good=true
    
    echo ""
    echo -e "${BLUE}Verifying updates...${NC}"
    
    # Check VERSION file
    if grep -q "$new_version" "$VERSION_FILE"; then
        echo -e "${GREEN}✓${NC} VERSION file: $new_version"
    else
        echo -e "${RED}✗${NC} VERSION file: FAILED"
        all_good=false
    fi
    
    # Check app README
    if grep -q "Version $new_version" "$APP_README"; then
        echo -e "${GREEN}✓${NC} App README: $new_version"
    else
        echo -e "${RED}✗${NC} App README: FAILED"
        all_good=false
    fi
    
    # Check root README
    if grep -q "Version.*$new_version" "$ROOT_README"; then
        echo -e "${GREEN}✓${NC} Root README: $new_version"
    else
        echo -e "${RED}✗${NC} Root README: FAILED"
        all_good=false
    fi
    
    # Check package.json
    if [ -f "$PACKAGE_JSON" ] && grep -q "\"version\": \"$new_version\"" "$PACKAGE_JSON"; then
        echo -e "${GREEN}✓${NC} package.json: $new_version"
    elif [ -f "$PACKAGE_JSON" ]; then
        echo -e "${RED}✗${NC} package.json: FAILED"
        all_good=false
    fi
    
    # Check CHANGELOG
    if grep -q "\[$new_version\]" "$CHANGELOG_FILE"; then
        echo -e "${GREEN}✓${NC} CHANGELOG.md: $new_version"
    else
        echo -e "${RED}✗${NC} CHANGELOG.md: FAILED"
        all_good=false
    fi
    
    if [ "$all_good" = true ]; then
        echo ""
        echo -e "${GREEN}All files updated successfully!${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}Some files failed to update. Please check manually.${NC}"
        return 1
    fi
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║     Music Catalog - Version Bump Script   ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Check if bump type provided
    if [ $# -eq 0 ]; then
        usage
    fi
    
    local bump_type=$1
    
    # Validate bump type
    if [[ ! "$bump_type" =~ ^(major|minor|patch)$ ]]; then
        echo -e "${RED}Error:${NC} Invalid bump type '$bump_type'"
        usage
    fi
    
    # Get current version
    local current_version=$(get_current_version)
    echo -e "Current version: ${YELLOW}$current_version${NC}"
    
    # Calculate new version
    local new_version=$(calculate_new_version "$current_version" "$bump_type")
    echo -e "New version:     ${GREEN}$new_version${NC}"
    echo ""
    
    # Confirm
    read -p "Proceed with version bump? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Version bump cancelled${NC}"
        exit 0
    fi
    
    echo ""
    echo -e "${BLUE}Updating files...${NC}"
    
    # Update all files
    update_version_file "$new_version"
    update_app_readme "$new_version"
    update_root_readme "$new_version"
    update_package_json "$new_version"
    update_changelog "$new_version"
    
    # Verify updates
    if verify_updates "$new_version"; then
        echo ""
        echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║            Next Steps                      ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        echo ""
        echo "1. Review and edit CHANGELOG.md to document changes"
        echo "2. Commit changes:"
        echo -e "   ${YELLOW}git add .${NC}"
        echo -e "   ${YELLOW}git commit -m \"Bump version to $new_version\"${NC}"
        echo ""
        echo "3. Rebuild Docker containers:"
        echo -e "   ${YELLOW}docker compose build${NC}"
        echo -e "   ${YELLOW}docker compose up -d${NC}"
        echo ""
        echo "4. Tag the release:"
        echo -e "   ${YELLOW}git tag -a v$new_version -m \"Release v$new_version\"${NC}"
        echo -e "   ${YELLOW}git push origin v$new_version${NC}"
        echo ""
    else
        exit 1
    fi
}

# Run main function
main "$@"
