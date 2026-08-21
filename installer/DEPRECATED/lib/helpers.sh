#!/bin/bash
#libs/helpers.sh
# shellcheck disable=SC2034
# shellcheck disable=SC2059

menu_loop() {
	while true; do
		clear
		menu_draw
		menu_handle_selection
	done
}

printc() {
	printf '%b' "$*"
}

strip_ansi() {
	printf '%s' "$1" | sed -E 's/\x1B\[[0-9;]*[mK]//g'
}

get_libs() {
	printf '%s\n' "$LIBS"/*.sh | sort
}

get_scripts() {
	printf '%s\n' "$SCRIPTS"/*.sh | sort
}

command_exists() {
	command -v "$1" >/dev/null 2>&1
}

format_title() {
	local file="$1"
	local name
	name="$(basename "$file" .sh)"
	name="${name#[0-9][0-9]_}"
	name="${name//_/ }"
	name="${name//-/ }"
	name=$(sed -E 's/\b(.)/\U\1/g' <<<"$name")
	echo "$name"
}

#EOF
