#!/bin/bash
#libs/ui.sh
# shellcheck disable=SC2034
# shellcheck disable=SC2059

: "${UI_WIDTH:=54}"
INNER_WIDTH=0

ui_init() {
	local cols
	cols=$(tput cols 2>/dev/null)
	if [[ -n "$cols" ]] && ((cols > 20)); then
		UI_WIDTH=$((cols - 10))
		((UI_WIDTH > 100)) && UI_WIDTH=100
		((UI_WIDTH < 40)) && UI_WIDTH=40
	fi
	INNER_WIDTH=$((UI_WIDTH - 2))
}

ui_len() {
	strip_ansi "$1" | awk '{print length}'
}

ui_repeat() {
	local char="$1"
	local count="$2"
	local i
	for ((i = 0; i < count; i++)); do
		printf "%s" "$char"
	done
}

ui_pad_right() {
	local text="$1"
	local width="$2"
	printc "%-*s" "$width" "$text"
}

ui_center() {
	local text="$1"
	local width="${2:-$INNER_WIDTH}"
	local clean
	clean=$(strip_ansi "$text")
	local len=${#clean}
	((len >= width)) && {
		printf "%s" "$text"
		return
	}
	local left=$(((width - len) / 2))
	local right=$((width - len - left))
	printf "%*s%s%*s" \
		"$left" "" \
		"$text" \
		"$right" ""
}

ui_border_top() {
	printc "╔$(ui_repeat '═' "$INNER_WIDTH")╗\n"
}

ui_border_bottom() {
	printc "╚$(ui_repeat '═' "$INNER_WIDTH")╝\n"
}

ui_border_divider() {
	printc "╠$(ui_repeat '═' "$INNER_WIDTH")╣\n"
}

ui_line() {
	local text="$1"
	local len pad
	len=$(ui_len "$text")
	pad=$((INNER_WIDTH - len))
	((pad < 0)) && pad=0
	printf "║ %s%*s ║\n" "$text" "$pad" ""
}

ui_blank() {
	ui_line ""
}

ui_title() {
	local title="$1"
	ui_border_top
	ui_line "$(ui_center "$title")"
	ui_border_divider
}

ui_section() {
	local title="$1"
	printc "\n${CYAN}"
	ui_title "$title"
	printc "${RESET}\n"
}

ui_menu_entry() {
	local index="$1"
	local title="$2"
	local content
	printf -v content " [%s] %s" "$index" "$title"
	ui_line "$content"
}

ui_info() {
	printc "${CYAN}[*]${RESET} %s\n" "$1"
}

ui_success() {
	printc "${GREEN}[+]${RESET} %s\n" "$1"
}

ui_warn() {
	printc "${YELLOW}[!]${RESET} %s\n" "$1"
}

ui_error() {
	printc "${RED}[X]${RESET} %s\n" "$1"
}

ui_banner() {
	printc "\n"
	printc "${WHITE}"
	printf "%s\n" \
		"    A T H A N O R   I N S T A L L   S Y S T E M"
	printc "${GRAY}"
	printf "%s\n\n" \
		"         Forge Node :: Interactive TTY"
	ui_border_top
	ui_line "${CYAN}SYSTEM${RESET}     :: Athanor Installer"
	ui_line "${CYAN}VERSION${RESET}    :: 0.01"
	ui_line "${CYAN}AUTHOR${RESET}     :: ETJAKEOC"
	ui_line "${CYAN}DATE/TIME${RESET}  :: $(date '+%m/%d/%Y %H:%M')"
	ui_border_bottom
	printc "\n"
}

ui_footer() {
	printc "\n"
	ui_border_top
	ui_line "${RED}[Q]${RESET} Exit Installer"
	ui_border_bottom
	printc "\n${GREEN}>>>${RESET} Select Option: "
}

#EOF
