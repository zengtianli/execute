#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title xlsx2csv0
# @raycast.mode silent
# @raycast.icon 📋
# @raycast.packageName Custom
# @raycast.description Convert xlsx files to csv in current Finder directory

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
    echo "❌ 在Finder中未选择文件"
    exit 1
fi

# Get the directory of the selected file
FILE_DIR=$(dirname "$SELECTED_FILE")

# Change to the file's directory
cd "$FILE_DIR"

# Run the Python script
/Users/tianli/miniforge3/bin/python3 /Users/tianli/useful_scripts/execute/xlsx2csv.py "$SELECTED_FILE"

# Show notification
echo "✅ 已将 $(basename \"$SELECTED_FILE\") 转换为 csv 格式，保存在 $(basename \"$FILE_DIR\")"
