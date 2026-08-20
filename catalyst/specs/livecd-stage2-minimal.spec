subarch: amd64
version_stamp: @VERSION@-minimal
target: livecd-stage2
rel_type: athanor
profile: default/linux/amd64/23.0/musl/llvm
snapshot_treeish: @TREEISH@
source_subpath: athanor/livecd-stage1-amd64-@VERSION@-minimal
compression_mode: pixz

portage_confdir: @REPO_DIR@/catalyst/portage
livecd/fsscript: @REPO_DIR@/catalyst/files/fsscript.sh

livecd/volid: ATHANOROS
livecd/fstype: squashfs
livecd/iso: athanoros-minimal-amd64-@VERSION@.iso
livecd/type: gentoo-release-minimal
livecd/depclean: yes

livecd/bootargs: rd.live.image rd.live.squashimg=athanoros-minimal.squashfs

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
