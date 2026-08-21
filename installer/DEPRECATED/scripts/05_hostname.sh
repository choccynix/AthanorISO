#!/bin/bash
#scripts/05_hostname.sh
# shellcheck disable=SC2034

MODULE_NAME="Hostname Configuration"
MODULE_DESCRIPTION="Set system hostname and configure hosts file"
MODULE_AUTHOR="ETJAKEOC"
MODULE_VERSION="1.0"

set_hostname() {
	printc "\n${CYAN}══════════════════════════════════════${RESET}\n"
	printc "${WHITE} System Hostname Configuration${RESET}\n"
	printc "${CYAN}══════════════════════════════════════${RESET}\n\n"
	while true; do
		printc "${GREEN}Enter hostname: ${RESET}"
		read -r HOSTNAME
		HOSTNAME=$(echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]')
		if [[ ! "$HOSTNAME" =~ ^[a-z0-9]([a-z0-9-]*[a-z0-9])?$ ]]; then
			printc "${RED}Invalid hostname format.${RESET}\n"
			printc "${GRAY}Use lowercase letters, numbers, and hyphens only.${RESET}\n"
			continue
		fi
		break
	done
	local target="$INSTALL_DEST"
	if [[ -z "$target" ]]; then
		printc "${RED}No installation target found.${RESET}\n"
		return 1
	fi
	printc "\n${CYAN}Applying hostname...${RESET}\n"
	echo "$HOSTNAME" >"$target/etc/hostname"
	cat >"$target/etc/hosts" <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOF
	printc "${GREEN}Hostname set successfully:${RESET} $HOSTNAME\n"
}

module_run() {
	set_hostname
}

#EFO
