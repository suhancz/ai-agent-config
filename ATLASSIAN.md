# Shared Atlassian tool integration

## Scope

Apply root AGENTS.md, memory/MEMORY.md, MAIL-ROUTING.md, and GIT-CONFIG-SAFETY.md together with the answering agent's instructions. Rovo is an agent; standalone TWG is a shared tool, not a separate quota-owning agent. Prefer one explicitly chosen Atlassian access surface per session to avoid ambiguous account routing. Never copy another agent's credentials.

## Host-selective setup

The private agents allowlist may include `rovo` and `twg`, preserving all other entries. Without an allowlist, Rovo requires its executable and ~/.rovo/config.yml; standalone TWG requires the private twg-bin selector described below. These are configuration indicators, not proof of authentication. Missing CLIs are not installed.

For standalone TWG, create `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/twg-bin` privately with exactly one absolute path to an approved standalone executable. Keep it user-only and outside the repository. Do not point it at Rovo's bundled TWG. The helper rejects known .rovo/.rovodev bundle paths, but that path check is not exhaustive provenance verification: the user must select an actual standalone installation.

Selected initial setup runs the approved standalone binary's `skills install --global` followed by `doctor`. The vendor installer owns third-party skills under ~/.agents/skills and any supported locally detected agent-specific copies; do not copy those skills or their licenses into this repository. Review local agent detection before selecting TWG if additional detected clients must be excluded. Global skill installation uses the vendor's selection behavior, not this repository's agent allowlist.

Request-time setup validates the selected executable but does not reinstall skills, upgrade software, start OAuth, or run network diagnostics. If initial doctor fails, report authentication/connectivity as pending, not configured. First-time consent/login must use an interactive terminal and approved account. Do not bypass organizational consent or security controls.

## Discovery and operations

Use `twg help` and `twg help describe` with the intended command path before guessing product commands, arguments, or output handling. Inspect installed vendor skill instructions. At task start, use an authorized available surface to check assigned Jira work when required; retrieve relevant work-item details and verify assignee and status. Do not publish returned private product data.

Read-only discovery does not authorize creating, updating, deleting, commenting, or sending. Respect the current platform's exact-target/content confirmation requirements for all external changes, regardless of any standing preference. Do not run a write as a connectivity test.

Rovo's bundled TWG is authenticated and versioned by Rovo. Use rovo login for that bundle; do not independently run its login, update/upgrade, uninstall, or consent lifecycle commands. An unrelated standalone TWG installation has its own lifecycle and requires separately authorized setup.

## Privacy and capability boundaries

Keep sites, email addresses, account identifiers, connector identities, tokens, OAuth/keychain state, and machine-specific paths private. Do not print credentials, store command output in tracked files, or publish raw doctor reports. Never infer an organization credit pool is an individual agent balance. No Rovo/TWG quota API is invented here. Neither setup nor instructions prove authentication, automatic hook execution, connector registration, or delivery.
