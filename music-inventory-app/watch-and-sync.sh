#!/bin/bash
# Watch index.html for changes and auto-sync to public version

INDEX_FILE="frontend/index.html"
SYNC_SCRIPT="./sync-public.sh"

echo "🔍 Watching $INDEX_FILE for changes..."
echo "📝 Will auto-sync, rebuild, and restart public-frontend on changes"
echo "Press Ctrl+C to stop"
echo ""

# Get initial checksum
LAST_CHECKSUM=$(md5 -q "$INDEX_FILE" 2>/dev/null || echo "")

while true; do
    sleep 2
    
    # Get current checksum
    CURRENT_CHECKSUM=$(md5 -q "$INDEX_FILE" 2>/dev/null || echo "")
    
    # Check if file changed
    if [ "$CURRENT_CHECKSUM" != "$LAST_CHECKSUM" ] && [ -n "$CURRENT_CHECKSUM" ]; then
        echo "⚡ Change detected in $INDEX_FILE"
        echo "🔄 Running sync script..."
        
        # Run sync script
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
        
        # Update checksum
        LAST_CHECKSUM="$CURRENT_CHECKSUM"
        echo ""
        echo "🔍 Watching for next change..."
        echo ""
    fi
done
