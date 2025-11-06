#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

echo "🔍 Running Music Catalog Health Checks..."

# Function to check endpoint
check_endpoint() {
    local url=$1
    local name=$2
    echo -n "Checking $name... "
    
    response=$(curl -s -w "\n%{http_code}" "$url")
    status_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed \$d)
    
    if [ "$status_code" -eq 200 ]; then
        echo -e "${GREEN}✓${NC}"
        echo "Response: $body"
    else
        echo -e "${RED}✗${NC}"
        echo "Error: Received status code $status_code"
        return 1
    fi
}

# Check if Docker is running
echo -n "Checking Docker status... "
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}✗${NC}"
    echo "Error: Docker is not running or not accessible"
    exit 1
else
    echo -e "${GREEN}✓${NC}"
fi

# Check if containers are running
echo -n "Checking containers status... "
if ! docker compose ps --format json | grep -q "running"; then
    echo -e "${YELLOW}Warning: Containers may not be running${NC}"
    echo "Starting containers..."
    docker compose up -d
    sleep 5  # Wait for containers to start
fi
echo -e "${GREEN}✓${NC}"

echo "Testing API endpoints..."
# Backend health checks
check_endpoint "http://localhost:8000/health" "Backend health endpoint"
check_endpoint "http://localhost:8000/" "Backend root endpoint"

# Frontend checks
echo -n "Checking frontend (Vite dev server)... "
if curl -s -I "http://localhost:5173" | grep -q "200\|304"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Error: Frontend not responding on port 5173"
fi

# Nginx proxy check
echo -n "Checking nginx proxy... "
if curl -s -I "http://localhost:8080" | grep -q "200\|304"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Error: Nginx proxy not responding on port 8080"
fi

echo "🔍 Health check complete!"