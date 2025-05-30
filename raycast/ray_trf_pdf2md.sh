#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title pdf2md
# @raycast.mode silent
# @raycast.icon 📄
# @raycast.packageName Custom
# @raycast.description Convert selected PDF files to markdown using marker_single

# 设置环境变量，确保能找到marker_single命令
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:$HOME/.local/bin:/Users/tianli/miniforge3/bin"

# Get selected files in Finder
SELECTED_FILES=$(osascript <<'EOF'
tell application "Finder"
    set selectedItems to selection as list
    set posixPaths to {}
    
    if (count of selectedItems) > 0 then
        repeat with i from 1 to count of selectedItems
            set thisItem to item i of selectedItems
            set end of posixPaths to POSIX path of (thisItem as alias)
        end repeat
        
        set AppleScript's text item delimiters to ","
        set pathsText to posixPaths as text
        set AppleScript's text item delimiters to ""
        return pathsText
    end if
end tell
EOF
)

if [ -z "$SELECTED_FILES" ]; then
    echo "❌ No files selected in Finder"
    exit 1
fi

# Split the comma-separated list of files
IFS=',' read -ra FILE_ARRAY <<< "$SELECTED_FILES"

# Counter for successful conversions
SUCCESS_COUNT=0

# Process each file
for SELECTED_FILE in "${FILE_ARRAY[@]}"; do
    # Get the directory of the selected file
    FILE_DIR=$(dirname "$SELECTED_FILE")
    
    # Check if the file is a PDF file
    if [[ "$SELECTED_FILE" != *".pdf" ]]; then
        echo "⚠️ Skipping $(basename "$SELECTED_FILE") - not a PDF file"
        continue
    fi
    
    # Change to the file's directory
    cd "$FILE_DIR"
    
    # Run the conversion using marker_single with the correct parameters
    echo "Converting $(basename "$SELECTED_FILE") to markdown"
    /Users/tianli/miniforge3/bin/marker_single "$SELECTED_FILE" --output_dir "$FILE_DIR"
    
    # Increment success counter
    ((SUCCESS_COUNT++))
done

# Show success notification
if [ $SUCCESS_COUNT -eq 1 ]; then
    echo "✅ Converted $SUCCESS_COUNT PDF file to markdown"
else
    echo "✅ Converted $SUCCESS_COUNT PDF files to markdown"
fi
