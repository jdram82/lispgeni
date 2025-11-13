#!/bin/bash
# Chat Archive Utility
# Usage: ./save_chat.sh [optional: custom filename]

# Get current date and time
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
DEFAULT_FILENAME="CHAT_LOG_${TIMESTAMP}.md"

# Use custom filename if provided, otherwise use default
FILENAME=${1:-$DEFAULT_FILENAME}

# Create chats directory if it doesn't exist
CHAT_DIR="/workspaces/codespaces-blank/chat_archives"
mkdir -p "$CHAT_DIR"

FILEPATH="${CHAT_DIR}/${FILENAME}"

echo "╔═══════════════════════════════════════════════════════════╗"
echo "║          CHAT ARCHIVE UTILITY                             ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo ""
echo "Save location: $FILEPATH"
echo ""
echo "Please paste your chat content below."
echo "Press Ctrl+D when finished (or Ctrl+C to cancel)."
echo ""
echo "────────────────────────────────────────────────────────────"

# Read multiline input until Ctrl+D
cat > "$FILEPATH"

if [ -s "$FILEPATH" ]; then
    echo ""
    echo "────────────────────────────────────────────────────────────"
    echo "✓ Chat saved successfully!"
    echo "  Location: $FILEPATH"
    echo "  Size: $(wc -c < "$FILEPATH") bytes"
    echo "  Lines: $(wc -l < "$FILEPATH") lines"
    echo ""
    
    # Add to git if repository exists
    if [ -d "/workspaces/codespaces-blank/.git" ]; then
        cd /workspaces/codespaces-blank
        git add "$FILEPATH"
        git commit -m "Archive: Chat log from $TIMESTAMP"
        echo "✓ Changes committed to git"
    fi
else
    echo ""
    echo "✗ No content entered. File not created."
    rm "$FILEPATH"
fi
