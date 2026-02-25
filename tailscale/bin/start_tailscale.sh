#!/bin/sh
/mnt/us/extensions/tailscale/bin/tailscale up --ssh --auth-key=$(cat /mnt/us/extensions/tailscale/bin/auth.key)> tailscale_start_log.txt 2>&1

