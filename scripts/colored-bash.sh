#!/bin/bash
# Colored bash setup for Amp instances

INSTANCE_NUM=${1:-1}

# Define colors for each instance
case $INSTANCE_NUM in
    1)
        BG_COLOR="46"     # Cyan background
        COLOR_NAME="Cyan"
        ;;
    2)
        BG_COLOR="45"     # Magenta background
        COLOR_NAME="Magenta"
        ;;
    3)
        BG_COLOR="44"     # Blue background
        COLOR_NAME="Blue"
        ;;
    *)
        BG_COLOR="40"     # Default black background
        COLOR_NAME="Default"
        ;;
esac

# Display welcome banner
echo -e "\033[${BG_COLOR};30m"
echo "════════════════════════════════════════════════════════════════"
echo "  🚀 AMP INSTANCE $INSTANCE_NUM - $COLOR_NAME Background"
echo "════════════════════════════════════════════════════════════════"
echo -e "\033[0m"

# Set colored prompt
export PS1="\[\033[${BG_COLOR};30m\][\u@amp-${INSTANCE_NUM} \W]\$ \[\033[0m\]"

# Start interactive bash
exec bash
