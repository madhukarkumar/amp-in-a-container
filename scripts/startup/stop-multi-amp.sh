#!/bin/bash

# Stop all Amp container instances

set -e

CONTAINER_PREFIX="amp-dev"

echo "🛑 Stopping all Amp container instances..."

# Get running containers with our prefix
RUNNING_CONTAINERS=$(docker ps -q --filter "name=$CONTAINER_PREFIX" 2>/dev/null || true)

if [[ -z "$RUNNING_CONTAINERS" ]]; then
    echo "✅ No running Amp containers found."
else
    echo "🐳 Found running containers:"
    docker ps --filter "name=$CONTAINER_PREFIX" --format "table {{.Names}}\t{{.Status}}"
    
    echo "🛑 Stopping containers..."
    docker stop $RUNNING_CONTAINERS
    
    echo "🧹 Cleaning up..."
    docker rm $RUNNING_CONTAINERS 2>/dev/null || true
    
    echo "✅ All Amp containers stopped and cleaned up."
fi

# Also clean up any tmux sessions
if command -v tmux >/dev/null 2>&1; then
    AMP_SESSIONS=$(tmux list-sessions 2>/dev/null | grep "amp-" | cut -d: -f1 || true)
    if [[ -n "$AMP_SESSIONS" ]]; then
        echo "🧹 Cleaning up tmux sessions..."
        for session in $AMP_SESSIONS; do
            tmux kill-session -t "$session" 2>/dev/null || true
            echo "   Killed tmux session: $session"
        done
    fi
fi

# Also clean up any screen sessions
if command -v screen >/dev/null 2>&1; then
    AMP_SCREENS=$(screen -ls 2>/dev/null | grep "amp-" | awk '{print $1}' | cut -d. -f2 || true)
    if [[ -n "$AMP_SCREENS" ]]; then
        echo "🧹 Cleaning up screen sessions..."
        for session in $AMP_SCREENS; do
            screen -S "$session" -X quit 2>/dev/null || true
            echo "   Killed screen session: $session"
        done
    fi
fi

echo "✅ Cleanup complete!"
