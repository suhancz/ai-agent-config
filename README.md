# Agent instructions and helpers

This repository is the canonical source for shared user instructions and setup helpers. Keep shared filenames and documentation agent-neutral. Put product-specific behavior in linked adapter documents; mention a product in shared documentation only when needed to identify an adapter or compatibility requirement.

No credentials, private addresses, account or connector identities, endpoints, identifying user information, runtime state, or third-party skill packages belong here. Original content is MIT licensed; referenced tools retain their own licenses.

## Shared policies

| File | Purpose |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Mandatory instruction loading, permissions, privacy, timestamps, and Git workflow |
| [Global preferences](instructions/global-preferences.instructions.md) | Generic shared preference entry point |
| [Shared memory](memory/MEMORY.md) | Non-sensitive durable preferences and private backup-loader policy |
| [Setup](SETUP.md) | Host selection, installation, request-time refresh, and compatibility |
| [Reporting](REPORTING.md) | Completion reports, private mail configuration, and own-agent quota handling |
| [Mail routing](MAIL-ROUTING.md) | Private identity resolution and connector-first routing |
| [Git safety](GIT-CONFIG-SAFETY.md) | Latest-config comparison and executable-script requirements |

Read root instructions, current shared memory, applicable policies, and the answering agent's entry instructions at each task boundary. Private local backups override repository preferences as documented in shared memory, subject to current explicit instructions and platform permissions.

## Setup

```sh
bash setup.sh
bash setup.sh --request
```

See [the setup guide](SETUP.md) before running either command. Setup operates only on selected configured surfaces. It does not install agent CLIs, silently authenticate accounts, fetch upstream, or guarantee native instruction loading.

## Adapter documentation

Product names below identify the relevant adapter; product-specific paths and commands live in those documents.

- [Codex](codex/README.md)
- [Copilot](copilot/README.md)
- [Editor integration](vscode/README.md)
- [OpenCode](opencode/README.md)
- [Perplexity and its search CLI](perplexity/README.md)
- [Qwen Code](qwen/README.md)
- [Rovo](rovo/README.md)
- [Standalone Teamwork Graph CLI](twg/README.md)

## Validation and automation

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
bash -n setup.sh helpers/*.sh
```

The workflow checks Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions, and runs the Python regression tests. ESLint uses the repository-owned configuration under .github/linters for both JavaScript plugins and MJS helpers; the root config re-exports the same rules. YAML rules allow GitHub's on key and long policy/workflow lines without weakening structural validation.

Executable-mode repair runs on main and other repository branches, including same-repository PR heads. Only tracked regular files with a shebang are treated as executable entry points; imported test modules, libraries, declarative configuration, and symlinks are not marked executable merely by extension. Repairs are mode-only, idempotent, serialized per branch, and refuse to overwrite a concurrently changed branch. A fixture self-test checks classification, content preservation, and idempotence.

Lint checks out the exact repaired commit. Because workflow-token pushes do not normally trigger another run, a repair explicitly dispatches this workflow on the repaired branch with repair_script_modes=false. No additional token secret is required: the repair job uses contents: write and actions: write. Branch protections and repository permissions can still block repairs; such failures must not be hidden. Manual runs can disable repair and audit only.

Fork PRs remain read-only and receive an actual mode audit; missing entry-point bits must be fixed in the contributor's branch. No pull_request_target workflow or privileged execution of fork code is introduced. Same-repository branches are the write-enabled trust boundary. Real lint errors and failed tests still fail CI; local syntax/fixture checks are not a substitute for a live Actions run and a disposable-PR test.

Local tests, configured policy, and observed runtime behavior are different evidence. Report unrun checks and unsupported capabilities. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.
