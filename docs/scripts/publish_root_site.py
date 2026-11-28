#!/usr/bin/env python3
"""Publish the built Starlight site to the repo root for GitHub Pages.

Why: GitHub Pages is currently in legacy mode (source: main, path /),
which serves static files straight from the repo root — the Actions
workflow alone cannot change that setting (API token lacks permission).
Committing the built site at the root (like the committed Portable
artifact) makes https://molik-labs.github.io/MOLIK_WINLIK/ serve the
Starlight docs immediately, with zero repo-settings changes. If Pages
is later switched to "GitHub Actions", the workflow keeps deploying
the same docs/dist — both paths stay valid.

Usage:
  cd docs && npm ci && npm run build
  python3 docs/scripts/publish_root_site.py
Then commit the changed root files together with the docs sources.
Re-run after every docs change; audit_molik.py verifies the root
fallback exists and (when docs/dist is present) is byte-identical.
"""
import pathlib
import shutil
import sys

ROOT = pathlib.Path(__file__).resolve().parents[2]
DIST = ROOT / "docs" / "dist"

# Paths at the repo root that are owned by the published site.
MANAGED_FILES = [
    "index.html", "404.html",
    "sitemap-index.xml", "sitemap-0.xml",
    "favicon.svg", "logo.svg", "tui-preview.svg",
]
MANAGED_DIRS = ["_astro", "pagefind", "guide", "adr-001-engine-language"]


def main() -> int:
    if not (DIST / "index.html").exists():
        print("ERROR: docs/dist not found - run `cd docs && npm run build` first.")
        return 1

    for name in MANAGED_FILES:
        dst = ROOT / name
        if dst.exists():
            dst.unlink()
    for name in MANAGED_DIRS:
        dst = ROOT / name
        if dst.exists():
            shutil.rmtree(dst)

    copied = 0
    for item in DIST.iterdir():
        dst = ROOT / item.name
        if item.is_dir():
            shutil.copytree(item, dst)
            copied += sum(1 for _ in dst.rglob("*") if _.is_file())
        else:
            shutil.copy2(item, dst)
            copied += 1

    # .nojekyll: serve files exactly as built (Jekyll would drop _astro/)
    (ROOT / ".nojekyll").write_text("", encoding="ascii")
    print(f"OK: published {copied} site files to repo root (+ .nojekyll)")
    print("Commit them together with the docs/ sources.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
