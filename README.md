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
| [Executable intent](.github/executable-files.txt) | Exact tracked entry points permitted to have executable Git modes |

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
```

The final CI decision flow is permission-first. A read-only job checks the exact submitted commit against .github/executable-files.txt and reports whether its modes are correct without modifying the index. Invalid manifests fail closed rather than being treated as ordinary repairable mode mismatches.

If permissions are wrong on a same-repository branch, CI automatically repairs only the manifest-defined modes, commits and pushes the mode-only changes, and explicitly dispatches a new workflow run. Super-Linter and regression tests do not run in the repair-producing pipeline. No interactive approval, manual repair input, or new token secret is required for normal CI repair. The repair job needs contents: write and actions: write; branch protections or repository restrictions can still block writes and must be reported, not bypassed.

The explicit dispatch is necessary because pushes made with the workflow GITHUB_TOKEN do not normally start another pipeline. The new run checks permissions again. If they are now correct, it runs Super-Linter; if another mismatch exists, it follows the same repair path. Branch movement checks and ordinary non-force pushes preserve concurrent work.

If permissions are already correct, the lint job contains only actions/checkout and super-linter/super-linter. Use Super-Linter as the sole code-linting implementation; do not reintroduce standalone ShellCheck, handwritten source-code lint steps, or duplicate linter wrappers. Repository-owned validator configurations remain supported. Super-Linter provides Bash diagnostics, log groups, and saved summaries. Its six positive selections cover Bash, GitHub Actions, JavaScript, Markdown, Python Ruff, and YAML.

Checkout exposes the checked commit through its built-in commit output. Downstream jobs use that exact SHA. Super-Linter v9 derives its internal SHA from the checked-out HEAD in its supported snapshot/local mode, avoiding absent synthetic PR merge commits. Regression tests run separately only after Super-Linter succeeds; permission-sensitive direct execution therefore tests a permission-correct snapshot.

Only exact tracked regular entry points listed in .github/executable-files.txt receive 100755; every other regular file receives 100644. Shebangs and extensions alone do not establish intent. Listed entry points need a shebang. Symlink and submodule modes are preserved. All agents must maintain the manifest and explicitly stage intended Git modes when changing entry points. Fixture tests cover explicit intent, unlisted files, symlinks, invalid manifests, idempotence, and content preservation.

Fork PRs remain read-only. Correct fork modes permit Super-Linter and tests; incorrect modes fail with an explicit contributor-action message because this repository cannot automatically write to arbitrary forks. No pull_request_target workflow or privileged fork-code execution is introduced. Same-repository branches are the write-enabled repair boundary.

Local checks, configured policy, and observed live CI results are different evidence. Report unrun checks and unsupported capabilities; do not suppress real lint errors merely to obtain green CI. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend Super-Linter validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.
