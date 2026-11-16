#!/usr/bin/env python3
"""Install per-prompt hooks without replacing unrelated hooks or credentials."""

import argparse
import json
import os
import shlex
import shutil
import tempfile
from pathlib import Path


def _windows_setup_command(repo: Path) -> str:
    ps1 = repo / "setup.ps1"
    pw = shutil.which("pwsh") or shutil.which("powershell") or shutil.which("powershell.exe")
    if pw and ps1.exists():
        return f'"{pw}" -NoProfile -ExecutionPolicy Bypass -File "{ps1}" --request'
    # fallback: bash-based setup if available (e.g. Git Bash/WSL interop)
    sh = repo / "setup.sh"
    bash = shutil.which("bash")
    if bash and sh.exists():
        return f'"{bash}" "{sh}" --request'
    return f'powershell -NoProfile -ExecutionPolicy Bypass -File "{ps1}" --request'


def _unix_setup_command(repo: Path) -> str:
    return "bash " + shlex.quote(str(repo / "setup.sh")) + " --request"


def install(agent, repo):
    """Merge the managed command into the selected local hook file."""
    home = Path.home()
    is_windows = os.name == "nt"
    command = _windows_setup_command(repo) if is_windows else _unix_setup_command(repo)

    if agent == "codex":
        target = Path(os.environ.get("CODEX_HOME", home / ".codex")) / "hooks.json"
        event = "UserPromptSubmit"
        entry = {"hooks": [{"type": "command", "command": command}]}
        data = {"hooks": {}}
    elif agent == "qwen":
        target = home / ".qwen" / "settings.json"
        event = "UserPromptSubmit"
        if is_windows:
            # PowerShell-friendly blocking behavior
            q_command = f'{command}; if ($LASTEXITCODE -ne 0) {{ [Console]::Error.WriteLine("setup request failed"); exit 2 }}'
        else:
            q_command = "(" + command + ") >&2 || exit 2"
        entry = {"hooks": [{"type": "command", "command": q_command}]}
        data = {"hooks": {}}
    else:
        target = Path(os.environ.get("COPILOT_HOME", home / ".copilot")) / "hooks" / "ai-agent-config.json"
        event = "userPromptSubmitted"
        if is_windows:
            entry = {"type": "command", "command": command, "timeoutSec": 30}
        else:
            entry = {"type": "command", "bash": command, "timeoutSec": 30}
        data = {"version": 1, "hooks": {}}

    if target.is_symlink():
        raise ValueError("Refusing to replace a symlinked hook/settings file")
    if target.exists():
        data = json.loads(target.read_text(encoding="utf-8"))
    hooks = data.setdefault("hooks", {})
    entries = hooks.setdefault(event, [])
    if entry in entries:
        return
    # Remove stale managed entries for the same repo/setup script (old checkout/mode) to avoid duplicates across migrations
    def _is_managed(e):
        text = json.dumps(e, sort_keys=True)
        return "setup.ps1" in text or "setup.sh" in text and "--request" in text and "ai-agent-config" in text
    hooks[event] = [e for e in entries if not _is_managed(e)]
    hooks[event].append(entry)
    target.parent.mkdir(parents=True, exist_ok=True)
    fd, name = tempfile.mkstemp(prefix=".agent-hooks-", dir=target.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as stream:
            json.dump(data, stream, indent=2)
            stream.write("\n")
        os.replace(name, target)
    finally:
        if os.path.exists(name):
            os.unlink(name)


def main():
    """Install only for the explicitly selected agent."""
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--agent", choices=("codex", "copilot", "qwen"), required=True)
    parser.add_argument("--repo", type=Path, required=True)
    args = parser.parse_args()
    install(args.agent, args.repo.resolve())


if __name__ == "__main__":
    main()
