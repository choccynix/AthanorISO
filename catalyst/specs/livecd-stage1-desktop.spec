subarch: amd64
version_stamp: @VERSION@-desktop
target: livecd-stage1
rel_type: athanor
profile: default/linux/amd64/23.0/musl/llvm
snapshot_treeish: @TREEISH@
source_subpath: athanor/stage3-amd64-musl-llvm-openrc-@VERSION@
compression_mode: pixz

portage_confdir: @REPO_DIR@/catalyst/portage

livecd/use:
	unicode
	livecd
	X

livecd/packages:
	app-editors/nano
	app-editors/vim
	app-misc/screen
	app-misc/livecd-tools
	app-shells/bash
	dev-vcs/git
	sys-libs/musl
	sys-fs/e2fsprogs
	sys-fs/dosfstools
	sys-fs/btrfs-progs
	sys-fs/xfsprogs
	sys-block/parted
	net-misc/openssh
	net-misc/dhcpcd
	net-misc/curl
	net-misc/wget
	sys-apps/iproute2
	net-wireless/wpa_supplicant
	net-wireless/iw
	sys-apps/pciutils
	sys-apps/usbutils
	sys-apps/gptfdisk
	sys-process/htop
	sys-kernel/linux-firmware
	x11-apps/xinit
	x11-base/xorg-server
	x11-drivers/xf86-input-libinput
	x11-drivers/xf86-video-vesa
	x11-drivers/xf86-video-fbdev
	x11-apps/xrdb
	x11-apps/xprop
	x11-apps/xsetroot
	x11-misc/xterm
	x11-libs/libX11
	x11-libs/libXft
	x11-libs/libXinerama
	x11-libs/libXrandr
	media-fonts/liberation-fonts
