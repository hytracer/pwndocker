#!/bin/bash

mode="$1"

echo "[*] Starting SSH service..."
service ssh start

if [[ "$mode" == "interactive" ]]; then
    echo "[*] Launching tmux session..."
    exec tmux
else
    echo "[*] Running in background mode. SSH should be available on port 2222."
    tail -f /dev/null
fi
