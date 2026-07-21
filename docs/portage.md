# AnthorOS — Portage Configuration

The `catalyst/portage/` directory is overlaid onto `/etc/portage` inside Catalyst chroots. It controls what gets built and how.

Reference: [Gentoo Wiki — Portage](https://wiki.gentoo.org/wiki/Portage)

---

## make.conf

Key settings and why they exist:

```bash
CC="clang"
CXX="clang++"
AR="llvm-ar"
NM="llvm-nm"
RANLIB="llvm-ranlib"
```
Forces the full LLVM toolchain. Required for the musl+llvm profile.
Reference: [Gentoo Wiki — Clang](https://wiki.gentoo.org/wiki/Clang)

```bash
USE="musl -systemd -pam -nls unicode"
```
- `musl` — activates musl-specific code paths
- `-systemd` — excludes all systemd dependencies
- `-pam` — excludes PAM (not compatible with musl in our config)
- `-nls` — disables native language support (reduces size)
- `unicode` — keeps unicode support for terminal

```bash
FEATURES="buildpkg getbinpkg binpkg-multi-instance"
```
Builds binary packages during stage1 and reuses them in stage2, reducing total build time on repeat runs.

---

## package.use/anthoros

| Package | USE flags | Reason |
|---|---|---|
| `sys-boot/grub` | `grub_platforms_efi-32 grub_platforms_efi-64 grub_platforms_pc` | Required by `dev-util/catalyst[iso]` for hybrid BIOS+UEFI ISO |
| `sys-apps/util-linux` | `python` | Required by Catalyst |
| `sys-kernel/installkernel` | `grub dracut -ugrd -ukify -generic-uki` | Use GRUB + dracut for boot setup, exclude UKI paths (systemd/glibc dependent) |
| `sys-kernel/gentoo-kernel-bin` | `-generic-uki` | Disable prebuilt UKI initramfs (glibc-based, won't boot on musl) |
| `sys-kernel/dracut` | `-systemd` | Build dracut without systemd for musl+openrc compatibility |

---

## package.accept_keywords/anthoros

| Package | Keyword | Reason |
|---|---|---|
| `dev-util/catalyst` | `~amd64` | Catalyst is testing-only on musl |
| `sys-kernel/dracut` | `~amd64` | Dracut is testing-only on musl |
| `app-misc/livecd-tools` | `~amd64` | Required by livecd-stage1 |
| `sys-kernel/linux-firmware` | `~amd64` | Latest firmware only in testing |

Reference: [Gentoo Wiki — ACCEPT_KEYWORDS](https://wiki.gentoo.org/wiki/ACCEPT_KEYWORDS)

---

## package.license/anthoros

| Package | Licenses | Reason |
|---|---|---|
| `sys-kernel/linux-firmware` | `linux-fw-redistributable no-source-code` | Firmware blobs require explicit acceptance even with `ACCEPT_LICENSE="*"` |

Reference: [Gentoo Wiki — License Groups](https://wiki.gentoo.org/wiki/License_Groups)

---

## Profile

```
default/linux/amd64/23.0/musl/llvm
```

This profile sets up the musl+llvm toolchain defaults. It's the basis for everything AnthorOS builds on.

Reference: [Gentoo Wiki — Profile](https://wiki.gentoo.org/wiki/Profile_(Portage))
