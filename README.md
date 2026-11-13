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
bash -n setup.sh helpers/*.sh
```

CI lints the exact immutable submitted commit first, without changing executable permissions. The lint job runs explicit ShellCheck diagnostics for tracked .sh files using the Super-Linter v9 image, then runs the configured Bash, JavaScript, Markdown, Python, YAML, and GitHub Actions validators. Super-Linter derives its internal SHA from the actual checkout. A Bash diagnostic failure remains a job failure even if another linter succeeds.

The explicit Bash step writes readable GCC-format diagnostics to the job log and saves its output in the bash-lint artifact for that workflow run, including failed runs. The commit's normal push trigger starts these checks; no separate manual dispatch is needed to begin Bash linting. No new token secret is needed.

Only after lint succeeds may the trusted-branch job apply the executable manifest, audit modes, and run the full regression suite. Permission-sensitive direct-execution tests run after mode handling, not before it. A failed lint job prevents the permission job from starting; failed tests prevent publishing a repair commit.

Only exact tracked regular entry points listed in .github/executable-files.txt receive 100755; every other regular file receives 100644. Shebangs and extensions alone do not establish intent. Listed entry points need a shebang. Symlink and submodule modes are preserved. All agents must maintain this manifest and explicitly stage intended Git modes when changing entry points. Invalid manifest entries fail before repair. Fixture tests cover explicit intent, unlisted files, symlinks, invalid manifests, idempotence, and content preservation.

Repair checks out the exact SHA that passed lint and refuses to act on a branch that moved to other content. Published repairs must be mode-only and follow successful tests. Because workflow-token pushes do not normally trigger workflows, a repair explicitly dispatches a follow-up run on the repaired branch with repair_script_modes=false. That run lints again and audits/tests without further repair. The repair job needs contents: write and actions: write; branch protections and repository restrictions can still block it.

Fork PRs are linted first but remain read-only. Their post-lint job audits the manifest and runs tests without permission changes. Contributors must correct any mode mismatch in their own branch. No pull_request_target workflow or privileged fork-code execution is introduced. Same-repository branches are the write-enabled trust boundary.

Local tests, configured policy, and observed runtime behavior are different evidence. Report unrun checks and unsupported capabilities. Live Bash errors remain unresolved until the diagnostic output is inspected and the code is fixed; no checks should be suppressed merely to obtain green CI. See [Git safety](GIT-CONFIG-SAFETY.md) before publishing. Extend validators when introducing a tracked format.

## License

Original files are covered by the [MIT License](LICENSE). Third-party tools and packages retain their own licenses.
