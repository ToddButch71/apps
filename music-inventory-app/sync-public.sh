#!/bin/bash
# Sync index.html to index-public.html with admin features removed

SOURCE_FILE="frontend/index.html"
TARGET_FILE="frontend/index-public.html"

echo "Syncing $SOURCE_FILE to $TARGET_FILE..."

# Copy the source file
cp "$SOURCE_FILE" "$TARGET_FILE"

# Remove auth status indicator section
sed -i '' '/<div class="auth-status"/,/<\/div>/d' "$TARGET_FILE"

# Remove login modal section
sed -i '' '/<!-- Login Modal -->/,/<\/div>/{ /<!-- Login Modal -->/!d; }' "$TARGET_FILE"

# Remove album modal section  
sed -i '' '/<!-- Add\/Edit Album Modal -->/,/<!-- Action buttons/{ /<!-- Action buttons/!d; }' "$TARGET_FILE"

# Remove action buttons div
sed -i '' '/<div class="action-buttons"/,/<\/div>/d' "$TARGET_FILE"

# Remove Actions table header
sed -i '' 's/<th id="actionsHeader".*Actions<\/th>//g' "$TARGET_FILE"

# Update page title
sed -i '' 's/<title>Music Catalog - Realtime Search<\/title>/<title>Music Catalog - Public<\/title>/' "$TARGET_FILE"
sed -i '' 's/<h1>Music Catalog<\/h1>/<h1>Music Catalog - Public<\/h1>/' "$TARGET_FILE"

# Remove auth-related CSS
sed -i '' '/\.auth-status {/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/\.btn-logout {/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/\.action-buttons {/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/\.btn-add {/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/\.btn-edit {/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/\.btn-delete {/,/^[[:space:]]*}$/d' "$TARGET_FILE"

# Remove auth-related JavaScript functions
sed -i '' '/let authToken = /,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function checkAuthStatus/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function showLoginModal/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function closeLoginModal/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/async function handleLogin/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function logout/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function showAddRecordForm/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function showEditRecordForm/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/function closeAlbumModal/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/async function handleAlbumSubmit/,/^[[:space:]]*}$/d' "$TARGET_FILE"
sed -i '' '/async function deleteRecord/,/^[[:space:]]*}$/d' "$TARGET_FILE"

# Remove action button rendering in table
sed -i '' '/let actionsCell = /,/authToken {$/d' "$TARGET_FILE"
sed -i '' '/actionsCell = /,/};$/d' "$TARGET_FILE"
sed -i '' 's/\${actionsCell}//g' "$TARGET_FILE"

# Remove auth header show/hide logic
sed -i '' '/Show\/hide actions header/,/}$/d' "$TARGET_FILE"

# Remove checkAuthStatus call
sed -i '' '/checkAuthStatus();/d' "$TARGET_FILE"

# Remove logout button listener
sed -i '' "/getElementById('logoutBtn')/d" "$TARGET_FILE"

# Add comment markers
sed -i '' 's/<!-- Login Modal/<!-- Login Modal removed for public version/g' "$TARGET_FILE"
sed -i '' 's/<!-- Add\/Edit Album Modal/<!-- Add\/Edit Album Modal removed for public version/g' "$TARGET_FILE"
sed -i '' 's/<!-- Action buttons/<!-- Action buttons removed for public version/g' "$TARGET_FILE"

echo "✅ Sync complete! Public version ready at $TARGET_FILE"
echo ""
echo "Remember to rebuild the Docker container:"
echo "  docker compose build public-frontend"
echo "  docker compose up -d public-frontend"
