#!/bin/bash
#scripts/06_bootloader.sh
# shellcheck disable=SC2034

MODULE_NAME="Bootloader Configuration"
MODULE_DESCRIPTION="Install and configure system bootloader"
MODULE_AUTHOR="ETJAKEOC"
MODULE_VERSION="1.0"

detect_firmware() {
	if [[ -d /sys/firmware/efi ]]; then
		echo "uefi"
	else
		echo "bios"
	fi
}

select_bootloader() {
	printc "\n${CYAN}══════════════════════════════════════${RESET}\n"
	printc "${WHITE} Bootloader Selection${RESET}\n"
	printc "${CYAN}══════════════════════════════════════${RESET}\n\n"
	printc "${GREEN}Available options:${RESET}\n"
	printc "  1) GRUB2\n"
	printc "  2) LILO (legacy)\n"
	printc "  3) Systemd-boot (gummiboot)\n"
	printc "  4) UKI (Unified Kernel Image)\n"
	printc "  5) Other / custom\n\n"
	printc "${GREEN}Select bootloader: ${RESET}"
	read -r choice
	case "$choice" in
	1) BOOTLOADER="grub" ;;
	2) BOOTLOADER="lilo" ;;
	3) BOOTLOADER="systemd-boot" ;;
	4) BOOTLOADER="uki" ;;
	5) BOOTLOADER="custom" ;;
	*)
		printc "${RED}Invalid selection.${RESET}\n"
		return 1
		;;
	esac
}

install_grub() {
	local fw
	fw=$(detect_firmware)
	printc "${CYAN}Installing GRUB (${fw})...${RESET}\n"
	if [[ "$fw" == "uefi" ]]; then
		arch-chroot "$INSTALL_DEST" grub-install \
			--target=x86_64-efi \
			--efi-directory=/efi \
			--bootloader-id=ATHANOR
	else
		arch-chroot "$INSTALL_DEST" grub-install /dev/"${DISK##*/}"
	fi
	arch-chroot "$INSTALL_DEST" grub-mkconfig -o /boot/grub/grub.cfg
	printc "${GREEN}GRUB installation complete.${RESET}\n"
}

install_lilo() {
	printc "${CYAN}Installing LILO...${RESET}\n"
	if [[ "$(detect_firmware)" == "uefi" ]]; then
		printc "${RED}LILO does not support UEFI.${RESET}\n"
		return 1
	fi
	arch-chroot "$INSTALL_DEST" lilo
	printc "${GREEN}LILO installation complete.${RESET}\n"
}

install_systemd_boot() {
	local fw
	fw=$(detect_firmware)
	printc "${CYAN}Installing systemd-boot...${RESET}\n"
	if [[ "$fw" != "uefi" ]]; then
		printc "${RED}systemd-boot requires UEFI firmware.${RESET}\n"
		return 1
	fi
	if [[ ! -d "$INSTALL_DEST/efi/EFI" ]]; then
		printc "${RED}EFI System Partition not mounted at /efi inside target.${RESET}\n"
		return 1
	fi
	printc "${GREEN}Installing bootctl into ESP...${RESET}\n"
	arch-chroot "$INSTALL_DEST" bootctl install --esp-path=/efi
	if ! command; then
		printc "${RED}systemd-boot installation failed.${RESET}\n"
		return 1
	fi
	mkdir -p "$INSTALL_DEST/efi/loader"
	cat >"$INSTALL_DEST/efi/loader/loader.conf" <<EOF
default  athanor.conf
timeout  3
console-mode max
editor   no
EOF
	printc "${GREEN}Creating boot entry for kernel...${RESET}\n"
	local kernel
	kernel=$(arch-chroot "$INSTALL_DEST" bash -c "ls /lib/modules | sort -V | tail -n1")
	if [[ -z "$kernel" ]]; then
		printc "${RED}Could not detect kernel version.${RESET}\n"
		return 1
	fi
	mkdir -p "$INSTALL_DEST/efi/loader/entries"
	cat >"$INSTALL_DEST/efi/loader/entries/athanor.conf" <<EOF
title   Athanor Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=PARTUUID=$(blkid -s PARTUUID -o value "${DISK}1") rw
EOF
	printc "${GREEN}systemd-boot installation complete.${RESET}\n"
}

install_uki() {
	local fw
	fw=$(detect_firmware)
	printc "${CYAN}Installing UKI (Unified Kernel Image)...${RESET}\n"
	if [[ "$fw" != "uefi" ]]; then
		printc "${RED}UKI requires UEFI firmware.${RESET}\n"
		return 1
	fi
	local efi_dir="/efi/EFI/Linux"
	arch-chroot "$INSTALL_DEST" mkdir -p "$efi_dir"
	local kernel
	kernel=$(arch-chroot "$INSTALL_DEST" bash -c "ls /lib/modules | sort -V | tail -n1")
	if [[ -z "$kernel" ]]; then
		printc "${RED}Could not detect kernel version.${RESET}\n"
		return 1
	fi
	printc "${GREEN}Building UKI for kernel: $kernel${RESET}\n"
	arch-chroot "$INSTALL_DEST" mkinitcpio \
		-z xz \
		-k "/boot/vmlinuz-linux" \
		-c /etc/mkinitcpio.conf \
		-g "$efi_dir/athenar-linux.efi"
	if ! command; then
		printc "${RED}UKI build failed.${RESET}\n"
		return 1
	fi
	printc "${GREEN}UKI created at: %s/athenar-linux.efi${RESET}\n" "$efi_dir"
	if command -v efibootmgr >/dev/null 2>&1; then
		printc "${CYAN}Creating UEFI boot entry...${RESET}\n"
		arch-chroot "$INSTALL_DEST" efibootmgr \
			--create \
			--disk "$DISK" \
			--part 1 \
			--label "Athanor UKI" \
			--loader "\\EFI\\Linux\\athenar-linux.efi"
	fi
	printc "${GREEN}UKI installation complete.${RESET}\n"
}

install_other() {
	printc "${CYAN}Custom bootloader path selected.${RESET}\n"
	printc "${GRAY}No automated steps defined.${RESET}\n"
	return 0
}

module_run() {
	select_bootloader || return 1
	case "$BOOTLOADER" in
	grub)
		install_grub || return 1
		;;
	lilo)
		install_lilo || return 1
		;;
	systemd-boot)
		install_systemd_boot || return 1
		;;
	uki)
		install_uki || return 1
		;;
	custom)
		install_other || return 1
		;;
	esac
}

#EOF
