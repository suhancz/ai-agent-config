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

Use Super-Linter as the sole CI code-linting implementation. The lint job contains only actions/checkout and super-linter/super-linter; do not add duplicate standalone ShellCheck, handwritten code-lint steps, or parallel custom linter wrappers. Repository-owned configuration for Super-Linter's selected validators remains supported. Bash diagnostics, log groups, and summaries come from Super-Linter itself. The removed standalone Bash step and its artifact uploader are not required.

Checkout selects the exact submitted commit and exposes its built-in commit output to downstream jobs. Super-Linter v9 uses its supported snapshot/local mode to derive its internal SHA from the checked-out HEAD, avoiding absent synthetic PR merge commits. Its six positive validator selections cover Bash, GitHub Actions, JavaScript, Markdown, Python Ruff, and YAML, with summary output enabled. Normal push and PR triggers start the checks.

Only after Super-Linter succeeds may the trusted-branch job apply the executable manifest, audit modes, and run the full regression suite. Permission maintenance and regression testing are separate from code linting, not substitute linters. A failed lint job prevents permission changes; failed tests prevent publishing a repair commit. Permission-sensitive direct-execution tests run after mode handling.

Only exact tracked regular entry points listed in .github/executable-files.txt receive 100755; every other regular file receives 100644. Shebangs and extensions alone do not establish intent. Listed entry points need a shebang. Symlink and submodule modes are preserved. All agents must maintain this manifest and explicitly stage intended Git modes when changing entry points. Invalid manifest entries fail before repair. Fixture tests cover explicit intent, unlisted files, symlinks, invalid manifests, idempotence, and content preservation.

Repair checks out the exact SHA that passed lint and refuses to act on a branch that moved to other content. Published repairs must be mode-only and follow successful tests. A repair explicitly dispatches a follow-up run with repair_script_modes=false because workflow-token pushes do not normally trigger workflows. That run uses Super-Linter again, then audits/tests without further repair. The repair job needs contents: write and actions: write; branch protections and repository restrictions can still block it.

Fork PRs remain read-only: Super-Linter runs first, followed by a manifest audit and tests without permission changes. Contributors must correct mode mismatches in their own branches. No pull_request_target workflow or privileged fork-code execution is introduced. Same-repository branches are the write-enabled trust boundary.

Local structural checks, configured policy, and observed live CI results are different evidence. Report unrun checks and unsupported capabilities; do not suppress real lint errors merely to obtain green CI. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend Super-Linter validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.
