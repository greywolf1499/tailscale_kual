#!/bin/sh

INSTALL_DIR=/mnt/us/extensions/tailscale/bin
TMP_DIR=/tmp/ts_update
LOG=$INSTALL_DIR/update_log.txt
ARCH=arm

echo "[$(date)] Starting update check..." > "$LOG"

# Record currently installed version
if [ -f "$INSTALL_DIR/tailscale" ]; then
    CURRENT=$("$INSTALL_DIR/tailscale" version 2>/dev/null | head -1)
else
    CURRENT="none"
fi
echo "Installed version : $CURRENT" >> "$LOG"

# Resolve the latest release tag from the GitHub API
LATEST=$(wget -qO- "https://api.github.com/repos/tailscale/tailscale/releases/latest" 2>>"$LOG" \
    | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "Could not determine latest version. Check network connectivity." >> "$LOG"
    exit 1
fi
echo "Latest version    : $LATEST" >> "$LOG"

if [ "$CURRENT" = "$LATEST" ]; then
    echo "Already up to date." >> "$LOG"
    exit 0
fi

# Download the tarball
mkdir -p "$TMP_DIR"
URL="https://pkgs.tailscale.com/stable/tailscale_${LATEST}_${ARCH}.tgz"
echo "Downloading $URL..." >> "$LOG"
wget -qO "$TMP_DIR/ts.tgz" "$URL" 2>>"$LOG"

if [ $? -ne 0 ] || [ ! -s "$TMP_DIR/ts.tgz" ]; then
    echo "Download failed." >> "$LOG"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Extract
tar -xzf "$TMP_DIR/ts.tgz" -C "$TMP_DIR" 2>>"$LOG"
EXTRACTED=$(find "$TMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -1)

if [ -z "$EXTRACTED" ]; then
    echo "Extraction failed." >> "$LOG"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Back up existing binaries before replacing
[ -f "$INSTALL_DIR/tailscale" ]  && cp "$INSTALL_DIR/tailscale"  "$INSTALL_DIR/tailscale.bak"
[ -f "$INSTALL_DIR/tailscaled" ] && cp "$INSTALL_DIR/tailscaled" "$INSTALL_DIR/tailscaled.bak"

# Install
cp "$EXTRACTED/tailscale"  "$INSTALL_DIR/tailscale"  && chmod +x "$INSTALL_DIR/tailscale"
cp "$EXTRACTED/tailscaled" "$INSTALL_DIR/tailscaled" && chmod +x "$INSTALL_DIR/tailscaled"

rm -rf "$TMP_DIR"
echo "Updated $CURRENT -> $LATEST." >> "$LOG"
