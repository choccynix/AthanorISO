# 🧠 TKT  Git Workflow Guide

Welcome to the dev circle for **TKT**. This guide lays out the ground rules and basic workflow for contributing to these projects without turning the Git history into spaghetti or breaking shit on `main`.

## 🔧 Repo Purposes

- **[TKT](https://github.com/ETJAKEOC/TKT)**: The **kernel project**. We build and package Linux kernels here. No container stuff.

***Keep the boundaries clean:  ***
> If you're not building an actual kernel artifact, you're in the wrong repo.

## 🌲 Branching Strategy

- `main`: **Stable**, tested, shippable. This is what GH Actions will pull from. Breaking changes here = pain for everyone.
- `dev`: (optional) A shared in-progress branch, but **still test your stuff before pushing**.
- `your-feature-branch`: Create a new branch off `main` or `dev` for **every feature, fix, or tweak**.

```bash
git checkout -b fix/gcc-clang-parity
```
✅ Always branch
❌ Never push straight to main (unless you're fixing a typo in a comment)
