#!/bin/bash

echo "=== Docker Container Status ==="
docker compose ps

echo -e "\n=== Backend Container Logs (last 30 lines) ==="
docker compose logs --tail=30 backend

echo -e "\n=== Nginx Proxy Logs (last 30 lines) ==="
docker compose logs --tail=30 nginx-proxy

echo -e "\n=== Frontend Container Logs (last 30 lines) ==="
docker compose logs --tail=30 frontend

echo -e "\n=== Check if Backend is Listening ==="
docker compose exec backend netstat -tlnp 2>/dev/null || docker compose exec backend ss -tlnp 2>/dev/null || echo "netstat/ss not available"

echo -e "\n=== Test Backend from Nginx Container ==="
docker compose exec nginx-proxy wget -O- --timeout=5 http://backend:8000/health 2>&1 || echo "Failed to reach backend from nginx"

echo -e "\n=== Test Backend from Frontend Container ==="
docker compose exec frontend wget -O- --timeout=5 http://backend:8000/health 2>&1 || echo "Failed to reach backend from frontend"

echo -e "\n=== Docker Network Inspection ==="
docker network ls | grep music

echo -e "\n=== Check VIRTUAL_HOST configuration ==="
docker compose exec nginx-proxy cat /etc/nginx/conf.d/default.conf 2>/dev/null || echo "Nginx config not accessible"
