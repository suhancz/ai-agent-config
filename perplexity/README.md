# Perplexity adapter and search tool

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [entry instructions](AGENTS.md). Configure actual Project/agent entry instructions to retrieve current root policy and memory; a file in this repository does not automatically configure cloud chats.

## Agent staging

Selector: `perplexity`, explicitly enabled in the private allowlist. Neither setup script auto-detects it, so it is skipped silently when it is not listed. Setup stages the instruction link at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/perplexity/AGENTS.md` and refreshes its private backup loader. That is a private staging location, not a documented automatically discovered client path. A permitted host shell can run request setup; cloud-only sessions cannot read host backups or operate local SSH/SMTP merely because the instructions ask for it. No native per-prompt hook is installed by this adapter.

Setup on Linux/WSL (`setup.sh`) and Windows (`setup.ps1`) also links the shared helpers `track_agent_usage.py`, `send-completion-report.py`, and `test_completion_report.py` into the historical `$HOME/code/.codex-tools/` directory. If Windows cannot create symlinks, `setup.ps1` falls back to hardlinks; the usage helper then keeps its ignored log next to the linked copy under `code/` instead of inside the checkout. Keep that log unpublished either way.

## Search CLI

Selector: `pplx`, explicitly enabled and requiring an installed executable. Install/authenticate the official CLI separately. Invoke the search helper with its supported CLI arguments (`bash helpers/perplexity-search.sh` on Linux/WSL, `pwsh ./helpers/perplexity-search.ps1` or `powershell -ExecutionPolicy Bypass -File ./helpers/perplexity-search.ps1` on Windows). The wrapper runs lightweight request setup and forwards arguments unchanged. It is a hosted-search integration, not an autonomous local coding agent or free local inference. Search calls can consume the configured API allowance; no quota API is invented here.

The wrapper is linked under the historical `$HOME/code/.codex-tools/` directory, retained for compatibility. Shared tracking/report helpers are installed for the agent staging selector, not the search-only selector.

## Reports and limits

Resolve the approved sender/recipient privately and keep them identical. Use the configured authorized route, HTML format, timestamped content, and exact-message approval where required. Connector acceptance is not verified delivery/rendering or raw-MIME evidence.

When the Pro weekly Computer usage meter is readable in the authenticated session, report its remaining percentage and reset time, and record it with `helpers/track_agent_usage.py --agent perplexity --metric "Included in Pro"` (`python3.12` on Linux/WSL, `python` or `py -3` on Windows), passing text such as `Included in Pro 72% remaining` on stdin. Only when the meter cannot be read, state: `Perplexity credits: percentage and renewal unavailable. Forecast unavailable.` Do not substitute another agent's quota or inspect authentication secrets.

The [former local-setup path](LOCAL-SETUP.md) is only a redirect to shared setup and this document.
