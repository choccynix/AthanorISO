#!/usr/bin/env bash
# build.sh — AthanorOS build orchestrator (Catalyst-based)
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CATALYST_DIR="/var/tmp/catalyst"
BUILDS_DIR="${CATALYST_DIR}/builds/athanor"
OUTPUT_DIR="${REPO_DIR}/output"
SPECS_DIR="${REPO_DIR}/catalyst/specs"
CATALYST_CONF="${REPO_DIR}/catalyst/catalyst.conf"
VERSION="${VERSION:-$(date +%Y%m%d)}"
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
  echo "Fix flags in:      ${REPO_DIR}/catalyst/portage/package.use/athanor"
  echo "Fix host flags in: /etc/portage/package.use/catalyst-host"
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
  echo "ERROR: Could not parse stage3 filename from:"
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
  echo "ERROR: No snapshot found in ${CATALYST_DIR}/snapshots/"
  exit 1
fi
echo "Snapshot: ${TREEISH}"

# ── Step 2.5: Stage installer files for fsscript ─────────────────────────────
log "Staging installer files"
if [[ -d "${REPO_DIR}/installer" ]]; then
  cp -r "${REPO_DIR}/installer" "${CATALYST_DIR}/installer"
  echo "Installer staged from ${REPO_DIR}/installer"
else
  echo "No installer/ directory found in repo — skipping"
fi

# ── Step 3: livecd-stage1 ────────────────────────────────────────────────────
log "Running livecd-stage1"
fill_spec "${SPECS_DIR}/livecd-stage1.spec" "/tmp/athanor-stage1.spec"
catalyst --configs "${CATALYST_CONF}" -a -f /tmp/athanor-stage1.spec

# ── Step 4: livecd-stage2 ────────────────────────────────────────────────────
log "Running livecd-stage2 (kernel + ISO)"
fill_spec "${SPECS_DIR}/livecd-stage2.spec" "/tmp/athanor-stage2.spec"
catalyst --configs "${CATALYST_CONF}" -a -f /tmp/athanor-stage2.spec

# ── Step 5: Collect outputs ───────────────────────────────────────────────────
log "Collecting outputs"

ISO_SRC="${CATALYST_DIR}/builds/athanor/athanoros-amd64-${VERSION}.iso"
ISO_OUT="${OUTPUT_DIR}/athanoros-amd64-${VERSION}.iso"
TARBALL_OUT="${OUTPUT_DIR}/athanoros-stage3-amd64-${VERSION}.tar.xz"

cp "${ISO_SRC}" "${ISO_OUT}"
cp "${STAGE3_DEST}" "${TARBALL_OUT}"

pushd "${OUTPUT_DIR}" > /dev/null
sha256sum "$(basename "${ISO_OUT}")"     > "$(basename "${ISO_OUT}").sha256"
sha256sum "$(basename "${TARBALL_OUT}")" > "$(basename "${TARBALL_OUT}").sha256"
popd > /dev/null

echo ""
echo "Build complete. Outputs:"
ls -lh "${OUTPUT_DIR}/"
