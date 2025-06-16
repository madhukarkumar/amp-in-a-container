#!/bin/bash
# Usage: ./amp-prompt.sh <prompt-file>

if [ $# -eq 0 ]; then
    echo "Usage: $0 <prompt-file>"
    echo "Example: $0 /workspace/my-prompt.txt"
    exit 1
fi

PROMPT_FILE="$1"

if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: File '$PROMPT_FILE' not found"
    exit 1
fi

echo "Running Amp with prompt from: $PROMPT_FILE"
echo "----------------------------------------"
cat "$PROMPT_FILE"
echo "----------------------------------------"

amp chat < "$PROMPT_FILE"
