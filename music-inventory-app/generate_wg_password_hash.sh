#!/bin/bash

echo "======================================"
echo "WireGuard Password Hash Generator"
echo "======================================"
echo ""

# Read current password from .secrets.env
CURRENT_PASSWORD=$(grep "PASSWORD=" backend/.secrets.env | cut -d'=' -f2)

if [ -z "$CURRENT_PASSWORD" ]; then
    echo "Error: Could not find password in backend/.secrets.env"
    exit 1
fi

echo "Current password: $CURRENT_PASSWORD"
echo ""
echo "Generating bcrypt hash..."
echo ""

# Generate hash using the wg-easy docker image
PASSWORD_HASH=$(docker run --rm ghcr.io/wg-easy/wg-easy wgpw "$CURRENT_PASSWORD")

if [ -z "$PASSWORD_HASH" ]; then
    echo "Error: Failed to generate password hash"
    exit 1
fi

echo "Generated hash: $PASSWORD_HASH"
echo ""

# Update .secrets.env file
echo "Updating backend/.secrets.env..."
cat > backend/.secrets.env << EOF
# WireGuard Web UI Admin Password Hash
# Original password: $CURRENT_PASSWORD
PASSWORD_HASH=$PASSWORD_HASH
EOF

echo ""
echo "✅ Password hash updated in backend/.secrets.env"
echo ""
echo "Next step: Restart WireGuard container"
echo "  docker compose restart wireguard"
echo ""
