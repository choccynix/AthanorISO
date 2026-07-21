```
 █████╗ ███╗   ██╗████████╗██╗  ██╗ ██████╗ ██████╗  ██████╗ ███████╗
██╔══██╗████╗  ██║╚══██╔══╝██║  ██║██╔═══██╗██╔══██╗██╔═══██╗██╔════╝
███████║██╔██╗ ██║   ██║   ███████║██║   ██║██████╔╝██║   ██║███████╗
██╔══██║██║╚██╗██║   ██║   ██╔══██║██║   ██║██╔══██╗██║   ██║╚════██║
██║  ██║██║ ╚████║   ██║   ██║  ██║╚██████╔╝██║  ██║╚██████╔╝███████║
╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝
```

<div align="center">

**Diverge. Distill. Transcend.**

*A minimal, rolling Linux distribution forged from Gentoo*

*musl · llvm · openrc · amd64*

![Build](https://github.com/choccynix/AnthorISO/actions/workflows/build.yml/badge.svg?branch=main)
![License](https://img.shields.io/badge/license-MIT-8B5CF6)
![Arch](https://img.shields.io/badge/arch-amd64-6D28D9)
![Base](https://img.shields.io/badge/base-Gentoo-54286B)

</div>

---

## ◈ Philosophy

AnthorOS is built on three principles borrowed from alchemy:

- **Divergence** — break from convention. musl over glibc. LLVM over GCC. No systemd.
- **Minimalism** — nothing installed that isn't needed. Every package is a choice.
- **Transmutation** — Gentoo's source-based foundation means the system becomes exactly what you make it.

This is not a beginner distro. It is a foundation.

---

## ◈ Downloads

> Latest release → **[Releases](../../releases/latest)**

| File | Description |
|---|---|
| `anthoros-amd64-YYYYMMDD.iso` | Bootable live ISO (BIOS + UEFI) |
| `anthoros-stage3-amd64-YYYYMMDD.tar.xz` | Rootfs tarball |
| `*.sha256` | SHA-256 checksums |

**Verify:**
```bash
sha256sum -c anthoros-amd64-YYYYMMDD.iso.sha256
```

**Write to USB:**
```bash
dd if=anthoros-amd64-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress && sync
```

**Quick test (QEMU):**
```bash
qemu-system-x86_64 -cdrom anthoros-amd64-YYYYMMDD.iso -m 2G -enable-kvm
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

Full documentation lives in [`/docs`](./docs/).

| Document | Description |
|---|---|
| [Architecture](./docs/architecture.md) | How the build system works end to end |
| [Build Guide](./docs/build-guide.md) | How to build AnthorOS locally |
| [Contributing](./docs/contributing.md) | Branch strategy, PR workflow, standards |
| [Catalyst Reference](./docs/catalyst.md) | Catalyst config and spec file reference |
| [Portage Config](./docs/portage.md) | USE flags, keywords, license decisions |
| [TODO](./docs/TODO.md) | Roadmap and planned features |

---

## ◈ Repository Structure

```
anthoros/
├── catalyst/
│   ├── catalyst.conf              # Catalyst build tool config
│   ├── specs/
│   │   ├── livecd-stage1.spec     # Package installation stage
│   │   └── livecd-stage2.spec     # Kernel + ISO assembly stage
│   └── portage/
│       ├── make.conf              # Compiler + feature flags
│       ├── package.use/           # Per-package USE flags
│       ├── package.accept_keywords/ # Keyword overrides
│       └── package.license/       # License acceptances
├── scripts/
│   ├── build.sh                   # Build orchestrator
│   └── patch-catalyst.py          # Upstream Catalyst bug patches
├── docs/                          # Full documentation
└── .github/workflows/
    └── build.yml                  # CI/CD pipeline
```

---

## ◈ Branch Strategy

| Branch | Purpose | Releases |
|---|---|---|
| `main` | Stable builds | GitHub Releases + weekly Sunday auto-build |
| `dev` | Active development | Build artifacts only (14 day retention) |
| `feature/*` | Feature work | Build artifacts only |
| `fix/*` | Bug fixes | Build artifacts only |

Only `main` publishes GitHub Releases. Everything else builds but only uploads artifacts for dev/testing.

---

## ◈ Contributing

See [Contributing Guide](./docs/contributing.md) for the full workflow.

Quick version:
1. Branch off `dev` — never commit directly to `main`
2. `feature/your-thing` or `fix/your-thing`
3. PR into `dev`, get review
4. `dev` gets merged into `main` when stable

---

## ◈ Building Locally

See [Build Guide](./docs/build-guide.md) for full instructions.

Requires privileged Docker and ~3GB free space:
```bash
docker run --rm --privileged \
  -v "$(pwd)":/anthoros \
  -e WORK_DIR=/build/anthoros \
  gentoo/stage3:musl-llvm \
  bash -c "emerge-webrsync -q && cd /anthoros && ./scripts/build.sh"
```

---

## ◈ Status

**Early development.** The ISO boots. The rest is being forged.

---

<div align="center">

*"The process of transmutation is not the destruction of what was —*
*it is the revelation of what could be."*

</div>
