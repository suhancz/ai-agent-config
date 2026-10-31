"""Install per-prompt hooks without replacing unrelated hooks or credentials."""

import argparse
import json
import os
from pathlib import Path
import shlex
import tempfile


def install(agent, repo):
    """Merge the managed command into the selected local hook file."""
    home = Path.home()
    command = "bash " + shlex.quote(str(repo / "setup.sh")) + " --request"
    if agent == "codex":
        target = Path(os.environ.get("CODEX_HOME", home / ".codex")) / "hooks.json"
        event = "UserPromptSubmit"
        entry = {"hooks": [{"type": "command", "command": command}]}
        data = {"hooks": {}}
    else:
        target = Path(os.environ.get("COPILOT_HOME", home / ".copilot")) / "hooks" / "ai-agent-config.json"
        event = "userPromptSubmitted"
        entry = {"type": "command", "bash": command, "timeoutSec": 30}
        data = {"version": 1, "hooks": {}}
    if target.exists():
        data = json.loads(target.read_text(encoding="utf-8"))
    hooks = data.setdefault("hooks", {})
    entries = hooks.setdefault(event, [])
    if entry in entries:
        return
    entries.append(entry)
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
    parser.add_argument("--agent", choices=("codex", "copilot"), required=True)
    parser.add_argument("--repo", type=Path, required=True)
    args = parser.parse_args()
    install(args.agent, args.repo.resolve())


if __name__ == "__main__":
    main()
