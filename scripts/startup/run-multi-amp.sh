#!/bin/bash

# Multi-Amp Container Runner
# Launches 3 instances of Amp containers in separate terminals

set -e

# Configuration
CONTAINER_PREFIX="amp-dev"
NUM_INSTANCES=3
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🚀 Starting $NUM_INSTANCES Amp container instances..."
echo "📁 Project directory: $PROJECT_DIR"

# Function to detect terminal and run command
run_in_new_terminal() {
    local instance_num=$1
    local container_name="${CONTAINER_PREFIX}-${instance_num}"
    
    # Build the docker command
    local docker_cmd="cd '$PROJECT_DIR' && docker-compose run --rm --name $container_name amp-cli bash"
    
    # Detect terminal type and run accordingly
    if command -v osascript >/dev/null 2>&1; then
        # macOS - use Terminal.app
        osascript -e "
        tell application \"Terminal\"
            activate
            do script \"$docker_cmd\"
            set custom title of front window to \"Amp Instance $instance_num\"
        end tell"
    elif command -v gnome-terminal >/dev/null 2>&1; then
        # Linux with GNOME Terminal
        gnome-terminal --title="Amp Instance $instance_num" -- bash -c "$docker_cmd"
    elif command -v xterm >/dev/null 2>&1; then
        # Generic X11 terminal
        xterm -title "Amp Instance $instance_num" -e bash -c "$docker_cmd" &
    elif command -v konsole >/dev/null 2>&1; then
        # KDE Konsole
        konsole --title "Amp Instance $instance_num" -e bash -c "$docker_cmd" &
    elif [[ "$TERM_PROGRAM" == "iTerm.app" ]]; then
        # iTerm2 on macOS
        osascript -e "
        tell application \"iTerm\"
            activate
            create window with default profile
            tell current session of current window
                write text \"$docker_cmd\"
                set name to \"Amp Instance $instance_num\"
            end tell
        end tell"
    else
        # Fallback - try to use tmux or screen
        if command -v tmux >/dev/null 2>&1; then
            tmux new-session -d -s "amp-$instance_num" "$docker_cmd"
            echo "✅ Started Amp instance $instance_num in tmux session 'amp-$instance_num'"
            echo "   Connect with: tmux attach -t amp-$instance_num"
        elif command -v screen >/dev/null 2>&1; then
            screen -dmS "amp-$instance_num" bash -c "$docker_cmd"
            echo "✅ Started Amp instance $instance_num in screen session 'amp-$instance_num'"
            echo "   Connect with: screen -r amp-$instance_num"
        else
            echo "❌ No supported terminal found. Please run manually:"
            echo "   $docker_cmd"
            return 1
        fi
    fi
}

# Check if docker-compose is available
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

# Check if we're in the right directory
if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml not found in $PROJECT_DIR"
    echo "   Please run this script from the amp-container-dev directory."
    exit 1
fi

# Build the container first
echo "🔧 Building Amp container..."
cd "$PROJECT_DIR"
docker-compose build

# Launch instances
echo "🚀 Launching $NUM_INSTANCES Amp instances..."
for i in $(seq 1 $NUM_INSTANCES); do
    echo "Starting Amp instance $i..."
    run_in_new_terminal $i
    sleep 2  # Small delay to avoid conflicts
done

echo ""
echo "✅ All instances launched!"
echo ""
echo "📋 Each terminal will run:"
echo "   • Amp CLI with your configured settings"
echo "   • Auto-clone your Git repository (if configured)"
echo "   • Ready for interactive development"
echo ""
echo "💡 Usage examples in each terminal:"
echo "   amp chat \"Review this code for improvements\""
echo "   amp chat \"Add comprehensive tests\""
echo "   amp chat \"Optimize performance\""
echo ""
echo "🛑 To stop all containers:"
echo "   docker stop \$(docker ps -q --filter name=$CONTAINER_PREFIX)"
echo ""

# Optional: Show running containers
if command -v docker >/dev/null 2>&1; then
    echo "🐳 Running containers:"
    docker ps --filter "name=$CONTAINER_PREFIX" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
fi
