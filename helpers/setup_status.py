"""Imported setup diagnostics library, not an autonomous agent or registrar."""

import json
import os
import re
import selectors
import shutil
import signal
import subprocess
import sys
import tempfile
import time
from datetime import UTC, datetime
from html import escape
from pathlib import Path
from zoneinfo import ZoneInfo

CLIS = {"codex", "copilot", "opencode", "qwen", "kilo", "rovo", "pplx"}
LIMIT = 262144


def _script_for(repo, name):
    base = repo / "helpers" / name
    if os.name == "nt":
        ps1 = base.with_suffix(".ps1")
        if ps1.exists():
            return [ps1]
        bat = base.with_suffix(".bat")
        if bat.exists():
            return [bat]
        cmd = base.with_suffix(".cmd")
        if cmd.exists():
            return [cmd]
    sh = base.with_suffix(".sh")
    if sh.exists():
        return [sh]
    return [base]


def _command_for_script(script_path):
    path = Path(script_path)
    suffix = path.suffix.lower()
    if suffix == ".ps1":
        pw = shutil.which("pwsh") or shutil.which("powershell") or shutil.which("powershell.exe")
        if pw:
            return [pw, "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", str(path)]
    if suffix in {".bat", ".cmd"} and os.name == "nt":
        return [str(path)]
    # Unix shell scripts
    if shutil.which("bash"):
        return ["bash", str(path)]
    if os.name == "nt":
        wsl = shutil.which("wsl") or shutil.which("wsl.exe")
        if wsl:
            # best-effort: run from wsl if bash unavailable on Windows
            return [wsl, "bash", str(path)]
    return [str(path)]


def _terminate(child):
    try:
        if os.name == "nt":
            child.kill()
        else:
            os.killpg(child.pid, signal.SIGKILL)
    except (ProcessLookupError, OSError):
        pass
    try:
        child.wait(timeout=1)
    except subprocess.TimeoutExpired:
        pass


def run(argv, data="", seconds=5):
    with tempfile.TemporaryFile() as source:
        source.write(data.encode())
        source.seek(0)
        try:
            popen_kw = {
                "stdin": source,
                "stdout": subprocess.PIPE,
                "stderr": subprocess.DEVNULL,
                "env": dict(os.environ, CI="1", NO_COLOR="1", AI_AGENT_STATUS_LIVE_ONLY="1"),
            }
            if os.name == "nt":
                popen_kw["creationflags"] = getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0)
            else:
                popen_kw["start_new_session"] = True
            child = subprocess.Popen(argv, **popen_kw)
        except OSError:
            return None
        output = bytearray()
        deadline = time.monotonic() + seconds
        try:
            with selectors.DefaultSelector() as selector:
                selector.register(child.stdout, selectors.EVENT_READ)
                while time.monotonic() < deadline:
                    events = selector.select(timeout=0.05)
                    for key, _ in events:
                        chunk = os.read(key.fd, 8192)
                        if not chunk:
                            rc = child.poll()
                            if rc is None:
                                try:
                                    child.wait(timeout=0.5)
                                except subprocess.TimeoutExpired:
                                    return None
                            return output.decode(errors="replace") if child.wait(timeout=0.5) == 0 else None
                        output.extend(chunk)
                        if len(output) > LIMIT:
                            return None
                return None
        except (OSError, UnicodeError, subprocess.TimeoutExpired):
            return None
        finally:
            _terminate(child)
            try:
                child.stdout.close()
            except OSError:
                pass


def registry(agent):
    if agent not in CLIS or not shutil.which(agent):
        return "CLI missing or unsupported for this surface; connection unverified."
    text = run([agent, "--help"])
    if text is None or not re.search(r"\bmcp\b", text):
        return "CLI present; safe MCP discovery unavailable; connection unverified."
    if agent not in {"codex", "copilot"}:
        return "CLI help inspected; registry schema unsupported; connection unverified."
    for args, pattern in [(["mcp", "--help"], r"\blist\b"), (["mcp", "list", "--help"], r"--json\b")]:
        text = run([agent, *args])
        if text is None or not re.search(pattern, text):
            return "CLI present; safe JSON listing unsupported or failed; connection unverified."
    try:
        value = json.loads(run([agent, "mcp", "list", "--json"]) or "")
        servers = value.get("servers") if isinstance(value, dict) else value
        if not isinstance(servers, list) or any(not isinstance(s, dict) or not isinstance(s.get("name"), str) for s in servers):
            raise ValueError("Unknown schema")
        connected = sum(s.get("status") == "connected" for s in servers)
        return f"{len(servers)} configured server(s); {connected} client-reported connected. Not independently live-tested."
    except (ValueError, TypeError):
        return "Registry failed or unknown JSON schema; connection unverified."


def quota(repo, agent, request):
    if agent not in {"codex", "copilot"} or (request and os.environ.get("AI_AGENT_CALLER") != agent):
        return f"{agent}: quota/reset/forecast unavailable or reserved for its calling context."
    if not shutil.which(agent):
        return f"{agent}: CLI missing; quota/reset/forecast unavailable."
    candidates = _script_for(repo, f"{agent}-credit-status")
    raw = ""
    for script in candidates:
        cmd = _command_for_script(script)
        raw = run(cmd, seconds=25) or ""
        if raw:
            break
    labels = r"business individual limit|individual limit|5-hour|weekly|chat|completions|premium interactions"
    values = re.findall(rf"(?<![\w-])({labels})\s+(\d+(?:\.\d+)?)%\s+remaining", raw, re.IGNORECASE)
    status = "; ".join(f"{label.lower()} {value}% remaining" for label, value in values if 0 <= float(value) <= 100)
    if not status:
        if "Codex credits: unlimited; no renewal date applies." in raw:
            return "codex: unlimited; no renewal date applies; percentage forecast not applicable."
        return f"{agent}: fresh quota/reset unavailable; no sample recorded; forecast unavailable."
    reset = re.search(r"(?:renews|resets) [0-9-]{10} [0-9:]{5} [A-Za-z0-9+:-]{1,20}", raw)
    status += "; " + (reset[0] if reset else "reset unavailable")
    try:
        ZoneInfo(os.environ["TZ"])
    except (KeyError, ValueError):
        return f"{agent}: {status}; user TZ unavailable; recording/forecast withheld."
    output = run([sys.executable, str(repo / "helpers/track_agent_usage.py"), "--agent", agent], data=status)
    return f"{agent}: " + (output.strip() if output else status + "; recording/forecast failed.")


def _safe_private_state(repo):
    if os.name == "nt":
        base = Path(os.environ.get("LOCALAPPDATA") or (Path.home() / "AppData/Local"))
        return base / "ai-agent-config" / "setup"
    return Path(os.environ.get("XDG_STATE_HOME", Path.home() / ".local/state")) / "ai-agent-config/setup"


def report():
    repo, request, exit_status, *agents = sys.argv[1:]
    repo = Path(repo)
    agents = list(dict.fromkeys(a for a in agents if a in CLIS | {"vscode", "twg", "perplexity"}))
    now = datetime.now(UTC).isoformat()
    lines = [f"Prepared {now}; original setup exit status {int(exit_status)}.",
             "Agent: deterministic setup collector; Model/version: not applicable.",
             "Original user request/time unavailable to shell collector; timezone comes from private TZ."]
    for agent in agents:
        lines += [f"{agent}: {registry(agent)}", quota(repo, agent, request == "1")]
    if os.environ.get("FIRECRAWL_API_KEY"):
        lines.append("Firecrawl documented environment fallback present; authentication unverified; prefer existing current-client connection.")
    lines += ["Firecrawl service-credit forecast unavailable: CLI registries expose no verified balance history; caller must use its supported credit-status interface.",
              "Firecrawl credential expiry/refresh unavailable: no supported non-secret expiry metadata exposed by these CLI adapters. No refresh performed.",
              "Cloud-native clients: caller must inspect its own fresh connector inventory; a local CLI connection is not evidence for another client.",
              "SSH fingerprints: caller must obtain through its authorized SSH surface; not inspected by this collector.",
              "HTML email pending: caller must resolve approved same-context identical sender/recipient and mandatory send approval. No email submitted."]
    print("\nSetup connection/status summary:\n" + "\n".join(lines))
    state = _safe_private_state(repo)
    try:
        if state.resolve().is_relative_to(repo.resolve()) or state.is_symlink():
            raise ValueError("Private state must be outside repository")
        state.mkdir(parents=True, exist_ok=True)
        if os.name != "nt" and (state.stat().st_uid != os.getuid() or state.stat().st_mode & 0o077):
            raise ValueError("Unsafe private directory")
        descriptor, temporary = tempfile.mkstemp(dir=state)
        try:
            with os.fdopen(descriptor, "w") as stream:
                stream.write("<!doctype html><html><head><meta charset='utf-8'><title>Setup status</title></head><body>" + "".join("<p>" + escape(line) + "</p>" for line in lines) + "</body></html>")
            os.replace(temporary, state / "setup-report.html")
        finally:
            if os.path.exists(temporary):
                os.unlink(temporary)
        print("Private mode-0600 HTML status report prepared outside repository; not sent.")
    except (OSError, ValueError):
        print("HTML preparation blocked: private state directory unavailable or unsafe; original setup status preserved.")
