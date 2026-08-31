podman run --rm --privileged \
  -v "$(pwd)":/anthoros \
  gentoo/stage3:musl-llvm \
  bash -c "
    # 1. Prepare Portage directories
    mkdir -p /etc/portage/package.use /etc/portage/package.accept_keywords
    
    # 2. Set required Keywords
    echo 'dev-util/catalyst ~amd64' > /etc/portage/package.accept_keywords/catalyst
    
    # 3. Set required USE flags (Catalyst + Kernel/Initramfs tooling)
    cat << 'EOF' > /etc/portage/package.use/build-deps
sys-apps/util-linux python
sys-boot/grub grub_platforms_efi-32
sys-kernel/installkernel dracut grub
EOF

    # 4. Sync and install Catalyst
    emerge-webrsync -q
    emerge --nospinner -q dev-util/catalyst
    
    # 5. Patch Catalyst and trigger the build
    python3 /anthoros/scripts/patch-catalyst.py
    cd /anthoros && VERSION=\$(date +%Y%m%d) ./scripts/build.sh
  "
