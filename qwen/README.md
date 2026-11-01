# Qwen Code adapter

Read [entry instructions](QWEN.md), [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [mail routing](../MAIL-ROUTING.md). This adapter configures Qwen Code, not the hosted Android chat app or an Ollama model server.

## Host selection and installation

Selector: `qwen`. Preserve existing entries when adding it to the private agents allowlist described in shared setup. An existing allowlist is authoritative, including an empty file. Without one, conservative detection requires both the qwen executable and ~/.qwen/settings.json. Setup never installs the CLI or authenticates an account.

Run bash setup.sh from the canonical checkout after selecting the installed client. Setup links qwen/QWEN.md to the documented global ~/.qwen/QWEN.md and refreshes its adjacent private backup loader. Existing unmanaged instructions are refused; review them before using --backup-existing. This adapter uses the documented default Qwen home; custom home locations are not inferred.

Initial setup merges one managed UserPromptSubmit command into ~/.qwen/settings.json, preserving unrelated settings and hooks. Identical reruns do not duplicate the entry. Symlinked settings files are refused, not replaced. Invalid JSON or incompatible hook structures fail rather than being reset. Provider/model selection and authentication remain unchanged. Concurrent local settings edits require separate coordination.

The hook runs bash setup.sh --request with output redirected to stderr and translates setup failure to blocking exit code 2. It does not log submitted prompts, call Qwen recursively, fetch Git, install packages, or rewrite hooks. Running request setup is not proof that the model reread all policies; the global instructions separately require that reading.

## Hook coverage and verification

UserPromptSubmit covers supported model-invocation paths, not every retry, continuation, background event, or client transport. Hooks may be disabled by user settings, safe mode, or bare mode. Preserve those controls and report the resulting gap; do not silently enable them. Restart Qwen after installation or use its supported interactive /hooks reload mechanism. Verify the managed entry, two prompts in one session, and a new session. Record actual version and results. Repository edits alone do not install or test host hooks.

If the checkout moves, review/remove the old managed command before reinstalling. The installer deduplicates identical entries but does not identify commands for an old checkout. Symlinks do not fetch upstream or synchronize already running model contexts.

## Reporting, usage, and tools

Apply the full shared reporting, timestamp, privacy, canonical-memory, Git safety, and private-backup policies. Configure supported same-context connectors only with Qwen's existing authorization and eligible host metadata. No universal MCP registrar, personal connection, OAuth session, or mail delivery is established by this adapter. Work hosts must not gain personal MCP registrations.

Report Agent, selected Model, and Model version/mode separately when supported; explain unavailable details. Inspect only Qwen's supported non-secret account/status facilities. No Qwen quota endpoint or shared tracker adapter is assumed. Never use another agent's quota helpers. When unavailable, say: Qwen quota/reset unavailable; private usage tracking and forecast unavailable. Do not claim that Qwen has no quota solely because its local status cannot expose one.

## Sources and validation

Official Qwen Code documentation describes the global QWEN.md and settings-based UserPromptSubmit mechanisms. Verify compatibility against the installed version. This addition uses existing Bash, Python, and Markdown formats; existing validators remain applicable. Run shared tests, Bash syntax checks, Python lint, Markdown validation, and Git executable-mode checks before declaring full validation complete. Native Qwen execution, local overrides, connector authentication, mail submission, and repeated-session behavior require separate host verification.
