#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Windsurf
# @raycast.mode silent
# @raycast.icon 🏄‍♂️
# @raycast.packageName Custom
# @raycast.description Open Windsurf in current Finder directory
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
# Change to the directory
cd "$CURRENT_DIR"
# Open Windsurf
open -a Windsurf .

# Optional: Show notification that Windsurf was opened
echo "✅ Windsurf opened in $(basename "$CURRENT_DIR")"
