#!/usr/bin/env bash
# fsscript.sh — runs inside the stage2 chroot after packages are installed
set -euo pipefail

# ── os-release — fixes "Gentoo Linux" on OpenRC boot banner ──────────────────
cat > /etc/os-release << 'EOF'
NAME="AnthorOS"
VERSION="rolling"
ID=anthoros
ID_LIKE=gentoo
PRETTY_NAME="AnthorOS (Live)"
HOME_URL="https://github.com/choccynix/AnthorISO"
BUILD_ID=rolling
ANSI_COLOR="1;35"
EOF
ln -sf /etc/os-release /usr/lib/os-release 2>/dev/null || true

# ── hostname ──────────────────────────────────────────────────────────────────
echo "anthoros" > /etc/hostname
cat > /etc/hosts << 'EOF'
127.0.0.1   localhost
127.0.1.1   anthoros
::1         localhost
EOF

# ── motd ──────────────────────────────────────────────────────────────────────
cat > /etc/motd << 'EOF'

  ▄▄▄   ▄  ▄▄▄▄▄▄▄ ▄▄   ▄▄ ▄▄▄▄▄▄▄ ▄▄▄▄▄▄   ▄▄▄▄▄▄▄ ▄▄▄▄▄▄▄
 █   █ █ █       █  █ █ █  █       █   ▄  █ █       █       █
 █   █▄█ █▄     ▄█  █▄█ █  █   ▄   █  █ █ █ █   ▄   █  ▄▄▄▄▄█
 █      ▄  █   █ █       █  █  █ █  █   █▄▄█▄█  █ █  █ █▄▄▄▄▄
 █     █▄█ █   █ █   ▄   █  █  █▄█  █    ▄▄  █  █▄█  █▄▄▄▄▄  █
 █    ▄  █ █   █ █  █ █  █  █       █   █  █ █       █▄▄▄▄▄█ █
 █▄▄▄█ █▄█ █▄▄▄█ █▄▄█ █▄▄█  █▄▄▄▄▄▄▄█▄▄▄█  █▄█▄▄▄▄▄▄▄█▄▄▄▄▄▄▄█

  Diverge. Distill. Transcend.
  musl · llvm · openrc · amd64

  ══════════════════════════════════════════════════════════════════

  Welcome to the AnthorOS Live Environment.

  This is an early development release. You are running a minimal
  live system built on Gentoo with musl libc, LLVM/Clang, and OpenRC.

  ── What's available ───────────────────────────────────────────────
  • vim, nano          — text editors
  • parted, gptfdisk   — disk partitioning
  • e2fsprogs, btrfs   — filesystem tools
  • iproute2, dhcpcd   — networking
  • openssh            — remote access
  • curl, wget         — file transfer
  • htop               — process monitor

  ── Installer ──────────────────────────────────────────────────────
  An installer is in development. For now, installation is manual.
  See: https://github.com/choccynix/AnthorISO

  ── Networking ─────────────────────────────────────────────────────
  • Wired:    dhcpcd <interface>
  • Wireless: wpa_supplicant + dhcpcd

  ══════════════════════════════════════════════════════════════════

EOF

# ── /etc/issue ────────────────────────────────────────────────────────────────
cat > /etc/issue << 'EOF'
AnthorOS Live — musl · llvm · openrc
Login as root (no password)

EOF

# ── agetty — ONLY on tty1, stop other gettys competing for input ──────────────
# Remove any default getty configs that might run on multiple ttys
rm -f /etc/init.d/agetty.tty2 2>/dev/null || true
rm -f /etc/init.d/agetty.tty3 2>/dev/null || true
rm -f /etc/init.d/agetty.tty4 2>/dev/null || true
rm -f /etc/init.d/agetty.tty5 2>/dev/null || true
rm -f /etc/init.d/agetty.tty6 2>/dev/null || true

# Disable all gettys from default runlevel first
for i in 2 3 4 5 6; do
    rc-update del agetty.tty${i} default 2>/dev/null || true
done

# Configure tty1 with autologin — explicit tty device, no competing consoles
mkdir -p /etc/conf.d
cat > /etc/conf.d/agetty.tty1 << 'EOF'
agetty_options="--autologin root --noclear"
agetty_tty="tty1"
EOF

ln -sf /etc/init.d/agetty /etc/init.d/agetty.tty1 2>/dev/null || true
rc-update add agetty.tty1 default 2>/dev/null || true

# ── root with no password ─────────────────────────────────────────────────────
passwd -d root

# ── sshd ──────────────────────────────────────────────────────────────────────
rc-update add sshd default 2>/dev/null || true
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config 2>/dev/null || true

# ── dhcpcd ────────────────────────────────────────────────────────────────────
rc-update add dhcpcd default 2>/dev/null || true

echo "fsscript complete"
