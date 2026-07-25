#!/usr/bin/env python3
"""
Create or update a GitHub Release and upload build artifacts.
Uses only stdlib — no gh CLI or jq needed.
"""
import datetime
import json
import os
import sys
import urllib.request
import urllib.error
from pathlib import Path

TOKEN      = os.environ["GH_TOKEN"]
REPO       = os.environ["REPO"]
BRANCH     = os.environ["BRANCH"]
EVENT      = os.environ["EVENT"]
PUBLISH    = os.environ.get("PUBLISH_INPUT", "false").lower() == "true"
RUN_NUMBER = os.environ.get("RUN_NUMBER", "?")
VERSION    = os.environ.get("VERSION", "unknown")
OUTPUT_DIR = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/athanor/output")

API     = f"https://api.github.com/repos/{REPO}"
HEADERS = {
    "Authorization": f"Bearer {TOKEN}",
    "Content-Type": "application/json",
    "X-GitHub-Api-Version": "2022-11-28",
    "Accept": "application/vnd.github+json",
}

is_release = (
    BRANCH == "main"
    or EVENT == "schedule"
    or (EVENT == "workflow_dispatch" and PUBLISH)
)

build_date  = datetime.date.today().isoformat()
safe_branch = BRANCH.replace("/", "-")

if is_release:
    tag        = f"rolling-{VERSION}"
    title      = f"AthanorOS Rolling Build {build_date}"
    prerelease = False
    body = (
        f"## AthanorOS Rolling Build — {build_date}\n\n"
        "Built from Gentoo stage3 musl+llvm+openrc using Catalyst.\n\n"
        "| File | Description |\n"
        "|---|---|\n"
        "| `athanoros-amd64-*.iso` | Bootable ISO (BIOS + UEFI) |\n"
        "| `athanoros-stage3-amd64-*.tar.xz` | Rootfs tarball |\n"
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

def api_request(method, path, data=None):
    url  = f"{API}{path}"
    body = json.dumps(data).encode() if data else None
    req  = urllib.request.Request(url, data=body, headers=HEADERS, method=method)
    try:
        with urllib.request.urlopen(req) as r:
            raw = r.read()
            return json.loads(raw) if raw.strip() else None
    except urllib.error.HTTPError as e:
        if e.code in (404, 204):
            return None
        raise

def upload_asset(upload_url, filepath):
    data = filepath.read_bytes()
    req  = urllib.request.Request(
        f"{upload_url}?name={filepath.name}",
        data=data,
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/octet-stream",
            "Accept": "application/vnd.github+json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())

print(f"Tag: {tag}")
existing = api_request("GET", f"/releases/tags/{tag}")
if existing and "id" in existing:
    print(f"Deleting existing release {existing['id']}...")
    api_request("DELETE", f"/releases/{existing['id']}")
    api_request("DELETE", f"/git/refs/tags/{tag}")
    print("Deleted.")

print(f"Creating: {title}")
release = api_request("POST", "/releases", {
    "tag_name":   tag,
    "name":       title,
    "body":       body,
    "draft":      False,
    "prerelease": prerelease,
    "make_latest": str(not prerelease).lower(),
})

upload_url = release["upload_url"].split("{")[0]
files = sorted(f for f in OUTPUT_DIR.iterdir() if f.is_file())

if not files:
    print("ERROR: No files found in output directory!", file=sys.stderr)
    sys.exit(1)

for f in files:
    size_mb = f.stat().st_size // 1024 // 1024
    print(f"Uploading {f.name} ({size_mb} MB)...")
    upload_asset(upload_url, f)
    print(f"  ✓ {f.name}")

print(f"\nDone: https://github.com/{REPO}/releases/tag/{tag}")
