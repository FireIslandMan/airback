#!/bin/zsh
# v2: crossfaded segments, arranged soundtrack, Veo clips for the iPhone beat and the live-TV return.
set -eu
V=/Users/gamalier/Desktop/PROJECTS/airplay-receiver-eval/video
B=$V/build; C=$V/cards; S=$V/src
mkdir -p $B/seg2
cd $V

TAKE1=${TAKE1:-$S/take1d.mp4}      # Safari + QuickTime beats
TAKE4=${TAKE4:-$S/take4.mp4}       # connect (Overview) + return beats
TAKE2=${TAKE2:-$S/take2-settings.mp4}
VEO_PHONE=${VEO_PHONE:-$S/veo-phone.mp4}
VEO_TV=${VEO_TV:-$S/veo-tv.mp4}
T_CONNECT=${T_CONNECT:-5}; T_SAFARI=${T_SAFARI:-29.5}; T_QT=${T_QT:-42}; T_RETURN=${T_RETURN:-20}
XF=0.6   # crossfade length
FPS=30
enc=(-c:v libx264 -preset medium -crf 17 -pix_fmt yuv420p -r $FPS -an)
MACCROP="crop=1920:1040:0:0,scale=1920:1080"

# every segment is rendered WITHOUT fades; xfade handles the joins
card(){ local n=$1 png=$2 d=$3
  ffmpeg -loglevel error -y -loop 1 -framerate $FPS -i "$png" -t $d \
    -vf "scale=1920:1080,zoompan=z='1+0.025*on/($FPS*$d)':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':d=1:s=1920x1080:fps=$FPS" $enc "$B/seg2/$n.mp4"; }
clip(){ local n=$1 in=$2 ss=$3 d=$4 cap=$5 pre=${6:-crop=1920:1064:0:0,scale=1920:1080}
  ffmpeg -loglevel error -y -ss $ss -t $d -i "$in" -loop 1 -framerate $FPS -t $d -i "$cap" \
    -filter_complex "[0:v]$pre,scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1,fps=$FPS,tpad=stop_mode=clone:stop_duration=${d}[v];[1:v]format=rgba,fade=t=in:st=0.7:d=0.5:alpha=1,fade=t=out:st=$((d-1.2)):d=0.5:alpha=1[c];[v][c]overlay=shortest=1" \
    -t $d $enc "$B/seg2/$n.mp4"; }
still(){ local n=$1 png=$2 d=$3 cap=$4
  ffmpeg -loglevel error -y -loop 1 -framerate $FPS -i "$png" -t $d -loop 1 -framerate $FPS -t $d -i "$cap" \
    -filter_complex "[0:v]scale=1920:1080,zoompan=z='1+0.03*on/($FPS*$d)':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':d=1:s=1920x1080:fps=${FPS}[v];[1:v]format=rgba,fade=t=in:st=0.7:d=0.5:alpha=1,fade=t=out:st=$((d-1.2)):d=0.5:alpha=1[c];[v][c]overlay=shortest=1" \
    -t $d $enc "$B/seg2/$n.mp4"; }

# segment list: name, duration (durations include XF overlap on each join)
segs=()
add(){ segs+=("$1:$2"); }
card  01 $C/c01-line.png 5;                                   add 01 5
card  02 $C/c02-title.png 5.5;                                add 02 5.5
still 03 $S/tv-now.png 8 $C/c03.png;                          add 03 8
clip  04 $TAKE4 $T_CONNECT 7.5 $C/c04.png;                    add 04 7.5
if [ -f "$VEO_PHONE" ]; then clip 05 $VEO_PHONE 0.8 8.5 $C/c05.png null; add 05 8.5; else card 05 $C/c05-steps.png 7.5; add 05 7.5; fi
clip  06a $TAKE1 $T_SAFARI 7 $C/c06.png $MACCROP;             add 06a 7
clip  06b $TAKE1 $T_QT 7 $C/c06b.png $MACCROP;                 add 06b 7
clip  07 $TAKE4 $T_RETURN 7.5 $C/c07.png;                     add 07 7.5
if [ -f "$VEO_TV" ]; then clip 07b $VEO_TV 1.5 7.5 $C/c07b.png null; add 07b 7.5; fi
clip  08 $TAKE2 0 8 $C/c08.png;                               add 08 8
card  09 $C/c09-line.png 7;                                   add 09 7
card  10 $C/c10-end.png 8;                                    add 10 8

# chain xfades
inputs=(); filt=""; prev=""; offset=0; i=0
typeset -A START; cur=0
for s in $segs; do
  n=${s%%:*}; d=${s##*:}
  inputs+=(-i "$B/seg2/$n.mp4")
  START[$n]=$cur; cur=$(python3 -c "print(round($cur + $d - $XF, 3))")
  if [ -z "$prev" ]; then prev="[0:v]"; offset=$d; i=1; continue; fi
  offset=$(python3 -c "print(round($offset - $XF, 3))")
  out="[x$i]"
  filt+="${prev}[$i:v]xfade=transition=fade:duration=$XF:offset=$offset${out};"
  prev=$out; offset=$(python3 -c "print(round($offset + $d, 3))"); i=$((i+1))
done
filt+="${prev}fade=t=in:d=0.6,fade=t=out:st=$(python3 -c "print(round($offset-1.0,3))"):d=1.0,format=yuv420p[vout]"
ffmpeg -loglevel error -y "${inputs[@]}" -filter_complex "$filt" -map "[vout]" -c:v libx264 -preset slow -crf 17 -pix_fmt yuv420p -r $FPS -an $B/seg2/video-only.mp4
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 $B/seg2/video-only.mp4)
echo "picture: $DUR s"
# soundtrack marks from the real segment starts
T_ARP=${START[02]}; T_BEAT=$(python3 -c "print(${START[04]}+5.0)"); T_LA=${START[06a]}; T_LB=${START[07]}
T_KA=$(python3 -c "print(${START[07]}+3.5)"); T_KB=${START[08]}
./mkbed.sh $S/bed-v2.wav $T_ARP $T_BEAT $T_LA $T_LB $T_KA $T_KB $DUR
ffmpeg -loglevel error -y -i $B/seg2/video-only.mp4 -i $S/bed-v2.wav \
  -filter_complex "[1:a]atrim=0:$DUR,afade=t=out:st=$((DUR-5)):d=5,loudnorm=I=-16:TP=-1.5:LRA=11[a]" \
  -map 0:v -map "[a]" -c:v copy -c:a aac -b:a 192k -movflags +faststart -shortest $B/AirBack-launch-v2.mp4
ffprobe -v error -show_entries format=duration -of csv=p=0 $B/AirBack-launch-v2.mp4
echo done
