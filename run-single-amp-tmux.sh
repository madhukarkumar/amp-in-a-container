#!/bin/bash

# Single Amp Container Runner with tmux
# Creates a simple tmux session with one Amp container

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_NAME="amp-single"

echo "🚀 Starting single Amp container in tmux..."

# Check dependencies
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found. Please install tmux first:"
    echo "   macOS: brew install tmux"
    echo "   Ubuntu/Debian: sudo apt install tmux"
    exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml not found in $PROJECT_DIR"
    exit 1
fi

# Kill existing session if it exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "🧹 Killing existing tmux session '$SESSION_NAME'..."
    tmux kill-session -t "$SESSION_NAME"
fi

# Build and run
cd "$PROJECT_DIR"
echo "🔧 Building container if needed..."
docker-compose build

echo "🚀 Creating tmux session with Amp CLI..."

# Create new tmux session
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR" \
    "docker-compose run --rm amp-cli bash -c 'echo \"🚀 AMP CLI Ready\" && echo \"Use: amp chat \\\"your prompt here\\\"\" && bash'"

# Set session options for better experience
tmux set-option -t "$SESSION_NAME" status-style 'bg=green,fg=black'
tmux set-option -t "$SESSION_NAME" status-left "🚀 Amp CLI "

echo "✅ Tmux session '$SESSION_NAME' created!"
echo "🔌 To reconnect later: tmux attach -t $SESSION_NAME"
echo "🛑 To stop: tmux kill-session -t $SESSION_NAME"
echo ""

# Attach to the session
tmux attach-session -t "$SESSION_NAME"
