#!/usr/bin/env python3
"""Detect the installed OpenCode API family without reading authentication state."""
import re
import subprocess
import sys


def family(text):
    """Accept stable semantic versions, optionally prefixed with the product name."""
    match = re.fullmatch(
        r"(?:opencode\s+)?v?(\d+)\.(\d+)\.(\d+)(?:\+[0-9A-Za-z.-]+)?",
        text.strip(), re.IGNORECASE,
    )
    if not match or int(match[1]) not in (1, 2):
        raise ValueError("Unsupported OpenCode version; no hook changes made")
    return int(match[1])


def main():
    """Probe the actual executable with a bounded wait."""
    try:
        result = subprocess.run(
            ["opencode", "--version"], check=True, capture_output=True,
            text=True, timeout=10,
        )
        print(family(result.stdout))
    except (OSError, subprocess.SubprocessError, ValueError) as error:
        print(f"OpenCode version detection failed: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
