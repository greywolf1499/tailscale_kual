#!/bin/sh
nohup /mnt/us/extensions/tailscale/bin/tailscaled --statedir=/mnt/us/extensions/tailscale/bin/ -tun userspace-networking -no-logs-no-support --socks5-server=localhost:1055 --outbound-http-proxy-listen=localhost:1055 > tailscaled_start_log.txt 2>&1 &
