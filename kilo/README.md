# Kilo Code adapter

Read [entry instructions](AGENTS.md), [shared setup](../SETUP.md), [reporting](../REPORTING.md), and [mail routing](../MAIL-ROUTING.md). This adapter covers the Kilo Code CLI and the Kilo Code VS Code extension, which share the Kilo 1.0 configuration model.

## Host selection and installation

Selector: `kilo`. Preserve existing entries when adding it to the private agents allowlist described in shared setup. An existing allowlist is authoritative, including an empty file. Without one, conservative detection requires either the `kilo` executable or an existing standard global Kilo configuration file at `${XDG_CONFIG_HOME:-$HOME/.config}/kilo/kilo.json` or `kilo.jsonc`. Setup never installs the CLI/extension, provider credentials, or authenticates an account.

Run `bash setup.sh` from the canonical checkout after selecting the installed client. Setup links `kilo/AGENTS.md` to the documented global `${XDG_CONFIG_HOME:-$HOME/.config}/kilo/AGENTS.md` and refreshes its adjacent private backup loader. Existing unmanaged instructions are refused; review them before using `--backup-existing`. The selected executable or existing global config is a configuration indicator, not proof that the client is authenticated, that MCP servers are registered, or that the extension/CLI will load instructions in every surface.

This adapter targets the standard global Kilo config directory. Custom `KILO_CONFIG_DIR` or other nonstandard locations require separate verified discovery support; do not assume they are covered by this managed link.

## CLI and VS Code extension surfaces

The Kilo Code CLI uses `~/.config/kilo/kilo.json[c]` for provider/model/permission/MCP settings and reads instruction files such as `AGENTS.md` per Kilo's documented instruction discovery. The Kilo Code VS Code extension in current releases is built on the same Kilo 1.0 configuration model; project `AGENTS.md` files and shared Kilo config apply where the installed client supports them. Setup configures the managed global instruction link only; verify actual loading in the installed CLI and extension surfaces, including repeated prompts and a new session.

No native per-request hook/plugin is installed by this adapter. Running `bash setup.sh --request` refreshes links and backup loaders but does not fetch Git or force a running session to reread policy. The global instructions require reading current canonical policies and memory each request; unsupported automatic enforcement must be reported explicitly.

## Reporting, usage, and tools

Apply the full shared reporting, timestamp, privacy, canonical-memory, Git safety, and private-backup policies. Configure supported same-context connectors only with Kilo's existing authorization and eligible host metadata. No universal MCP registrar, personal connection, OAuth session, or mail delivery is established by this adapter.

Report Agent, selected Model, and Model version/mode separately when supported; explain unavailable details. Inspect only Kilo's supported non-secret account/status facilities. No Kilo quota endpoint or shared tracker adapter is assumed by default. Never use another agent's quota helpers. When unavailable, say: `Kilo quota and renewal unavailable. Forecast unavailable.` Use the generic tracker interface only with an explicitly supported real quota source and documented metric labels.

## Sources and validation

Kilo Code documentation describes global config under `~/.config/kilo/`, `kilo.jsonc` for providers/MCP, and instruction discovery including `AGENTS.md`. Verify compatibility against the installed CLI and extension versions. This addition uses existing Bash, Python, and Markdown formats; existing validators remain applicable. Run shared tests and relevant lint/syntax checks before declaring full validation complete. Native CLI/extension instruction loading, local overrides, connector authentication, MCP configuration, mail submission, and repeated-session behavior require separate host verification.
