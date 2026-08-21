#!/bin/bash
#libs/logo.sh
# shellcheck disable=SC2034
# shellcheck disable=SC2059

splash() {
	tput civis 2>/dev/null
	clear
	printc "${BLUE}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@@@@@@@@@${PURPLE}%%#******#%%${BLUE}@@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@@@@${PURPLE}********************${BLUE}@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@${PURPLE}**********#${BLUE}@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@${PURPLE}*********#${BLUE}@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@${PURPLE}*********%%${BLUE}@@@@@@@@@@@${GRAY}%%-${BLUE}@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@${PURPLE}%%*********${BLUE}@@@@@@@@@@${GRAY}*-------#${BLUE}@@@@@@@@@@@@@@\n"
	printc "@@@@@${PURPLE}*********#${BLUE}@@@@@@@@${GRAY}=-------------+${BLUE}@@@@@@@@@@@@\n"
	printc "@@@@${PURPLE}#*********${BLUE}@@@@@@${GRAY}=-------------------+${BLUE}@@@@@@@@@\n"
	printc "@@@@${PURPLE}*********${BLUE}@@@@@${VIOLET}#+=${GRAY}-------------------${LAVENDER}=#${BLUE}@@@@@@@@\n"
	printc "@@@${PURPLE}*********%${BLUE}@@@@@@${VIOLET}#++++=${GRAY}-------------${LAVENDER}+****${BLUE}@@@@@@@\n"
	printc "@@@${PURPLE}*********${BLUE}@@@@@@${VIOLET}#+++++++=${GRAY}-------${LAVENDER}********${BLUE}@@@@@@@@\n"
	printc "@@${PURPLE}#*********${BLUE}@@@@@@${VIOLET}#+++++++++++${GRAY}=${LAVENDER}***********${BLUE}@@@@@@@@\n"
	printc "@@${PURPLE}#*********${BLUE}@@@@@@${VIOLET}#+++++++++++${LAVENDER}************${BLUE}@@@@@@@@\n"
	printc "@@${PURPLE}#*********%${BLUE}@@@@@${VIOLET}#+++++++++++${LAVENDER}************${BLUE}@@@@@@@@\n"
	printc "@@@${PURPLE}**********${BLUE}@@@@@${VIOLET}#+++++++++++${LAVENDER}************${BLUE}@@@@@@@@\n"
	printc "@@@${PURPLE}***********${BLUE}@@@@${VIOLET}%%+++++++++++${LAVENDER}************${BLUE}@@@@@@@\n"
	printc "@@@@${PURPLE}**********${BLUE}#@@@@@@@${VIOLET}++++++++${LAVENDER}********#${BLUE}@@@@@@@@@@@\n"
	printc "@@@@${PURPLE}#***********${BLUE}@@@@@@@@@${VIOLET}+++++${LAVENDER}*****#${BLUE}@@@@@@@@@#@@@@\n"
	printc "@@@@@${PURPLE}************${BLUE}%%@@@@@@@@@@${VIOLET}++${LAVENDER}**#${BLUE}@@@@@@@@@@${PURPLE}%%*${BLUE}@@@\n"
	printc "@@@@@@${PURPLE}%%************${BLUE}#@@@@@@@@@@@@@@@@@@@@@${PURPLE}#*#${BLUE}@@@@@\n"
	printc "@@@@@@@@${PURPLE}***************${BLUE}@@@@@@@@@@@@@@@${PURPLE}****${BLUE}@@@@@@@@\n"
	printc "@@@@@@@@@@${PURPLE}******************************${BLUE}@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@${PURPLE}**************************${BLUE}@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@@@@${PURPLE}********************${BLUE}@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@@@@@@@@@${PURPLE}%%#******#%%${BLUE}@@@@@@@@@@@@@@@@@@\n"
	printc "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@${RESET}\n"
	printc "\n"
	printc "${GRAY}          ·         *             ✦              ·\n"
	printc "     *             ·                     *\n\n${RESET}"

	printc "${LAVENDER}"
	cat <<"EOF"
 █████╗ ████████╗██╗  ██╗ █████╗ ███╗   ██╗ ██████╗ ██████╗
██╔══██╗╚══██╔══╝██║  ██║██╔══██╗████╗  ██║██╔═══██╗██╔══██╗
███████║   ██║   ███████║███████║██╔██╗ ██║██║   ██║██████╔╝
██╔══██║   ██║   ██╔══██║██╔══██║██║╚██╗██║██║   ██║██╔══██╗
██║  ██║   ██║   ██║  ██║██║  ██║██║ ╚████║╚██████╔╝██║  ██║
╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝  ╚═╝
EOF

	printc "${RESET}\n"

	printc "         ${WHITE}A T H A N O R   I N S T A L L   S Y S T E M${RESET}\n"
	sleep 3
	clear
	tput cnorm 2>/dev/null
}

#EOF
