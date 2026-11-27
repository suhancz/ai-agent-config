# All-agent contract: scripts and quota

Part of the all-agent contract in [all-agents.instructions.md](all-agents.instructions.md). Read it on every request together with that file.

## Executable intent and all-agent script maintenance

Every current and successor agent must maintain [.github/executable-files.txt](../.github/executable-files.txt) whenever adding, renaming, removing, or changing the invocation role of a script in this repository. This exact-path reviewed manifest is the authority for executable intent, not an extension, a shebang alone, or a directory-wide chmod.

- Identify actual command-line entry points, including helpers invoked through an explicit interpreter. Add their exact tracked repository-relative paths to the manifest, give them an appropriate interpreter shebang, and record Git mode 100755 in the same task. Renames must replace the old manifest path; removals must remove it.
- Do not list imported test modules, libraries, sourced-only shell helpers, plugin modules, documentation, or configuration merely because they contain code. Unlisted regular files must have Git mode 100644. Preserve symlinks as 120000 and do not follow them for permission changes; do not alter submodule modes.
- With Git-capable host access, apply `chmod +x` and `git update-index --chmod=+x -- <path>` for intended entry points. Use the corresponding non-executable mode and `git update-index --chmod=-x -- <path>` for regular files that are no longer entry points. Verify `git ls-files --stage` and the staged diff, and verify committed modes after publication. Preserve unrelated dirty/staged work.
- The CI manifest validator must reject missing/untracked entries, directories, symlinks, duplicate paths, wildcard/parent-traversal paths, empty manifests, and listed scripts without shebangs before applying any repair. It repairs both missing intended executable bits and unintended executable bits on unlisted regular files.
- Never add unrelated files to the manifest to silence a check, mass-chmod by extension, or defer the agent's mode responsibility solely to CI. If the current connector cannot set modes, disclose that boundary and verify the mode-only bot repair at the resulting commit before claiming success. Keep actual lint and test failures visible.

## Generic quota and forecast interface

helpers/track_agent_usage.py accepts any validated agent slug. Codex/Copilot built-in labels remain unchanged. Other agents use repeated --metric options or AI_AGENT_QUOTA_METRICS, with fresh real status on stdin in the form `<metric> <percentage>% remaining`. Retain supported reset/renewal text in that status. No provider API, credentials, sampler, or renewal value is invented.

Use stable non-identifying provider-and-window-specific labels; do not mix accounts/providers/windows under one label or reuse another agent's samples. Run once per actual snapshot. The existing private mode-0600 log, same-day trend, five-minute minimum, replenishment detection, and warning behavior are reused. No configured labels or parseable real percentage means no sample and no fabricated forecast. Earlier adapter text limiting tracker identifiers to two agents is superseded by this interface, not by a claim that every provider exposes quotas.

```sh
python3.12 helpers/track_agent_usage.py --agent opencode --metric provider-daily
```

The existing setup already symlinks this tracker and the shared SMTP report helper for selected agent surfaces. Use the canonical helper from the resolved checkout on surfaces without host symlinks. Cloud-only agents must report unavailable host execution. The agent still resolves and invokes authorized mail/Jira tools; the tracker does not send email or query tickets.
