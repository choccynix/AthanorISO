# AnthorOS — Architecture

## Overview

AnthorOS is built using [Catalyst](https://wiki.gentoo.org/wiki/Catalyst), Gentoo's official release engineering tool. The build pipeline runs inside a `gentoo/stage3:musl-llvm` Docker container and produces two outputs: a bootable hybrid ISO and a rootfs tarball.

---

## Build Pipeline

```
gentoo/stage3:musl-llvm (base container)
        │
        ▼
  emerge-webrsync          ← Portage snapshot
        │
        ▼
  catalyst -s stable       ← Squashfs snapshot for Catalyst
        │
        ▼
  livecd-stage1            ← Chroot from stage3, emerge packages
        │
        ▼
  livecd-stage2            ← Install kernel (gentoo-kernel-bin),
        │                    build initramfs (dracut),
        │                    assemble ISO (GRUB, BIOS+UEFI)
        ▼
  anthoros-amd64-YYYYMMDD.iso
  anthoros-stage3-amd64-YYYYMMDD.tar.xz
```

---

## Catalyst Stages

### livecd-stage1

Takes the Gentoo stage3 tarball as input. Installs the packages defined in `livecd-stage1.spec` into a fresh chroot. Output is a compressed stage that feeds into stage2.

Reference: [Gentoo Wiki — Catalyst livecd-stage1](https://wiki.gentoo.org/wiki/Catalyst/Reference#livecd-stage1)

### livecd-stage2

Takes the stage1 output. Installs the kernel (`gentoo-kernel-bin`), builds a musl-compatible initramfs via dracut (`dmsquash-live` module for live boot), and assembles the final ISO using GRUB for both BIOS (El Torito + hybrid MBR) and UEFI (EFI system partition) boot.

Reference: [Gentoo Wiki — Catalyst livecd-stage2](https://wiki.gentoo.org/wiki/Catalyst/Reference#livecd-stage2)

---

## Why musl?

musl is a clean, minimal C standard library. Compared to glibc it is smaller, faster to compile against, and has a simpler, more correct implementation. The tradeoff is reduced compatibility with software that assumes glibc extensions — on AnthorOS, that's a feature, not a bug.

Reference: [Gentoo Wiki — Musl](https://wiki.gentoo.org/wiki/Musl)

---

## Why LLVM/Clang?

The musl+llvm profile uses Clang as the system compiler instead of GCC. LLVM produces faster code on modern hardware and has better static analysis tooling. The full LLVM toolchain (`llvm-ar`, `llvm-nm`, `llvm-ranlib`) replaces GNU binutils.

Reference: [Gentoo Wiki — Clang](https://wiki.gentoo.org/wiki/Clang)

---

## Why OpenRC?

OpenRC is a dependency-based init system that is simple, auditable, and works correctly without a service manager daemon. It doesn't try to own the system. On a minimal distro, that matters.

Reference: [Gentoo Wiki — OpenRC](https://wiki.gentoo.org/wiki/OpenRC)

---

## Known Upstream Issues

### Catalyst 4.1.1-r1 — options.extend() bug

Catalyst's `main.py` calls `.extend()` on a Python `set`, which fails because sets have no `extend()` method. We patch this at build time via `scripts/patch-catalyst.py`.

### Catalyst 4.1.1-r1 — kmerge.sh gentoo-kernel hardcode

Catalyst's `kmerge.sh` hardcodes `sys-kernel/gentoo-kernel` (source build) even when the spec specifies `sources: gentoo-kernel-bin`. We patch this to use the binary kernel instead, avoiding a 30+ minute compile on CI runners.

Both patches are applied by `scripts/patch-catalyst.py` before each build.
