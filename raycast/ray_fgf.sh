#!/bin/bash

# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title FZF Goto Folder
# @raycast.mode fullOutput
# @raycast.icon 🔍
# @raycast.packageName Navigation
# @raycast.description Use FZF to find and open directories in Finder

# Check if fzf is installed
if ! command -v fzf &> /dev/null; then
    echo "❌ FZF is not installed. Please install it with 'brew install fzf'"
    exit 1
fi

# Set temporary file for fzf output
TEMP_FILE=$(mktemp)

# Use find to list directories and pipe to fzf
# The --height option limits the height of the fzf window
# Preview shows directory contents
find $HOME -type d -not -path "*/\.*" -not -path "*/node_modules/*" -not -path "*/.git/*" 2>/dev/null | \
fzf --height 50% --reverse --preview 'ls -la {}' > "$TEMP_FILE"

# Get the selected directory from the temp file
SELECTED_DIR=$(cat "$TEMP_FILE")
rm "$TEMP_FILE"

# Check if a directory was selected
if [[ -n "$SELECTED_DIR" ]]; then
    # Open the directory in Finder
    open -a Finder "$SELECTED_DIR"
    echo "✅ Opened in Finder: $SELECTED_DIR"
else
    echo "❌ No directory selected"
fi

