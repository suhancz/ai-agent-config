# Repository instructions

This public repository is the canonical source for the user's AI-agent instructions and helper scripts.

## Mandatory instruction loading and preference persistence

These shared rules apply equally to Codex, Copilot, VS Code agent surfaces, Perplexity, and future agents that use this repository.

- At the start of every user task, read the latest accessible canonical root AGENTS.md and the applicable agent instructions from this repository. Refresh them before final reporting and before publishing instruction changes. Do not rely solely on conversation history, memory, or a previously cached copy. Report repository access failures and identify any stale revision used.
- The synchronized instruction set includes codex/AGENTS.md, copilot/copilot-instructions.md, vscode/global-codex-preferences.instructions.md, and perplexity/AGENTS.md. Every agent must apply this root policy alongside its own entry instructions. When adding another agent surface, include it in this set and its documented loading mechanism.
- Whenever the user requests an enduring preference, including wording such as always, never, from now on, or whenever, persist the non-sensitive preference in the canonical repository instructions as part of that task. Update all affected agent entry instructions together when needed to keep their behavior consistent. Preserve unrelated preferences and do not claim persistence until the repository write succeeds.
- If a new preference conflicts with an existing one, identify the difference and the user's apparent reasoning. Ask for clarification or approval when the change of mind is ambiguous; do not silently replace an existing preference. An explicit unambiguous later instruction takes precedence within the user's instructions, subject to platform rules.
- Explicit exclusions take precedence over persistence: do not commit a preference the user says to keep out of the repository. Keep addresses, account usernames, credentials, connector identities, private endpoints, and machine-specific values in private runtime configuration. Persist only the generic behavior when appropriate, without copying the private value. Do not leak it through commit messages, examples, fixtures, or reports published to the repository.
- Before changing instructions, retrieve the current affected files, preserve unrelated edits, inspect the complete proposed changes, and follow applicable testing and Git workflow requirements. Respect mandatory platform confirmation gates; a standing preference does not authorize bypassing them. If approval, write access, or another capability is missing, report persistence as pending or blocked rather than completed.
- Synchronization means keeping canonical policies and affected agent entry instructions consistent and refreshing accessible copies at task boundaries. Symlinks do not fetch upstream changes, and repository text does not install background synchronization or update running sessions. Do not claim all agents are continuously synchronized without a separately configured and verified mechanism. Never overwrite dirty local work to force synchronization.
- Each agent must instruct successor agents and newly configured agent surfaces to follow the same canonical-loading, preference-persistence, privacy, and synchronization rules. If the current platform does not automatically load repository instructions, document and configure a supported bootstrap or Project instruction mechanism rather than claiming automatic loading.

## Managed files and reporting

- Edit and add managed files here; the user's live Codex, Copilot, VS Code, and helper paths are symlinks into this checkout.
- Locate this checkout from the directory containing `setup.sh`, rather than assuming a fixed home-directory path.
- `setup.sh` installs Python requirements and checks external runtime tools; avoid adding system packages or agent CLIs unless explicitly requested.
- Keep the README's file map and setup instructions current.
- Keep `.github/workflows/super-linter.yml` aligned with every language and executable/configuration format used in the repository. When adding one, enable its Super-Linter validator, add necessary linter configuration, update the README's lint coverage, and verify the new lint check.
- At the end of every user query, each agent must record its own current quota through its existing status helper and `track_agent_usage.py`; retain the generated forecast and any warning in the local `.agent-usage.jsonl` report, and include warnings in both the final response and completion/status email. This data file must remain ignored and never be staged or published.
- Timestamp every user-facing step in CLI and VS Code progress/final responses and every material step in completion/status emails, using the actual local time. Include a footer in every such response and email with available SSH-agent key fingerprints (never key material), the answering agent's own quota usage/remaining and renewal/reset time, and any forecast warning projecting exhaustion before local midnight. State when a forecast is unavailable; do not report another agent's quota or expose authentication tokens.

## Git changes

- Use the machine's global SSH transport preference for Git remotes; do not change a remote to HTTPS.
- Before committing, inspect the complete diff and scan tracked changes for credentials, private keys, personal/work recipient addresses, SMTP relay hostnames, and internal-only details. Keep machine-specific values outside tracked files.
- Run relevant tests before publishing changes. Never commit user runtime state, local authentication/configuration files, or tool caches.
- Keep task changes in one final commit. Before rewriting a remote branch, verify its expected state, preserve a recovery reference when useful, and use an explicit `--force-with-lease`.
- For pull requests, use one final commit and write a concise reviewer-focused overview covering the problem, resulting behavior, validation, and limitations.
- Push changes upstream when requested or required by the applicable global agent instructions.
