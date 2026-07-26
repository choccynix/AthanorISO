subarch: amd64
version_stamp: @VERSION@
target: livecd-stage2
rel_type: athanor
profile: default/linux/amd64/23.0/musl/llvm
snapshot_treeish: @TREEISH@
source_subpath: athanor/livecd-stage1-amd64-@VERSION@
compression_mode: pixz

portage_confdir: @REPO_DIR@/catalyst/portage
livecd/fsscript: @REPO_DIR@/catalyst/files/fsscript.sh

# Single-word volid — GRUB label search requires no spaces
livecd/volid: ATHANOROS
livecd/fstype: squashfs
livecd/iso: athanoros-amd64-@VERSION@.iso
livecd/type: gentoo-release-minimal
livecd/depclean: yes

# console=tty1 forces kernel to use a single console
# this stops keyboard input being split across multiple ttys (scrambled input bug)
livecd/bootargs: rd.live.image rd.live.squashimg=athanoros.squashfs

boot/kernel: athanor
boot/kernel/athanor/distkernel: yes
boot/kernel/athanor/sources: gentoo-kernel-bin
boot/kernel/athanor/packages:
	sys-boot/grub
	sys-kernel/dracut
	sys-fs/squashfs-tools
	sys-fs/mdadm

boot/kernel/athanor/dracut_args: --xz --no-hostonly -a dmsquash-live -a mdraid -o btrfs -o crypt -o i18n

livecd/rm:
	/usr/share/doc
	/usr/share/man
	/var/cache/distfiles
	/var/tmp/portage

livecd/empty:
	/var/cache/distfiles
	/var/tmp/portage
