#!/bin/sh
# Requires kernel TUN/TAP support. Not available on all Kindle firmware versions.
nohup /mnt/us/extensions/tailscale/bin/tailscaled --statedir=/mnt/us/extensions/tailscale/bin/ -no-logs-no-support > tailscaled_start_log.txt 2>&1 &
