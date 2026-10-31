# Editor adapter

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), and the generic [global preferences](../instructions/global-preferences.instructions.md). This adapter targets the existing VS Code Server user-instruction layout; it is not a native Windows desktop installer or a universal IDE hook installer.

Selector: `vscode`. Without an allowlist, setup selects it only when `$HOME/.vscode-server/data/User` already exists. The canonical shared source now has the generic path instructions/global-preferences.instructions.md and generic front-matter metadata.

The live filename `$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md` is retained solely for compatibility with existing discovery, backups, private loaders, and prior links. Setup retargets that live link automatically only if it is a symlink pointing exactly to this checkout's legacy source. A private regular file or unrelated link remains protected by the usual conflict/backup rules. The adjacent private loader is refreshed against the generic source.

The old tracked source file is a small redirect, not a duplicate policy. It remains readable for older clients and references. This compatibility exception does not authorize product-specific names for new shared instructions.

Use the answering model/agent's own supported quota adapter; the editor itself is not a substitute balance identity. No universal editor per-prompt shell hook is installed. Verify instruction loading with the actual client and report unsupported discovery rather than claiming it worked.
