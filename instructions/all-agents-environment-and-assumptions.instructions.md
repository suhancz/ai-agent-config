# All-agent contract: environment and assumptions

Part of the all-agent contract in [all-agents.instructions.md](all-agents.instructions.md). Read it on every request together with that file.

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
