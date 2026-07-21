#!/usr/bin/env python3
"""
Create or update a GitHub Release and upload build artifacts.
Called by the CI workflow — uses only stdlib, no gh CLI needed.

Usage:
  python3 upload-release.py <output_dir>

Environment variables (all required):
  GH_TOKEN       GitHub token with contents:write
  REPO           owner/repo  (e.g. choccynix/AnthorISO)
  BRANCH         Current branch name
  EVENT          GitHub event name (push, schedule, workflow_dispatch)
  PUBLISH_INPUT  'true' if manual dispatch requested a release
  RUN_NUMBER     GitHub Actions run number
  VERSION        Build date string e.g. 20260721
"""

import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path

# ── Config from environment ───────────────────────────────────────────────────
TOKEN       = os.environ["GH_TOKEN"]
REPO        = os.environ["REPO"]
BRANCH      = os.environ["BRANCH"]
EVENT       = os.environ["EVENT"]
PUBLISH     = os.environ.get("PUBLISH_INPUT", "false").lower() == "true"
RUN_NUMBER  = os.environ.get("RUN_NUMBER", "?")
VERSION     = os.environ.get("VERSION", "unknown")
OUTPUT_DIR  = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/anthoros/output")

API         = f"https://api.github.com/repos/{REPO}"
HEADERS     = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json",
    "X-GitHub-Api-Version": "2022-11-28",
}

# ── Decide release vs artifact ────────────────────────────────────────────────
is_release = (
    BRANCH == "main"
    or EVENT == "schedule"
    or (EVENT == "workflow_dispatch" and PUBLISH)
)

import datetime
build_date = datetime.date.today().isoformat()
safe_branch = BRANCH.replace("/", "-")

if is_release:
    tag        = f"rolling-{VERSION}"
    title      = f"AnthorOS Rolling Build {build_date}"
    prerelease = False
    body = (
        f"## AnthorOS Rolling Build — {build_date}\n\n"
        "Built from Gentoo stage3 musl+llvm+openrc using Catalyst.\n\n"
        "| File | Description |\n"
        "|---|---|\n"
        "| `anthoros-amd64-*.iso` | Bootable ISO (BIOS + UEFI) |\n"
        "| `anthoros-stage3-amd64-*.tar.xz` | Rootfs tarball |\n"
        "| `*.sha256` | SHA-256 checksums |\n\n"
        f"Built by GitHub Actions · Run `{RUN_NUMBER}` · Branch `{BRANCH}`"
    )
else:
    tag        = f"artifacts-{safe_branch}"
    title      = f"Dev artifact: {BRANCH} ({build_date})"
    prerelease = True
    body       = (
        f"Dev build from branch `{BRANCH}` — "
        f"run {RUN_NUMBER}. Not a stable release."
    )

# ── Helpers ───────────────────────────────────────────────────────────────────
def api_request(method, path, data=None, extra_headers=None):
    url = f"{API}{path}"
    body = json.dumps(data).encode() if data else None
    headers = dict(HEADERS)
    if extra_headers:
        headers.update(extra_headers)
    req = urllib.request.Request(url, data=body, headers=headers, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            return json.loads(r.read())
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise

def upload_file(upload_url, filepath):
    data = filepath.read_bytes()
    req = urllib.request.Request(
        f"{upload_url}?name={filepath.name}",
        data=data,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/octet-stream",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())

# ── Delete existing release if present ───────────────────────────────────────
print(f"Tag: {tag}")
existing = api_request("GET", f"/releases/tags/{tag}")
if existing and "id" in existing:
    print(f"Deleting existing release {existing['id']}...")
    api_request("DELETE", f"/releases/{existing['id']}")
    api_request("DELETE", f"/git/refs/tags/{tag}")

# ── Create release ────────────────────────────────────────────────────────────
print(f"Creating release: {title}")
release = api_request("POST", "/releases", {
    "tag_name":   tag,
    "name":       title,
    "body":       body,
    "draft":      False,
    "prerelease": prerelease,
    "make_latest": str(not prerelease).lower(),
})

upload_url = release["upload_url"].split("{")[0]
print(f"Upload URL: {upload_url}")

# ── Upload all output files ───────────────────────────────────────────────────
files = sorted(OUTPUT_DIR.iterdir())
if not files:
    print("ERROR: No files found in output directory!", file=sys.stderr)
    sys.exit(1)

for f in files:
    if not f.is_file():
        continue
    print(f"Uploading {f.name} ({f.stat().st_size // 1024 // 1024} MB)...")
    upload_file(upload_url, f)
    print(f"  done.")

print(f"\nRelease published: https://github.com/{REPO}/releases/tag/{tag}")
