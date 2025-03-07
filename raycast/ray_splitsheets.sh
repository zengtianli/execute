#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Split Excel Sheets
# @raycast.mode silent
# @raycast.icon 📂
# @raycast.packageName Custom
# @raycast.description Split the selected Excel file into separate sheets

# Get selected file in Finder
SELECTED_FILE=$(osascript <<'EOF'
tell application "Finder"
    if (count of (selection as list)) = 1 then
        set selectedItem to item 1 of (selection as list)
        POSIX path of (selectedItem as alias)
    else
        return ""
    end if
end tell
EOF
)

# Check if exactly one file is selected
if [ -z "$SELECTED_FILE" ]; then
    echo "❌ Please select one Excel file in Finder"
    exit 1
fi

# Get the directory of the selected file
FILE_DIR=$(dirname "$SELECTED_FILE")

# Change to the file's directory
cd "$FILE_DIR"

# Run the splitsheets.py script with absolute path
/Users/tianli/miniforge3/bin/python3 /Users/tianli/useful_scripts/execute/splitsheets.py "$SELECTED_FILE"

# Notify via Raycast echo
echo "✅ Excel sheets split for '$(basename "$SELECTED_FILE")'"

