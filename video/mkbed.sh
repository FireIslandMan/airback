#!/bin/zsh
# mkbed.sh <out.wav> <t_arp> <t_beat> <t_lead_a> <t_lead_b> <t_break_a> <t_break_b> <t_end>
# Arranged bed from the Apple Loops "Afloat" family plus two soft synthesized swells:
#   pad from 0, arp enters at t_arp, beat enters at t_beat (with a swell), lead under t_lead_a..t_lead_b,
#   breakdown (beat out, arp down) t_break_a..t_break_b with a soft swell at t_break_a, fade out before t_end.
set -eu
S=/Users/gamalier/Desktop/PROJECTS/airplay-receiver-eval/video/src
out=$1; TA=$2; TB=$3; TLA=$4; TLB=$5; TKA=$6; TKB=$7; TE=$8
LEN=$(python3 -c "print($TE+2)")
ffmpeg -loglevel error -y \
  -stream_loop 6 -i $S/loop-afloat-pad.wav -stream_loop 6 -i $S/loop-afloat-synth-arp.wav \
  -stream_loop 6 -i $S/loop-afloat-beat.wav -stream_loop 6 -i $S/loop-afloat-synth-lead.wav \
  -f lavfi -i "anoisesrc=color=pink:r=48000:a=0.6:d=$LEN" \
  -filter_complex "
[0:a]atrim=0:$LEN,volume=0.85,afade=t=in:d=2[pad];
[1:a]atrim=0:$LEN,volume=0.5,volume='if(lt(t,$TA),0,1)*if(between(t,$TKA,$TKB),0.4,1)':eval=frame,afade=t=in:st=$TA:d=1.5[arp];
[2:a]atrim=0:$LEN,volume=0.55,volume='if(lt(t,$TB),0,1)*if(between(t,$TKA,$TKB),0,1)*if(gt(t,$TE-9),0,1)':eval=frame[beat];
[3:a]atrim=0:$LEN,volume=0.26,volume='if(between(t,$TLA,$TLB),1,0)':eval=frame,afade=t=in:st=$TLA:d=1.5,afade=t=out:st=$((TLB-2)):d=2[lead];
[4:a]highpass=f=400,lowpass=f=6000,volume='0.0+0.5*(between(t,$TB-1.2,$TB)*((t-($TB-1.2))/1.2)^2)+0.3*(between(t,$TKA-0.9,$TKA)*((t-($TKA-0.9))/0.9)^2)':eval=frame,asetpts=PTS-STARTPTS[sw];
[pad][arp][beat][lead][sw]amix=inputs=5:normalize=0,highpass=f=35,alimiter=limit=0.85:level=false,afade=t=out:st=$((TE-6)):d=6,atrim=0:${TE}[a]" \
  -map "[a]" -ar 48000 "$out"
echo "bed $out $(ffprobe -v error -show_entries format=duration -of csv=p=0 "$out") s"
