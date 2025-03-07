#!/bin/sh
# Quit Raycast if it's running
if pgrep -q "Raycast"; then
  osascript -e 'quit app "Raycast"'
fi
# Wait for Raycast to fully quit
while pgrep -q "Raycast"; do
  sleep 0.5
done
# Relaunch Raycast
open -a "Raycast"


