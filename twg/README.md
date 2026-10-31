# Standalone Teamwork Graph CLI

This is a shared tool, not another AI agent. See [shared setup](../SETUP.md), the [integration policy](../ATLASSIAN.md), and the [Rovo adapter](../rovo/README.md) for its separately managed bundle.

Selector: `twg`. The private `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/twg-bin` file contains one absolute path to an approved standalone executable; keep it user-only. An existing agents allowlist must also include twg. Without an allowlist, the selector file enables it. Missing executables are not installed.

Never select the Rovo-managed bundle. Known .rovo/.rovodev paths are rejected, but the user must verify standalone provenance; path checks are not exhaustive proof. Authentication and organizational consent require a separately authorized interactive setup.

Initial setup runs the selected binary's skills install --global and doctor. Third-party skills remain vendor-owned outside this repository. The global installer follows its own detected-client behavior, not this repository's allowlist; review its scope before enabling it. Request mode validates the private executable selection without reinstalling skills, upgrading, network diagnostics, or starting OAuth. Failed doctor means authentication/connectivity is pending.

Use twg help and twg help describe with the intended command path, and inspect the installed vendor skills before guessing syntax. Perform authorized assigned-work checks and verify native issue assignment/status when required. Respect all external-write confirmation gates; do not use a write as a connectivity test. Never publish private product data, account metadata, tokens, or raw doctor reports. No separate AI-agent quota is inferred for this tool.
