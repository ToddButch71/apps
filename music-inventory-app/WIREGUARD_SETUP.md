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

Once connected to WireGuard VPN:

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
- Use strong passwords for WireGuard admin UI
- Use strong passwords in `.secrets` file
- Monitor logs: `tail -f backend/logs/external_access.log`
- Keep WireGuard updated: `docker compose pull wireguard`
- Use unique passwords for each admin user

❌ **DON'T:**
- Expose port 8080 directly to internet (use VPN only)
- Share your WireGuard config files publicly
- Use default passwords
- Leave web UI (51821) exposed to internet

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

```
Internet
   ↓
Router (Port Forward 51820 UDP)
   ↓
Your Mac (192.168.1.x)
   ├── WireGuard (51820) ← VPN clients connect here
   ├── Web UI (51821)
   └── Music App (8080)   ← Accessible only via VPN
```

## Support

Check logs if issues occur:
- WireGuard: `docker logs wg-easy`
- Backend: `docker logs music-inventory-app-backend-1`
- External access: `cat backend/logs/external_access.log`
