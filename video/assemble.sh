#!/bin/zsh
# Builds video/build/AirBack-launch-v1.mp4 from the takes and cards.
# Usage: ./assemble.sh            (uses the in-points below)
set -eu
V=/Users/gamalier/Desktop/PROJECTS/airplay-receiver-eval/video
B=$V/build; C=$V/cards; S=$V/src
mkdir -p $B/seg
cd $V

TAKE1=${TAKE1:-$S/take1c.mp4}
TAKE2=${TAKE2:-$S/take2-settings.mp4}
# in-points (seconds) inside TAKE1, set after reviewing the contact sheet
T_CONNECT=${T_CONNECT:-5}      # a few seconds before AirBack comes forward
T_SAFARI=${T_SAFARI:-40}       # Safari visible on the TV
T_QT=${T_QT:-52}               # QuickTime playing on the TV
T_RETURN=${T_RETURN:-66}       # a second before the disconnect

FPS=30
enc=(-c:v libx264 -preset medium -crf 18 -pix_fmt yuv420p -r $FPS -an)

# card segment: still PNG with a slow push-in and fades
card(){ # name png dur
  local n=$1 png=$2 d=$3
  ffmpeg -loglevel error -y -loop 1 -framerate $FPS -i "$png" -t $d \
    -vf "scale=1920:1080,zoompan=z='1+0.025*on/($FPS*$d)':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':d=1:s=1920x1080:fps=$FPS,fade=t=in:d=0.4,fade=t=out:st=$((d-0.4)):d=0.4" \
    $enc "$B/seg/$n.mp4"
}
# footage segment with a caption overlay
clip(){ # name input start dur caption [prefilter]
  local n=$1 in=$2 ss=$3 d=$4 cap=$5 pre=${6:-null}
  ffmpeg -loglevel error -y -ss $ss -t $d -i "$in" -loop 1 -framerate $FPS -t $d -i "$cap" \
    -filter_complex "[0:v]$pre,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=$FPS,tpad=stop_mode=clone:stop_duration=${d}[v];[1:v]format=rgba,fade=t=in:st=0.5:d=0.5:alpha=1,fade=t=out:st=$((d-1.0)):d=0.5:alpha=1[c];[v][c]overlay=shortest=1,fade=t=in:d=0.3,fade=t=out:st=$((d-0.3)):d=0.3" \
    -t $d $enc "$B/seg/$n.mp4"
}
# still frame (PNG) with caption and push-in
still(){ # name png dur caption
  local n=$1 png=$2 d=$3 cap=$4
  ffmpeg -loglevel error -y -loop 1 -framerate $FPS -i "$png" -t $d -loop 1 -framerate $FPS -t $d -i "$cap" \
    -filter_complex "[0:v]scale=1920:1080,zoompan=z='1+0.03*on/($FPS*$d)':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':d=1:s=1920x1080:fps=${FPS}[v];[1:v]format=rgba,fade=t=in:st=0.5:d=0.5:alpha=1,fade=t=out:st=$((d-1.0)):d=0.5:alpha=1[c];[v][c]overlay=shortest=1,fade=t=in:d=0.3,fade=t=out:st=$((d-0.3)):d=0.3" \
    -t $d $enc "$B/seg/$n.mp4"
}

card  01 $C/c01-line.png 4.5
card  02 $C/c02-title.png 5
still 03 $S/tv-now.png 8 $C/c03.png
clip  04 $TAKE1 $T_CONNECT 7 $C/c04.png
card  05 $C/c05-steps.png 7.5
# the AirPlay stream from the Mac carries a green band at the bottom edge; crop it away
MACCROP="crop=1920:1050:0:0"
clip  06a $TAKE1 $T_SAFARI 7 $C/c06.png $MACCROP
clip  06b $TAKE1 $T_QT 7 $C/c06.png $MACCROP
clip  07 $TAKE1 $T_RETURN 8 $C/c07.png
clip  08 $TAKE2 0 8 $C/c08.png
card  09 $C/c09-line.png 7
card  10 $C/c10-end.png 7

printf "file '%s'\n" $B/seg/01.mp4 $B/seg/02.mp4 $B/seg/03.mp4 $B/seg/04.mp4 $B/seg/05.mp4 $B/seg/06a.mp4 $B/seg/06b.mp4 $B/seg/07.mp4 $B/seg/08.mp4 $B/seg/09.mp4 $B/seg/10.mp4 > $B/seg/list.txt
ffmpeg -loglevel error -y -f concat -safe 0 -i $B/seg/list.txt -c copy $B/seg/video-only.mp4
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 $B/seg/video-only.mp4)
echo "picture: $DUR s"
ffmpeg -loglevel error -y -i $B/seg/video-only.mp4 -i $S/bed-78s.wav \
  -filter_complex "[1:a]atrim=0:$DUR,afade=t=out:st=$((DUR-5)):d=5,volume=0.8[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -movflags +faststart -shortest $B/AirBack-launch-v1.mp4
ffprobe -v error -show_entries format=duration:stream=codec_name,width,height -of csv=p=0 $B/AirBack-launch-v1.mp4
echo done
