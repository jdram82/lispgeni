#!/bin/bash

###############################################################################
# SETUP CRON JOB FOR AUTO GIT PUSH
# Configures system cron to run git push every 20 minutes
###############################################################################

REPO_PATH="/workspaces/codespaces-blank"
SCRIPT_PATH="$REPO_PATH/auto_git_push_cron.sh"

echo "╔════════════════════════════════════════════════════════════╗"
echo "║   CRON-BASED AUTO GIT PUSH SETUP                          ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Create the script that cron will execute
cat > "$SCRIPT_PATH" << 'CRONSCRIPT'
#!/bin/bash

REPO_PATH="/workspaces/codespaces-blank"
LOG_FILE="$REPO_PATH/auto_git_push.log"
BRANCH="dev-macro"

cd "$REPO_PATH" || exit 1

# Ensure we're on dev-macro branch
git checkout $BRANCH 2>/dev/null

timestamp=$(date '+%Y-%m-%d %H:%M:%S')

# Check if there are changes
if [[ -n $(git status -s) ]]; then
    echo "[$timestamp] Changes detected - Auto-committing..." >> "$LOG_FILE"
    
    git add -A >> "$LOG_FILE" 2>&1
    
    commit_msg="Auto-commit: $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m "$commit_msg" >> "$LOG_FILE" 2>&1
    
    if git push origin $BRANCH >> "$LOG_FILE" 2>&1; then
        echo "[$timestamp] ✓ Successfully pushed to $BRANCH" >> "$LOG_FILE"
    else
        echo "[$timestamp] ✗ Push failed" >> "$LOG_FILE"
    fi
else
    echo "[$timestamp] No changes detected" >> "$LOG_FILE"
fi
CRONSCRIPT

chmod +x "$SCRIPT_PATH"

echo "✓ Created cron script at: $SCRIPT_PATH"
echo ""

# Add cron job (runs every 20 minutes)
CRON_ENTRY="*/20 * * * * $SCRIPT_PATH"

# Check if cron job already exists
if crontab -l 2>/dev/null | grep -q "$SCRIPT_PATH"; then
    echo "⚠ Cron job already exists"
else
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    echo "✓ Added cron job: Runs every 20 minutes"
fi

echo ""
echo "Cron schedule: */20 * * * * (every 20 minutes)"
echo "Log file: $REPO_PATH/auto_git_push.log"
echo ""
echo "To view current cron jobs: crontab -l"
echo "To remove cron job: crontab -e (then delete the line)"
echo "To view logs: tail -f $REPO_PATH/auto_git_push.log"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
