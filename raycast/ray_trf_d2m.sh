#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title d2m
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description Convert selected file to markdown using docxmark

# Get selected file in Finder
SELECTED_FILE=$(osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) > 0 then
        POSIX path of (item 1 of (selection as list) as alias)
    end if
end tell
EOF
)

if [ -z "$SELECTED_FILE" ]; then
    echo "❌ No file selected in Finder"
    exit 1
fi

# Get the directory of the selected file
FILE_DIR=$(dirname "$SELECTED_FILE")

# Change to the file's directory
cd "$FILE_DIR"

# Run the conversion
/Users/tianli/miniforge3/bin/python3 /Users/tianli/bendownloads/mark_docx/src/docxmark_1.py "$SELECTED_FILE"

# Show success notification
echo "✅ Converted $(basename "$SELECTED_FILE") to markdown in $(basename "$FILE_DIR")"


