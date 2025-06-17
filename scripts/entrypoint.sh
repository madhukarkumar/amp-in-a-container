#!/bin/bash
set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Error handling function
cleanup_on_error() {
    local exit_code=$?
    log "ERROR: Script failed with exit code $exit_code"
    if [[ -n "${TEMP_CLONE_DIR:-}" ]] && [[ -d "$TEMP_CLONE_DIR" ]]; then
        log "Cleaning up temporary directory: $TEMP_CLONE_DIR"
        rm -rf "$TEMP_CLONE_DIR"
    fi
    exit $exit_code
}

trap cleanup_on_error ERR

# Validate Git URL format
validate_git_url() {
    local url="$1"
    if [[ ! "$url" =~ ^(https?://|git@|ssh://) ]]; then
        log "ERROR: Invalid Git URL format: $url"
        return 1
    fi
}

# Clone repository if GIT_REPO is set and workspace is empty
if [[ -n "${GIT_REPO:-}" ]] && [[ ! -d "/workspace/.git" ]]; then
    log "Validating Git repository URL: $GIT_REPO"
    validate_git_url "$GIT_REPO"
    
    log "Cloning repository: $GIT_REPO"
    # Check if workspace is empty or only contains hidden files
    if [[ -z "$(ls -A /workspace 2>/dev/null)" ]]; then
        log "Cloning to /workspace..."
        if timeout 300 git clone "$GIT_REPO" /workspace; then
            log "Repository cloned successfully"
        else
            log "ERROR: Failed to clone repository. Please check:"
            log "1. Repository URL is correct"
            log "2. You have access to the repository"
            log "3. If private, use SSH URL or Personal Access Token"
            log "4. For public repos, HTTPS should work without authentication"
            exit 1
        fi
    else
        # If workspace has content, clone to a subdirectory
        REPO_NAME=$(basename "$GIT_REPO" .git)
        CLONE_PATH="/workspace/$REPO_NAME"
        log "Workspace not empty, cloning to $CLONE_PATH"
        
        if [[ -d "$CLONE_PATH" ]]; then
            log "WARNING: Directory $CLONE_PATH already exists, skipping clone"
        else
            if timeout 300 git clone "$GIT_REPO" "$CLONE_PATH"; then
                log "Repository cloned successfully to $REPO_NAME"
                cd "$CLONE_PATH"
            else
                log "ERROR: Failed to clone repository to subdirectory"
                exit 1
            fi
        fi
    fi
fi

# Configure Git user settings
if [[ -n "${GIT_USER_NAME:-}" ]]; then
    log "Configuring Git user name: $GIT_USER_NAME"
    git config --global user.name "$GIT_USER_NAME"
fi

if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
    log "Configuring Git user email: $GIT_USER_EMAIL"
    git config --global user.email "$GIT_USER_EMAIL"
fi

# Validate and set Amp API key
if [[ -n "${AMP_API_KEY:-}" ]]; then
    log "Setting up Amp authentication..."
    export AMP_API_KEY="$AMP_API_KEY"
    
    # Validate API key format (basic check)
    if [[ ${#AMP_API_KEY} -lt 20 ]]; then
        log "WARNING: API key seems too short, please verify it's correct"
    fi
else
    log "WARNING: AMP_API_KEY not set. Amp commands may not work properly."
fi

log "Container initialization completed successfully"
exec "$@"
