#!/bin/bash
#scripts/04_users.sh
# shellcheck disable=SC2034

MODULE_NAME="User Configuration"
MODULE_DESCRIPTION="Create user and configure sudo access"
MODULE_AUTHOR="ETJAKEOC"
MODULE_VERSION="1.0"

create_user() {
	printc "\n${CYAN}══════════════════════════════════════${RESET}\n"
	printc "${WHITE} User Account Setup${RESET}\n"
	printc "${CYAN}══════════════════════════════════════${RESET}\n\n"
	while true; do
		printc "${GREEN}Enter username: ${RESET}"
		read -r MYUSER
		if [[ ! "$MYUSER" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
			printc "${RED}Invalid username format.${RESET}\n"
			continue
		fi
		break
	done
	printc "${GREEN}Enter password: ${RESET}"
	read -rs MYPASS
	echo
	printc "${GREEN}Confirm password: ${RESET}"
	read -rs MYPASS_CONFIRM
	echo
	if [[ "$MYPASS" != "$MYPASS_CONFIRM" ]]; then
		printc "${RED}Passwords do not match.${RESET}\n"
		return 1
	fi
}

add_user_and_sudo() {
	printc "\n${CYAN}Creating user in target system...${RESET}\n"
	if [[ -z "$INSTALL_DEST" ]]; then
		printc "${RED}No valid mount target found.${RESET}\n"
		return 1
	fi
	local target="$INSTALL_DEST"
	arch-chroot "$target" useradd -m -s /bin/bash "$MYUSER"
	printc "%s:%s" "$MYUSER" "$MYPASS" | arch-chroot "$target" chpasswd
	printc "%s ALL=(ALL) ALL\n" "$MYUSER" >"$target/etc/sudoers.d/$MYUSER"
	chmod 440 "$target/etc/sudoers.d/$MYUSER"
	printc "${GREEN}User created successfully:${RESET} $MYUSER\n"
}

module_run() {
	create_user || return 1
	add_user_and_sudo || return 1
}

#EOF
