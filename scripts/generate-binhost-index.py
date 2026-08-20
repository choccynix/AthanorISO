#!/usr/bin/env python3
"""
generate-binhost-index.py

Fetches .gpkg.tar assets from the latest athanor-binpkgs release,
generates a Portage-compatible Packages index, and uploads it back
to the same release.

Run this from inside the Catalyst chroot or the build container.

Environment:
  GH_TOKEN   — GitHub token with contents:write on athanor-binpkgs
  BINPKG_REPO — owner/repo of the binpkg repo (default: choccynix/athanor-binpkgs)
"""

import json
import os
import re
import subprocess
import sys
import tarfile
import tempfile
import urllib.request
import urllib.error
from pathlib import Path

BINPKG_REPO = os.environ.get("BINPKG_REPO", "choccynix/athanor-binpkgs")
# BINPKGS_TOKEN: PAT with write access to athanor-binpkgs (for uploads)
# GH_TOKEN: fallback for reads only
BINPKGS_TOKEN = os.environ.get("BINPKGS_TOKEN", "")
GH_TOKEN_READ = os.environ.get("GH_TOKEN", "")
TOKEN         = BINPKGS_TOKEN or GH_TOKEN_READ  # upload uses BINPKGS_TOKEN
API         = f"https://api.github.com/repos/{BINPKG_REPO}"

HEADERS = {
    "Accept": "application/vnd.github+json",
    "X-GitHub-Api-Version": "2022-11-28",
}
if TOKEN:
    HEADERS["Authorization"] = f"Bearer {TOKEN}"


def api_get(path):
    req = urllib.request.Request(f"{API}{path}", headers=HEADERS)
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())


def download(url, dest):
    headers = dict(HEADERS)
    headers["Accept"] = "application/octet-stream"
    req = urllib.request.Request(url, headers=headers)
    with urllib.request.urlopen(req) as r, open(dest, "wb") as f:
        while chunk := r.read(65536):
            f.write(chunk)


def upload_asset(upload_url, filepath, token):
    data = Path(filepath).read_bytes()
    req  = urllib.request.Request(
        f"{upload_url}?name={Path(filepath).name}",
        data=data,
        headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/octet-stream",
            "Accept": "application/vnd.github+json",
        },
        method="POST",
    )
    with urllib.request.urlopen(req) as r:
        return json.loads(r.read())


def extract_pkg_metadata(gpkg_path):
    """
    Extract CPV and metadata from a .gpkg.tar file.
    gpkg format: outer tar containing <cpv>/package.tar + <cpv>/environment.tar.xz etc.
    """
    meta = {}
    try:
        with tarfile.open(gpkg_path, "r") as outer:
            # Find the environment or package.tar inside
            for member in outer.getmembers():
                if member.name.endswith("/package.tar"):
                    # CPV is the directory name
                    cpv_dir = member.name.split("/")[0]
                    meta["CPV"] = cpv_dir
                    break
            # Try to get SIZE
            meta["SIZE"] = str(Path(gpkg_path).stat().st_size)
            meta["PATH"] = Path(gpkg_path).name
    except Exception as e:
        print(f"  Warning: could not parse {gpkg_path}: {e}")
    return meta


# ── Get latest release ────────────────────────────────────────────────────────
print(f"Fetching latest release from {BINPKG_REPO}...")
release = api_get("/releases/latest")
release_id   = release["id"]
upload_url   = release["upload_url"].split("{")[0]
tag          = release["tag_name"]
assets       = release["assets"]

print(f"Release: {tag} ({len(assets)} assets)")

gpkg_assets = [a for a in assets if a["name"].endswith(".gpkg.tar")]
print(f"Found {len(gpkg_assets)} .gpkg.tar packages")

if not gpkg_assets:
    print("No packages found — nothing to index.")
    sys.exit(0)

# ── Download and index packages ───────────────────────────────────────────────
packages_lines = []
packages_lines.append("PACKAGES: 1")
packages_lines.append(f"TIMESTAMP: {tag}")
packages_lines.append("")

with tempfile.TemporaryDirectory() as tmpdir:
    for asset in gpkg_assets:
        name     = asset["name"]
        dl_url   = asset["browser_download_url"]
        dest     = os.path.join(tmpdir, name)

        print(f"  Downloading {name}...")
        download(dl_url, dest)

        meta = extract_pkg_metadata(dest)
        if not meta.get("CPV"):
            # Fall back: derive CPV from filename (strip .gpkg.tar)
            cpv = name.replace(".gpkg.tar", "")
            # Convert Name-Version-Revision to cat/name-ver format if possible
            meta["CPV"] = cpv

        # Write package entry
        packages_lines.append(f"CPV: {meta['CPV']}")
        packages_lines.append(f"PATH: {name}")
        packages_lines.append(f"SIZE: {meta.get('SIZE', '0')}")
        packages_lines.append(f"URI: {dl_url}")
        packages_lines.append("")

    # Write Packages index
    packages_path = os.path.join(tmpdir, "Packages")
    with open(packages_path, "w") as f:
        f.write("\n".join(packages_lines))

    print(f"Generated Packages index ({len(gpkg_assets)} entries)")

    # Delete existing Packages asset if present
    for asset in assets:
        if asset["name"] == "Packages":
            print(f"Deleting old Packages asset {asset['id']}...")
            req = urllib.request.Request(
                f"{API}/releases/assets/{asset['id']}",
                headers=HEADERS,
                method="DELETE",
            )
            try:
                urllib.request.urlopen(req)
            except urllib.error.HTTPError as e:
                if e.code != 204:
                    raise

    # Upload new Packages index
    if TOKEN:
        print("Uploading Packages index...")
        upload_asset(upload_url, packages_path, TOKEN)
        print("Done.")
    else:
        print("No GH_TOKEN — skipping upload. Packages index written locally.")
        print(Path(packages_path).read_text()[:500])
