subarch: amd64
version_stamp: @VERSION@
target: livecd-stage2
rel_type: anthoros
profile: default/linux/amd64/23.0/musl/llvm
snapshot_treeish: @TREEISH@
source_subpath: anthoros/livecd-stage1-amd64-@VERSION@
compression_mode: pixz

portage_confdir: @REPO_DIR@/catalyst/portage
livecd/fsscript: @REPO_DIR@/catalyst/files/fsscript.sh

# volid must be a single token — no spaces — GRUB searches by this exact label
livecd/volid: ANTHOROS
livecd/fstype: squashfs
livecd/iso: anthoros-amd64-@VERSION@.iso
livecd/type: gentoo-release-minimal
livecd/depclean: yes

# rd.live.image tells dracut this is a live image
# root=live:CDLABEL=ANTHOROS must match volid exactly
# rd.live.squashimg=anthoros.squashfs tells dracut the squashfs filename
livecd/bootargs: dokeymap rd.live.image rd.live.squashimg=anthoros.squashfs

boot/kernel: anthoros
boot/kernel/anthoros/distkernel: yes
boot/kernel/anthoros/sources: gentoo-kernel-bin
boot/kernel/anthoros/packages:
	sys-boot/grub
	sys-kernel/dracut

# Match what Gentoo releng uses — add mdraid, usrmount, lunmask
# these are needed for reliable live boot
boot/kernel/anthoros/dracut_args: --xz --no-hostonly -a dmsquash-live -a mdraid -o btrfs -o crypt -o i18n -o usrmount -o lunmask

livecd/rm:
	/usr/share/doc
	/usr/share/man
	/var/cache/distfiles
	/var/tmp/portage

livecd/empty:
	/var/cache/distfiles
	/var/tmp/portage
