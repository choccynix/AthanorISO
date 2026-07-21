# AnthorOS — Build Guide

## Requirements

- Docker with `--privileged` support
- ~5GB free disk space
- Linux host (for bind mounts)

---

## Quick Build (Docker)

```bash
git clone https://github.com/choccynix/AnthorISO.git
cd AnthorISO

docker run --rm --privileged \
  -v "$(pwd)":/anthoros \
  gentoo/stage3:musl-llvm \
  bash -c "
    mkdir -p /var/db/repos/gentoo
    emerge-webrsync -q
    echo 'dev-util/catalyst ~amd64' > /etc/portage/package.accept_keywords/catalyst
    emerge --nospinner -q dev-util/catalyst
    python3 /anthoros/scripts/patch-catalyst.py
    cd /anthoros && VERSION=$(date +%Y%m%d) ./scripts/build.sh
  "
```

Outputs will be in `./output/`.

---

## Manual Build (inside Gentoo container)

### 1. Set up the container

```bash
docker run --rm --privileged -it \
  -v "$(pwd)":/anthoros \
  gentoo/stage3:musl-llvm bash
```

### 2. Install Catalyst

```bash
mkdir -p /var/db/repos/gentoo
emerge-webrsync -q

mkdir -p /etc/portage/package.accept_keywords
echo "dev-util/catalyst ~amd64" > /etc/portage/package.accept_keywords/catalyst

mkdir -p /etc/portage/package.use
cat > /etc/portage/package.use/build-deps << 'USEEOF'
sys-apps/util-linux python
sys-boot/grub grub_platforms_efi-32 grub_platforms_efi-64 grub_platforms_pc
sys-kernel/installkernel grub dracut -ugrd -ukify -generic-uki
sys-kernel/gentoo-kernel-bin -generic-uki
sys-kernel/dracut -systemd
USEEOF

emerge --nospinner -q dev-util/catalyst
```

### 3. Patch Catalyst

```bash
python3 /anthoros/scripts/patch-catalyst.py
```

### 4. Run the build

```bash
cd /anthoros
VERSION=$(date +%Y%m%d) ./scripts/build.sh
```

---

## Build Outputs

| File | Location |
|---|---|
| ISO | `output/anthoros-amd64-YYYYMMDD.iso` |
| Tarball | `output/anthoros-stage3-amd64-YYYYMMDD.tar.xz` |
| Checksums | `output/*.sha256` |

---

## Troubleshooting

### USE flag errors
Check `catalyst/portage/package.use/anthoros` and ensure host `package.use` matches.
See [Portage Config](./portage.md).

### Catalyst Python errors
Run `python3 scripts/patch-catalyst.py` manually and check output.
See [Architecture](./architecture.md#known-upstream-issues).

### Kernel not found after stage2
Catalyst's `kmerge.sh` may not have been patched. Check that `patch-catalyst.py` ran successfully before the build.

### License masked packages
Check `catalyst/portage/package.license/anthoros`.
Reference: [Gentoo Wiki — License Groups](https://wiki.gentoo.org/wiki/License_Groups)
