#!/bin/bash
#scripts/03_base.sh
# shellcheck disable=SC2034

MODULE_NAME="Base System Installation"
MODULE_DESCRIPTION="Install core system files and generate fstab"
MODULE_AUTHOR="ETJAKEOC"
MODULE_VERSION="1.0"

install_base() {
	printc "\n${CYAN}══════════════════════════════════════${RESET}\n"
	printc "${WHITE} Base System Installation${RESET}\n"
	printc "${CYAN}══════════════════════════════════════${RESET}\n\n"
	printc "${GREEN}Installing base system...${RESET}\n\n"
	if [[ -z "$INSTALL_DEST" ]] || [[ ! -d "$INSTALL_DEST" ]]; then
		printc "${RED}Invalid INSTALL_DEST:${RESET} $INSTALL_DEST\n"
		return 1
	fi
	rsync -aHAXu --info=progress2 \
		--exclude={dev,sys,run,proc,home,root} \
		/ "$INSTALL_DEST"
	if ! command; then
		printc "${RED}Base system installation failed.${RESET}\n"
		return 1
	fi
	printc "\n${GREEN}Base system installed successfully.${RESET}\n"
}

generate_fstab() {
	printc "\n${CYAN}Generating fstab...${RESET}\n"
	if [[ ! -d "$INSTALL_DEST" ]]; then
		printc "${RED}Mount destination missing.${RESET}\n"
		return 1
	fi
	mkdir -p "$INSTALL_DEST/etc"
	genfstab -U "$INSTALL_DEST" >>"$INSTALL_DEST/etc/fstab"
	printc "${GREEN}fstab generated at:${RESET} $INSTALL_DEST/etc/fstab\n"
}

module_run() {
	install_base || return 1
	generate_fstab || return 1
}

#EOF
