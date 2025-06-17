#!/bin/bash

# Stop tmux-based multi-Amp session

set -e

SESSION_NAME="amp-multi"
CONTAINER_PREFIX="amp-dev"

echo "🛑 Stopping tmux-based Amp session..."

# Kill tmux session if it exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "🧹 Killing tmux session '$SESSION_NAME'..."
    tmux kill-session -t "$SESSION_NAME"
    echo "✅ Tmux session terminated."
else
    echo "ℹ️  No tmux session '$SESSION_NAME' found."
fi

# Stop any running containers
echo "🔍 Checking for running Amp containers..."
RUNNING_CONTAINERS=$(docker ps -q --filter "name=$CONTAINER_PREFIX" 2>/dev/null || true)

if [[ -n "$RUNNING_CONTAINERS" ]]; then
    echo "🐳 Found running Amp containers:"
    docker ps --filter "name=$CONTAINER_PREFIX" --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"
    
    echo "🛑 Stopping running containers..."
    echo "$RUNNING_CONTAINERS" | xargs -r docker stop
    
    echo "🧹 Removing stopped containers..."
    echo "$RUNNING_CONTAINERS" | xargs -r docker rm 2>/dev/null || true
    
    echo "✅ All Amp containers stopped and cleaned up."
else
    echo "ℹ️  No running Amp containers found."
fi

# Also check for any orphaned containers that might not be running
echo "🔍 Checking for stopped Amp containers..."
STOPPED_CONTAINERS=$(docker ps -aq --filter "name=$CONTAINER_PREFIX" 2>/dev/null || true)

if [[ -n "$STOPPED_CONTAINERS" ]]; then
    echo "🧹 Removing stopped Amp containers..."
    echo "$STOPPED_CONTAINERS" | xargs -r docker rm 2>/dev/null || true
    echo "✅ Stopped containers cleaned up."
fi

echo "✅ Cleanup complete!"
