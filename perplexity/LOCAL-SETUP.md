# Perplexity and per-request setup

## Agent surfaces

Perplexity Computer is an agent product. Portable Computer runs its orchestrator and model locally on supported hardware. The separate `pplx` CLI supplies Search API results; it is not a drop-in autonomous coding agent. Do not invent a coding-agent command, configuration directory, quota API, or request hook for Perplexity.

## Host selection

Keep the private allowlist at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/agents`, one exact name per line: `codex`, `copilot`, `vscode`, `perplexity`, or `pplx`. An existing empty file disables all selections. The allowlist is authoritative; include only surfaces actually configured on that host. Do not commit it or authentication material.

Without an allowlist, setup conservatively selects Codex only when its CLI and `config.toml` exist, Copilot only when its CLI and `config.json` exist, and VS Code Server only when its user directory exists. These are configuration indicators, not proof of authentication. Other installations require explicit selection. Perplexity and `pplx` always require explicit selection. Missing selected CLIs are skipped, not installed.

Run `bash setup.sh` once from this checkout to install requirements, instruction links, selected helpers, and supported hooks. Existing instruction files are not overwritten; inspect conflicts before using `--backup-existing`. Hook installation merges existing event lists and preserves unrelated hooks. Malformed hook files fail rather than being replaced. No agent CLI or system package is installed.

## Every request

The enduring preference is to run `bash setup.sh --request` at the beginning of every user request on a host with an accessible checkout. Request mode repairs managed links but does not run pip, install hooks, launch another agent, query another agent's quota, fetch Git changes, or overwrite conflicting files. It uses only the host's selected surfaces. It does not remove old links when an agent is deselected.

Codex uses the user-level `UserPromptSubmit` hook; review and trust it using `/hooks`. Copilot CLI uses the user-level `userPromptSubmitted` hook. Initial installation must occur before these hooks can run. Disabled hooks, unsupported versions, policy restrictions, and unavailable shells must be reported, not described as working. Verify two prompts in the same session on each real host. Hook failures are not a universal enforcement boundary.

VS Code Server receives its existing instruction link, not an invented universal VS Code hook. The shell implementation targets the existing Linux/WSL environment with Bash, GNU readlink, and Python 3.12 for initial installation. It does not install native Windows hooks or configure a Windows desktop app from WSL.

## Perplexity bootstrap and search

For local Perplexity execution, explicitly select `perplexity`. Setup creates a managed copy reference at the private configuration directory's `perplexity/AGENTS.md`; this is a staging location, not an automatically discovered Perplexity path. Configure the actual Project or local agent entry instructions to read canonical root `AGENTS.md`, `memory/MEMORY.md`, and `perplexity/AGENTS.md`, run request setup before work when a permitted local shell is available, and report missing capabilities. No documented per-prompt Perplexity shell hook was established for this integration; automatic execution is not promised.

For search, install and authenticate the official `pplx` CLI separately, then explicitly select `pplx`. Invoke `bash helpers/perplexity-search.sh` with the CLI's documented arguments. The wrapper runs request setup, then forwards arguments unchanged to the installed CLI. It does not install packages, copy credentials, guess CLI options, or implement quota sampling. Search calls may use the configured API allowance.

A cloud chat cannot run the user's host setup merely because this file exists. Local MCP access, when supported and explicitly configured, is separate from cloud connectors. Never claim this chat installed or tested host-side automation without evidence.

## Verification and synchronization

Read the current canonical instructions and shared memory independently of setup; symlinks and hook commands do not load text into every model's context. Refresh them before reporting. Synchronize upstream through the approved Git workflow without changing SSH transport or overwriting dirty work. This implementation does not provide background synchronization.

If the checkout moves, review and remove stale managed hook commands before reinstalling. The installer deduplicates identical commands, not commands referencing an old checkout. Generated hook JSON stays in private runtime configuration; tracked code remains Bash, Python, and Markdown under the existing validators.
