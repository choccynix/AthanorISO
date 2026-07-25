#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"

mapfile -d '' FILES < <(
	find "$ROOT" \
		-type f \
		-name '*.sh' \
		-not -path '*/.git/*' \
		-print0
)

printf '==> Running shellcheck\n'
shellcheck \
	--external-sources \
	--severity=style \
	"${FILES[@]}"
