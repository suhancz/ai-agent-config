# AI agent instructions and helpers

This public repository is the canonical source for user-owned AI instructions and helper scripts. It excludes credentials, private keys, reporting addresses, relay hostnames, identifying information, internal runtime state, and third-party skill packages. Original content is MIT licensed; referenced tools retain their own licenses.

## Instructions and managed files

Read root `AGENTS.md`, `memory/MEMORY.md`, and the applicable agent entry instructions for every request. Keep workstation-only preferences in ignored `AGENTS.local.md`, never in tracked files. The synchronized instruction set includes `rovo/AGENTS.md` under root policy for current and successor agents.

| Tracked file | Managed destination |
| --- | --- |
| `codex/AGENTS.md` | `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` |
| `copilot/copilot-instructions.md` | `${COPILOT_HOME:-$HOME/.copilot}/copilot-instructions.md` |
| `rovo/AGENTS.md` | `$HOME/.rovo/AGENTS.md`, selected Rovo only |
| `helpers/rovo-request.sh` | `$HOME/code/.codex-tools/rovo-request.sh`, selected Rovo only |
| `helpers/twg-setup.sh` | Initial/request setup adapter for an explicitly approved standalone TWG |
| `vscode/global-codex-preferences.instructions.md` | `$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md` |
| `perplexity/AGENTS.md` | Private configuration directory's `perplexity/AGENTS.md`; explicit bootstrap required |
| `helpers/codex-credit-status.sh` | `$HOME/code/.codex-tools/`, selected Codex only |
| `helpers/copilot-credit-status.sh` and `.mjs` | `$HOME/code/.codex-tools/`, selected Copilot only |
| `helpers/track_agent_usage.py` | `$HOME/code/.codex-tools/`, selected non-search agents |
| `helpers/send-completion-report.py` | `$HOME/code/.codex-tools/`, selected non-search agents |
| `helpers/test_completion_report.py` | `$HOME/code/.codex-tools/`, selected non-search agents |
| `helpers/perplexity-search.sh` | `$HOME/code/.codex-tools/`, explicitly selected `pplx` only |
| `helpers/install-request-hooks.py` | Run during initial setup; merges private Codex/Copilot request hooks |
| `perplexity/LOCAL-SETUP.md` | Host selection, bootstrap, capabilities, and validation instructions |
| `MAIL-ROUTING.md` | Shared identity, connector-first mail routing, and per-agent setup policy |
| `GIT-CONFIG-SAFETY.md` | Mandatory latest-Git comparison and concurrent-update safeguards |
| `ATLASSIAN.md` | Shared Rovo/TWG setup, authentication boundaries, and command discovery |

Tool-managed authentication, settings, logs, sessions, caches, databases, and third-party skills stay outside the repository.

## Setup and every-request execution

```sh
bash setup.sh
bash setup.sh --request
```

Initial setup installs `requirements.txt` through Python 3.12 pip, then links only selected surfaces and installs supported request hooks. Request mode avoids dependency installation and hook rewriting. No system package or agent CLI is installed. No configured agents means no changes.

Selection uses a private allowlist when present, otherwise conservative existing configuration indicators. See [host selection and Perplexity integration](perplexity/LOCAL-SETUP.md) before running setup. Explicit selection is required for Perplexity and its search CLI. This is not an authentication test. The allowlist also accepts `rovo` and `twg`; preserve every other desired entry when adding them.

Links already pointing into this checkout are preserved. Conflicts stop setup instead of overwriting files. After reviewing existing files, `bash setup.sh --backup-existing` moves conflicting paths to timestamped backups. Existing hooks are merged, not discarded. Installation is not transactional; inspect failures before retrying.

Supported local Codex and Copilot CLI per-prompt hooks run request setup before each user request, after initial installation and required hook trust. Other surfaces require a supported bootstrap; no universal Perplexity or VS Code shell hook is claimed. This Bash setup targets Linux/WSL, not native Windows. It neither fetches upstream nor installs continuous synchronization.

## Latest Git before configuration changes

Every agent must apply [the latest-Git safety policy](GIT-CONFIG-SAFETY.md), which setup prints alongside mail routing. Fetch or resolve the latest canonical branch before editing configuration, compare actual affected files, preserve concurrent changes, and recheck immediately before publication, including after approval waits. A moved head requires review and revised approval if approved content changes. The shell script surfaces this requirement; it does not itself fetch or merge Git. Preflight checks are not atomic expected-head guards.

## Rovo and standalone TWG

Read [the shared Atlassian policy](ATLASSIAN.md). Rovo is selected without an allowlist only when its executable and ~/.rovo/config.yml exist. Setup links its user instructions and request helper; it does not authenticate Rovo or repair keychain errors. Existing conflicting user memory is preserved unless explicitly backed up after review.

At each Rovo request, run from the checkout and read the output:

```sh
bash helpers/rovo-request.sh
```

Verify user-memory loading in the installed Rovo client. Automatic Rovo per-prompt hook installation remains unverified: inspect `/hooks`, configure only supported events/schema using bash and the absolute helper path, then test two prompts in a session and one new session. Instructions alone do not prove hook enforcement.

Standalone TWG is a tool, not an agent. Select it with a private `twg-bin` file under `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config`, containing one absolute path to an approved standalone executable; restrict the file to the user. An existing agents allowlist must also include `twg`. Without an allowlist, that selector enables it. Do not point it at Rovo's bundled TWG; known bundle paths are rejected, but provenance still requires review.

Initial TWG setup installs vendor skills globally and runs doctor; request mode only validates selection and does not reinstall skills or start login. Vendor global skill installation follows its own locally detected-client behavior, not the repository allowlist. Review that behavior before selecting TWG. Third-party skills remain vendor-managed outside this repository. Authentication/consent is interactive and separate; failed doctor means setup is pending.

Rovo manages its bundled TWG credentials/version through Rovo. Standalone TWG requires separate authorized setup. Use supported help/command contracts before guessing syntax, respect all external-write approvals, and keep all account and product data private. Neither Rovo nor TWG receives an invented quota sampler.

## Shared mail routing and setup

All agents must read [the shared mail policy](MAIL-ROUTING.md). It supersedes older SMTP-first instructions: use a suitable already authenticated connector, with the existing same-context SMTP setup as fallback. Personal email is the default unless work context is verified. Resolve task Git email before global Git email and compare with the authenticated GitHub user's personal email addresses. A verified non-personal Git email, private work identity, or known work computer establishes work context. Missing Git or GitHub information alone retains the personal default; an incomplete address listing does not prove a nonmatch. Conflicting verified signals require clarification.

Setup prints the policy without changing the caller's working directory. The calling agent must perform supported client configuration using existing private authentication and metadata, only on eligible hosts, and report verified versus pending steps. This is agent-directed setup, not a universal automated MCP registrar: invoking the shell script alone does not register connectors. Missing support or preconfigured authentication uses SMTP fallback. Personal MCP registration is prohibited on known work hosts. No tokens, endpoints, connector identities, or retrieved email addresses are stored here.

## Private reporting and quota tracking

The report helper is the SMTP fallback and uses `/usr/sbin/sendmail`. Its local-only recipient file defaults to `$HOME/.config/ai-agent-config/report-address`; restrict it with `chmod 600`. Override the path with `AI_AGENT_REPORT_ADDRESS_FILE`. Without the file, the helper falls back to the current user's outgoing mapping in `/etc/ssmtp/revaliases`, then the configured `root` mailbox in `/etc/ssmtp/ssmtp.conf`. Configure relay settings outside this repository. Applicable agent instructions can impose stricter sender and recipient requirements.

Each answering agent records only its own authenticated status through its status helper and `track_agent_usage.py --agent codex` or `--agent copilot`. The ignored, private `.agent-usage.jsonl` stores samples, forecasts, and warnings. Include warnings in the final response and completion/status email. Never publish this file or inspect credentials for quota sampling. Perplexity and Rovo quota support is not invented. Do not pass `--agent rovo` to the current tracker. TWG has no separate agent quota record.

Forecasts require two samples at least five minutes apart. An observed replenishment starts a new trend. Linear depletion estimates warn about exhaustion before local midnight but cannot predict usage changes or unseen resets.

## Tests and continuous linting

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
bash -n setup.sh helpers/perplexity-search.sh helpers/rovo-request.sh helpers/twg-setup.sh
```

Super-Linter runs on pushes, pull requests, and manual dispatches. Existing validators cover Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions. These additions use existing Bash and Markdown validators; no new tracked format is introduced. Extend workflow validators and configuration whenever adding a tracked language or format. Generated private hook JSON is not committed. Real agent hook execution and host authentication require separate on-host verification.

## License

Original files are covered by the [MIT License](LICENSE). Referenced third-party tools and packages retain their own licenses.
