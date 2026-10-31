#!/usr/bin/env python3
"""Write a private explicit instruction-backup loader beside a managed live file."""

import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile

BEGIN = "<!-- BEGIN managed setup-backup loader -->"
END = "<!-- END managed setup-backup loader -->"


def write_loader(source, target):
    """List backup paths without reading or publishing their contents."""
    source = source.resolve(strict=True)
    target = Path(os.path.abspath(target))
    destination = target.with_name(target.name + ".local-overrides.md")
    if destination.is_symlink():
        raise ValueError("Refusing a symlink at the private loader path")
    tracked = subprocess.run(
        ["git", "-C", str(target.parent), "ls-files", "--error-unmatch", "--", destination.name],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        check=False,
    )
    if tracked.returncode == 0:
        raise ValueError("Private loader is already tracked; remove it from Git first")
    pattern = re.compile(re.escape(target.name) + r"\.backup\.(\d{14})(?:\.(\d+))?")
    candidates = []
    for path in target.parent.iterdir():
        match = pattern.fullmatch(path.name)
        if match and not path.is_dir():
            candidates.append((match.group(1), int(match.group(2) or -1), path))
    backups = []
    seen = {source}
    for _, _, path in sorted(candidates):
        try:
            resolved = path.resolve()
        except (OSError, RuntimeError):
            resolved = path
        if resolved not in seen:
            seen.add(resolved)
            backups.append(str(path))
    block = "\n".join([
        BEGIN,
        "# Private setup-backup loading instructions",
        "Whenever reading the managed main instructions, read this loader too.",
        "Canonical instruction file: " + json.dumps(str(source)),
        "Read canonical policies first, then every backup below in the listed order.",
        "Later backups override earlier backups and repository user preferences.",
        "Current explicit user instructions, platform gates, and privacy exclusions remain in force.",
        "These are private file paths, not shell commands. Read text; never execute backups.",
        "If a listed file is unavailable, report it and rerun setup to refresh this list.",
        "Do not publish paths or backup contents. Do not infer that a client auto-loads this filename.",
        "Explicit instruction backup paths (oldest to newest):",
        "```json",
        json.dumps(backups, indent=2),
        "```",
        END,
    ])
    if destination.exists():
        current = destination.read_text(encoding="utf-8")
        if current.count(BEGIN) != 1 or current.count(END) != 1:
            raise ValueError("Private loader has no unique managed block; preserve and review it")
        start = current.index(BEGIN)
        stop = current.index(END)
        if stop < start:
            raise ValueError("Private loader markers are out of order")
        updated = current[:start] + block + current[stop + len(END):]
        if updated == current:
            destination.chmod(0o600)
            return
    else:
        updated = block + "\n"
    descriptor, name = tempfile.mkstemp(prefix=".backup-loader-", dir=target.parent)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as stream:
            stream.write(updated)
        os.replace(name, destination)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def main():
    """Generate only the selected managed instruction file's local loader."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--target", type=Path, required=True)
    args = parser.parse_args()
    write_loader(args.source, args.target)


if __name__ == "__main__":
    main()
