# AthanorOS Installer

Place the contents of the athanor-installer repo here.

The build system copies everything in this directory into
`/opt/athanor-installer/` on the live ISO, and creates a
`/usr/local/bin/install-athanor` wrapper that calls `linter.sh`.

## Structure expected

```
installer/
├── linter.sh       ← entry point, called by install-athanor
└── ...             ← any other installer files
```
