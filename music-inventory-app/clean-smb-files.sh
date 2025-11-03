#!/bin/bash
# Script to clean up SMB temporary files
# These files are created by macOS SMB/Samba when files are deleted on network shares

echo "Cleaning up SMB temporary files..."

# Count files before
count=$(find . -name ".smbdelete*" -o -name ".smb*" | wc -l | tr -d ' ')
echo "Found $count SMB temporary files"

if [ "$count" -eq 0 ]; then
    echo "No SMB files to clean up."
    exit 0
fi

# Try to remove them
# Some may be locked by SMB daemon - those will fail with "Resource busy"
find . -name ".smbdelete*" -o -name ".smb*" 2>/dev/null | while read -r file; do
    rm -f "$file" 2>/dev/null && echo "Deleted: $file" || echo "Locked: $file (will be cleaned up when SMB connection closes)"
done

# Count remaining files
remaining=$(find . -name ".smbdelete*" -o -name ".smb*" | wc -l | tr -d ' ')
removed=$((count - remaining))

echo ""
echo "Summary:"
echo "  Removed: $removed files"
echo "  Locked: $remaining files (these will be automatically cleaned up when the SMB connection closes)"

if [ "$remaining" -gt 0 ]; then
    echo ""
    echo "To force cleanup of locked files:"
    echo "  1. Close any SMB/network connections to this directory"
    echo "  2. Unmount and remount the network share"
    echo "  3. Run this script again"
fi
