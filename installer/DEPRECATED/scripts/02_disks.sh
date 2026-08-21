#!/bin/bash
#scripts/02_disks.sh
# shellcheck disable=SC2034

MODULE_NAME="Disk Configuration"
MODULE_DESCRIPTION="Partition and mount installation disks"
MODULE_AUTHOR="ETJAKEOC"
MODULE_VERSION="1.0"

choose_disk() {
	printc "\n${CYAN}══════════════════════════════════════${RESET}\n"
	printc "${WHITE} Disk Selection${RESET}\n"
	printc "${CYAN}══════════════════════════════════════${RESET}\n\n"
	lsblk -d -n -b -o NAME,SIZE,MODEL | awk '$2 > 0'
	printc "\n${GREEN}>>> Select target disk number: ${RESET}"
	read -r disknum
	DISK_NAME=$(lsblk -d -n -o NAME | sed -n "${disknum}p")
	if [[ -z "$DISK_NAME" ]]; then
		printc "${RED}Invalid selection. Try again.${RESET}\n"
		return 1
	fi
	DISK="/dev/$DISK_NAME"
	printc "${GREEN}Selected:${RESET} $DISK\n"
}

confirm_wipe() {
	printc "\n${RED}⚠ WARNING ⚠${RESET}\n"
	printc "${WHITE}This will destroy ALL data on:${RESET} ${CYAN}%s${RESET}\n" "$DISK"
	printc "${WHITE}Type ${GREEN}YES${WHITE} to continue: ${RESET}"
	read -r confirm
	[[ "$confirm" == "YES" ]]
}

partition_disk() {
	printc "\n${CYAN}Partitioning disk...${RESET}\n"
	parted --script "$DISK" mklabel gpt \
		mkpart primary fat32 1MiB 512MiB \
		set 1 esp on \
		mkpart primary ext4 512MiB 100%
	mkfs.fat -F32 "${DISK}1"
	mkfs.ext4 "${DISK}2"
	printc "${GREEN}Partitioning complete.${RESET}\n"
}

mount_partitions() {
	printc "\n${CYAN}Mounting filesystem...${RESET}\n"
	mkdir -p "$INSTALL_DEST"
	mount "${DISK}2" "$INSTALL_DEST"
	mkdir -p "$INSTALL_DEST/efi"
	mount "${DISK}1" "$INSTALL_DEST/efi"
	printc "${GREEN}Mount complete:${RESET} $INSTALL_DEST\n"
}

module_run() {
	if ! choose_disk; then
		return 1
	fi
	if ! confirm_wipe; then
		printc "${RED}Aborted by user.${RESET}\n"
		return 1
	fi
	partition_disk
	mount_partitions
}

#EOF
