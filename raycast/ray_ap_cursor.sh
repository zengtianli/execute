#!/bin/bash
# Raycast parameters
# @raycast.schemaVersion 1
# @raycast.title Cursor
# @raycast.mode silent
# @raycast.icon 🏄‍♂️
# @raycast.packageName Custom
# @raycast.description Open Cursor in current Finder directory
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
# Open Cursor
open -a Cursor .

# Optional: Show notification that Cursor was opened
echo "✅ Cursor opened in $(basename "$CURRENT_DIR")"
