# AnthorOS — Contributing

## Branch Strategy

```
main
 └── dev
      ├── feature/desktop-environment
      ├── feature/installer
      ├── fix/grub-config
      └── fix/dracut-modules
```

| Branch | Purpose | CI Output |
|---|---|---|
| `main` | Stable, tested builds | GitHub Release + weekly auto-build |
| `dev` | Integration branch | Build artifact (14 day retention) |
| `feature/*` | New features | Build artifact |
| `fix/*` | Bug fixes | Build artifact |

**Never commit directly to `main`.** PRs only, from `dev`.

---

## Workflow

1. **Branch from `dev`**
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-thing
   ```

2. **Make your changes**

3. **Push and open a PR into `dev`**
   ```bash
   git push origin feature/your-thing
   # Open PR: feature/your-thing → dev
   ```

4. **CI builds an artifact** — download and test the ISO

5. **PR gets reviewed and merged into `dev`**

6. **When `dev` is stable, PR `dev` → `main`** — this triggers a GitHub Release

---

## What Goes Where

| Change | Where |
|---|---|
| New packages for the ISO | `catalyst/specs/livecd-stage1.spec` → `livecd/packages` |
| USE flag changes | `catalyst/portage/package.use/anthoros` |
| New keyword overrides | `catalyst/portage/package.accept_keywords/anthoros` |
| License acceptances | `catalyst/portage/package.license/anthoros` |
| Build script changes | `scripts/build.sh` |
| Catalyst bug patches | `scripts/patch-catalyst.py` |
| Documentation | `docs/` |

---

## Code Standards

- Shell scripts: `set -euo pipefail` at the top, no pipelines with `head` (SIGPIPE under GitHub Actions)
- Python: standard library only where possible, no magic
- Commit messages: `type: short description` — types are `feat`, `fix`, `docs`, `refactor`, `ci`
- Keep PRs focused — one thing per PR

---

## Reporting Issues

Open an issue with:
- The full CI log (or the relevant section)
- The branch you were on
- What you expected vs what happened
