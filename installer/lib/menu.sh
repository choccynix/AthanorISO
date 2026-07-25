#!/bin/bash
#libs/menu.sh
# shellcheck disable=SC2034
# shellcheck disable=SC2059

menu_load_scripts() {
	mapfile -t MENU_SCRIPTS < <(get_scripts)
}

menu_render_entries() {
	local i=1
	for script in "${MENU_SCRIPTS[@]}"; do
		local title
		title="$(format_title "$script")"
		ui_menu_entry "$i" "$title"
		((i++))
	done
}

menu_draw() {
	menu_load_scripts
	ui_banner
	ui_section "SYSTEM CONFIGURATION"
	menu_render_entries
	ui_footer
}

menu_handle_selection() {
	read -r selection

	case "${selection^^}" in
	Q)
		clear
		exit 0
		;;
	esac
	if ! [[ "$selection" =~ ^[0-9]+$ ]]; then
		return
	fi
	local index=$((selection - 1))
	local script="${MENU_SCRIPTS[$index]}"
	if [[ -z "$script" ]]; then
		return
	fi
	clear
	# shellcheck disable=SC1090
	source "$script"
	if declare -F module_run >/dev/null; then
		module_run
	else
		printc "${RED}ERROR:${RESET} module_run() missing in %s\n" "$script"
	fi
}

#EOF
