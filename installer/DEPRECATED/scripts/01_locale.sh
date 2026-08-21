#!/bin/bash
#scripts/01_locale.sh
# shellcheck disable=SC2034

module_run() {
	ui_section "Locale / Timezone Configuration"

	ui_info "Available timezones:"
	echo

	find /usr/share/zoneinfo \
		-maxdepth 1 \
		-type d | head -n 20 | nl

	ui_prompt "Enter your Continent/City:"
	read -r TZ

	if [[ ! -e "/usr/share/zoneinfo/$TZ" ]]; then
		ui_error "Invalid timezone selection."
		return 1
	fi

	ln -sf \
		"/usr/share/zoneinfo/$TZ" \
		"$INSTALL_DEST/etc/localtime"

	arch-chroot "$INSTALL_DEST" hwclock --systohc

	ui_success "Timezone set to: $TZ"

	ui_info "Generating locale configuration..."

	sed -i \
		's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' \
		"$INSTALL_DEST/etc/locale.gen"

	arch-chroot "$INSTALL_DEST" locale-gen

	echo "LANG=en_US.UTF-8" \
		>"$INSTALL_DEST/etc/locale.conf"

	ui_success "Locale configured successfully."
}

#EOF
