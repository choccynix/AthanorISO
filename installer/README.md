# AthanorOS Installer

This installer was created by: ETJAKEOC. he has left the organization. all credits go to him. the installer has not been tested so BE WARNED

the files shoved in here are now hosted at - https://github.com/choccynix/athanor-installer

The build system copies everything in this directory into
`/opt/athanor-installer/` on the live ISO, and creates a
`/usr/local/bin/install-athanor` wrapper that calls `Athanor_installer.sh`.

## Structure expected

```
installer/
├── Athanor_installer.sh       ← entry point, called by install-athanor
└── ...                        ← any other installer files
```
