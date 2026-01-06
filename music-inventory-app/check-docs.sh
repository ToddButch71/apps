#!/bin/bash

# Music Catalog - Documentation Consistency Checker
# Validates that version numbers are consistent across all documentation
# Usage: ./check-docs.sh

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

# Function to extract version from VERSION file
get_version_file() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "MISSING"
    fi
}

# Function to extract version from app README
get_app_readme_version() {
    grep -m 1 "^\*\*Version" "$APP_README" | sed 's/\*\*Version \([0-9.]*\)\*\*/\1/'
}

# Function to extract version from root README
get_root_readme_version() {
    grep "^\*\*Version:\*\*" "$ROOT_README" | sed 's/.*Version:\*\* \([0-9.]*\).*/\1/' | head -1
}

# Function to extract version from package.json
get_package_json_version() {
    if [ -f "$PACKAGE_JSON" ]; then
        grep '"version"' "$PACKAGE_JSON" | head -1 | sed 's/.*"version": "\([0-9.]*\)".*/\1/'
    else
        echo "MISSING"
    fi
}

# Function to extract latest version from CHANGELOG
get_changelog_version() {
    grep -m 1 "^## \[[0-9]" "$CHANGELOG_FILE" | sed 's/## \[\([0-9.]*\)\].*/\1/'
}

# Function to check for deleted scripts referenced in docs
check_deleted_scripts() {
    local files_to_check=("$APP_README" "$ROOT_README")
    local deleted_scripts=("get-version.sh")
    local found_references=false
    
    for file in "${files_to_check[@]}"; do
        if [ -f "$file" ]; then
            for script in "${deleted_scripts[@]}"; do
                if grep -q "$script" "$file" 2>/dev/null; then
                    if [ "$found_references" = false ]; then
                        echo -e "\n${YELLOW}Warning: References to deleted scripts found:${NC}"
                        found_references=true
                    fi
                    echo -e "${RED}✗${NC} $file references deleted script: $script"
                fi
            done
        fi
    done
    
    return 0
}

# Function to check for outdated version references
check_outdated_versions() {
    local current_version=$1
    local found_outdated=false
    
    # Check for old version patterns in README files
    local old_versions=$(grep -ho "Version [0-9]\+\.[0-9]\+\.[0-9]\+" "$APP_README" "$ROOT_README" 2>/dev/null | sort -u)
    
    while IFS= read -r version_string; do
        local version=$(echo "$version_string" | sed 's/Version //')
        if [ "$version" != "$current_version" ]; then
            if [ "$found_outdated" = false ]; then
                echo -e "\n${YELLOW}Warning: Multiple version references found:${NC}"
                found_outdated=true
            fi
            echo -e "${YELLOW}⚠${NC}  Found reference to: $version"
        fi
    done <<< "$old_versions"
    
    return 0
}

# Main execution
main() {
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║   Documentation Consistency Checker        ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Get versions from all files
    local version_file=$(get_version_file)
    local app_readme=$(get_app_readme_version)
    local root_readme=$(get_root_readme_version)
    local package_json=$(get_package_json_version)
    local changelog=$(get_changelog_version)
    
    # Display versions
    echo -e "${BLUE}Version Information:${NC}"
    echo "─────────────────────────────────────────"
    echo -e "VERSION file:     ${YELLOW}$version_file${NC}"
    echo -e "App README:       ${YELLOW}$app_readme${NC}"
    echo -e "Root README:      ${YELLOW}$root_readme${NC}"
    echo -e "package.json:     ${YELLOW}$package_json${NC}"
    echo -e "CHANGELOG.md:     ${YELLOW}$changelog${NC}"
    echo ""
    
    # Check consistency
    local all_consistent=true
    
    if [ "$version_file" = "$app_readme" ] && \
       [ "$version_file" = "$root_readme" ] && \
       [ "$version_file" = "$package_json" ] && \
       [ "$version_file" = "$changelog" ]; then
        echo -e "${GREEN}✓ All version numbers are consistent!${NC}"
    else
        echo -e "${RED}✗ Version inconsistency detected!${NC}"
        all_consistent=false
        
        # Show which files don't match
        echo ""
        echo -e "${YELLOW}Mismatches:${NC}"
        [ "$version_file" != "$app_readme" ] && echo -e "  ${RED}✗${NC} VERSION ($version_file) ≠ App README ($app_readme)"
        [ "$version_file" != "$root_readme" ] && echo -e "  ${RED}✗${NC} VERSION ($version_file) ≠ Root README ($root_readme)"
        [ "$version_file" != "$package_json" ] && echo -e "  ${RED}✗${NC} VERSION ($version_file) ≠ package.json ($package_json)"
        [ "$version_file" != "$changelog" ] && echo -e "  ${RED}✗${NC} VERSION ($version_file) ≠ CHANGELOG ($changelog)"
    fi
    
    # Check for deleted script references
    check_deleted_scripts
    
    # Check for outdated version references
    check_outdated_versions "$version_file"
    
    # Check CHANGELOG format
    echo ""
    echo -e "${BLUE}CHANGELOG Validation:${NC}"
    echo "─────────────────────────────────────────"
    
    if grep -q "## \[Unreleased\]" "$CHANGELOG_FILE"; then
        echo -e "${YELLOW}⚠${NC}  [Unreleased] section found - run bump-version.sh to release"
    else
        echo -e "${GREEN}✓${NC} No unreleased changes"
    fi
    
    if [ "$(grep -c "^## \[[0-9]" "$CHANGELOG_FILE")" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} CHANGELOG contains version entries"
    else
        echo -e "${RED}✗${NC} No version entries in CHANGELOG"
        all_consistent=false
    fi
    
    # Summary
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
    
    if [ "$all_consistent" = true ]; then
        echo -e "${BLUE}║  ${GREEN}✓ Documentation is consistent${BLUE}            ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        exit 0
    else
        echo -e "${BLUE}║  ${RED}✗ Inconsistencies found${BLUE}                  ║${NC}"
        echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "${YELLOW}Recommendation:${NC} Run ./bump-version.sh to synchronize versions"
        exit 1
    fi
}

# Run main function
main
