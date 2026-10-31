# Copilot adapter

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [native entry instructions](copilot-instructions.md). Its native filename is adapter-specific, not a naming convention for shared policies. Root mail-routing and timestamp overrides supersede older entry wording.

Selector: `copilot`. Without an allowlist, detection requires the copilot executable and `${COPILOT_HOME:-$HOME/.copilot}/config.json`. Setup links native instructions under that configured home and refreshes their private backup loader. Initial setup merges userPromptSubmitted into hooks/ai-agent-config.json. Verify actual client hook loading and repeated prompts; installation alone does not prove execution.

The own-agent helper is `$HOME/code/.codex-tools/copilot-credit-status.sh`, backed by copilot-credit-status.mjs. The historical shared helper directory is retained for compatibility. The helper uses the authenticated CLI SDK quota interface and must not expose credentials. At query end pipe only this agent's output to the tracker with --agent copilot. On failure or unavailable authentication/quota, the exact fallback is: `Copilot credits: percentage and renewal unavailable.`

The same directory exposes shared tracking/report helpers. Do not inspect tokens or query a different agent's quota. Missing runtime, authentication, or native configuration support is a reported limitation, not a reason to install software or overwrite private files silently.
