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

2. Get the latest tailscale binaries for the `arm` architecture from [here](https://pkgs.tailscale.com/stable/#static). Or see releases page for a version that worked for me.

3. Place the `tailscale` and `tailscaled` binaries in the `tailscale/bin/` folder of this (local) repository.

4. Fill the empty `auth.key` file, in the `tailscale/bin/` folder with your [Tailscale Auth Key](https://tailscale.com/kb/1085/auth-keys) to login.

5. Place the **tailscale** (not the `tailscale_kual`) folder into the `extensions` folder on your kindle.

6. In the KUAL menu, open the **Start Tailscaled** submenu and pick the mode that suits your device (see [Tailscaled Modes](#tailscaled-modes) below). Wait about 10 seconds, then run **Start Tailscale**.

7. After this, tailscale should add the kindle to your [Machines](https://login.tailscale.com/admin/machines) page on tailscale [admin console](https://login.tailscale.com/welcome).

8. Now you can see the (fairly static) IP address assigned by Tailscale for your kindle. You can use this ip to `ssh root@<kindle-ip>`!

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

## Note:

Check out Open/Closed issues if this does not work right out of the gate.
