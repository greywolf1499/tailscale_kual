#!/bin/sh

INSTALL_DIR=/mnt/us/extensions/tailscale/bin
TMP_DIR=/tmp/ts_update
LOG=$INSTALL_DIR/update_log.txt
ARCH=arm

# Print a message to the Kindle screen via eips and append to the log file.
# Text is padded to 50 chars so each call fully overwrites the previous line.
eips_print() {
    eips 0 22 "$(printf '%-50s' "$1")" 2>/dev/null
}

log() {
    echo "$1" >> "$LOG"
    eips_print "$1"
}

echo "[$(date)] Starting install/update..." > "$LOG"

# Determine whether this is a fresh install or an upgrade
if [ -f "$INSTALL_DIR/tailscale" ]; then
    CURRENT=$("$INSTALL_DIR/tailscale" version 2>/dev/null | head -1)
else
    CURRENT="none"
fi
echo "Installed version : $CURRENT" >> "$LOG"

# Resolve the latest release tag from the GitHub API
# A User-Agent header is required - GitHub resets connections from clients that omit it.
log "Checking latest Tailscale version..."
LATEST=$(wget -qO- --user-agent="tailscale-kual-updater/1.0" \
    "https://api.github.com/repos/tailscale/tailscale/releases/latest" 2>>"$LOG" \
    | grep '"tag_name"' | head -1 | sed 's/.*"v\([^"]*\)".*/\1/')

if [ -z "$LATEST" ]; then
    log "ERROR: Could not determine latest version. Check Wi-Fi connectivity."
    exit 1
fi
echo "Latest version    : $LATEST" >> "$LOG"

if [ "$CURRENT" = "$LATEST" ]; then
    log "Already up to date (v$LATEST). Nothing to do."
    exit 0
fi

if [ "$CURRENT" = "none" ]; then
    log "No binaries found. Installing v$LATEST..."
else
    log "Updating $CURRENT -> $LATEST..."
fi

# Download the tarball
mkdir -p "$TMP_DIR"
URL="https://pkgs.tailscale.com/stable/tailscale_${LATEST}_${ARCH}.tgz"
echo "Downloading $URL..." >> "$LOG"
log "Downloading tailscale v$LATEST (~31 MB). Please wait..."
wget -qO "$TMP_DIR/ts.tgz" "$URL" 2>>"$LOG"

if [ $? -ne 0 ] || [ ! -s "$TMP_DIR/ts.tgz" ]; then
    log "ERROR: Download failed. Check Wi-Fi connectivity and try again."
    rm -rf "$TMP_DIR"
    exit 1
fi

# Extract
tar -xzf "$TMP_DIR/ts.tgz" -C "$TMP_DIR" 2>>"$LOG"
EXTRACTED=$(find "$TMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -1)

if [ -z "$EXTRACTED" ]; then
    log "ERROR: Extraction failed."
    rm -rf "$TMP_DIR"
    exit 1
fi

# Back up existing binaries before replacing (only when upgrading)
if [ "$CURRENT" != "none" ]; then
    [ -f "$INSTALL_DIR/tailscale" ]  && cp "$INSTALL_DIR/tailscale"  "$INSTALL_DIR/tailscale.bak"
    [ -f "$INSTALL_DIR/tailscaled" ] && cp "$INSTALL_DIR/tailscaled" "$INSTALL_DIR/tailscaled.bak"
    echo "Backed up existing binaries as *.bak" >> "$LOG"
fi

# Install binaries
cp "$EXTRACTED/tailscale"  "$INSTALL_DIR/tailscale"  && chmod +x "$INSTALL_DIR/tailscale"
cp "$EXTRACTED/tailscaled" "$INSTALL_DIR/tailscaled" && chmod +x "$INSTALL_DIR/tailscaled"

rm -rf "$TMP_DIR"

# Create an empty auth.key placeholder on a fresh install
if [ ! -f "$INSTALL_DIR/auth.key" ]; then
    touch "$INSTALL_DIR/auth.key"
    echo "Created empty auth.key placeholder." >> "$LOG"
fi

if [ "$CURRENT" = "none" ]; then
    log "Install complete: v$LATEST. Fill in auth.key before starting Tailscale."
else
    log "Update complete: v$LATEST successfully installed."
fi
