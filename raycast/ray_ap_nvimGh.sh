#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Nvim in Ghostty
# @raycast.mode silent
# @raycast.icon 👻
# @raycast.packageName Custom
# @raycast.description Open selected file in Nvim in a new Ghostty window
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
    echo "No file selected in Finder"
    exit 1
fi
FILE_DIR=$(dirname "$SELECTED_FILE")
osascript <<'EOF'
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "n" using command down
    end tell
end tell
EOF
# 等待 1 秒钟让窗口打开
sleep 1
COMMAND="cd \"${FILE_DIR}\" && nvim \"${SELECTED_FILE}\""
COMMAND_ESCAPED=$(printf "%s" "$COMMAND" | sed 's/"/\\"/g')
osascript <<EOF
tell application "Ghostty"
    activate
    delay 0.2
    set the clipboard to "$COMMAND_ESCAPED"
    tell application "System Events"
       keystroke "v" using command down
       delay 0.1
       key code 36
    end tell
end tell
EOF
# 显示通知
echo "✅ Opened $(basename "$SELECTED_FILE") in Nvim"
