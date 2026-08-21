# AnthorOS — TODO

> Items marked 🔥 are high priority. Items marked 🧪 are experimental/research.

---

## ◈ Immediate — Get the ISO Working

* [ ] 🔥 Fix remaining package/build issues
* [ ] 🔥 Complete `livecd-stage1` build
* [ ] Boot test on real hardware (BIOS)
* [ ] Boot test on real hardware (UEFI)
* [ ] Boot test in QEMU (BIOS + UEFI)
* [ ] Verify networking works on boot (`dhcpcd`, `wpa_supplicant`)
* [ ] Verify SSH works
* [ ] Verify basic tools are present and functional
* [ ] Verify X11 starts successfully

---

## ◈ Desktop Environment

> Do this after the base ISO is stable.

* [ ] 🔥 Decide on DE/WM

  * **dwm** (X11, minimal, source-patched)
  * **Sway** (Wayland, minimal)
  * **Hyprland** (Wayland, modern)
* [ ] Add selected compositor/window manager to the ISO
* [ ] Add supporting Wayland/X11 packages as needed
* [ ] Configure default keybindings and theme
* [ ] Wallpaper / AnthorOS branding
* [ ] Add terminal emulator
* [ ] Add file manager
* [ ] Add basic desktop utilities
* [ ] Configure live-session startup/autologin

---

## ◈ Installer

> Start simple. A lightweight TUI installer fits AnthorOS better than immediately pulling in a large GUI framework.

* [ ] 🔥 Design installer workflow
* [ ] 🔥 Disk selection and partitioning
* [ ] 🔥 Filesystem selection (`ext4`, `btrfs`, `xfs`)
* [ ] 🔥 BIOS + UEFI bootloader installation
* [ ] 🔥 Extract base system from squashfs
* [ ] 🔥 Locale and timezone setup
* [ ] 🔥 User account creation
* [ ] 🔥 Hostname configuration
* [ ] 🔥 Basic network configuration
* [ ] 🔥 Root password setup
* [ ] First-boot setup
* [ ] Portage sync on first boot
* [ ] Optional binary package support

---

## ◈ Build System

* [x] Catalyst-based build system
* [x] Custom AthanorOS stage3
* [x] amd64 musl + LLVM + OpenRC profile
* [x] Stage1 specification
* [x] Custom Portage configuration directory
* [ ] 🔥 Cache stage1 output for faster rebuilds
* [ ] Add build-time reporting
* [ ] Track ISO size between releases
* [ ] 🧪 Investigate faster CI/build runners

---

## ◈ System

* [ ] 🔥 Custom kernel configuration
* [ ] Review and trim live ISO package list
* [ ] Verify musl compatibility of included packages
* [ ] Add AnthorOS `fetch`/system information script
* [ ] `/etc/motd` with AnthorOS ASCII art and version
* [ ] Custom `/etc/os-release`
* [ ] Verify firmware coverage
* [ ] Verify hardware detection tools
* [ ] Review default services and OpenRC configuration

---

## ◈ Branding

* [ ] AnthorOS logo (SVG)
* [ ] GRUB splash / theme
* [ ] Desktop wallpaper
* [ ] Custom font selection
* [ ] Define AnthorOS color palette
* [ ] Apply branding consistently across boot, TTY, and desktop

---

## ◈ Documentation

* [ ] Installation guide
* [ ] Post-install guide
* [ ] Portage basics guide
* [ ] Hardware compatibility notes
* [ ] Known issues page
* [ ] Build/release documentation

---

## ◈ Experimental / Future

* [ ] 🧪 Arm64 support
* [ ] 🧪 Binary package infrastructure
* [ ] 🧪 Automated ISO releases
* [ ] 🧪 Automated hardware/QEMU boot testing

