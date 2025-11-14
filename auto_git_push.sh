#!/bin/bash

###############################################################################
# AUTO GIT PUSH SCHEDULER
# Automatically commits and pushes changes every 20 minutes
###############################################################################

# Configuration
INTERVAL=1200  # 20 minutes in seconds (20 * 60)
REPO_PATH="/workspaces/codespaces-blank"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   AUTO GIT PUSH SCHEDULER - Running every 20 minutes      ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "Repository: $REPO_PATH"
echo "Interval: 20 minutes ($INTERVAL seconds)"
echo "Started at: $(date)"
echo ""
echo "Press Ctrl+C to stop"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$REPO_PATH" || exit 1

# Counter for tracking pushes
push_count=0

while true; do
    # Get current timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Check if there are changes
    if [[ -n $(git status -s) ]]; then
        echo "[$timestamp] Changes detected - Starting auto-commit..."
        
        # Add all changes
        git add -A
        
        # Create commit with timestamp
        commit_msg="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S') - Push #$((++push_count))"
        git commit -m "$commit_msg"
        
        # Push to remote
        if git push; then
            echo "[$timestamp] ✓ Successfully pushed to remote"
            echo "             Commit: $commit_msg"
        else
            echo "[$timestamp] ✗ Push failed - will retry next cycle"
        fi
    else
        echo "[$timestamp] No changes detected - skipping commit"
    fi
    
    echo "[$timestamp] Next check in 20 minutes..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Wait for 20 minutes
    sleep $INTERVAL
done
