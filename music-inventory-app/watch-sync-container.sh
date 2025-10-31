#!/bin/bash
# Container-based file watcher for index.html

INDEX_FILE="/workspace/frontend/index.html"
SYNC_SCRIPT="/workspace/sync-public.sh"

echo "🔍 Container watcher started"
echo "📝 Monitoring: $INDEX_FILE"
echo "🐳 Docker socket: /var/run/docker.sock"
echo ""

# Wait for file to exist
while [ ! -f "$INDEX_FILE" ]; do
    echo "⏳ Waiting for $INDEX_FILE to exist..."
    sleep 2
done

echo "✅ File found, starting watch with polling (macOS compatible)..."
echo ""

# Get initial checksum
LAST_CHECKSUM=$(md5sum "$INDEX_FILE" 2>/dev/null | cut -d' ' -f1)

# Use polling loop instead of inotifywait (more reliable on macOS Docker)
while true; do
    sleep 2
    
    # Get current checksum
    CURRENT_CHECKSUM=$(md5sum "$INDEX_FILE" 2>/dev/null | cut -d' ' -f1)
    
    # Check if file changed
    if [ "$CURRENT_CHECKSUM" != "$LAST_CHECKSUM" ] && [ -n "$CURRENT_CHECKSUM" ]; then
        echo "⚡ Change detected in index.html"
        echo "🔄 Running sync script..."
        
        LAST_CHECKSUM="$CURRENT_CHECKSUM"
        
        # Run sync script
        cd /workspace
        bash "$SYNC_SCRIPT"
        
        if [ $? -eq 0 ]; then
            echo "🏗️  Rebuilding public-frontend..."
            docker compose build public-frontend
            
            if [ $? -eq 0 ]; then
                echo "🚀 Restarting public-frontend..."
                docker compose up -d public-frontend
                
                if [ $? -eq 0 ]; then
                    echo "✅ Public frontend updated successfully!"
                    echo "🌐 Available at http://localhost:9000"
                else
                    echo "❌ Failed to restart container"
                fi
            else
                echo "❌ Build failed"
            fi
        else
            echo "❌ Sync failed"
        fi
        
        echo ""
        echo "🔍 Watching for next change..."
        echo ""
    fi
done
