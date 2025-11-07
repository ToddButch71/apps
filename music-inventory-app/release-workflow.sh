#!/bin/bash

# Music Catalog - Release Workflow Script
# Demonstrates complete version bump and release process
# Usage: ./release-workflow.sh [major|minor|patch]

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║          Music Catalog - Release Workflow Demo        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}This script demonstrates the complete release workflow.${NC}"
echo -e "${YELLOW}It will show you each step but NOT execute them.${NC}"
echo ""

if [ $# -eq 0 ]; then
    echo -e "${RED}Usage:${NC} $0 [major|minor|patch]"
    exit 1
fi

BUMP_TYPE=$1
CURRENT_VERSION=$(cat VERSION 2>/dev/null || echo "1.1.3")

# Calculate new version (simplified for demo)
IFS='.' read -r -a parts <<< "$CURRENT_VERSION"
case $BUMP_TYPE in
    patch)
        NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 1))"
        ;;
    minor)
        NEW_VERSION="${parts[0]}.$((parts[1] + 1)).0"
        ;;
    major)
        NEW_VERSION="$((parts[0] + 1)).0.0"
        ;;
    *)
        echo -e "${RED}Invalid bump type${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 1: Pre-Release Checks${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Run documentation consistency check:"
echo -e "  ${CYAN}./check-docs.sh${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 2: Update CHANGELOG.md${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Add [Unreleased] section to CHANGELOG.md:"
echo ""
echo -e "${YELLOW}## [Unreleased]${NC}"
echo -e "${YELLOW}${NC}"
echo -e "${YELLOW}### Added${NC}"
echo -e "${YELLOW}- New feature 1${NC}"
echo -e "${YELLOW}- New feature 2${NC}"
echo -e "${YELLOW}${NC}"
echo -e "${YELLOW}### Changed${NC}"
echo -e "${YELLOW}- Updated component X${NC}"
echo -e "${YELLOW}${NC}"
echo -e "${YELLOW}### Fixed${NC}"
echo -e "${YELLOW}- Bug fix for issue #123${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 3: Bump Version${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Run version bump script:"
echo -e "  ${CYAN}./bump-version.sh $BUMP_TYPE${NC}"
echo ""
echo -e "This will:"
echo -e "  ${GREEN}✓${NC} Update VERSION: $CURRENT_VERSION → $NEW_VERSION"
echo -e "  ${GREEN}✓${NC} Update README.md (app)"
echo -e "  ${GREEN}✓${NC} Update ../README.md (root)"
echo -e "  ${GREEN}✓${NC} Update frontend/package.json"
echo -e "  ${GREEN}✓${NC} Update CHANGELOG.md ([Unreleased] → [$NEW_VERSION])"
echo -e "  ${GREEN}✓${NC} Verify all changes"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 4: Review Changes${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Review the updated files:"
echo -e "  ${CYAN}git diff${NC}"
echo ""
echo -e "${GREEN}→${NC} Verify CHANGELOG.md has proper date and descriptions"
echo ""
echo -e "${GREEN}→${NC} Run consistency check again:"
echo -e "  ${CYAN}./check-docs.sh${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 5: Commit Changes${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Stage all changes:"
echo -e "  ${CYAN}git add .${NC}"
echo ""
echo -e "${GREEN}→${NC} Commit with version message:"
echo -e "  ${CYAN}git commit -m \"Bump version to $NEW_VERSION\"${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 6: Tag Release${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Create annotated tag:"
echo -e "  ${CYAN}git tag -a v$NEW_VERSION -m \"Release v$NEW_VERSION\"${NC}"
echo ""
echo -e "${GREEN}→${NC} Push to remote:"
echo -e "  ${CYAN}git push origin master${NC}"
echo -e "  ${CYAN}git push origin v$NEW_VERSION${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 7: Rebuild Docker Containers${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Rebuild all containers:"
echo -e "  ${CYAN}docker compose build${NC}"
echo ""
echo -e "${GREEN}→${NC} Restart services:"
echo -e "  ${CYAN}docker compose up -d${NC}"
echo ""
echo -e "${GREEN}→${NC} Verify services are running:"
echo -e "  ${CYAN}docker compose ps${NC}"
echo ""
read -p "Press Enter to continue..."
echo ""

echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  STEP 8: Post-Release Verification${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}→${NC} Check version via API:"
echo -e "  ${CYAN}curl http://localhost:8000/${NC}"
echo ""
echo -e "${GREEN}→${NC} Test admin interface:"
echo -e "  ${CYAN}http://localhost:5173${NC}"
echo ""
echo -e "${GREEN}→${NC} Test public interface:"
echo -e "  ${CYAN}http://localhost:9000${NC}"
echo ""
echo -e "${GREEN}→${NC} Review logs:"
echo -e "  ${CYAN}docker compose logs -f${NC}"
echo ""
read -p "Press Enter to finish..."
echo ""

echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  Release Complete!                     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Summary:${NC}"
echo -e "  Version: ${YELLOW}$CURRENT_VERSION${NC} → ${GREEN}$NEW_VERSION${NC}"
echo -e "  Type: ${YELLOW}$BUMP_TYPE${NC}"
echo ""
echo -e "${CYAN}Quick Reference:${NC}"
echo -e "  Check docs:    ${CYAN}./check-docs.sh${NC}"
echo -e "  Bump version:  ${CYAN}./bump-version.sh [major|minor|patch]${NC}"
echo -e "  View logs:     ${CYAN}docker compose logs -f${NC}"
echo -e "  Restart:       ${CYAN}docker compose restart${NC}"
echo ""
echo -e "${YELLOW}For detailed workflows, see: VERSION_MANAGEMENT.md${NC}"
echo ""
