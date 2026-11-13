# Complete preferences for all agents

Apply this contract to every current and successor agent across every project, request, and session. It supplements root AGENTS.md, shared preferences, shared memory, SETUP.md, REPORTING.md, MAIL-ROUTING.md, GIT-CONFIG-SAFETY.md, applicable ATLASSIAN.md, and the answering adapter. The adapter index is the synchronized surface registry, including opencode/AGENTS.md; older static lists do not exclude newer agents. Read actual current policies and private backup loaders, not just this summary.

## Required behavior

- Timestamps: prefix user-facing messages and reports with actual user-local response time; record supplied request time separately, preserve precision, and label missing clocks. Never reuse request time as response time.
- Reporting/email: produce completion or blocked-status HTML reports with agent/model metadata, request/outcome, revisions, verification, limitations, SSH status, quota/reset, forecast warnings, and submission evidence. Use the authorized same-context connector first, existing SMTP helper second; actual sender equals the sole recipient, with no CC/BCC. Preserve mandatory approval, MIME validation, and duplicate-delivery protection. Do not silently waive reporting when the primary task succeeds.
- Quota/forecast: sample only the answering agent through supported authenticated status sources. Reuse existing built-in status helpers or the generic tracker interface below. Do not substitute another agent's balance, context usage, token counts, estimated costs, or shared organization pools for account quota. Unknown quota/reset/forecast stays unavailable.
- Tickets/Jira: read ATLASSIAN.md, use an authorized available work-item surface, inspect supported commands before use, check assigned work when required, and verify relevant ticket assignee/status. Use a known active ticket key and a fresh timestamp in remote backup names; never guess ticket keys or use writes as connectivity tests.
- Memory/privacy: read current shared memory every request; persist eligible durable non-sensitive lessons. Preserve private-backup precedence and explicit exclusions. Never publish raw transcripts, private identifiers, credentials, endpoints, account data, overrides, work data, or runtime samples.
- Git/setup: preserve SSH transport, upstream freshness checks, dirty/concurrent work, conflict-safe symlinks, validation, modes, and host selection. Do not install CLIs or copy credentials implicitly. Keep one final commit where supported; an expanded already-published PR may be squash-merged by its owner. Leave this PR's approval and merge to the user; do not enable auto-merge.
- Completion: refresh applicable policies/memory and explicitly distinguish completed, assumed-compatible/unverified, pending approval, blocked, failed, and genuinely inapplicable obligations. Hooks and saved policy do not prove real-client compliance.

## Executable intent and all-agent script maintenance

Every current and successor agent must maintain [.github/executable-files.txt](../.github/executable-files.txt) whenever adding, renaming, removing, or changing the invocation role of a script in this repository. This exact-path reviewed manifest is the authority for executable intent, not an extension, a shebang alone, or a directory-wide chmod.

- Identify actual command-line entry points, including helpers invoked through an explicit interpreter. Add their exact tracked repository-relative paths to the manifest, give them an appropriate interpreter shebang, and record Git mode 100755 in the same task. Renames must replace the old manifest path; removals must remove it.
- Do not list imported test modules, libraries, sourced-only shell helpers, plugin modules, documentation, or configuration merely because they contain code. Unlisted regular files must have Git mode 100644. Preserve symlinks as 120000 and do not follow them for permission changes; do not alter submodule modes.
- With Git-capable host access, apply chmod +x and git update-index --chmod=+x -- <path> for intended entry points. Use the corresponding non-executable mode and git update-index --chmod=-x -- <path> for regular files that are no longer entry points. Verify git ls-files --stage and the staged diff, and verify committed modes after publication. Preserve unrelated dirty/staged work.
- The CI manifest validator must reject missing/untracked entries, directories, symlinks, duplicate paths, wildcard/parent-traversal paths, empty manifests, and listed scripts without shebangs before applying any repair. It repairs both missing intended executable bits and unintended executable bits on unlisted regular files.
- Never add unrelated files to the manifest to silence a check, mass-chmod by extension, or defer the agent's mode responsibility solely to CI. If the current connector cannot set modes, disclose that boundary and verify the mode-only bot repair at the resulting commit before claiming success. Keep actual lint and test failures visible.

## Generic quota and forecast interface

helpers/track_agent_usage.py accepts any validated agent slug. Codex/Copilot built-in labels remain unchanged. Other agents use repeated --metric options or AI_AGENT_QUOTA_METRICS, with fresh real status on stdin in the form <metric> <percentage>% remaining. Retain supported reset/renewal text in that status. No provider API, credentials, sampler, or renewal value is invented.

Use stable non-identifying provider-and-window-specific labels; do not mix accounts/providers/windows under one label or reuse another agent's samples. Run once per actual snapshot. The existing private mode-0600 log, same-day trend, five-minute minimum, replenishment detection, and warning behavior are reused. No configured labels or parseable real percentage means no sample and no fabricated forecast. Earlier adapter text limiting tracker identifiers to two agents is superseded by this interface, not by a claim that every provider exposes quotas.

```sh
python3.12 helpers/track_agent_usage.py --agent opencode --metric provider-daily
```

The existing setup already symlinks this tracker and the shared SMTP report helper for selected agent surfaces. Use the canonical helper from the resolved checkout on surfaces without host symlinks. Cloud-only agents must report unavailable host execution. The agent still resolves and invokes authorized mail/Jira tools; the tracker does not send email or query tickets.

## Environment and private configuration

| Setting | Purpose and requirement |
| --- | --- |
| TZ | Set the user's real IANA timezone in the agent/hook/service environment when host time differs. Existing Python timestamp, mail, and forecast helpers inherit it. A shell export does not change an already-running IDE/service. Keep the actual user setting private. |
| AI_AGENT_QUOTA_METRICS | Optional new comma-separated tracker labels for generic agents. Repeated --metric options take precedence. Do not override built-in labels. Requires an independently supported actual quota source. |
| AI_AGENT_REPORT_ADDRESS_FILE | Existing SMTP helper override for the private approved report-address file. Otherwise existing sSMTP mappings apply. It does not register a connector or supply a password. |
| XDG_CONFIG_HOME | Existing selection/OpenCode config base, defaulting to the home .config directory. The SMTP address-file default does not follow it automatically; set AI_AGENT_REPORT_ADDRESS_FILE when relocating that file. |
| CODEX_HOME / COPILOT_HOME | Existing optional native configuration-home overrides used by setup/hooks. Preserve private client contents and discovery semantics. |
| SSH_AUTH_SOCK | Existing socket for SSH transport and fingerprint reporting where an SSH agent is used; never publish socket paths or key material. |
| OPENCODE_CONFIG_DIR | Current OpenCode setup refuses nonempty overrides pending verified discovery support. It is not required. |

Keep private host selections in the existing agents allowlist and standalone TWG selection in twg-bin per SETUP.md/ATLASSIAN.md. MCP endpoints/authentication remain in private supported client settings. No universal Jira token, SMTP password, or provider-key variable is introduced. The tracker retains its ignored .agent-usage.jsonl default; --data-file selects another private log. Never commit runtime logs.

## Untestable environments

Proceed by analogy with existing code when a client/environment cannot be tested: reuse supported parameters, runtimes, privacy, error handling, and setup conventions. Document the source analogy and exact assumption as assumed-compatible/unverified. Do not turn that assumption into a passed test, real quota measurement, authenticated identity, ticket result, mail submission, or delivered report. Platform gates and privacy rules remain binding.

The generic tracker reuses the existing parser/log/forecast design; mail reuses send-completion-report.py; Jira reuses approved connector/TWG discovery. Repeated-prompt, new-session, client authentication, connector delivery, and actual provider behavior remain separate real-environment checks.
