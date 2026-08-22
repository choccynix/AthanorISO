# ◈ Consuming the AthanorOS binhost

AthanorOS uses a two-part binary package service:

- **GitHub Pages** serves the Portage `Packages` index at
  `https://choccynix.github.io/athanor-binpkgs/`.
- **GitHub Releases** stores the actual `.gpkg.tar` package files. Each entry
  in `Packages` contains an absolute `URI:` pointing at its Release asset.

The ISO build already installs this repository configuration in
`/etc/portage/binrepos.conf/athanor.conf` and sets `PORTAGE_BINHOST` in
`/etc/portage/make.conf`. There is no need for the ISO builder to upload or
regenerate the binhost index. The `athanor-binpkgs` repository owns that job.

## Verify the binhost

From an AthanorOS installation or live environment:

```
curl -fsSL https://choccynix.github.io/athanor-binpkgs/Packages | head
```

Then check Portage's configuration:

```
emerge --info | grep PORTAGE_BINHOST
cat /etc/portage/binrepos.conf/athanor.conf
```

To test a package known to be in the binhost:

```
emerge --getbinpkg=y --usepkg=y gui-wm/sway
```

Portage should report a binary package when the package version, USE flags,
ABI, and keywords match the installed configuration. If it falls back to a
source build, check the package's USE flags and keyword acceptance first.

## Xorg vs XLibre

These are alternatives, not both-at-once. Installing both causes real file
collisions. Pick one of the package sets when constructing an image or
installation.

## GitHub Pages setup

The binhost workflow publishes `Packages` and `Packages.sig` to the
repository's `gh-pages` branch. In the GitHub repository settings, configure
**Pages → Build and deployment → Deploy from a branch → `gh-pages` / root**.

Once enabled, the URL above should serve `/Packages` directly. The workflow
also writes a `.nojekyll` marker so GitHub Pages does not try to transform the
repository contents.
