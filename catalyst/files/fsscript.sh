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

# ── agetty — ONLY tty1, no competing gettys (fixes scrambled keyboard) ────────
# The keyboard scramble happens when multiple agetty processes all receive the
# same keystrokes and interleave them. Kill all but tty1.
for i in 2 3 4 5 6; do
    rc-update del agetty.tty${i} default 2>/dev/null || true
    rm -f /etc/init.d/agetty.tty${i} 2>/dev/null || true
    rm -f /etc/conf.d/agetty.tty${i} 2>/dev/null || true
done

mkdir -p /etc/conf.d
cat > /etc/conf.d/agetty.tty1 << 'EOF'
agetty_options="--autologin root --noclear"
agetty_tty="tty1"
EOF

ln -sf /etc/init.d/agetty /etc/init.d/agetty.tty1 2>/dev/null || true
rc-update add agetty.tty1 default 2>/dev/null || true

# ── root with no password for live session ────────────────────────────────────
passwd -d root

# ── sshd ──────────────────────────────────────────────────────────────────────
rc-update add sshd default 2>/dev/null || true
sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/#PermitEmptyPasswords.*/PermitEmptyPasswords yes/' /etc/ssh/sshd_config 2>/dev/null || true

# ── dhcpcd ────────────────────────────────────────────────────────────────────
rc-update add dhcpcd default 2>/dev/null || true

echo "fsscript complete"
