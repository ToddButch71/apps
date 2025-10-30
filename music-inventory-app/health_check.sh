#!/bin/bash
# Health check script for Music Inventory App

set -e

echo "======================================"
echo "Music Inventory App Health Check"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if services are running
echo "1. Checking Docker containers status..."
if ! docker compose ps | grep -q "Up"; then
    echo -e "${RED}ERROR: Containers are not running${NC}"
    echo "Run: docker compose up --build -d"
    exit 1
fi
echo -e "${GREEN}✓ Containers are running${NC}"
echo ""

# Backend health check
echo "2. Checking backend health endpoint..."
if curl -sf http://localhost:8000/health > /dev/null 2>&1; then
    HEALTH=$(curl -s http://localhost:8000/health)
    echo -e "${GREEN}✓ Backend /health: ${HEALTH}${NC}"
else
    echo -e "${RED}✗ Backend /health not responding${NC}"
    echo "Check backend logs: docker compose logs backend"
fi
echo ""

# Backend root check
echo "3. Checking backend root endpoint..."
if curl -sf http://localhost:8000/ > /dev/null 2>&1; then
    ROOT=$(curl -s http://localhost:8000/)
    echo -e "${GREEN}✓ Backend /: ${ROOT}${NC}"
else
    echo -e "${RED}✗ Backend root not responding${NC}"
fi
echo ""

# Frontend direct check
echo "4. Checking frontend (direct on port 5173)..."
if curl -sf http://localhost:5173 > /dev/null 2>&1; then
    TITLE=$(curl -s http://localhost:5173 | grep -o '<title>[^<]*</title>' || echo "No title found")
    echo -e "${GREEN}✓ Frontend responding on port 5173${NC}"
    echo "   Page title: ${TITLE}"
else
    echo -e "${RED}✗ Frontend not responding on port 5173${NC}"
    echo "Check frontend logs: docker compose logs frontend"
    echo "Verify port mapping in compose.yaml: should be 5173:80"
fi
echo ""

# Nginx proxy check
echo "5. Checking nginx-proxy (on port 8080)..."
if curl -sf http://localhost:8080 > /dev/null 2>&1; then
    TITLE=$(curl -s http://localhost:8080 | grep -o '<title>[^<]*</title>' || echo "No title found")
    echo -e "${GREEN}✓ Nginx proxy responding on port 8080${NC}"
    echo "   Page title: ${TITLE}"
else
    echo -e "${RED}✗ Nginx proxy not responding on port 8080${NC}"
    echo "Check nginx-proxy logs: docker compose logs nginx-proxy"
    echo "Verify VIRTUAL_HOST and VIRTUAL_PORT env vars in compose.yaml"
fi
echo ""

echo "======================================"
echo "Summary"
echo "======================================"
echo "Backend API:     http://localhost:8000"
echo "Frontend Direct: http://localhost:5173"
echo "Frontend Proxy:  http://localhost:8080"
echo ""
