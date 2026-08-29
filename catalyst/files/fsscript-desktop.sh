#!/usr/bin/env bash
# fsscript-desktop.sh — desktop edition live environment setup
# Builds suckless tools from source so users can easily patch/modify them
set -euo pipefail

# ── os-release ────────────────────────────────────────────────────────────────
cat > /etc/os-release << 'EOF'
NAME="AthanorOS"
VERSION="rolling"
ID=athanoros
ID_LIKE=gentoo
PRETTY_NAME="AthanorOS Desktop (Live)"
HOME_URL="https://github.com/choccynix/AthanorISO"
BUILD_ID=rolling
ANSI_COLOR="1;35"
EOF
ln -sf /etc/os-release /usr/lib/os-release 2>/dev/null || true

# OpenRC reads this for the boot banner — must match NAME
sed -i 's/Gentoo Linux/AthanorOS/' /etc/rc.conf 2>/dev/null || true
# Also patch the OpenRC banner directly if present
if [[ -f /sbin/openrc ]]; then
    sed -i 's/Gentoo Linux/AthanorOS/g' /sbin/openrc 2>/dev/null || true
fi
# The actual banner comes from /etc/os-release NAME field via openrc's functions
# Set it in openrc-run functions file if present
for f in /lib/rc/sh/functions.sh /usr/lib/rc/sh/functions.sh; do
    [[ -f "${f}" ]] && sed -i 's/Gentoo Linux/AthanorOS/g' "${f}" 2>/dev/null || true
done

# ── hostname ──────────────────────────────────────────────────────────────────
echo "athanoros" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   athanoros
::1         localhost
EOF

# ── Installer ─────────────────────────────────────────────────────────────────
if [[ -d /var/tmp/catalyst/installer ]]; then
    cp -r /var/tmp/catalyst/installer /opt/athanor-installer
    chmod +x /opt/athanor-installer/*.sh 2>/dev/null || true
fi
cat > /usr/local/bin/install-athanor << 'WRAPPER'
#!/usr/bin/env bash
exec /opt/athanor-installer/Athanor_installer.sh "$@"
WRAPPER
chmod +x /usr/local/bin/install-athanor

# ── Build suckless tools from source ─────────────────────────────────────────
# Source lives in /usr/local/src/suckless/ — users can patch and recompile
# Replace these URLs with your own forks once ready
SUCKLESS_SRC="/usr/local/src/suckless"
mkdir -p "${SUCKLESS_SRC}"

build_suckless() {
    local name="$1"
    local url="$2"
    local dir="${SUCKLESS_SRC}/${name}"

    echo "[suckless] Building ${name}..."
    curl -fsSL --connect-timeout 30 --max-time 120 -o "/tmp/${name}.tar.gz" "${url}" || {
        echo "[suckless] WARNING: Failed to download ${name}, skipping"
        return 0
    }

    mkdir -p "${dir}"
    tar xzf "/tmp/${name}.tar.gz" -C "${dir}" --strip-components=1

    # Write a minimal config.mk for musl+clang if not overriding config.h
    cat > "${dir}/config.mk.athanor" << 'MK'
# AthanorOS build overrides — included by config.mk
CC = clang
MK

    pushd "${dir}" > /dev/null
    make CC=clang PREFIX=/usr/local install 2>&1 | tail -5 \
        || echo "[suckless] WARNING: ${name} build failed, check ${dir}"
    popd > /dev/null
    echo "[suckless] ${name} installed."
}

# ── dwm ───────────────────────────────────────────────────────────────────────
build_suckless "dwm"      "https://dl.suckless.org/dwm/dwm-6.5.tar.gz"

# ── st ────────────────────────────────────────────────────────────────────────
build_suckless "st"       "https://dl.suckless.org/st/st-0.9.2.tar.gz"

# ── dmenu ─────────────────────────────────────────────────────────────────────
build_suckless "dmenu"    "https://dl.suckless.org/tools/dmenu-5.3.tar.gz"

# ── slock ─────────────────────────────────────────────────────────────────────
build_suckless "slock"    "https://dl.suckless.org/tools/slock-1.5.tar.gz"

# ── slstatus ──────────────────────────────────────────────────────────────────
build_suckless "slstatus" "https://dl.suckless.org/tools/slstatus-1.0.tar.gz"

# Leave a README so users know how to patch/rebuild
cat > "${SUCKLESS_SRC}/README.md" << 'EOF'
# AthanorOS — Suckless Sources

Source code for the suckless tools is here so you can patch and recompile.

## Tools

| Tool | Purpose |
|---|---|
| dwm | Window manager |
| st | Terminal emulator |
| dmenu | Application launcher |
| slock | Screen locker |
| slstatus | Status bar for dwm |

## Patching

```bash
cd /usr/local/src/suckless/dwm
# Edit config.h or apply a patch
patch -p1 < your-patch.diff
make CC=clang PREFIX=/usr/local install
```

## Replacing URLs

To use your own forks, edit the URLs in:
  /athanor/catalyst/files/fsscript-desktop.sh

then rebuild the ISO.
EOF

# ── .xinitrc ──────────────────────────────────────────────────────────────────
cat > /root/.xinitrc << 'EOF'
#!/bin/sh
xsetroot -solid "#1a1a2e"

mpd &

dunst &

picom --backend xrender &

slstatus &
exec dwm
EOF
chmod +x /root/.xinitrc

# ── Keybindings cheatsheet ────────────────────────────────────────────────────
mkdir -p /root/.config/athanoros
cat > /root/.config/athanoros/keybindings.txt << 'EOF'
AthanorOS Desktop — dwm keybindings
=====================================
Mod = Alt key

Mod+Shift+Return   Open terminal (st)
Mod+p              dmenu app launcher
Mod+Shift+c        Close window
Mod+Shift+q        Quit dwm
Mod+1..9           Switch tag
Mod+Shift+1..9     Move window to tag
Mod+Return         Promote to master
Mod+j/k            Focus next/prev
Mod+h/l            Resize master area
Mod+t              Tiling layout
Mod+f              Floating layout
Mod+m              Monocle layout

slock              Lock screen
install-athanor    Run installer
EOF

# ── motd ──────────────────────────────────────────────────────────────────────
cat > /etc/motd << 'EOF'

 █████╗ ████████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝
███████║   ██║   ███████║███████║██╔██╗ ██║██║   ██║██████╔╝██║   ██║███████╗
██╔══██║   ██║   ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══██╗██║   ██║╚════██║
██║  ██║   ██║   ██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║╚██████╔╝███████║
╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

  Diverge. Distill. Transcend.  [ Desktop Edition ]
  musl · llvm · openrc · dwm · amd64

  ══════════════════════════════════════════════════════════════════════

  Welcome to the AthanorOS Desktop Live Environment.

  ── Start the desktop ──────────────────────────────────────────────────
  Run:    startx

  ── Keybindings ────────────────────────────────────────────────────────
  See:    cat ~/.config/athanoros/keybindings.txt

  ── Modify suckless tools ──────────────────────────────────────────────
  Source: /usr/local/src/suckless/
  Edit config.h, then: make CC=clang PREFIX=/usr/local install

  ── Installer ──────────────────────────────────────────────────────────
  Run:    install-athanor (NOT TESTED)

  ══════════════════════════════════════════════════════════════════════

EOF

cat > /etc/issue << 'EOF'
AthanorOS Desktop Live — musl · llvm · openrc · dwm
Login as root (no password) — run 'startx' to start

EOF

# ── inittab — single tty1 ─────────────────────────────────────────────────────
for i in 1 2 3 4 5 6; do
    rc-update del agetty.tty${i} default 2>/dev/null || true
    rc-update del agetty.tty${i} sysinit 2>/dev/null || true
    rm -f /etc/init.d/agetty.tty${i} 2>/dev/null || true
    rm -f /etc/conf.d/agetty.tty${i} 2>/dev/null || true
done

cat > /etc/inittab << 'EOF'
id:3:initdefault:
si::sysinit:/sbin/openrc sysinit
rc::bootwait:/sbin/openrc boot
l3:3:wait:/sbin/openrc default
c1:12345:respawn:/sbin/agetty -a root -J 38400 tty1 linux
ca:12345:ctrlaltdel:/sbin/shutdown -r now
EOF

passwd -d root
rc-update add sshd default 2>/dev/null || true
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config 2>/dev/null || true
rc-update add dhcpcd default 2>/dev/null || true

echo "fsscript-desktop complete"
