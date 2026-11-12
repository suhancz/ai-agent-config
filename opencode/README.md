# OpenCode adapter

Selector: `opencode`. Preserve other entries in the private host allowlist. Without an allowlist, detection requires the installed executable and an existing standard global opencode.json or opencode.jsonc. No CLI, SDK package, or system package is installed by this adapter.

Initial setup probes `opencode --version` with a ten-second timeout, selects the V1 or V2 prompt adapter, and uses existing conflict-safe symlink handling. Stable major versions 1 and 2 are recognized; malformed output, prereleases, unknown majors, failed probes, and custom OPENCODE_CONFIG_DIR installations stop without guessing. Major-family recognition is not a guarantee that every historical minor release supports its documented hook; actual client loading must be verified.

Managed paths under `${XDG_CONFIG_HOME:-$HOME/.config}/opencode`:

- `AGENTS.md` links to this adapter's shared-policy entry; the existing helper refreshes its private backup loader.
- V1: `plugins/ai-agent-config.js` links to v1.js.
- V2: `plugins/ai-agent-config/index.js` links to v2.js.

V1 uses chat.message; V2 registers the session prompt hook. Both await `bash setup.sh --request` with a thirty-second timeout and the plugin instance's task directory. V2's instance location may differ from individual session locations; multi-location server behavior requires separate verification. Errors propagate rather than being reported as success. This is not a universal enforcement boundary.

Initial setup removes only an obsolete managed V1/V2 symlink after installing its replacement. It refuses unrelated inactive hooks. Request mode probes the version and checks the active managed adapter but does not rewrite hooks. After an API-family upgrade or downgrade, rerun initial setup and restart OpenCode. Existing opencode.json/jsonc, providers, models, MCP registrations, credentials, and unrelated plugins are untouched.

Shared reporting and tracking helper links are provided through the existing setup loop. No provider quota API or shared tracker adapter is invented. Use shared reporting, privacy, approval, and unsupported-capability policies.

Verify conflict protection, backups, idempotence, V1/V2 selection, upgrade and downgrade migration, missing executables, rejected versions, and timeout/failure behavior. Test two prompts in one session and another in a new session on actual installed clients. Mocked hook tests do not establish real OpenCode compatibility. Verify global plugin discovery, symlink loading, failure propagation, private overrides, and concurrent session working directories on the host.

See the upstream OpenCode plugin migration guide for the distinct APIs. No background synchronization is installed.
