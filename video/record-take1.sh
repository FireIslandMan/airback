#!/bin/zsh
# Take 1: a cast video on the TV -> Mac connects (AirBack comes forward) -> Safari + QuickTime on the TV -> disconnect -> TV returns to the video.
set -u
V=/Users/gamalier/Desktop/PROJECTS/airplay-receiver-eval/video
S=/private/tmp/claude-501/-Users-gamalier-Desktop-PROJECTS/8afe4516-0d1d-4cfd-8995-f257284ec3db/scratchpad
CATT=$S/cattenv/bin/catt
ADB=~/Library/Android/sdk/platform-tools/adb
TV=192.168.40.110:5555
OUT=${1:-take1c}
t(){ "$ADB" -s $TV "$@"; }
log(){ echo "[$(date +%H:%M:%S)] $*"; }
screens(){ swift -e 'import AppKit; for s in NSScreen.screens { print(s.localizedName, s.frame) }' 2>/dev/null; }
mirrored(){ system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Mirror: On"; }
tv_attached(){ system_profiler SPDisplaysDataType 2>/dev/null | grep -q "Living Room TV"; }

# a renamed copy so catt does not pick up the sidecar subtitles
mkdir -p $S/cast; [ -e $S/cast/tape2.mp4 ] || ln "/Users/gamalier/Desktop/PROJECTS/AI-VIDEO-PRODUCTION/IGUACA/IGUACA-E02-roughcut-v7b.mp4" $S/cast/tape2.mp4

log "park AirBack on its Overview tab"
t shell am start -n com.airback/.MainActivity >/dev/null 2>&1; sleep 3
t shell input keyevent KEYCODE_DPAD_DOWN; sleep 0.5; t shell input keyevent KEYCODE_DPAD_LEFT; sleep 0.4; t shell input keyevent KEYCODE_DPAD_LEFT; sleep 0.4; t shell input keyevent KEYCODE_DPAD_CENTER; sleep 1.5
t shell input keyevent KEYCODE_HOME; sleep 2
log "cast the video to the TV"
( cd $S/cast && nohup "$CATT" -d 192.168.40.110 cast tape2.mp4 --seek-to 300 > $S/catt.log 2>&1 & )
sleep 18
log "start screenrecord"
( t shell screenrecord --time-limit 150 --bit-rate 14000000 /sdcard/$OUT.mp4 & )
sleep 7
log "connect"
"$V/tvtoggle.sh" | tail -1
for i in $(seq 1 10); do
  sleep 2
  if tv_attached; then break; fi
done
log "attached after $((i*2)) s"
if mirrored; then
  log "came up mirrored; stopping mirroring"
  "$V/axpop" com.apple.systempreferences AXPopUpButton list
  "$V/axpop" com.apple.systempreferences AXPopUpButton find "Stop Mirroring" | grep -E "picked|no popup"
  for i in $(seq 1 8); do
    sleep 2
    if screens | grep -q "Living Room TV"; then break; fi
  done
fi
screens
log "Safari on the TV"
osascript <<'AS'
tell application "Safari"
  activate
  make new document with properties {URL:"https://fajardorentals.com"}
  delay 1
  set bounds of front window to {-1920, 0, 0, 1080}
  delay 4
  set URL of current tab of front window to "https://fajardorentals.com"
end tell
AS
sleep 12
log "QuickTime on the TV"
open -a "QuickTime Player" "/Users/gamalier/Desktop/PROJECTS/AI-VIDEO-PRODUCTION/IGUACA/IGUACA-E02-roughcut-v7b.mp4"
sleep 3
osascript <<'AS'
tell application "QuickTime Player"
  set d to front document
  set bounds of front window to {-1920, 0, 0, 1080}
  set current time of d to 352
  set audio volume of d to 0
  delay 1
  present d
  play d
end tell
AS
sleep 11
log "close QuickTime and Safari"
osascript -e 'tell application "QuickTime Player" to close every document saving no' 2>/dev/null
osascript -e 'tell application "Safari" to close (every window whose URL of current tab contains "fajardorentals.com")' 2>/dev/null
sleep 1
log "disconnect"
"$V/tvtoggle.sh" | tail -1
sleep 9
log "stop recording"
t shell pkill -INT screenrecord
sleep 4
t pull /sdcard/$OUT.mp4 "$V/src/$OUT.mp4"
ffprobe -v error -show_entries format=duration -of csv=p=0 "$V/src/$OUT.mp4"
"$CATT" -d 192.168.40.110 stop >/dev/null 2>&1
pkill -f "catt -d 192.168.40.110 cast" 2>/dev/null
screens
log "done"
