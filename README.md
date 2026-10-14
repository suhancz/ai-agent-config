# AI agent instructions and helpers

This public repository is the canonical source for user-owned AI instructions and helper scripts. It intentionally excludes credentials, private keys, personal/work reporting addresses, SMTP relay hostnames, internal runtime state, and third-party skill packages.
The repository's original instructions and helpers are licensed under MIT; referenced tools and packages are not included and remain under their own licenses.

## Contents and live paths

`AGENTS.md` contains the repository's shared development and commit guidance. The ignored local `AGENTS.local.md` contains workstation-only Git identity and branch preferences; keep those out of tracked files. Global agent instructions explain how to resolve and read it when applying machine preferences.

| Tracked file | Live path |
| --- | --- |
| `codex/AGENTS.md` | `$HOME/.codex/AGENTS.md` |
| `copilot/copilot-instructions.md` | `$HOME/.copilot/copilot-instructions.md` |
| `vscode/global-codex-preferences.instructions.md` | `$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md` |
| `helpers/codex-credit-status.sh` | `$HOME/code/.codex-tools/codex-credit-status.sh` |
| `helpers/copilot-credit-status.sh` | `$HOME/code/.codex-tools/copilot-credit-status.sh` |
| `helpers/copilot-credit-status.mjs` | `$HOME/code/.codex-tools/copilot-credit-status.mjs` |
| `helpers/track_agent_usage.py` | `$HOME/code/.codex-tools/track_agent_usage.py` |
| `helpers/send-completion-report.py` | `$HOME/code/.codex-tools/send-completion-report.py` |
| `helpers/test_completion_report.py` | `$HOME/code/.codex-tools/test_completion_report.py` |

Tool-managed runtime configuration and state (including authentication, application settings, logs, sessions, caches, and database files) do not belong here. Installed third-party skills are also excluded; keep their licenses and updates with their original distributions.
Run the root `setup.sh` to link the managed files into their live locations.

## Setup

```sh
./setup.sh
```

Run the script from a checkout of this repository. It installs Python dependencies from `requirements.txt` with Python 3.12 pip, then creates missing parent directories and links all managed files. The Python helpers currently use only the standard library. It checks for `jq`, common shell utilities, the Codex and Copilot CLIs, Node.js/npm, and `/usr/sbin/sendmail`; missing runtime tools are reported but not installed, since their installation and mail-relay configuration are managed by the OS or their vendors. It is safe to rerun when links already point into this checkout. If a live path already contains a file or a link to another location, the script stops rather than overwriting it. To preserve existing paths and install the managed links, run `./setup.sh --backup-existing`; it moves each conflicting path to a timestamped `.backup.*` path first.

The report sender uses `/usr/sbin/sendmail` and reads its recipient from the local-only file `$HOME/.config/ai-agent-config/report-address`. Create that file with the desired address and restrict it to the user (`chmod 600`). If the file does not exist, the helper sends to the current user's outgoing address from `/etc/ssmtp/revaliases`, or to the configured `root` mailbox in `/etc/ssmtp/ssmtp.conf` if no user mapping exists. Configure the SMTP relay in the OS mail-client configuration. Neither value is stored in this repository. Set `AI_AGENT_REPORT_ADDRESS_FILE` to use a different local path.

At the end of every user query, each agent records only its own authenticated quota snapshot by piping its existing status helper into `track_agent_usage.py --agent codex` or `--agent copilot`. The helper appends timestamped quota percentages and the generated forecast (including any warning) to the ignored, user-only `.agent-usage.jsonl` local report. Include any warning in the final response and completion/status email. A forecast requires at least two samples at least 5 minutes apart; it warns when the observed linear decline projects exhaustion before local midnight. A quota replenishment detected as an increase starts a new trend. The estimate cannot predict future changes or unobserved resets.

## Tests

Run the helper tests with:

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
```

## Continuous linting

GitHub Actions runs Super-Linter across all repository files on pushes, pull requests, and manual workflow dispatches. It checks Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions workflows. When adding or changing a language or executable/configuration format, update `.github/workflows/super-linter.yml` to enable its validator and add any needed linter configuration; keep this list current with the repository contents.

## License

The original files in this repository are covered by the [MIT License](LICENSE). Third-party tools and packages referenced by the instructions are not included and retain their own licenses.
