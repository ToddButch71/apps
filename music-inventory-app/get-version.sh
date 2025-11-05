#!/bin/bash
# Display current version of Music Inventory App

VERSION_FILE="$(dirname "$0")/VERSION"

if [ -f "$VERSION_FILE" ]; then
    VERSION=$(cat "$VERSION_FILE")
    echo "Music Inventory App - Version $VERSION"
else
    echo "Version file not found!"
    exit 1
fi
