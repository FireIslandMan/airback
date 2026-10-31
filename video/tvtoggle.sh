#!/bin/zsh
# toggles the Living Room TV entry in System Settings > Displays "+" (Add) menu
cd "$(dirname "$0")"
open "x-apple.systempreferences:com.apple.Displays-Settings.extension"
sleep 1
./axpop com.apple.systempreferences AXMenuButton 0 "Living Room TV"
