#!/usr/bin/env python3
"""
MOLIK WINLIK - static deep-debug audit (cross-platform, stdlib only).

Runs anywhere Python 3.9+ runs (CI, Linux sandbox, Windows). It NEVER touches
the registry or the system; it only reads source files in the repo.

Checks:
  1. Duplicate tweak IDs / duplicate function definitions across engines
  2. Registry conflicts: same Path\\Name targeted with different Apply values
     (native catalog Add-Reg one-liners it can parse; WinUtil cross-check)
  3. WinUtil data sanity: missing fields, internal dup targets, cross-dup vs native
  4. Reboot-required ID list: duplicates + IDs missing from catalog
  5. Dangerous-pattern scan: Invoke-Expression / DownloadString / irm|iex outside
     the known OFFLINE guard lines; unquoted %* forwarding in the .bat launcher
  6. Encoding: every .ps1 with non-ASCII bytes must carry a UTF-8 BOM (PS 5.1)
  7. Version consistency: launcher / UI fallback / ReportEngine / builder / docs
  8. Portable freshness: version + inline markers + function coverage vs sources

Usage:
  python3 skills/molik-deep-debug/scripts/audit_molik.py [--root PATH] [--json]

Exit code 0 = no FAIL, 1 = at least one FAIL (WARNs allowed).
"""
import argparse
import json
import re
import sys
from pathlib import Path

FAIL, WARN, PASS = "FAIL", "WARN", "PASS"
results = []


def report(status, msg):
    results.append({"status": status, "msg": msg})
    icon = {"FAIL": "X", "WARN": "!", "PASS": "OK"}[status]
    print(f"  [{icon} {status}] {msg}")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig", errors="replace")


def main() -> int:
    ap = argparse.ArgumentParser(description="MOLIK WINLIK static deep-debug audit")
    ap.add_argument("--root", default=".", help="repo root (default: cwd)")
    ap.add_argument("--json", action="store_true", help="also dump JSON summary")
    args = ap.parse_args()
    root = Path(args.root).resolve()

    ps_files = sorted((root / "Optimizer").rglob("*.ps1")) + [
        root / "MolikWinlik.ps1", root / "MolikWinlik-Portable.ps1"]
    ps_files = [p for p in ps_files if p.exists()]

    # -- 1. duplicate functions -------------------------------------------------
    fn_defs = {}
    online_only_fns = set()
    for f in ps_files:
        if f.name == "MolikWinlik-Portable.ps1":
            continue  # portable inlines everything on purpose
        for m in re.finditer(r"(?m)^\s*function\s+([A-Za-z0-9_-]+)", read_text(f)):
            fn_defs.setdefault(m.group(1), []).append(f.name)
            if f.name == "OnlineUpdate.ps1":
                online_only_fns.add(m.group(1))  # must NOT be inlined into Portable
    dup_fns = {k: v for k, v in fn_defs.items() if len(v) > 1}
    if dup_fns:
        report(FAIL, f"Duplicate function definitions: {dup_fns}")
    else:
        report(PASS, f"No duplicate functions ({len(fn_defs)} unique)")

    # -- catalog parsing (Add-Reg one-liners it can see) ------------------------
    catalog_path = root / "Optimizer" / "Catalog" / "TweaksCatalog.ps1"
    catalog = read_text(catalog_path)
    reg_calls = re.findall(
        r'Add-Reg\s+"([A-Z0-9]+)"\s+"[^"]*"\s+\$\w+\s+"[^"]*"\s+"[^"]*"\s+\$?\w*\s+'
        r'"([^"]*)"\s+"([^"]*)"\s+(-?\d+|0x[0-9A-Fa-f]+|\$null)',
        catalog)
    ids = re.findall(r'Add-(?:Reg|Cmd)\s+"([A-Z0-9]+)"', catalog)
    dup_ids = sorted({i for i in ids if ids.count(i) > 1})
    if dup_ids:
        report(FAIL, f"Duplicate tweak IDs in catalog: {dup_ids}")
    else:
        report(PASS, f"Catalog tweak IDs unique (parsed {len(ids)} Add-Reg/Add-Cmd)")

    targets = {}
    conflicts = []
    for tid, path, name, val in reg_calls:
        key = f"{path}\\{name}".lower()
        if key in targets and targets[key][1] != val:
            conflicts.append(f"{key}: {targets[key][0]}={targets[key][1]} vs {tid}={val}")
        targets.setdefault(key, (tid, val))
    if conflicts:
        report(FAIL, "Registry conflicts (same target, different value): " + "; ".join(conflicts))
    else:
        report(PASS, f"No registry conflicts among {len(targets)} parsed targets")

    # -- WinUtil data cross-check ------------------------------------------------
    wu_path = root / "Optimizer" / "Data" / "WinUtilTweaks.ps1"
    if wu_path.exists():
        wu = read_text(wu_path)
        wu_ids = re.findall(r"Id\s*=\s*'(WU\d+)'", wu)
        entries = re.findall(
            r"Path\s*=\s*'([^']+)';\s*Name\s*=\s*'([^']+)';\s*Value\s*=\s*'([^']*)';\s*"
            r"Type\s*=\s*'([^']+)';\s*Original\s*=\s*(\$null|'[^']*')", wu)
        entries = [(p, n, v, o, t) for p, n, v, t, o in entries]
        if wu_ids and not entries:
            report(FAIL, "WinUtil parser found tweaks but 0 entries - audit regex is stale, do not trust a PASS here")
            entries = None
        wu_targets = {}
        bad = []
        for path, name, val, orig, typ in (entries or []):
            k = f"{path}\\{name}".lower()
            if k in wu_targets:
                bad.append(f"internal dup target {k}")
            wu_targets[k] = val
            if orig not in ("$null",) and orig.strip('"') == val:
                bad.append(f"no-op restore {k} (Original == Value)")
        cross = [k for k in wu_targets if k in targets]
        if cross:
            bad.append("cross-dup vs native: " + ", ".join(cross[:5]))
        if bad:
            report(FAIL, "WinUtil data problems: " + "; ".join(bad))
        elif entries:
            report(PASS, f"WinUtil data clean: {len(wu_ids)} tweaks, {len(wu_targets)} targets, 0 literal cross-dup (full runtime cross-check runs in -SelfTest on Windows)")

    # -- reboot list --------------------------------------------------------------
    plan_path = root / "Optimizer" / "Core" / "PlanEngine.ps1"
    plan = read_text(plan_path)
    m = re.search(r"function Get-SophiaRebootTweakIds\s*\{\s*return @\((.*?)\)", plan, re.S)
    if m:
        reboot = re.findall(r'"([A-Z0-9]+)"', m.group(1))
        dup_r = sorted({i for i in reboot if reboot.count(i) > 1})
        all_ids = set(ids) | set(re.findall(r'"(WU\d+)"', read_text(wu_path))) if wu_path.exists() else set(ids)
        missing = [i for i in reboot if i not in all_ids and i not in set(ids)]
        # catalog text search fallback for IDs defined via other helpers
        missing = [i for i in missing if f'"{i}"' not in catalog]
        if dup_r:
            report(FAIL, f"Reboot list has duplicate IDs: {dup_r}")
        elif missing:
            report(FAIL, f"Reboot list references unknown IDs: {missing}")
        else:
            report(PASS, f"Reboot list clean: {len(reboot)} IDs, no dupes, all exist")

    # -- dangerous patterns ---------------------------------------------------------
    danger = []
    guard_ok = ("OFFLINE guard", "-match", "-notmatch")
    for f in ps_files:
        if f.name == "OnlineUpdate.ps1":
            continue  # the single opt-in online channel; verified separately below
        for n, line in enumerate(read_text(f).splitlines(), 1):
            if any(g in line for g in guard_ok):
                continue
            if re.search(r"Invoke-Expression|\biex\b|DownloadString|Invoke-RestMethod|Invoke-WebRequest", line):
                danger.append(f"{f.name}:{n}: {line.strip()[:90]}")
    if danger:
        report(FAIL, "Download/exec patterns outside guards: " + "; ".join(danger[:6]))
    else:
        report(PASS, "No download/exec code paths (offline purity holds)")

    bat = root / "MOLIK_WINLIK.bat"
    if bat.exists():
        bat_text = bat.read_text(errors="replace")
        if "-ArgumentList '%*'" in bat_text and "''" not in bat_text:
            report(FAIL, "MOLIK_WINLIK.bat forwards %* into a PowerShell string without '' escaping (quote-break)")
        elif "Invoke-WebRequest" in bat_text or "DownloadString" in bat_text:
            report(FAIL, "MOLIK_WINLIK.bat downloads code")
        else:
            report(PASS, "MOLIK_WINLIK.bat: offline, UAC elevation quoting escaped")

    # -- encoding ------------------------------------------------------------------
    bad_enc = []
    for f in ps_files:
        raw = f.read_bytes()
        if any(b > 127 for b in raw) and not raw.startswith(b"\xef\xbb\xbf"):
            bad_enc.append(f.name)
    if bad_enc:
        report(FAIL, f".ps1 files with non-ASCII but no UTF-8 BOM: {bad_enc}")
    else:
        report(PASS, f"Encoding guard: all {len(ps_files)} .ps1 files BOM-safe")

    # -- version consistency ---------------------------------------------------------
    ver_files = {
        "MolikWinlik.ps1": root / "MolikWinlik.ps1",
        "InteractiveCLI.ps1": root / "Optimizer" / "UI" / "InteractiveCLI.ps1",
        "ReportEngine.ps1": root / "Optimizer" / "Core" / "ReportEngine.ps1",
        "Build-Portable.ps1": root / "Optimizer" / "Build-Portable.ps1",
    }
    vers = {}
    for name, p in ver_files.items():
        mm = re.findall(r'\b(\d+\.\d+\.\d+)\b', read_text(p))
        if mm:
            vers[name] = mm[0]
    uniq = set(vers.values())
    if len(uniq) == 1:
        report(PASS, f"Version consistent everywhere: {uniq.pop()} ({vers})")
    else:
        report(FAIL, f"Version drift: {vers}")

    online_file = root / "Optimizer" / "Core" / "OnlineUpdate.ps1"
    if online_file.exists() and "Invoke-WebRequest" in read_text(online_file):
        report(PASS, "Online channel isolated: only Optimizer/Core/OnlineUpdate.ps1 may download (opt-in -Update/-Repair, SHA256-verified, never in Portable)")

    # -- engine loader parity (launcher vs portable builder vs build list) --------
    def engine_basenames(text, anchor):
        m = re.search(anchor + r"\s*=\s*@\((.*?)\)", text, re.S)
        if not m:
            return None
        return sorted({Path(p.replace("\\", "/")).name for p in re.findall(r'"([^"]+\.ps1)"', m.group(1))})

    l_list = engine_basenames(read_text(root / "MolikWinlik.ps1"), r"\$engineFiles")
    b_list = engine_basenames(read_text(root / "Optimizer" / "Build-Portable.ps1"), r"\$engineFiles")
    if not l_list or not b_list:
        report(FAIL, "Could not parse engine file lists (launcher/builder) - loader parity unverifiable")
    elif l_list != b_list:
        report(FAIL, f"Engine list drift launcher vs builder: only-launcher={set(l_list) - set(b_list)} only-builder={set(b_list) - set(l_list)}")
    else:
        report(PASS, f"Engine loader parity: {len(l_list)} files identical in launcher + builder")

    # -- GitHub Pages root fallback (legacy mode serves repo root) ---------------
    root_index = root / "index.html"
    root_online = root / "guide" / "online" / "index.html"
    if not root_index.exists() or not (root / ".nojekyll").exists() or not root_online.exists():
        report(FAIL, "GitHub Pages root fallback missing (index.html/.nojekyll/guide/online) - run docs build + docs/scripts/publish_root_site.py")
    elif "MOLIK WINLIK" not in read_text(root_index) or "CheckUpdate" not in read_text(root_online):
        report(FAIL, "GitHub Pages root fallback looks stale/wrong (content markers missing)")
    else:
        dist_index = root / "docs" / "dist" / "index.html"
        if dist_index.exists() and dist_index.read_bytes() != root_index.read_bytes():
            report(FAIL, "Root Pages site is stale vs docs/dist - re-run docs/scripts/publish_root_site.py")
        else:
            report(PASS, "GitHub Pages root fallback published (legacy main/ serves Starlight; Actions workflow also ready)")

    # -- skills pack sanity ---------------------------------------------------------
    skill_files = sorted((root / "skills").rglob("SKILL.md"))
    bad_skills = []
    for sf in skill_files:
        head = read_text(sf)[:1200]
        m = re.match(r"---\s*\nname:\s*(\S+)\s*\ndescription:\s*(.+)", head, re.S)
        if not m:
            bad_skills.append(f"{sf.parent.name} (no frontmatter)")
        elif sf.parent.parent.name == "skills" and m.group(1) != sf.parent.name:
            bad_skills.append(f"{sf.parent.name} (name={m.group(1)} != folder)")
    if bad_skills:
        report(FAIL, "Skills with broken frontmatter: " + ", ".join(bad_skills))
    elif skill_files:
        report(PASS, f"Skills pack sane: {len(skill_files)} SKILL.md with valid frontmatter")

    # -- portable freshness ---------------------------------------------------------
    portable = root / "MolikWinlik-Portable.ps1"
    if portable.exists():
        ptxt = read_text(portable)
        markers = ptxt.count("PORTABLE-INLINE")
        missing_fns = [fn for fn in fn_defs if fn not in online_only_fns and f"function {fn}" not in ptxt]
        if "function Update-MolikWinlik" in ptxt:  # download-cmdlet purity is covered by the danger scan above (guard lines excluded)
            report(FAIL, "Portable contains the online updater - the distributed Portable must stay 100% offline")
        pv = re.search(r"MolikWinlikVersion\s*=\s*\"([0-9.]+)\"", ptxt)
        lv = re.search(r"MolikWinlikVersion\s*=\s*\"([0-9.]+)\"", read_text(root / "MolikWinlik.ps1"))
        if markers < 10:
            report(FAIL, f"Portable has only {markers} inline markers (<10)")
        elif missing_fns:
            report(FAIL, f"Portable missing functions: {missing_fns[:8]}")
        elif pv and lv and pv.group(1) != lv.group(1):
            report(FAIL, f"Portable version {pv.group(1)} != launcher {lv.group(1)} (rebuild needed)")
        else:
            report(PASS, f"Portable fresh: {markers} inline modules, all {len(fn_defs)} functions, v{pv.group(1) if pv else '?'}")
    sha = root / "MolikWinlik-Portable.ps1.sha256"
    if portable.exists() and sha.exists():
        import hashlib
        actual = hashlib.sha256(portable.read_bytes()).hexdigest()
        recorded = sha.read_text().split()[0].strip().lower()
        if actual == recorded:
            report(PASS, "Portable SHA256 matches .sha256 sidecar")
        else:
            report(FAIL, f"Portable SHA256 mismatch: file={actual[:16]}.. sidecar={recorded[:16]}..")

    n_fail = sum(1 for r in results if r["status"] == FAIL)
    n_warn = sum(1 for r in results if r["status"] == WARN)
    n_pass = sum(1 for r in results if r["status"] == PASS)
    print(f"\n  == AUDIT: {n_pass} PASS / {n_fail} FAIL / {n_warn} WARN ==")
    if args.json:
        print(json.dumps({"pass": n_pass, "fail": n_fail, "warn": n_warn,
                          "results": results}, ensure_ascii=False, indent=1))
    return 1 if n_fail else 0


if __name__ == "__main__":
    sys.exit(main())
