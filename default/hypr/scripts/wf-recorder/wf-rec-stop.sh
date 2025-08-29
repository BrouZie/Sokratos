#!/usr/bin/env bash
pidfile="$HOME/.cache/wf-recorder.pid"
if [[ -f $pidfile ]]; then
  pid=$(<"$pidfile")
  kill -SIGINT "$pid"       # gracefully stop recording
  rm "$pidfile"
  notify-send "Screen recording stopped"
else
  notify-send "No wf-recorder process found"
fi
