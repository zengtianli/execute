#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Run Files in Parallel
# @raycast.mode fullOutput
# @raycast.icon 🚀
# @raycast.packageName Custom
# @raycast.description Run multiple selected shell or python scripts in parallel

# Path to Python executable
PYTHON_PATH="/Users/tianli/miniforge3/bin/python3"

# Get all selected files in Finder
SELECTED_FILES=$(osascript -e '
tell application "Finder"
    set selectedItems to selection as list
    set fileList to ""
    repeat with theItem in selectedItems
        set fileList to fileList & POSIX path of (theItem as alias) & "\n"
    end repeat
    return fileList
end tell
')

# Check if any files are selected
if [ -z "$SELECTED_FILES" ]; then
    echo "❌ No files selected in Finder"
    exit 1
fi

# Create a temporary directory for log files
TEMP_DIR=$(mktemp -d)
FILE_COUNT=0
VALID_COUNT=0

# Array to store process IDs
declare -a PIDS=()

# Function to run a single file and capture its output
run_file() {
    local file="$1"
    local file_ext="${file##*.}"
    local log_file="$TEMP_DIR/$(basename "$file").log"
    local success_log="$TEMP_DIR/$(basename "$file").success"
    
    # Check if it's a shell script or python file
    if [ "$file_ext" = "sh" ] || [ "$file_ext" = "py" ]; then
        # For shell scripts, make sure they are executable
        if [ "$file_ext" = "sh" ] && [ ! -x "$file" ]; then
            chmod +x "$file"
        fi
        
        # Get the directory of the script
        local script_dir=$(dirname "$file")
        
        # Run the file in its directory and capture output
        (
            cd "$script_dir"
            if [ "$file_ext" = "py" ]; then
                "$PYTHON_PATH" "$file" > "$log_file" 2>&1
            else
                "$file" > "$log_file" 2>&1
            fi
            
            # Store exit code
            echo $? > "$success_log"
        ) &
        
        # Return the process ID
        echo $!
    else
        echo "❌ File $(basename "$file") is not a shell script or python file" > "$log_file"
        echo "1" > "$success_log"
        echo "0" # Return dummy PID
    fi
}

# Process each selected file
while IFS= read -r file; do
    # Skip empty lines
    if [ -z "$file" ]; then
        continue
    fi
    
    FILE_COUNT=$((FILE_COUNT + 1))
    
    # Get file extension
    FILE_EXT="${file##*.}"
    
    # Check if it's a valid file type
    if [ "$FILE_EXT" = "sh" ] || [ "$FILE_EXT" = "py" ]; then
        VALID_COUNT=$((VALID_COUNT + 1))
        pid=$(run_file "$file")
        if [ "$pid" != "0" ]; then
            PIDS+=("$pid")
        fi
    else
        echo "❌ File $(basename "$file") is not a shell script or python file"
    fi
done <<< "$SELECTED_FILES"

echo "🚀 Started running $VALID_COUNT/$FILE_COUNT files in parallel..."

# Wait for all processes to finish
for pid in "${PIDS[@]}"; do
    if [ "$pid" != "0" ]; then
        wait "$pid"
    fi
done

# Display results for each file
echo ""
echo "📊 Results:"
echo "========================================"

while IFS= read -r file; do
    # Skip empty lines
    if [ -z "$file" ]; then
        continue
    fi
    
    base_name=$(basename "$file")
    log_file="$TEMP_DIR/$base_name.log"
    success_log="$TEMP_DIR/$base_name.success"
    
    if [ -f "$success_log" ]; then
        exit_code=$(cat "$success_log")
        
        if [ "$exit_code" = "0" ]; then
            echo "✅ Successfully ran $base_name"
        else
            echo "❌ Error running $base_name"
        fi
        
        echo "Output:"
        cat "$log_file"
        echo "========================================"
    fi
done <<< "$SELECTED_FILES"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

# Summary
echo ""
echo "💡 完成运行 $VALID_COUNT 个文件"
