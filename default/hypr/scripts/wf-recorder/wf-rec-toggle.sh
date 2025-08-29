!#/usr/bin/env bash
# ~/.config/hypr/scripts/wf-recorder/wf-rec-toggle.sh

PIDFILE="$HOME/.cache/wf-recorder.pid"
OUTDIR="$HOME/Videos/recordings"

# ensure output dir exists
mkdir -p "$OUTDIR"

if [[ -f $PIDFILE ]]; then
  # if running, stop it
  pid=$(<"$PIDFILE")
  kill -SIGINT "$pid" && rm "$PIDFILE"
  notify-send "Screen recording stopped"
else
  # else start a new recording
  timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
  outfile="$OUTDIR/${timestamp}.mp4"
  wf-recorder --audio -f $outfile &
  echo $! > "$PIDFILE"
  notify-send "Screen recording started" "$outfile"
fi
