#!/bin/bash
set -e

# Clone repository if GIT_REPO is set and workspace is empty
if [ -n "$GIT_REPO" ] && [ ! -d "/workspace/.git" ]; then
    echo "Cloning repository: $GIT_REPO"
    # Check if workspace is empty or only contains hidden files
    if [ -z "$(ls -A /workspace 2>/dev/null)" ]; then
        echo "Cloning to /workspace..."
        if git clone "$GIT_REPO" /workspace; then
            echo "Repository cloned successfully"
        else
            echo "Failed to clone repository. Please check:"
            echo "1. Repository URL is correct"
            echo "2. You have access to the repository"
            echo "3. If private, use SSH URL or Personal Access Token"
            echo "4. For public repos, HTTPS should work without authentication"
        fi
    else
        # If workspace has content, clone to a subdirectory
        REPO_NAME=$(basename "$GIT_REPO" .git)
        echo "Workspace not empty, cloning to /workspace/$REPO_NAME"
        if git clone "$GIT_REPO" "/workspace/$REPO_NAME"; then
            echo "Repository cloned successfully to $REPO_NAME"
            cd "/workspace/$REPO_NAME"
        else
            echo "Failed to clone repository to subdirectory"
        fi
    fi
fi

if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi

if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

if [ -n "$AMP_API_KEY" ]; then
    echo "Authenticating with Amp..."
    export AMP_API_KEY="$AMP_API_KEY"
fi

exec "$@"
