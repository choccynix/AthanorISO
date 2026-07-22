#!/usr/bin/env bash
# fsscript.sh — runs inside the stage2 chroot after packages are installed
# Used to configure the live environment

# ── motd ──────────────────────────────────────────────────────────────────────
cat > /etc/motd << 'EOF'

  █████╗ ███╗   ██╗████████╗██╗  ██╗ ██████╗ ██████╗  ██████╗ ███████╗
 ██╔══██╗████╗  ██║╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝
 ███████║██╔██╗ ██║   ██║   ███████║██║   ██║██████╔╝██║   ██║███████╗
 ██╔══██║██║╚██╗██║   ██║   ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║
 ██║  ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║
 ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝

  Diverge. Distill. Transcend.
  musl · llvm · openrc · amd64

  ══════════════════════════════════════════════════════════════════════

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

  ══════════════════════════════════════════════════════════════════════

EOF

# ── /etc/issue (shown at login prompt) ────────────────────────────────────────
cat > /etc/issue << 'EOF'
AnthorOS Live — musl · llvm · openrc
Login as root (no password)

EOF

# ── root auto-login on tty1 via agetty ────────────────────────────────────────
mkdir -p /etc/conf.d
cat > /etc/conf.d/agetty.tty1 << 'EOF'
agetty_options="--autologin root --noclear"
EOF

# ── Make sure OpenRC starts agetty ────────────────────────────────────────────
ln -sf /etc/init.d/agetty /etc/init.d/agetty.tty1 2>/dev/null || true
rc-update add agetty.tty1 default 2>/dev/null || true

# ── Unlock root (no password for live session) ────────────────────────────────
passwd -d root

# ── sshd ──────────────────────────────────────────────────────────────────────
rc-update add sshd default 2>/dev/null || true
# Allow root login with no password in live env
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config

# ── dhcpcd on boot ────────────────────────────────────────────────────────────
rc-update add dhcpcd default 2>/dev/null || true

echo "fsscript complete"
