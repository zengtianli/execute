#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Run File
# @raycast.mode silent
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description Run selected shell or python script

# Path to Python executable
PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"

# Set QT plugin path for PyQt applications

# Get selected file in Finder
SELECTED_FILE=$(osascript -e '
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    end if
end tell
')

# Check if a file is selected
if [ -z "$SELECTED_FILE" ]; then
    echo "❌ No file selected in Finder"
    exit 1
fi

# Get file extension
FILE_EXT="${SELECTED_FILE##*.}"

# Check if it's a shell script or python file
if [ "$FILE_EXT" = "sh" ] || [ "$FILE_EXT" = "py" ]; then
    # For shell scripts, make sure they are executable
    if [ "$FILE_EXT" = "sh" ] && [ ! -x "$SELECTED_FILE" ]; then
        chmod +x "$SELECTED_FILE"
    fi
    
    # Get the directory of the script
    SCRIPT_DIR=$(dirname "$SELECTED_FILE")
    
    # Change to the script's directory and run it
    cd "$SCRIPT_DIR"
    if [ "$FILE_EXT" = "py" ]; then
        output=$("$PYTHON_PATH" "$SELECTED_FILE" 2>&1)
    else
        output=$("$SELECTED_FILE" 2>&1)
    fi
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ Successfully ran $(basename "$SELECTED_FILE")"
        echo "Output:"
        echo "$output"
    else
        echo "❌ Error running $(basename "$SELECTED_FILE")"
        echo "Error output:"
        echo "$output"
        exit 1
    fi
else
    echo "❌ Selected file is not a shell script or python file"
    exit 1
fi
