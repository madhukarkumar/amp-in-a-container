#!/bin/bash

# Automated Multi-Amp Batch Processing with tmux
# Automatically runs numbered prompt files through Amp containers

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SESSION_NAME="amp-batch"
PROMPT_DIR="./workspace/prompts"
OUTPUT_DIR="./workspace/outputs"

# Configuration
NUM_INSTANCES=${1:-3}

echo "🚀 Batch Amp Processing with $NUM_INSTANCES instances"

# Check dependencies
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found. Install with: brew install tmux"
    exit 1
fi

# Create directories
mkdir -p "$PROMPT_DIR" "$OUTPUT_DIR"

# Create sample prompt files if they don't exist
if [ ! -f "$PROMPT_DIR/prompt1.txt" ]; then
    echo "📝 Creating sample prompt files..."
    echo "Review this code for security vulnerabilities and suggest improvements" > "$PROMPT_DIR/prompt1.txt"
    echo "Add comprehensive unit tests with good coverage" > "$PROMPT_DIR/prompt2.txt"
    echo "Optimize performance and memory usage throughout the application" > "$PROMPT_DIR/prompt3.txt"
    echo "Generate detailed documentation for all functions and classes" > "$PROMPT_DIR/prompt4.txt"
    echo "Refactor code to follow clean architecture principles" > "$PROMPT_DIR/prompt5.txt"
fi

# Kill existing session
tmux has-session -t "$SESSION_NAME" 2>/dev/null && tmux kill-session -t "$SESSION_NAME"

# Build container
echo "🔧 Building container..."
docker-compose build

# Create tmux session
echo "🚀 Creating tmux session..."
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR"

# Create panes
for ((i=2; i<=NUM_INSTANCES; i++)); do
    if [ "$i" -eq 2 ]; then
        tmux split-window -h -t "$SESSION_NAME" -c "$PROJECT_DIR"
    else
        tmux split-window -t "$SESSION_NAME" -c "$PROJECT_DIR"
    fi
done

# Use tiled layout for better organization
tmux select-layout -t "$SESSION_NAME" tiled

# Start batch processing in each pane
for ((i=1; i<=NUM_INSTANCES; i++)); do
    pane_index=$((i-1))
    
    echo "Starting batch processing $i..."
    tmux send-keys -t "$SESSION_NAME:0.$pane_index" \
        "docker-compose run --rm --name amp-batch-$i amp-cli bash -c 'amp < /workspace/prompts/prompt$i.txt > /workspace/outputs/output$i.txt && echo \"✅ Batch $i complete\" && bash'" Enter
    
    tmux select-pane -t "$SESSION_NAME:0.$pane_index" -T "Batch-$i"
done

echo "✅ Batch processing started!"
echo "📁 Prompt files: $PROMPT_DIR/prompt*.txt"
echo "📁 Output files: $OUTPUT_DIR/output*.txt"
echo ""
echo "🔌 Attach to session: tmux attach -t $SESSION_NAME"
echo "🛑 Stop session: tmux kill-session -t $SESSION_NAME"

# Attach to session
tmux attach-session -t "$SESSION_NAME"
