#!/usr/bin/env bash
# fsscript.sh — runs inside the stage2 chroot after packages are installed
set -euo pipefail

# ── os-release ────────────────────────────────────────────────────────────────
cat > /etc/os-release << 'EOF'
NAME="AthanorOS"
VERSION="rolling"
ID=athanoros
ID_LIKE=gentoo
PRETTY_NAME="AthanorOS (Live)"
HOME_URL="https://github.com/choccynix/AthanorISO"
BUILD_ID=rolling
ANSI_COLOR="1;35"
EOF
ln -sf /etc/os-release /usr/lib/os-release 2>/dev/null || true

# ── hostname ──────────────────────────────────────────────────────────────────
echo "athanoros" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   athanoros
::1         localhost
EOF

# ── Clone athanor-installer into the live image ───────────────────────────────
echo "Cloning athanor-installer..."
git clone --depth=1 https://github.com/choccynix/athanor-installer.git \
    /opt/athanor-installer 2>/dev/null || {
    echo "Warning: could not clone athanor-installer (repo may not be public yet)"
    mkdir -p /opt/athanor-installer
}

# Make all scripts executable
chmod +x /opt/athanor-installer/*.sh 2>/dev/null || true

# Create a convenience wrapper so 'install-athanor' works from anywhere
cat > /usr/local/bin/install-athanor << 'WRAPPER'
#!/usr/bin/env bash
exec /opt/athanor-installer/linter.sh "$@"
WRAPPER
chmod +x /usr/local/bin/install-athanor

# ── motd ──────────────────────────────────────────────────────────────────────
cat > /etc/motd << 'EOF'

 █████╗ ████████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝
███████║   ██║   ███████║███████║██╔██╗ ██║██║   ██║██████╔╝██║   ██║███████╗
██╔══██║   ██║   ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══██╗██║   ██║╚════██║
██║  ██║   ██║   ██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║╚██████╔╝███████║
╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

  Diverge. Distill. Transcend.
  musl · llvm · openrc · amd64

  ══════════════════════════════════════════════════════════════════════

  Welcome to the AthanorOS Live Environment.

  This is an early development release. You are running a minimal
  live system built on Gentoo with musl libc, LLVM/Clang, and OpenRC.

  AthanorOS takes its name from the athanor — the alchemist's furnace,
  a place of patient transformation. This system is that furnace.
  What you build with it is up to you.

  ── Installer ──────────────────────────────────────────────────────────
  To install AthanorOS to disk, run:

      install-athanor

  Installer files are in /opt/athanor-installer/

  ── What's available ───────────────────────────────────────────────────
  • vim, nano          — text editors
  • parted, gptfdisk   — disk partitioning
  • e2fsprogs, btrfs   — filesystem tools
  • iproute2, dhcpcd   — networking
  • openssh            — remote access
  • curl, wget         — file transfer
  • htop               — process monitor

  ── Networking ─────────────────────────────────────────────────────────
  • Wired:    dhcpcd <interface>
  • Wireless: wpa_supplicant -B -i <iface> -c /etc/wpa_supplicant.conf
              dhcpcd <iface>

  ══════════════════════════════════════════════════════════════════════

EOF

# ── /etc/issue ────────────────────────────────────────────────────────────────
cat > /etc/issue << 'EOF'
AthanorOS Live — musl · llvm · openrc
Login as root (no password)

EOF

# ── TTY / login setup — use inittab for reliable TTY allocation ───────────────
# OpenRC agetty services in a live environment don't allocate a proper TTY,
# causing "not a tty" errors and scrambled keyboard input.
# inittab is more reliable — it spawns getty directly with proper TTY control.

# Disable ALL OpenRC agetty services to avoid conflicts
for i in 1 2 3 4 5 6; do
    rc-update del agetty.tty${i} default 2>/dev/null || true
    rc-update del agetty.tty${i} sysinit 2>/dev/null || true
    rm -f /etc/init.d/agetty.tty${i} 2>/dev/null || true
    rm -f /etc/conf.d/agetty.tty${i} 2>/dev/null || true
done

# Write inittab — single getty on tty1 with autologin, nothing else
cat > /etc/inittab << 'EOF'
# /etc/inittab — AthanorOS live environment
# Single TTY only — prevents scrambled keyboard input

# Default runlevel
id:3:initdefault:

# System init
si::sysinit:/sbin/openrc sysinit
rc::bootwait:/sbin/openrc boot
l3:3:wait:/sbin/openrc default

# Single getty on tty1 with root autologin
# -a root: autologin as root
# -J: disable UART speed negotiation (cleaner for virtual consoles)
c1:12345:respawn:/sbin/agetty -a root -J 38400 tty1 linux

# Handle shutdown/reboot
ca:12345:ctrlaltdel:/sbin/shutdown -r now
EOF

# ── root with no password for live session ────────────────────────────────────
passwd -d root

# ── sshd ──────────────────────────────────────────────────────────────────────
rc-update add sshd default 2>/dev/null || true
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config 2>/dev/null || true

# ── dhcpcd ────────────────────────────────────────────────────────────────────
rc-update add dhcpcd default 2>/dev/null || true

echo "fsscript complete"
