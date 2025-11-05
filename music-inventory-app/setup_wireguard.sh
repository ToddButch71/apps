#!/bin/bash

echo "======================================"
echo "WireGuard VPN Setup for Music Inventory"
echo "======================================"
echo ""

# Get public IP
echo "🔍 Detecting your public IP address..."
PUBLIC_IP=$(curl -s ifconfig.me)
echo "   Your public IP: $PUBLIC_IP"
echo ""

# Get Mac's local IP
echo "🔍 Detecting your Mac's local IP address..."
LOCAL_IP=$(ifconfig | grep "inet " | grep -v 127.0.0.1 | head -n 1 | awk '{print $2}')
echo "   Your local IP: $LOCAL_IP"
echo ""

# Prompt for admin password
echo "🔐 Set a password for WireGuard web UI:"
read -s ADMIN_PASSWORD
echo ""

# Update compose.yaml with actual values
echo "📝 Updating compose.yaml..."
sed -i '' "s/YOUR_PUBLIC_IP_OR_DOMAIN/$PUBLIC_IP/" compose.yaml
sed -i '' "s/your_admin_password/$ADMIN_PASSWORD/" compose.yaml

echo ""
echo "✅ Configuration updated!"
echo ""
echo "======================================"
echo "Next Steps:"
echo "======================================"
echo ""
echo "1. Port Forward on Your Router:"
echo "   - Log into your router (usually 192.168.1.1 or 192.168.0.1)"
echo "   - Forward UDP port 51820 to $LOCAL_IP"
echo "   - Forward TCP port 51821 to $LOCAL_IP (optional, for web UI access)"
echo ""
echo "2. Start WireGuard:"
echo "   docker compose up -d wireguard"
echo ""
echo "3. Access WireGuard Web UI:"
echo "   Local: http://localhost:51821"
echo "   Remote (after port forward): http://$PUBLIC_IP:51821"
echo "   Password: (the one you just set)"
echo ""
echo "4. Add Clients:"
echo "   - Open web UI"
echo "   - Click 'New Client'"
echo "   - Scan QR code with WireGuard app on your phone"
echo ""
echo "5. Connect & Access Your App:"
echo "   - Connect to WireGuard VPN on your device"
echo "   - Visit: http://$LOCAL_IP:8080"
echo ""
echo "======================================"
echo "Security Tips:"
echo "======================================"
echo "- Use a strong admin password"
echo "- Only expose port 51820 (VPN) to internet"
echo "- Keep port 51821 (web UI) local-only if possible"
echo "- Monitor backend/logs/external_access.log"
echo ""
