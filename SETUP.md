# Shared setup

## Configuration loading for every agent

Configuration loading is a prerequisite for every user query, not merely session start, a new project, or a coding task. This applies to every AI assistant and agent, all providers and applications, and all follow-ups, short replies, approval replies, conversations, folders, workspaces, and successor systems. At the start of each query, read the complete applicable configuration required by root AGENTS.md before beginning substantive work. Do not rely only on a previous query's loaded copy, conversation history, or private model memory.

Before the configuration has been read, do not begin web or task-data searches, unrelated connector operations, task execution, edits, outgoing communications, or substantive answers. The only permitted bootstrap operations are the minimum capability discovery, path or repository resolution, access checks, and reads necessary to locate and load the configuration and its applicable references, subject to higher-priority platform requirements. Do not run task searches in parallel with instruction loading. Apply required work-item checks and other startup actions only after this prerequisite is satisfied.

Try the actual local filesystem first when a supported host-filesystem reader is available: locate the canonical checkout through the managed instruction symlink or setup.sh, read the current shared policies, memory, and answering adapter, and load the applicable private instruction sidecar and its listed backups. Do not assume a fixed checkout path, scan unrelated private data, overwrite dirty work, or claim an unavailable local capability was tested. A sandbox filesystem is not proof of access to the user's host clone.

If local access is unavailable, the clone is missing or unreadable, or a required canonical file cannot be read, retrieve the missing configuration from the canonical GitHub repository through existing authorized Git access or the repository connector before doing substantive work. A local Git executable is not required when an authorized repository connector can retrieve the files. Resolve the current canonical branch/revision, read the actual applicable files and linked policies, and identify the revision used. Refresh before final reporting as required by root policy. Preserve the existing latest-Git comparison and approval requirements before configuration writes even when reading locally.

Remote retrieval cannot recover ignored private overrides, host configuration, or credentials. Preserve accessible private overrides and their documented precedence; explicitly report unavailable private files and any missing or stale canonical content. If neither local nor GitHub retrieval succeeds, stop substantive work and report configuration loading as blocked instead of silently using cached instructions or claiming compliance. Limit further actions to authorized recovery of configuration access and a blocker report consistent with platform requirements; do not invent inaccessible settings. Do not publish private paths, backups, addresses, or runtime state.

Apply this local-first, GitHub-fallback prerequisite to every current and successor AI through supported bootstrap instructions. Configure and test actual loading only where host/platform access and permissions exist; a repository policy alone does not install universal hooks, update all containers, or prove every-query enforcement. Report actual loading separately from saved policy and verify repeated queries in one session and a new session wherever supported.

## Requirements and modes

Run setup from a checkout on the existing Linux/WSL environment with Bash, GNU readlink, Git, and Python 3.12/pip. This is not a native Windows installer. Resolve the checkout from setup.sh rather than assuming a home-directory path. Preserve the caller's working directory for task identity resolution.

- `bash setup.sh`: install requirements.txt through user-level Python 3.12 pip, link selected instructions/helpers, refresh private backup loaders, and perform supported initial adapter setup. The Python helpers use the standard library.
- `bash setup.sh --request`: refresh selected links and private instruction-backup loaders without pip installation, hook rewriting, new OAuth, software upgrades, another agent's quota requests, or Git fetching.
- `bash setup.sh --backup-existing`: after reviewing conflicts, preserve conflicting paths in timestamped sibling backups before linking managed files. Existing main links into this checkout are idempotent. Installation is not transactional.

No system packages or agent CLIs are installed. Missing selected executables are skipped; missing required setup runtimes are reported. Selection indicates configuration, not successful authentication.

## Host selection

Keep the authoritative private allowlist at `${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config/agents`, one exact selector per line. An existing empty file selects nothing. Preserve all other desired entries when adding one. Without an allowlist, setup uses conservative existing configuration indicators. See the [adapter index](README.md#adapter-documentation) for exact selectors and detection conditions.

Only selected surfaces receive managed files. Deselecting a surface does not remove its old files. Additional adapter-owned installers may have their own scope; review the adapter's documented behavior rather than assuming this allowlist controls third-party installers.

## Private backup overrides

Selected main instruction files remain links to canonical sources. Setup generates `<main-filename>.local-overrides.md` beside each live instruction file using helpers/write-backup-loader.py, including request-time reruns. It records explicit ordered backup paths, not their contents, in a mode-0600 local file. The helper refuses tracked loaders, symlink loader paths, and unmanaged conflicts, and preserves notes outside its managed block.

Agents must read the local loader and its listed instruction backups whenever they read the main instructions. Canonical instructions load first; oldest-to-newest backups override repository user preferences. Later backups win conflicts. Current explicit instructions, platform permissions, and sensitive-data exclusions remain in force. See [shared memory](memory/MEMORY.md) for exact discovery, ordering, and capability boundaries.

Backups, generated loaders, and temporary loader files are excluded from Git. Ignore patterns do not untrack existing files. Missing host access or unreadable files must be reported; creating a sidecar does not prove native client loading. Never execute a backup or treat credentials and executable helpers as instruction overrides.

## Shared helper implementation

The helpers directory contains reporting, usage tracking, hook installation, and private-loader generation. Selected adapters expose the applicable helpers at their documented live paths. Historical helper-directory names are retained as compatibility interfaces; this documentation refactor does not move local runtime files or copy private state. Keep user-only settings in ignored AGENTS.local.md or external private configuration.

Setup surfaces [mail routing](MAIL-ROUTING.md) and [Git safety](GIT-CONFIG-SAFETY.md). Supported private client configuration remains the calling agent's responsibility. Printing policy is not connector registration or authentication.

## Request hooks and synchronization

Supported adapter hooks can run request setup after initial installation and any trust approval. Exact events and paths are adapter-specific. Test at least two prompts in the same session and a new session. A session-start-only event does not satisfy every request, and hook failure handling is not a universal enforcement boundary.

Symlinks do not fetch upstream or load all files into every model context. Read current canonical instructions and memory independently, refresh before reporting, and compare with latest Git before configuration changes. Preserve dirty work and existing SSH transport. No background synchronization is installed.

If the checkout moves, remove stale managed hook commands through the approved workflow before reinstalling. The current hook installer deduplicates identical commands, not commands pointing to an old checkout. Generated hook JSON and authentication remain private.

## Compatibility

Legacy documentation paths may remain small redirects, not parallel policy authorities. Native client filenames may retain product-specific spelling where changing them would break discovery or private backup paths. The [editor adapter](vscode/README.md) documents the shared-source migration and its preserved live filename. No unrelated private file is overwritten during migration.
