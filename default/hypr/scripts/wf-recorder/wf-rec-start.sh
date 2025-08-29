#!/usr/bin/env bash
# generate a timestamped filename
outfile="$HOME/Videos/recordings/$(date '+%Y-%m-%d_%H-%M-%S').mp4"
# start recording in background
wf-recorder --audio --framerate 60 -f "$outfile" &
# record the PID so we can stop it
echo $! > "$HOME/.cache/wf-recorder.pid"
# optional notification
notify-send "Screen recording started" "$outfile"
