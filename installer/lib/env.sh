#!/bin/bash
#libs/env.sh
# shellcheck disable=SC2034
# shellcheck disable=SC2059

MODULE_TITLE="Athanor Installer Environment"

date="$(date -u +%-m/%d/%Y)"
export date
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIBS="$BASE_DIR/lib"
SCRIPTS="$BASE_DIR/scripts"
export INSTALL_DEST="/mnt/install_dest"

# shellcheck source=lib/colors.sh
source "$LIBS/colors.sh"
# shellcheck source=lib/helpers.sh
source "$LIBS/helpers.sh"
# shellcheck source=lib/logging.sh
source "$LIBS/logging.sh"
# shellcheck source=lib/logo.sh
source "$LIBS/logo.sh"
# shellcheck source=lib/menu.sh
source "$LIBS/menu.sh"
# shellcheck source=lib/ui.sh
source "$LIBS/ui.sh"
ui_init >/dev/null

#EOF
