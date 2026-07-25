# AthanorOS Installer

Thanks to Jake for writing this installer! all copyrights go to him

The build system copies everything in this directory into
`/opt/athanor-installer/` on the live ISO, and creates a
`/usr/local/bin/install-athanor` wrapper that calls `linter.sh`.

## Structure expected

```
installer/
├── linter.sh       ← entry point, called by install-athanor
└── ...             ← any other installer files
```
