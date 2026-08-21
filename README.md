```
 █████╗ ████████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝
███████║   ██║   ███████║███████║██╔██╗ ██║██║   ██║██████╔╝██║   ██║███████╗
██╔══██║   ██║   ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══██╗██║   ██║╚════██║
██║  ██║   ██║   ██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║╚██████╔╝███████║
╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

<div align="center">

**Diverge. Distill. Transcend.**

*A minimal, rolling Linux distribution forged from Gentoo*

*musl · llvm · openrc · amd64*

![Build](https://github.com/choccynix/AthanorISO/actions/workflows/build.yml/badge.svg?branch=main)
![License](https://img.shields.io/badge/license-MIT-8B5CF6)
![Arch](https://img.shields.io/badge/arch-amd64-6D28D9)
![Base](https://img.shields.io/badge/base-Gentoo-54286B)

</div>

---

## ◈ Philosophy

AthanorOS takes its name from the **athanor** — the alchemist's furnace, a device of patient, sustained heat used to transform base materials into something refined. This system is that furnace.

Built on three principles:

- **Divergence** — break from convention. musl over glibc. LLVM over GCC. No systemd.
- **Minimalism** — nothing installed that isn't needed. Every package is a deliberate choice.
- **Transmutation** — Gentoo's source-based foundation means the system becomes exactly what you make it.

---

## ◈ Downloads

> Latest release → **[Releases](../../releases/latest)**

Desktop ISOs are on the way, please use minimal ones in the meantime. 
This readme is out of date. and the docs will be up to date as the time goes on

| File | Description |
|---|---|
| `athanoros-amd64-YYYYMMDD.iso` | Bootable live ISO (BIOS + UEFI) |
| `athanoros-stage3-amd64-YYYYMMDD.tar.xz` | Rootfs tarball |
| `*.sha256` | SHA-256 checksums |

```bash
# Verify
sha256sum -c athanoros-amd64-YYYYMMDD.iso.sha256

# Write to USB
dd if=athanoros-amd64-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress && sync

# Quick test (QEMU)
qemu-system-x86_64 -cdrom athanoros-amd64-YYYYMMDD.iso -m 2G -enable-kvm
```

---

## ◈ Stack

| Layer | Choice | Why |
|---|---|---|
| **Libc** | musl | Minimal, fast, correct |
| **Toolchain** | LLVM / Clang | Modern, aggressive optimisation |
| **Init** | OpenRC | Simple, predictable |
| **Kernel** | gentoo-kernel-bin | Prebuilt, fast iteration |
| **Build tool** | Catalyst | Gentoo's official ISO builder |
| **Boot** | GRUB | BIOS + UEFI hybrid support |

---

## ◈ Documentation

| Document | Description |
|---|---|
| [Architecture](./docs/architecture.md) | Build pipeline explained |
| [Build Guide](./docs/build-guide.md) | How to build locally |
| [Contributing](./docs/contributing.md) | Branch strategy and PR workflow |
| [Catalyst Reference](./docs/catalyst.md) | Spec file and config reference |
| [Portage Config](./docs/portage.md) | USE flags and license decisions |
| [TODO](./docs/TODO.md) | Roadmap |

---

## ◈ Branch Strategy

| Branch | Purpose | Output |
|---|---|---|
| `main` | Stable | GitHub Release + weekly Sunday auto-build |
| `dev` | Development | Build artifact only |
| `feature/*` | New features | Build artifact only |
| `fix/*` | Bug fixes | Build artifact only |

Never commit directly to `main`. PRs from `dev` only.

---

## ◈ Status

**Early development.** The ISO boots. The furnace is lit.

---

<div align="center">

*"The athanor requires no tending — only patience, and the right materials."*

</div>
