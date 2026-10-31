# Codex adapter

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [entry instructions](AGENTS.md). Preserve root-policy precedence over older entry wording.

Selector: `codex`. Without an allowlist, detection requires the codex executable and `${CODEX_HOME:-$HOME/.codex}/config.toml`. Setup links this directory's AGENTS.md to `${CODEX_HOME:-$HOME/.codex}/AGENTS.md` and refreshes its private backup loader. This is not an authentication test.

Initial setup merges the user-level UserPromptSubmit command into the configured home's hooks.json. Review/trust it with the installed client's supported /hooks interface. Verify repeated prompts; disabled/unsupported hooks must be reported. Existing unrelated hooks are preserved; malformed configuration fails rather than being replaced.

The own-agent helper is `$HOME/code/.codex-tools/codex-credit-status.sh`; the historical shared helper directory is retained for compatibility. Run with the required supported sandbox permission, without inspecting credentials. At query end pipe only this agent's output to the tracker with --agent codex. On failure the exact fallback is: `Codex credits: percentage and renewal unavailable.` Do not collect another agent's status.

Other shared helpers in that live directory include track_agent_usage.py, send-completion-report.py, and test_completion_report.py. Private usage logs, local Git identity, and authentication remain outside the repository.
