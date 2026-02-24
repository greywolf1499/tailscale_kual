#!/bin/sh

TAILSCALE=/mnt/us/extensions/tailscale/bin/tailscale
AUTH_KEY=/mnt/us/extensions/tailscale/bin/auth.key
LOG=/mnt/us/extensions/tailscale/bin/tailscale_start_log.txt

# Try bringing up without re-authenticating first.
# This works if the node is already registered and key expiry is disabled.
"$TAILSCALE" up > "$LOG" 2>&1 && exit 0

# Fall back to auth key for first-time registration or after a manual reset.
if [ -s "$AUTH_KEY" ]; then
    "$TAILSCALE" up --auth-key="$(cat "$AUTH_KEY")" >> "$LOG" 2>&1
else
    echo "tailscale up failed and auth.key is empty. Fill in auth.key and try again." >> "$LOG"
    exit 1
fi

