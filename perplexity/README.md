# Perplexity adapter and search tool

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [entry instructions](AGENTS.md). Configure actual Project/agent entry instructions to retrieve current root policy and memory; a file in this repository does not automatically configure cloud chats.

## Agent staging

Selector: `perplexity`, explicitly enabled in the private allowlist. Setup stages the instruction link at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/perplexity/AGENTS.md` and refreshes its private backup loader. That is a private staging location, not a documented automatically discovered client path. A permitted host shell can run request setup; cloud-only sessions cannot read host backups or operate local SSH/SMTP merely because the instructions ask for it. No native per-prompt hook is installed by this adapter.

## Search CLI

Selector: `pplx`, explicitly enabled and requiring an installed executable. Install/authenticate the official CLI separately. Invoke `bash helpers/perplexity-search.sh` with its supported CLI arguments. The wrapper runs lightweight request setup and forwards arguments unchanged. It is a hosted-search integration, not an autonomous local coding agent or free local inference. Search calls can consume the configured API allowance; no quota API is invented here.

The wrapper is linked under the historical `$HOME/code/.codex-tools/` directory, retained for compatibility. Shared tracking/report helpers are installed for the agent staging selector, not the search-only selector.

## Reports and limits

Resolve the approved sender/recipient privately and keep them identical. Use the configured authorized route, HTML format, timestamped content, and exact-message approval where required. Connector acceptance is not verified delivery/rendering or raw-MIME evidence. The unavailable status is: `Perplexity credits: percentage and renewal unavailable. Forecast unavailable.` Do not substitute another agent's quota or inspect authentication secrets.

The [former local-setup path](LOCAL-SETUP.md) is only a redirect to shared setup and this document.
