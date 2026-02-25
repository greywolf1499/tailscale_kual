# Tailscale for Kindle (KUAL)

This (very) simple repo allows you to connect your kindle remotely from anywhere using Tailscale VPN.

## Prerequisites:

1. Jailbroken Kindle. ([see](https://kindlemodding.gitbook.io/kindlemodding))
2. [KUAL](https://wiki.mobileread.com/wiki/KUAL) installed. ([see](https://kindlemodding.gitbook.io/kindlemodding/post-jailbreak/installing-kual-mrpi))
3. [USBNetworking](https://www.mobileread.com/forums/showthread.php?t=225030) hack installed and [enabled](https://wiki.mobileread.com/wiki/USBNetwork).
4. Set up ssh keys for ease of use.

## My Kindle:

I have a PaperWhite (7th Generation), referred to as [PW3](https://wiki.mobileread.com/wiki/Kindle_Serial_Numbers).

```
[root@kindle root]# uname -a
Linux kindle 3.0.35-lab126 #8 PREEMPT Tue Aug 1 12:49:59 UTC 2023 armv7l GNU/Linux
```

Having tested out on this device only, [YMMV](https://dictionary.cambridge.org/dictionary/english/ymmv).

## Usage:

1. Download the repository.

2. Fill the empty `auth.key` file, in the `tailscale/bin/` folder with your [Tailscale Auth Key](https://tailscale.com/kb/1085/auth-keys) to login.

3. Place the **tailscale** (not the `tailscale_kual`) folder into the `extensions` folder on your kindle.

4. In the KUAL menu, tap **Install Binaries**. This will download the latest `tailscale` and `tailscaled` ARM binaries directly onto the Kindle over Wi-Fi. Alternatively, download them manually for the `arm` architecture from [here](https://pkgs.tailscale.com/stable/#static) and place them in `extensions/tailscale/bin/` yourself.

5. In the KUAL menu, open the **Start Tailscaled** submenu and pick the mode that suits your device (see [Tailscaled Modes](#tailscaled-modes) below). Wait about 10 seconds, then run **Start Tailscale**.

6. After this, tailscale should add the kindle to your [Machines](https://login.tailscale.com/admin/machines) page on tailscale [admin console](https://login.tailscale.com/welcome).

7. Now you can see the (fairly static) IP address assigned by Tailscale for your kindle. You can use this ip to `ssh root@<kindle-ip>`!

8. **Recommended:** In the [Tailscale admin console](https://login.tailscale.com/admin/machines), find your Kindle, click the three-dot menu, and select **Disable key expiry**. After this one-time step, the Kindle will reconnect to your tailnet on every reboot without needing the `auth.key` file again. The auth key is only needed for the very first registration.

9. In case you want to restart fresh, Remove Kindle from tailscale admin console, Stop `tailscale` and `tailscaled` in KUAL, and delete the logs and new files created in `/extensions/tailscale/bin`. This will reset the state of tailscale on your kindle.

10. Note: Make sure the kindle screen is on, else the kindle sleeps the wifi. You can also not connect to kindle via ssh when it is connected to PC using the cable.

## Tailscaled Modes

The **Start Tailscaled** entry in KUAL is now a submenu with three options. They each map to a different way of running `tailscaled`. Try them in this order if one does not work:

### 1. Standard (Userspace) — default

Runs `tailscaled` with `-tun userspace-networking`. This is what the extension has always done. The kindle joins your tailnet and is reachable by its Tailscale IP (good for SSH), but **outgoing connections from the kindle itself** (e.g. accessing other tailnet nodes) may not work on all devices or firmware versions.

### 2. Proxy Mode (SOCKS5/HTTP)

Runs `tailscaled` in userspace-networking mode but also starts a SOCKS5 and HTTP proxy listener on `localhost:1055`. Outgoing traffic from apps that respect a proxy setting is routed through Tailscale. This is the recommended option if you want to use Tailscale URLs inside **KOReader** (OPDS, the CWA plugin, etc.).

After starting tailscaled in this mode and bringing tailscale up, configure KOReader's network proxy:

- Open KOReader → **Settings** → **Network** → **Proxy Settings**
- Set type to **SOCKS5** (or HTTP)
- Host: `localhost`, Port: `1055`

Once set, any request KOReader makes will go out through your tailnet.

### 3. Kernel TUN (if supported)

Runs `tailscaled` without the userspace-networking flag, relying on the kernel's TUN/TAP module instead. This gives full system-wide outgoing connectivity but requires the `tun` kernel module to be present and loadable. **This is not available on all Kindle firmware versions** — if it fails silently, fall back to Proxy Mode.

## Installing and Updating Tailscale Binaries

The KUAL menu has two entries for managing the binaries:

**Install Binaries** — use this on a fresh setup (no binaries present yet):
1. Fetches the latest release tag from the GitHub API.
2. Downloads `tailscale_{version}_arm.tgz` from `pkgs.tailscale.com` and extracts it.
3. Installs `tailscale` and `tailscaled` into `extensions/tailscale/bin/`.
4. Creates an empty `auth.key` placeholder if one is not already there.

**Update Binaries** — use this when binaries are already installed:
1. Queries the GitHub API for the latest Tailscale release.
2. Skips the download if the installed version is already current.
3. Downloads and extracts the latest tarball.
4. Backs up the existing binaries as `*.bak` before replacing them.

Progress and any errors are written to `install_log.txt` / `update_log.txt` in `extensions/tailscale/bin/`. The Kindle must have an active Wi-Fi connection.

**Note:** Stop `tailscale` and `tailscaled` via the KUAL menu first before running either, then start them again afterwards.

## Note:

Check out Open/Closed issues if this does not work right out of the gate.
