#!/bin/bash
# EcomNewsHQ Auto-Deploy
# Install: cPanel -> Cron Jobs -> * * * * * /home/ecomrztt/autodeploy.sh
# (runs every minute, only deploys if there are new commits)

REPO_DIR="/home/ecomrztt/site-repo"
PUBLIC_HTML="/home/ecomrztt/public_html"
GITHUB_REPO="https://github.com/amzdoc93/ecomnewshq-site.git"
LOCK_FILE="/tmp/ecomnewshq-deploy.lock"
LOG_FILE="/home/ecomrztt/deploy.log"

# Prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then exit 0; fi
touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

# Clone repo if it doesn't exist
if [ ! -d "$REPO_DIR/.git" ]; then
    git clone "$GITHUB_REPO" "$REPO_DIR" >> "$LOG_FILE" 2>&1
fi

# Check for new commits
cd "$REPO_DIR"
git fetch origin main -q 2>/dev/null

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "[$(date)] New commit detected: $REMOTE" >> "$LOG_FILE"
    git pull origin main -q >> "$LOG_FILE" 2>&1
    
    # Sync src/ to public_html (preserve _claude_api.php and other server files)
    rsync -av --delete \
        --exclude='_claude_api.php' \
        --exclude='_api.php' \
        --exclude='_test_claude.html' \
        --exclude='index_backup_*.html' \
        "$REPO_DIR/src/" "$PUBLIC_HTML/" >> "$LOG_FILE" 2>&1
    
    echo "[$(date)] Deploy complete" >> "$LOG_FILE"
fi
