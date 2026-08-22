#!/usr/bin/env bash
# build.sh — AthanorOS build orchestrator
# Builds minimal and desktop editions via Catalyst
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALYST_DIR="/var/tmp/catalyst"
BUILDS_DIR="${CATALYST_DIR}/builds/athanor"
OUTPUT_DIR="${REPO_DIR}/output"
SPECS_DIR="${REPO_DIR}/catalyst/specs"
CATALYST_CONF="${REPO_DIR}/catalyst/catalyst.conf"
VERSION="${VERSION:-$(date +%Y%m%d)}"
BRANCH="${BRANCH:-main}"
# EDITIONS: space-separated list — "minimal", "desktop", or "minimal desktop"
EDITIONS="${EDITIONS:-minimal desktop}"
MIRROR="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-musl-llvm-openrc"

mkdir -p "${BUILDS_DIR}" "${OUTPUT_DIR}"

log() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  $*"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

fill_spec() {
  local src="$1" dst="$2"
  sed \
    -e "s|@VERSION@|${VERSION}|g" \
    -e "s|@TREEISH@|${TREEISH}|g" \
    -e "s|@REPO_DIR@|${REPO_DIR}|g" \
    "${src}" > "${dst}"
}

# ── AthanorOS binhost ─────────────────────────────────────────────────────────
# The binhost is a normal Portage repository. Its Packages index is served
# from GitHub Pages and the package blobs are hosted by GitHub Releases.
# Keep the ISO build itself read-only with respect to the binhost: package
# publishing belongs exclusively to the athanor-binpkgs repository workflow.
ATHANOR_BINHOST_URL="${ATHANOR_BINHOST_URL:-https://choccynix.github.io/binhost}"

log "Checking AthanorOS binhost"
if ! curl -fsSL --connect-timeout 20 --max-time 60 \
    -o /tmp/athanor-Packages "${ATHANOR_BINHOST_URL%/}/Packages"; then
  echo "ERROR: AthanorOS binhost is unavailable: ${ATHANOR_BINHOST_URL}"
  exit 1
fi
if [[ ! -s /tmp/athanor-Packages ]]; then
  echo "ERROR: AthanorOS binhost returned an empty Packages index."
  exit 1
fi
echo "Binhost OK: ${ATHANOR_BINHOST_URL} ($(wc -l < /tmp/athanor-Packages) lines)"

# ── Pre-flight USE flag check ─────────────────────────────────────────────────
log "Pre-flight USE flag check"
if ! emerge --pretend --nospinner --autounmask=n \
    dev-util/catalyst \
    sys-boot/grub \
    sys-apps/util-linux \
    sys-kernel/dracut \
    sys-kernel/gentoo-kernel-bin \
    sys-kernel/installkernel 2>&1; then
  echo "ERROR: USE flag pre-flight failed."
  exit 1
fi
echo "Pre-flight passed."

# ── Step 1: Fetch stage3 seed ─────────────────────────────────────────────────
log "Fetching stage3 seed"

FILELIST="/tmp/latest-stage3.txt"
curl -fsSL --connect-timeout 30 --max-time 60 \
  -o "${FILELIST}" \
  "${MIRROR}/latest-stage3-amd64-musl-llvm-openrc.txt"

LATEST=''
while IFS= read -r line; do
  [[ -z "${line}" ]]             && continue
  [[ "${line}" == '#'*  ]]       && continue
  [[ "${line}" == '-----'* ]]    && continue
  [[ "${line}" == 'Hash:'* ]]    && continue
  [[ "${line}" != *'.tar.xz'* ]] && continue
  LATEST="${line%% *}"
  break
done < "${FILELIST}"

if [[ -z "${LATEST}" ]]; then
  echo "ERROR: Could not parse stage3 filename"
  cat "${FILELIST}"
  exit 1
fi

TARBALL_NAME=$(basename "${LATEST}")
STAGE3_DEST="${BUILDS_DIR}/stage3-amd64-musl-llvm-openrc-${VERSION}.tar.xz"

if [[ ! -f "${STAGE3_DEST}" ]]; then
  echo "Downloading ${TARBALL_NAME}..."
  curl -fsSL --connect-timeout 30 --max-time 1800 --progress-bar \
    -o "${STAGE3_DEST}" "${MIRROR}/${TARBALL_NAME}"
else
  echo "Stage3 already present, skipping download."
fi

# ── Step 2: Portage snapshot ──────────────────────────────────────────────────
log "Creating Portage snapshot"
catalyst --configs "${CATALYST_CONF}" -s stable

TREEISH=''
for f in "${CATALYST_DIR}/snapshots/"*.sqfs; do
  [[ -f "${f}" ]] || continue
  base=$(basename "${f}")
  TREEISH="${base#gentoo-}"
  TREEISH="${TREEISH%.sqfs}"
  break
done

if [[ -z "${TREEISH}" ]]; then
  echo "ERROR: No snapshot found"
  exit 1
fi
echo "Snapshot: ${TREEISH}"

# ── Step 2.5: Stage installer files ──────────────────────────────────────────
log "Staging installer files"
if [[ -d "${REPO_DIR}/installer" ]]; then
  cp -r "${REPO_DIR}/installer" "${CATALYST_DIR}/installer"
  echo "Installer staged"
else
  echo "No installer/ directory — skipping"
fi

# ── Step 3+: Build each edition ──────────────────────────────────────────────
for EDITION in ${EDITIONS}; do
  log "Building edition: ${EDITION}"

  STAGE1_SPEC="${SPECS_DIR}/livecd-stage1-${EDITION}.spec"
  STAGE2_SPEC="${SPECS_DIR}/livecd-stage2-${EDITION}.spec"

  if [[ ! -f "${STAGE1_SPEC}" || ! -f "${STAGE2_SPEC}" ]]; then
    echo "ERROR: Spec files not found for edition '${EDITION}'"
    echo "  Expected: ${STAGE1_SPEC}"
    echo "  Expected: ${STAGE2_SPEC}"
    exit 1
  fi

  fill_spec "${STAGE1_SPEC}" "/tmp/athanor-stage1-${EDITION}.spec"
  fill_spec "${STAGE2_SPEC}" "/tmp/athanor-stage2-${EDITION}.spec"

  log "livecd-stage1 [${EDITION}]"
  catalyst --configs "${CATALYST_CONF}" -a -f "/tmp/athanor-stage1-${EDITION}.spec"

  log "livecd-stage2 [${EDITION}]"
  catalyst --configs "${CATALYST_CONF}" -a -f "/tmp/athanor-stage2-${EDITION}.spec"

  # Collect outputs for this edition
  ISO_SRC="${CATALYST_DIR}/builds/athanor/athanoros-${EDITION}-amd64-${VERSION}.iso"
  ISO_OUT="${OUTPUT_DIR}/athanoros-${EDITION}-amd64-${VERSION}.iso"

  cp "${ISO_SRC}" "${ISO_OUT}"
  pushd "${OUTPUT_DIR}" > /dev/null
  sha256sum "$(basename "${ISO_OUT}")" > "$(basename "${ISO_OUT}").sha256"
  popd > /dev/null
  echo "Edition complete: ${ISO_OUT}"
done

# ── Also output the stage3 tarball ───────────────────────────────────────────
TARBALL_OUT="${OUTPUT_DIR}/athanoros-stage3-amd64-${VERSION}.tar.xz"
cp "${STAGE3_DEST}" "${TARBALL_OUT}"
pushd "${OUTPUT_DIR}" > /dev/null
sha256sum "$(basename "${TARBALL_OUT}")" > "$(basename "${TARBALL_OUT}").sha256"
popd > /dev/null

echo ""
echo "All editions built. Outputs:"
ls -lh "${OUTPUT_DIR}/"
