#!/bin/bash

# Single Amp Container Runner
# Quick launcher for a single Amp instance

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo "🚀 Starting single Amp container instance..."

# Check dependencies
if ! command -v docker-compose >/dev/null 2>&1; then
    echo "❌ docker-compose not found. Please install Docker Compose."
    exit 1
fi

if [[ ! -f "$PROJECT_DIR/docker-compose.yml" ]]; then
    echo "❌ docker-compose.yml not found in $PROJECT_DIR"
    exit 1
fi

# Build and run
cd "$PROJECT_DIR"

echo "🔧 Building container if needed..."
docker-compose build

echo "🚀 Starting Amp CLI..."
echo "💡 You can now use commands like:"
echo "   amp chat \"Review this code\""
echo "   amp chat \"Add tests for this function\""
echo "   amp-prompt /workspace/my-prompt.txt"
echo ""

# Run the container interactively
docker-compose run --rm amp-cli bash
