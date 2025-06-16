#!/bin/bash
# Process multiple prompt files in sequence

PROMPT_DIR="${1:-/workspace/prompts}"

if [ ! -d "$PROMPT_DIR" ]; then
    echo "Prompt directory '$PROMPT_DIR' not found"
    exit 1
fi

echo "Processing prompts from: $PROMPT_DIR"
echo "======================================="

for prompt_file in "$PROMPT_DIR"/*.txt; do
    if [ -f "$prompt_file" ]; then
        echo ""
        echo "Processing: $(basename "$prompt_file")"
        echo "-----------------------------------"
        amp chat < "$prompt_file"
        echo "==================================="
    fi
done
