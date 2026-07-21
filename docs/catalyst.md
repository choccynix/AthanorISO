# AnthorOS — Catalyst Reference

Catalyst is Gentoo's official tool for building stages, live CDs, and releases.

Reference: [Gentoo Wiki — Catalyst](https://wiki.gentoo.org/wiki/Catalyst)

---

## catalyst.conf

Location: `catalyst/catalyst.conf`

```ini
storedir="/var/tmp/catalyst"   # Where Catalyst stores builds, packages, snapshots
```

Catalyst is invoked with `--configs` pointing to this file. Most defaults are left intact.

Reference: [Gentoo Wiki — Catalyst/Configuration](https://wiki.gentoo.org/wiki/Catalyst/Configuration)

---

## Spec Files

Spec files tell Catalyst what to build. They use a simple `key: value` syntax with tab-indented list values.

Reference: [Gentoo Wiki — Catalyst/Reference](https://wiki.gentoo.org/wiki/Catalyst/Reference)

### Common Keys

| Key | Description |
|---|---|
| `subarch` | CPU architecture (e.g. `amd64`) |
| `version_stamp` | Build version label |
| `target` | Build target type (`livecd-stage1`, `livecd-stage2`) |
| `rel_type` | Release type, used as a directory name under `storedir/builds/` |
| `profile` | Gentoo profile path |
| `snapshot_treeish` | Portage snapshot identifier |
| `source_subpath` | Input stage path relative to `storedir/builds/` |
| `portage_confdir` | Directory overlaid onto `/etc/portage` inside the chroot |
| `compression_mode` | Archive compression (`pixz` = parallel xz) |

### livecd-stage1 Specific

| Key | Description |
|---|---|
| `livecd/use` | Extra USE flags active during the live CD build |
| `livecd/packages` | Packages to emerge into the live environment |

### livecd-stage2 Specific

| Key | Description |
|---|---|
| `livecd/fstype` | Filesystem type for the live image (`squashfs`) |
| `livecd/iso` | Output ISO filename |
| `livecd/volid` | ISO volume label |
| `livecd/bootargs` | Kernel boot arguments added to GRUB config |
| `livecd/type` | Release type preset (`gentoo-release-minimal`) |
| `boot/kernel` | Kernel label |
| `boot/kernel/<label>/distkernel` | Use a distribution kernel (`yes`) |
| `boot/kernel/<label>/sources` | Kernel package (`gentoo-kernel-bin`) |
| `boot/kernel/<label>/packages` | Extra packages installed alongside the kernel |
| `boot/kernel/<label>/dracut_args` | Arguments passed to dracut for initramfs |
| `livecd/rm` | Paths to delete from the final image |
| `livecd/empty` | Paths to empty (keep dir, remove contents) |

---

## Portage confdir

`catalyst/portage/` is overlaid onto `/etc/portage` inside each Catalyst chroot. Files here control the build environment for the chroot, not the host.

| File | Purpose |
|---|---|
| `make.conf` | Compiler flags, USE flags, FEATURES |
| `package.use/anthoros` | Per-package USE flag overrides |
| `package.accept_keywords/anthoros` | Keyword overrides for `~amd64` packages |
| `package.license/anthoros` | Explicit license acceptances |

Reference: [Gentoo Wiki — Portage/Configuration](https://wiki.gentoo.org/wiki/Portage/Configuration)

---

## dracut_args

The `dracut_args` in the stage2 spec control initramfs generation.

```
--xz                   # Compress with xz
--no-hostonly          # Generic initramfs (not tied to build host hardware)
-a dmsquash-live       # Required for squashfs live boot
-o btrfs               # Omit btrfs module (not needed for live)
-o crypt               # Omit dm-crypt module
-o i18n                # Omit i18n/keyboard module
```

The `dmsquash-live` module is essential — it handles mounting the squashfs filesystem at boot time for a live environment.

Reference: [Gentoo Wiki — Dracut](https://wiki.gentoo.org/wiki/Dracut)
