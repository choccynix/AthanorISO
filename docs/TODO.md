# AnthorOS — TODO

> Items marked 🔥 are high priority. Items marked 🧪 are experimental/research.

---

## ◈ Immediate (test the ISO first)

- [ ] Boot test on real hardware (BIOS)
- [ ] Boot test on real hardware (UEFI)
- [ ] Boot test in QEMU (BIOS + UEFI)
- [ ] Verify networking works on boot (`dhcpcd`, `wpa_supplicant`)
- [ ] Verify SSH works
- [ ] Verify basic tools are present and functional

---

## ◈ Desktop Environment

> Do this after the base ISO is stable.

- [ ] Decide on DE/WM — options to evaluate:
  - **Sway** (Wayland, minimal, fits the aesthetic)
  - **Hyprland** (Wayland, modern, performance-focused)
  - **dwm** (X11, absolute minimal, source-patched)
- [ ] Add Wayland compositor + supporting packages to `livecd-stage1.spec`
- [ ] Add display manager or autologin for live session
- [ ] Configure default keybindings and theme (alchemy aesthetic)
- [ ] Wallpaper / branding for desktop session
- [ ] Add terminal emulator (foot, alacritty, kitty)
- [ ] Add file manager (lf, ranger, or minimal GTK option)
- [ ] Add text editor for live session (already have vim/nano)

---

## ◈ Installer

- [ ] **Research installer approach:**
  - Option A: Custom shell/Python installer script (minimal, fits AnthorOS)
  - Option B: Calamares (GUI installer framework, heavier)
  - Option C: Simple TUI installer (dialog/whiptail based)
  - Recommendation: Start with a shell TUI, add Calamares later if needed

- [ ] **Installer features needed:**
  - [ ] Disk selection and partitioning (parted/fdisk)
  - [ ] Filesystem selection (ext4, btrfs, xfs)
  - [ ] GRUB installation (BIOS + UEFI)
  - [ ] Base system extraction from squashfs to disk
  - [ ] Locale and timezone setup
  - [ ] User account creation
  - [ ] Hostname configuration
  - [ ] Network configuration (basic)
  - [ ] Root password

- [ ] **Post-install:**
  - [ ] First-boot setup script
  - [ ] Portage sync on first boot
  - [ ] Optional: binary package cache for faster post-install emerges

---

## ◈ Build System

- [ ] Cache stage1 output to speed up stage2-only rebuilds
- [ ] Investigate GitHub Actions larger runners for faster builds
- [ ] Add build time reporting to release notes
- [ ] Add ISO size tracking over time
- [ ] Arm64 support (stage3 exists for musl+llvm on arm64)

---

## ◈ System

- [ ] Custom kernel configuration (replace gentoo-kernel-bin with configured source build)
- [ ] Review and trim default package list — remove anything not essential for live use
- [ ] Add `neofetch` or custom `fetch` script showing AnthorOS branding
- [ ] `/etc/motd` with AnthorOS ASCII art and version info
- [ ] Custom `/etc/os-release` with correct fields
- [ ] Verify musl compatibility for all included packages

---

## ◈ Branding

- [ ] AnthorOS logo (SVG)
- [ ] GRUB splash / theme
- [ ] Desktop wallpaper (alchemy theme)
- [ ] Custom font selection
- [ ] Color palette definition (publish as a design doc)

---

## ◈ Documentation

- [ ] Installation guide (when installer exists)
- [ ] Post-install guide (Portage basics for new users)
- [ ] Hardware compatibility notes
- [ ] Known issues page
