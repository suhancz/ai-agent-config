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
- [Perplexity and its search CLI](perplexity/README.md)
- [Qwen Code](qwen/README.md)
- [Rovo](rovo/README.md)
- [Standalone Teamwork Graph CLI](twg/README.md)

## Validation and automation

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
bash -n setup.sh helpers/*.sh
```

The existing workflow checks Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions. It also checks executable Git modes and repairs detected mode errors automatically on main pushes, subject to token permissions and branch protection. Repairs make no commit when no changes are required. No new push workflow is assumed for a workflow-token bot commit.

Local tests, configured policy, and observed runtime behavior are different evidence. Report unrun checks and unsupported capabilities. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.
