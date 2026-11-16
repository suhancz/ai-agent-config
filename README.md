# Agent instructions and helpers

[![Super-Linter](https://github.com/suhancz/ai-agent-config/actions/workflows/super-linter.yml/badge.svg)](https://github.com/suhancz/ai-agent-config/actions/workflows/super-linter.yml) [![Dependency Graph](https://github.com/suhancz/ai-agent-config/actions/workflows/dependabot/update-graph/badge.svg)](https://github.com/suhancz/ai-agent-config/actions/workflows/dependabot/update-graph) [![CodeQL](https://github.com/suhancz/ai-agent-config/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/suhancz/ai-agent-config/actions/workflows/github-code-scanning/codeql)

This repository is the main place for shared AI agent instructions and setup helpers. Keep shared filenames and docs agent-neutral. Put product-specific behavior in linked adapter docs.

No credentials, private addresses, account identities, endpoints, user info, runtime state, or third-party skill packages belong here. Original content is MIT licensed; referenced tools keep their own licenses.

## Shared policies

| File | Purpose |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Main rules: loading, permissions, privacy, timestamps, Git workflow |
| [Global preferences](instructions/global-preferences.instructions.md) | Shared preferences entry point |
| [Shared memory](memory/MEMORY.md) | Durable non-private preferences and backup-loader policy |
| [Setup](SETUP.md) | Host selection, installation, request-time refresh, compatibility |
| [Reporting](REPORTING.md) | Completion reports, mail config, quota handling |
| [Mail routing](MAIL-ROUTING.md) | Identity resolution and connector-first routing |
| [Git safety](GIT-CONFIG-SAFETY.md) | Latest-config comparison and executable script requirements |
| [Executable intent](.github/executable-files.txt) | Tracked entry points allowed to have executable Git modes |

Read root instructions, shared memory, applicable policies, and the agent's entry instructions at each task boundary. Private local backups override repository preferences as documented in shared memory, subject to current explicit instructions and platform permissions.

## Setup

```sh
# Linux/WSL
bash setup.sh
bash setup.sh --request

# Windows (PowerShell; prefers WSL-shared checkout when WSL is installed)
pwsh ./setup.ps1
pwsh ./setup.ps1 -Request
```

See [the setup guide](SETUP.md) before running. Setup only operates on selected configured surfaces. It does not install agent CLIs, silently authenticate accounts, fetch upstream, or guarantee native instruction loading.

## Adapter documentation

Product names below identify the relevant adapter; product-specific paths and commands live in those documents.

- [Codex](codex/README.md)
- [Copilot](copilot/README.md)
- [Editor integration](vscode/README.md)
- [Kilo Code (CLI and VS Code extension)](kilo/README.md)
- [OpenCode](opencode/README.md)
- [Perplexity and its search CLI](perplexity/README.md)
- [Firecrawl tools and delegated agent tasks](firecrawl/README.md)
- [Qwen Code](qwen/README.md)
- [Rovo](rovo/README.md)
- [Standalone Teamwork Graph CLI](twg/README.md)

## Validation and automation

```sh
python3.12 -m unittest discover -s helpers -p 'test_*.py'
```

The CI flow is permission-first. A read-only job checks the submitted commit against .github/executable-files.txt and reports whether its modes are correct. Invalid manifests fail closed.

Permission checks and repairs use a lightweight python:3.12-alpine image with only Git. Each job builds its own image. Super-Linter is not pulled by these jobs.

If permissions are wrong, CI automatically repairs only the manifest-defined modes, commits and pushes the mode-only changes, and dispatches a new workflow run. The repair job needs contents: write and actions: write; branch protections can still block writes and must be reported.

If permissions are correct, the lint job runs only Super-Linter. Repository-owned validator configs remain supported. Super-Linter covers Bash, GitHub Actions, JavaScript, Markdown, Python Ruff, and YAML.

Only exact tracked regular entry points in .github/executable-files.txt get mode 100755; all other regular files get 100644. Shebangs and extensions alone don't establish intent. Listed entry points need a shebang. Symlink and submodule modes are preserved. All agents must maintain the manifest and stage intended Git modes when changing entry points.

Fork PRs remain read-only. Correct fork modes permit Super-Linter and tests; incorrect modes fail with a contributor-action message. No pull_request_target or privileged fork-code execution. Same-repository branches are the write-enabled repair boundary.

Local checks, configured policy, and live CI results are different evidence. The lightweight container path is assumed-compatible until a real build verifies it. Report unrun checks and unsupported capabilities; don't suppress real lint errors. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend Super-Linter validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.