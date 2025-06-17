#!/bin/bash

# Multi-Amp Container Runner using tmux
# Creates a tmux session with 3 panes, each running an Amp container

set -e

# Configuration
CONTAINER_PREFIX="amp-dev"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_NAME="amp-multi"

# Ask user for number of containers
echo "🚀 Multi-Amp Container Runner using tmux"
echo ""
while true; do
    read -p "How many Amp containers would you like to run? (1-10): " NUM_INSTANCES
    
    # Check if input is a number
    if ! [[ "$NUM_INSTANCES" =~ ^[0-9]+$ ]]; then
        echo "❌ Please enter a valid number."
        continue
    fi
    
    # Check range
    if [ "$NUM_INSTANCES" -lt 1 ] || [ "$NUM_INSTANCES" -gt 10 ]; then
        echo "❌ Please enter a number between 1 and 10."
        continue
    fi
    
    break
done

echo "🚀 Starting $NUM_INSTANCES Amp container instances in tmux..."
echo "📁 Project directory: $PROJECT_DIR"

# Check dependencies
if ! command -v tmux >/dev/null 2>&1; then
    echo "❌ tmux not found. Please install tmux first:"
    echo "   macOS: brew install tmux"
    echo "   Ubuntu/Debian: sudo apt install tmux"
    echo "   CentOS/RHEL: sudo yum install tmux"
    exit 1
fi

if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml not found in $PROJECT_DIR"
    echo "   Please run this script from the amp-container-dev directory."
    exit 1
fi

# Kill existing session if it exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "🧹 Killing existing tmux session '$SESSION_NAME'..."
    tmux kill-session -t "$SESSION_NAME"
fi

# Build the container first
echo "🔧 Building Amp container..."
cd "$PROJECT_DIR"
docker-compose build

echo "🚀 Creating tmux session with $NUM_INSTANCES panes..."

# Create new tmux session with a simple shell first
echo "Creating base tmux session..."
if ! tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_DIR" 'bash'; then
    echo "❌ Failed to create tmux session"
    exit 1
fi

# Verify session was created
if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "❌ Tmux session was not created properly"
    exit 1
fi

echo "✅ Base session created, setting up $NUM_INSTANCES panes..."

# Color palette for panes (cycling through them)
declare -a COLORS=(
    "bg=#2d3748,fg=#e2e8f0"  # Dark slate with light gray
    "bg=#2c5282,fg=#bee3f8"  # Dark blue with light blue
    "bg=#553c9a,fg=#d6bcfa"  # Dark purple with light purple
    "bg=#2f5233,fg=#c6f6d5"  # Dark green with light green
    "bg=#744210,fg=#fbd38d"  # Dark orange with light orange
    "bg=#702459,fg=#f687b3"  # Dark pink with light pink
    "bg=#1a365d,fg=#90cdf4"  # Dark teal with light teal
    "bg=#4a5568,fg=#e2e8f0"  # Dark gray with light gray
    "bg=#553c4e,fg=#fed7e2"  # Dark rose with light rose
    "bg=#2c7a7b,fg=#81e6d9"  # Dark cyan with light cyan
)

# Function to create panes dynamically
create_panes() {
    local num_panes=$1
    
    # For 1 pane, no splitting needed
    if [ "$num_panes" -eq 1 ]; then
        return
    fi
    
    # Create additional panes
    for ((i=2; i<=num_panes; i++)); do
        echo "Creating pane $i..."
        
        # Calculate layout - for first few panes, split specific ways
        if [ "$i" -eq 2 ]; then
            # Split horizontally for second pane
            tmux split-window -h -t "$SESSION_NAME" -c "$PROJECT_DIR" 'bash'
        elif [ "$i" -eq 3 ]; then
            # Split first pane vertically for third pane
            tmux split-window -v -t "$SESSION_NAME:0.0" -c "$PROJECT_DIR" 'bash'
        elif [ "$i" -eq 4 ]; then
            # Split second pane vertically for fourth pane
            tmux split-window -v -t "$SESSION_NAME:0.2" -c "$PROJECT_DIR" 'bash'
        else
            # For additional panes, use tiled layout and just split the largest pane
            tmux split-window -t "$SESSION_NAME" -c "$PROJECT_DIR" 'bash'
        fi
    done
    
    # Use tiled layout for better organization with many panes
    if [ "$num_panes" -gt 4 ]; then
        tmux select-layout -t "$SESSION_NAME" tiled
    fi
}

# Create the required number of panes
create_panes "$NUM_INSTANCES"

# Start containers in each pane and set titles/colors
for ((i=1; i<=NUM_INSTANCES; i++)); do
    pane_index=$((i-1))
    color_index=$((pane_index % ${#COLORS[@]}))
    
    echo "Starting Amp instance $i in pane $pane_index..."
    tmux send-keys -t "$SESSION_NAME:0.$pane_index" "docker-compose run --rm --name ${CONTAINER_PREFIX}-$i amp-cli bash" Enter
    
    # Set pane title
    tmux select-pane -t "$SESSION_NAME:0.$pane_index" -T "Amp-$i"
    
    # Set pane color
    tmux select-pane -t "$SESSION_NAME:0.$pane_index" -P "${COLORS[$color_index]}" 2>/dev/null || true
done

# Enable pane titles display
tmux set-option -t "$SESSION_NAME" pane-border-status top
tmux set-option -t "$SESSION_NAME" pane-border-format "#{pane_title}"

# Focus on first pane
tmux select-pane -t "$SESSION_NAME:0.0"

echo ""
echo "✅ Tmux session '$SESSION_NAME' created with $NUM_INSTANCES Amp instances!"
echo ""
if [ "$NUM_INSTANCES" -le 4 ]; then
    echo "📋 Layout: Custom optimized layout"
else
    echo "📋 Layout: Tiled layout (automatic organization)"
fi
echo ""
echo "🎯 Tmux Navigation:"
echo "   Ctrl+b + arrow keys  - Switch between panes"
echo "   Ctrl+b + z           - Zoom/unzoom current pane"
echo "   Ctrl+b + d           - Detach from session"
echo "   Ctrl+b + x           - Kill current pane"
echo "   Ctrl+b + &           - Kill entire session"
echo ""
echo "💡 Usage in each pane:"
echo "   echo  \"Review this code for improvements\" | amp
echo "   echo  \"Add comprehensive tests\" | amp
echo "   echo  \"Optimize performance\" | amp
echo ""
echo "🔌 To reconnect later: tmux attach -t $SESSION_NAME"
echo "🛑 To stop all: ./stop-multi-amp.sh"
echo ""

# Wait a moment for containers to start
echo "⏳ Waiting for containers to initialize..."
sleep 3

# Verify session still exists before attaching
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "🎉 Attaching to tmux session..."
    tmux attach-session -t "$SESSION_NAME"
else
    echo "❌ Tmux session '$SESSION_NAME' not found. Something went wrong."
    echo "🔍 Checking for running containers..."
    docker ps --filter "name=$CONTAINER_PREFIX"
    exit 1
fi
