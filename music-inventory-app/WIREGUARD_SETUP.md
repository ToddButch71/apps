# WireGuard VPN Setup Guide

## Quick Setup

1. **Run the setup script:**
   ```bash
   cd /Volumes/data/github/apps/music-inventory-app
   chmod +x setup_wireguard.sh
   ./setup_wireguard.sh
   ```

2. **Generate password hash (recommended):**
   ```bash
   chmod +x generate_wg_password_hash.sh
   ./generate_wg_password_hash.sh
   ```
   This will convert your password to a secure bcrypt hash.

3. **Or manually configure:**
   - Get your public IP: `curl ifconfig.me`
   - Edit `compose.yaml` and replace:
     - `YOUR_PUBLIC_IP_OR_DOMAIN` with your public IP
   - Generate password hash:
     ```bash
     docker run --rm ghcr.io/wg-easy/wg-easy wgpw YOUR_PASSWORD
     ```
   - Add hash to `backend/.secrets.env`:
     ```
     PASSWORD_HASH=your_generated_hash
     ```

4. **Start WireGuard:**
   ```bash
   docker compose up -d wireguard
   ```

5. **Access Web UI:**
   - Local: http://localhost:51821
   - Login with your original password (not the hash)

## Router Configuration

### Option 1: Using Your Router's Existing WireGuard VPN (Recommended)

If your router already has WireGuard VPN configured:

1. **Connect to your router's VPN** when away from home
2. **No additional port forwarding needed** - VPN gives you access to your local network
3. **Access the public site:**
   - Visit: `http://YOUR_MAC_LOCAL_IP:9000`
   - Example: `http://192.168.1.100:9000`
4. **Benefits:**
   - All traffic is encrypted through VPN
   - No need to expose port 9000 to internet
   - More secure than direct port forwarding

### Option 2: Direct Port Forwarding (Public Access Without VPN)

**For the public read-only site (index-public.html):**
- External Port: 9000
- Internal IP: [Your Mac's local IP]
- Internal Port: 9000
- Protocol: TCP

After forwarding, access from anywhere: `http://YOUR_PUBLIC_IP:9000`

**Note:** This makes the site publicly accessible to anyone with your IP address.

### Option 3: Run the Dockerized WireGuard (If you want separate VPN for this app)

**Port Forwarding Rules:**
- **WireGuard VPN (Required):**
  - External Port: 51820
  - Internal IP: [Your Mac's local IP]
  - Internal Port: 51820
  - Protocol: UDP

- **Web UI (Optional - for remote management):**
  - External Port: 51821
  - Internal IP: [Your Mac's local IP]
  - Internal Port: 51821
  - Protocol: TCP

## Adding VPN Clients

1. Open web UI: http://localhost:51821
2. Click **"+ New Client"**
3. Give it a name (e.g., "iPhone", "Laptop")
4. Click **Create**
5. **Scan the QR code** with WireGuard app or download config file

## Mobile Apps

- **iOS:** https://apps.apple.com/us/app/wireguard/id1441195209
- **Android:** https://play.google.com/store/apps/details?id=com.wireguard.android

## Accessing Your Music Inventory

### Using Router's Existing VPN (Recommended):

1. **Connect to your router's WireGuard VPN** from your phone/laptop
2. **Access sites as if you were home:**
   - Admin site: `http://YOUR_MAC_LOCAL_IP:8080`
   - Public catalog: `http://YOUR_MAC_LOCAL_IP:9000`
   - Example: `http://192.168.1.100:9000`

### Using Direct Port Forwarding:

1. **Public catalog (read-only):**
   - From anywhere: `http://YOUR_PUBLIC_IP:9000`
   - No login required
   - Can only view albums

2. **Admin site (requires VPN):**
   - DO NOT expose port 8080 to internet
   - Always use VPN for admin access: `http://YOUR_MAC_LOCAL_IP:8080`

### Once connected to VPN:

1. **From anywhere in the world:**
   - Visit: `http://YOUR_MAC_LOCAL_IP:8080`
   - Example: `http://192.168.1.100:8080`

2. **All traffic is encrypted** through the VPN tunnel
3. **Login** with your admin or toddb credentials
4. **Add/Edit/Delete** albums securely

## Troubleshooting

### Can't connect to VPN:
- Verify port 51820 UDP is forwarded
- Check your public IP hasn't changed: `curl ifconfig.me`
- Update WG_HOST in compose.yaml if IP changed
- Restart: `docker compose restart wireguard`

### Can't access music app after connecting:
- Verify you're connected to WireGuard VPN
- Check Mac's local IP: `ifconfig | grep "inet "`
- Try: http://localhost:8080 (if on same network)
- Check containers are running: `docker compose ps`

### Web UI not accessible:
- Locally: http://localhost:51821 should always work
- Check password is correct
- Restart: `docker compose restart wireguard`

## Security Recommendations

✅ **DO:**
- **Use your router's existing VPN** for the most secure access
- Use strong passwords for admin UI
- Use strong passwords in `.secrets` file
- Monitor logs: `tail -f backend/logs/external_access.log`
- Keep containers updated: `docker compose pull`
- Use unique passwords for each admin user

❌ **DON'T:**
- Expose port 8080 directly to internet (admin site - use VPN only!)
- Expose port 9000 if you want private access (public site - use VPN or port forward)
- Share your WireGuard config files publicly
- Use default passwords

### Recommended Setup:

**Most Secure:**
- Use router's VPN for both admin (8080) and public (9000) access
- No ports exposed to internet
- All access encrypted

**Convenient Public Sharing:**
- Use router's VPN for admin access (8080)
- Port forward 9000 for public read-only catalog
- Anyone can view your music collection

## Dynamic DNS (Optional)

If your ISP changes your public IP frequently:

1. **Use a free DDNS service:**
   - DuckDNS: https://www.duckdns.org
   - No-IP: https://www.noip.com

2. **Update compose.yaml:**
   ```yaml
   - WG_HOST=yourname.duckdns.org
   ```

3. **Set up auto-updater:**
   ```bash
   # Add to crontab
   */5 * * * * curl "https://www.duckdns.org/update?domains=yourname&token=YOUR_TOKEN"
   ```

## Useful Commands

```bash
# View WireGuard logs
docker logs wg-easy

# Restart WireGuard
docker compose restart wireguard

# Stop WireGuard
docker compose stop wireguard

# View connected clients
docker exec wg-easy wg show

# Backup WireGuard configs
cp -r wireguard wireguard-backup-$(date +%Y%m%d)
```

## Network Diagram

### Using Router's Existing VPN:
```
Internet
   ↓
Router with WireGuard VPN
   ↓ (VPN Tunnel - Encrypted)
Your Mac (192.168.1.x)
   ├── Admin Site (8080)   ← Accessible only via VPN
   └── Public Site (9000)  ← Accessible via VPN or port forward
```

### Using Dockerized WireGuard:
```
Internet
   ↓
Router (Port Forward 51820 UDP)
   ↓
Your Mac (192.168.1.x)
   ├── WireGuard (51820) ← VPN clients connect here
   ├── Web UI (51821)
   ├── Admin Site (8080)   ← Accessible only via VPN
   └── Public Site (9000)  ← Accessible via VPN
```

## Support

Check logs if issues occur:
- WireGuard: `docker logs wg-easy`
- Backend: `docker logs music-inventory-app-backend-1`
- External access: `cat backend/logs/external_access.log`
