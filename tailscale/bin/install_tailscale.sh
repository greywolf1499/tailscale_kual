#!/bin/sh

INSTALL_DIR=/mnt/us/extensions/tailscale/bin
TMP_DIR=/tmp/ts_install
LOG=$INSTALL_DIR/install_log.txt
ARCH=arm

echo "[$(date)] Starting install..." > "$LOG"

# Resolve the latest release tag from the GitHub API
LATEST=$(wget -qO- "https://api.github.com/repos/tailscale/tailscale/releases/latest" 2>>"$LOG" \
    | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "Could not determine latest version. Check network connectivity." >> "$LOG"
    exit 1
fi
echo "Latest version: $LATEST" >> "$LOG"

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

# Install binaries
cp "$EXTRACTED/tailscale"  "$INSTALL_DIR/tailscale"  && chmod +x "$INSTALL_DIR/tailscale"
cp "$EXTRACTED/tailscaled" "$INSTALL_DIR/tailscaled" && chmod +x "$INSTALL_DIR/tailscaled"

rm -rf "$TMP_DIR"
echo "Installed version $LATEST." >> "$LOG"

# Create an empty auth.key if one is not already present
if [ ! -f "$INSTALL_DIR/auth.key" ]; then
    touch "$INSTALL_DIR/auth.key"
    echo "Created empty auth.key — fill it in before starting Tailscale." >> "$LOG"
fi
