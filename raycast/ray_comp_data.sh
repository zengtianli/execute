#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Compare Data
# @raycast.mode fullOutput
# @raycast.icon 📊
# @raycast.packageName Custom
# @raycast.description Compare two selected Excel files using compare_data.py script.

# Get selected files in Finder
SELECTED_FILES=$(osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    if (count of selectedItems) = 2 then
        set fileList to ""
        repeat with i from 1 to count of selectedItems
            set currentItem to item i of selectedItems
            set currentPath to POSIX path of (currentItem as alias)
            if i > 1 then
                set fileList to fileList & "
"
            end if
            set fileList to fileList & currentPath
        end repeat
        return fileList
    else
        return ""
    end if
end tell
EOF
)

# Check if exactly two files are selected
if [ -z "$SELECTED_FILES" ]; then
    echo "❌ Please select exactly two Excel files in Finder"
    exit 1
fi

# Convert the output into an array
IFS=$'\n' read -r -d '' -a FILES <<< "$SELECTED_FILES"

# Run the Python script with absolute paths
/Users/tianli/miniforge3/bin/python3 /Users/tianli/useful_scripts/execute/compare/compare_data.py "${FILES[0]}" "${FILES[1]}"

# Notify via Raycast echo
echo "✅ Compared data for:"
echo "1. $(basename "${FILES[0]}")"
echo "2. $(basename "${FILES[1]}")"
