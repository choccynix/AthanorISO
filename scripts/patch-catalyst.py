#!/usr/bin/env python3
"""
Patch Catalyst upstream bugs before running a build.

Fix 1: main.py calls .extend() on a set() — sets have no extend().
Fix 2: kmerge.sh hardcodes gentoo-kernel instead of gentoo-kernel-bin.
"""
import os
import sys

def find_file(name, path_fragment=None):
    for root, dirs, files in os.walk('/'):
        for skip in ('/proc', '/sys', '/dev', '/run'):
            if root.startswith(skip):
                dirs.clear()
                break
        for f in files:
            if f == name:
                full = os.path.join(root, f)
                if path_fragment is None or path_fragment in full:
                    return full
    return None

errors = []

# Fix 1: main.py options.extend()
print("Searching for catalyst/main.py...")
main_py = find_file('main.py', 'catalyst')
if not main_py:
    errors.append("catalyst/main.py not found")
else:
    print(f"Found: {main_py}")
    with open(main_py) as f:
        src = f.read()
    old = 'conf_values["options"].extend(options)'
    new = 'conf_values["options"] = set(list(conf_values["options"]) + list(options))'
    if old in src:
        with open(main_py, 'w') as f:
            f.write(src.replace(old, new))
        print("Fix 1 applied: options.extend() -> set merge")
    else:
        print("Fix 1: pattern not found, may already be patched")

# Fix 2: kmerge.sh gentoo-kernel -> gentoo-kernel-bin
print("Searching for kmerge.sh...")
kmerge = find_file('kmerge.sh')
if not kmerge:
    errors.append("kmerge.sh not found")
else:
    print(f"Found: {kmerge}")
    with open(kmerge) as f:
        src = f.read()
    patched = src.replace('sys-kernel/gentoo-kernel"', 'sys-kernel/gentoo-kernel-bin"')
    with open(kmerge, 'w') as f:
        f.write(patched)
    print("Fix 2 applied: gentoo-kernel -> gentoo-kernel-bin")

if errors:
    print(f"\nERRORS: {errors}", file=sys.stderr)
    sys.exit(1)

print("\nAll patches applied.")
