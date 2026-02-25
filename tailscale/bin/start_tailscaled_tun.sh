#!/bin/sh
# Requires kernel TUN/TAP support. Not available on all Kindle firmware versions.

BIN=/mnt/us/extensions/tailscale/bin
LOG=$BIN/tailscaled_tun_start_log.txt

nohup "$BIN/tailscaled" --statedir="$BIN/" > "$LOG" 2>&1 &
