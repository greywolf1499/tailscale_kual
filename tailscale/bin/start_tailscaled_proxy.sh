#!/bin/sh

BIN=/mnt/us/extensions/tailscale/bin
PROXY_ADDR_FILE=$BIN/proxy.address
LOG=$BIN/tailscaled_proxy_start_log.txt

# Read proxy address from config file, default to localhost:1055
if [ -s "$PROXY_ADDR_FILE" ]; then
    PROXY_ADDR=$(cat "$PROXY_ADDR_FILE")
else
    PROXY_ADDR=localhost:1055
fi

nohup "$BIN/tailscaled" --statedir="$BIN/" -tun userspace-networking --socks5-server="$PROXY_ADDR" --outbound-http-proxy-listen="$PROXY_ADDR" > "$LOG" 2>&1 &
