# Shared setup

## Loading rules for every agent

Loading rules is required before every user question, not just at session start. This applies to all AI assistants, providers, and follow-ups. At the start of each question, read all required rules before doing real work. Do not rely on previous loads, history, or model memory.

Before rules are loaded, do not start web searches, task searches, connector operations, task execution, edits, outgoing messages, or real answers. Only do the minimum to find and load the rules. Do not run task searches in parallel with rule loading.

Try the local filesystem first when available: find the main folder through the managed link or setup.sh, read current shared policies, memory, and the agent's rules, and load private backups. Do not assume a fixed path, scan unrelated data, overwrite dirty work, or claim an unavailable capability was tested.

If local access fails, get missing rules from the canonical GitHub repo through authorized Git access or the repo connector. A local Git executable is not required if a connector can retrieve files. Read the actual files and linked policies, and identify the revision used. Refresh before final reporting. Keep the latest-Git comparison and approval requirements before config writes.

Remote retrieval cannot recover ignored private overrides, host config, or credentials. Keep accessible private overrides and their precedence. Explicitly report unavailable private files and missing or stale content. If neither local nor GitHub retrieval works, stop real work and report config loading as blocked instead of silently using cached rules. Limit actions to authorized recovery and a blocker report. Do not publish private paths, backups, addresses, or runtime state.

Apply this local-first, GitHub-fallback rule to every AI through supported bootstrap instructions. Configure and test actual loading only where host/platform access and permissions exist. A repo policy alone does not install universal hooks, update all containers, or prove every-query enforcement. Report actual loading separately from saved policy and verify repeated queries and a new session where supported.

## Requirements and modes

Run setup from the main folder. On Linux/WSL, use Bash, GNU readlink, Git, and Python 3.12/pip via `bash setup.sh` or `bash setup.sh --request`. On Windows, use `pwsh ./setup.ps1` or `powershell -ExecutionPolicy Bypass -File ./setup.ps1` (same modes: `--request`, `--backup-existing`).

**WSL-shared on Windows (preferred when WSL is installed):** If WSL is present, the main folder should stay the Linux/WSL path and Windows setup should use the default WSL distro (never assume a distro name). `setup.ps1` attempts to run Linux `setup.sh` in WSL when invoked from a WSL UNC checkout and then manages Windows-side links/helpers for native Windows tools. When `setup.sh` runs inside WSL with Windows interop, it performs a best-effort delegation to Windows `setup.ps1` to configure Windows-side links. Agents on native Windows should use Windows binaries/helpers while reading/writing canonical shared config through the WSL path as applicable.

**Native Windows fallback:** If WSL is not installed/available, `setup.ps1` performs Windows-native setup mirroring Linux behavior. Resolve the checkout from the setup script path, not a hardcoded home-directory path. Preserve the caller's working directory for task identity resolution.

- `bash setup.sh`: install requirements.txt through user-level Python 3.12 pip, link selected instructions/helpers, refresh private backup loaders, and perform supported initial adapter setup. The Python helpers use the standard library.
- `bash setup.sh --request`: refresh selected links and private instruction-backup loaders without pip installation, hook rewriting, new OAuth, software upgrades, another agent's quota requests, or Git fetching.
- `bash setup.sh --backup-existing`: after reviewing conflicts, preserve conflicting paths in timestamped sibling backups before linking managed files. Existing main links into this checkout are idempotent. Installation is not transactional.

No system packages or agent CLIs are installed. Missing selected executables are skipped; missing required setup runtimes are reported. Selection indicates configuration, not successful authentication.

## Host selection

Keep the private allowlist at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/agents`, one exact selector per line. An empty file selects nothing. Preserve all other desired entries when adding one. Without an allowlist, setup uses conservative existing configuration indicators. See the adapter index for exact selectors and detection conditions.

Only selected surfaces receive managed files. Deselecting a surface does not remove its old files. Additional adapter-owned installers may have their own scope; review the adapter's documented behavior rather than assuming this allowlist controls third-party installers.

## Private backup overrides

Selected main instruction files remain links to canonical sources. Setup generates `<main-filename>.local-overrides.md` beside each live instruction file, including request-time reruns. It records explicit ordered backup paths, not their contents, in a mode-0600 local file. The helper refuses tracked loaders, symlink loader paths, and unmanaged conflicts, and preserves notes outside its managed block.

Agents must read the local loader and its listed instruction backups whenever they read the main instructions. Canonical instructions load first; oldest-to-newest backups override repository user preferences. Later backups win conflicts. Current explicit instructions, platform permissions, and sensitive-data exclusions remain in force. See shared memory for exact discovery, ordering, and capability boundaries.

Backups, generated loaders, and temporary loader files are excluded from Git. Ignore patterns do not untrack existing files. Missing host access or unreadable files must be reported; creating a sidecar does not prove native client loading. Never execute a backup or treat credentials and executable helpers as instruction overrides.

## Shared helper implementation

The helpers directory contains reporting, usage tracking, hook installation, and private-loader generation. Selected adapters expose the applicable helpers at their documented live paths. Historical helper-directory names are retained as compatibility interfaces; this documentation refactor does not move local runtime files or copy private state. Keep user-only settings in ignored AGENTS.local.md or external private configuration.

Setup surfaces mail routing and Git safety. Supported private client configuration remains the calling agent's responsibility. Printing policy is not connector registration or authentication.

## Request hooks and synchronization

Supported adapter hooks can run request setup after initial installation and any trust approval. Exact events and paths are adapter-specific. Test at least two prompts in the same session and a new session. A session-start-only event does not satisfy every request, and hook failure handling is not a universal enforcement boundary.

Symlinks do not fetch upstream or load all files into every model context. Read current canonical instructions and memory independently, refresh before reporting, and compare with latest Git before configuration changes. Preserve dirty work and existing SSH transport. No background synchronization is installed.

If the checkout moves, remove stale managed hook commands through the approved workflow before reinstalling. The current hook installer deduplicates identical commands, not commands pointing to an old checkout. Generated hook JSON and authentication remain private.

## Compatibility

Legacy documentation paths may remain small redirects, not parallel policy authorities. Native client filenames may retain product-specific spelling where changing them would break discovery or private backup paths. The editor adapter documents the shared-source migration and its preserved live filename. No unrelated private file is overwritten during migration.