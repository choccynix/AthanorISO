# AnthorOS

Minimal rolling Linux distro built on Gentoo (musl + llvm + openrc).  
Automated weekly builds via GitHub Actions using Catalyst.

---

## Downloads

Latest release: [Releases](../../releases/latest)

| File | Description |
|---|---|
| `anthoros-amd64-YYYYMMDD.iso` | Bootable live ISO (BIOS + UEFI) |
| `anthoros-stage3-amd64-YYYYMMDD.tar.xz` | Rootfs tarball |
| `*.sha256` | Checksums |

```bash
# Verify
sha256sum -c anthoros-amd64-YYYYMMDD.iso.sha256

# Write to USB
dd if=anthoros-amd64-YYYYMMDD.iso of=/dev/sdX bs=4M status=progress && sync
```

---

## Stack

- **Libc:** musl
- **Toolchain:** LLVM/Clang
- **Init:** OpenRC
- **Kernel:** gentoo-kernel-bin
- **Build tool:** Catalyst

---

## Build

Runs every Sunday at 03:00 UTC, or manually via Actions → Run workflow.

```
catalyst/
├── catalyst.conf
├── specs/
│   ├── livecd-stage1.spec
│   └── livecd-stage2.spec
└── portage/
    ├── make.conf
    ├── package.use/anthoros
    └── package.accept_keywords/anthoros
```

---

## Status

Early development. Things will break.
