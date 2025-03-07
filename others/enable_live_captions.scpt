tell application "System Preferences"
    activate
    reveal anchor "Hearing" of pane id "com.apple.preference.universalaccess"
end tell

delay 1

tell application "System Events"
    tell process "System Preferences"
        click checkbox "Enable Live Captions" of tab group 1 of window 1
    end tell
end tell

tell application "System Preferences" to quit
