# AI agent instructions and helpers

This public repository is the canonical source for user-owned AI instructions and helper scripts. It excludes credentials, private keys, reporting addresses, relay hostnames, identifying information, internal runtime state, and third-party skill packages. Original content is MIT licensed; referenced tools retain their own licenses.

## Instructions and managed files

Read root `AGENTS.md`, `memory/MEMORY.md`, and the applicable agent entry instructions for every request. Keep workstation-only preferences in ignored `AGENTS.local.md`, never in tracked files.

| Tracked file | Managed destination |
| --- | --- |
| `codex/AGENTS.md` | `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` |
| `copilot/copilot-instructions.md` | `${COPILOT_HOME:-$HOME/.copilot}/copilot-instructions.md` |
| `vscode/global-codex-preferences.instructions.md` | `$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md` |
| `perplexity/AGENTS.md` | Private configuration directory's `perplexity/AGENTS.md`; explicit bootstrap required |
| `helpers/codex-credit-status.sh` | `$HOME/code/.codex-tools/`, selected Codex only |
| `helpers/copilot-credit-status.sh` and `.mjs` | `$HOME/code/.codex-tools/`, selected Copilot only |
| `helpers/track_agent_usage.py` | `$HOME/code/.codex-tools/`, selected non-search surfaces |
| `helpers/send-completion-report.py` | `$HOME/code/.codex-tools/`, selected non-search surfaces |
| `helpers/test_completion_report.py` | `$HOME/code/.codex-tools/`, selected non-search surfaces |
| `helpers/perplexity-search.sh` | `$HOME/code/.codex-tools/`, explicitly selected `pplx` only |
| `helpers/install-request-hooks.py` | Run during initial setup; merges private Codex/Copilot request hooks |
| `perplexity/LOCAL-SETUP.md` | Host selection, bootstrap, capabilities, and validation instructions |
| `MAIL-ROUTING.md` | Shared identity, connector-first mail routing, and per-agent setup policy |

Tool-managed authentication, settings, logs, sessions, caches, databases, and third-party skills stay outside the repository.

## Setup and every-request execution

```sh
bash setup.sh
bash setup.sh --request
```

Initial setup installs `requirements.txt` through Python 3.12 pip, then links only selected surfaces and installs supported request hooks. Request mode avoids dependency installation and hook rewriting. No system package or agent CLI is installed. No configured agents means no changes.

Selection uses a private allowlist when present, otherwise conservative existing configuration indicators. See [host selection and Perplexity integration](perplexity/LOCAL-SETUP.md) before running setup. Explicit selection is required for Perplexity and its search CLI. This is not an authentication test.

Links already pointing into this checkout are preserved. Conflicts stop setup instead of overwriting files. After reviewing existing files, `bash setup.sh --backup-existing` moves conflicting paths to timestamped backups. Existing hooks are merged, not discarded. Installation is not transactional; inspect failures before retrying.

Supported local Codex and Copilot CLI per-prompt hooks run request setup before each user request, after initial installation and required hook trust. Other surfaces require a supported bootstrap; no universal Perplexity or VS Code shell hook is claimed. This Bash setup targets Linux/WSL, not native Windows. It neither fetches upstream nor installs continuous synchronization.

## Shared mail routing and setup

All agents must read [the shared mail policy](MAIL-ROUTING.md). It supersedes older SMTP-first instructions: use a suitable already authenticated connector for the resolved context, with the existing same-context SMTP setup as fallback. Resolve task Git email before global Git email and compare with the authenticated GitHub user's personal email and private work identities. Unknown identities do not default to work or personal.

Setup prints the policy without changing the caller's working directory. The calling agent must perform supported client configuration using existing private authentication and metadata, only on eligible hosts, and report verified versus pending steps. This is agent-directed setup, not a universal automated MCP registrar: invoking the shell script alone does not register connectors. Missing support or preconfigured authentication uses SMTP fallback. Personal MCP registration is prohibited on known work hosts. No tokens, endpoints, connector identities, or retrieved email addresses are stored here.

## Private reporting and quota tracking

The report helper is the SMTP fallback and uses `/usr/sbin/sendmail`. Its local-only recipient file defaults to `$HOME/.config/ai-agent-config/report-address`; restrict it with `chmod 600`. Override the path with `AI_AGENT_REPORT_ADDRESS_FILE`. Without the file, the helper falls back to the current user's outgoing mapping in `/etc/ssmtp/revaliases`, then the configured `root` mailbox in `/etc/ssmtp/ssmtp.conf`. Configure relay settings outside this repository. Applicable agent instructions can impose stricter sender and recipient requirements.

Each answering agent records only its own authenticated status through its status helper and `track_agent_usage.py --agent codex` or `--agent copilot`. The ignored, private `.agent-usage.jsonl` stores samples, forecasts, and warnings. Include warnings in the final response and completion/status email. Never publish this file or inspect credentials for quota sampling. Perplexity quota support is not invented.

Forecasts require two samples at least five minutes apart. An observed replenishment starts a new trend. Linear depletion estimates warn about exhaustion before local midnight but cannot predict usage changes or unseen resets.

## Tests and continuous linting

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
bash -n setup.sh helpers/perplexity-search.sh
```

Super-Linter runs on pushes, pull requests, and manual dispatches. Existing validators cover Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions. Extend workflow validators and configuration whenever adding a tracked language or format. Generated private hook JSON is not committed. Real agent hook execution and host authentication require separate on-host verification.

## License

Original files are covered by the [MIT License](LICENSE). Referenced third-party tools and packages retain their own licenses.
