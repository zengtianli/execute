#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Ghostty
# @raycast.mode fullOutput
# @raycast.icon 👻
# @raycast.packageName Custom
# @raycast.description Open Ghostty in current Finder directory

# Get selected directory in Finder
CURRENT_DIR=$(osascript -e '
tell application "Finder"
    if (count of (selection as list)) > 0 then
        if class of (item 1 of (selection as list)) is folder then
            POSIX path of (item 1 of (selection as list) as alias)
        else
            POSIX path of (container of (item 1 of (selection as list)) as alias)
        end if
    else
        POSIX path of (insertion location as alias)
    end if
end tell
')

# Open new Ghostty window
osascript -e '
tell application "Ghostty"
    activate
    tell application "System Events"
        keystroke "n" using command down
    end tell
end tell
'

# Wait a bit for new window to open
sleep 1

# Change directory in the new window using clipboard paste
COMMAND="cd \"${CURRENT_DIR}\""
COMMAND_ESCAPED=$(printf "%s" "$COMMAND" | sed 's/\"/\\\"/g')
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

# Optional: Show notification that Ghostty was opened
echo "✅ Ghostty opened in $(basename "$CURRENT_DIR")"
