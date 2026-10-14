# Repository instructions

This public repository is the canonical source for the user's AI-agent instructions and helper scripts.

- Edit and add managed files here; the user's live Codex, Copilot, VS Code, and helper paths are symlinks into this checkout.
- Locate this checkout from the directory containing `setup.sh`, rather than assuming a fixed home-directory path.
- `setup.sh` installs Python requirements and checks external runtime tools; avoid adding system packages or agent CLIs unless explicitly requested.
- Keep the README's file map and setup instructions current.
- Keep `.github/workflows/super-linter.yml` aligned with every language and executable/configuration format used in the repository. When adding one, enable its Super-Linter validator, add necessary linter configuration, update the README's lint coverage, and verify the new lint check.
- At the end of every user query, each agent must record its own current quota through its existing status helper and `track_agent_usage.py`; retain the generated forecast and any warning in the local `.agent-usage.jsonl` report, and include warnings in both the final response and completion/status email. This data file must remain ignored and never be staged or published.

## Git changes

- Use the machine's global SSH transport preference for Git remotes; do not change a remote to HTTPS.
- Before committing, inspect the complete diff and scan tracked changes for credentials, private keys, personal/work recipient addresses, SMTP relay hostnames, and internal-only details. Keep machine-specific values outside tracked files.
- Run relevant tests before publishing changes. Never commit user runtime state, local authentication/configuration files, or tool caches.
- Keep task changes in one final commit. Before rewriting a remote branch, verify its expected state, preserve a recovery reference when useful, and use an explicit `--force-with-lease`.
- For pull requests, use one final commit and write a concise reviewer-focused overview covering the problem, resulting behavior, validation, and limitations.
- Push changes upstream when requested or required by the applicable global agent instructions.
