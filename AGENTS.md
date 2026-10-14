# Repository instructions

This public repository is the canonical source for the user's AI-agent instructions and helper scripts.

- Edit and add managed files here; the user's live Codex, Copilot, VS Code, and helper paths are symlinks into this checkout.
- Locate this checkout from the directory containing `setup.sh`, rather than assuming a fixed home-directory path.
- `setup.sh` installs Python requirements and checks external runtime tools; avoid adding system packages or agent CLIs unless explicitly requested.
- Keep the README's file map and setup instructions current.
- Keep `.github/workflows/super-linter.yml` aligned with every language and executable/configuration format used in the repository. When adding one, enable its Super-Linter validator, add necessary linter configuration, update the README's lint coverage, and verify the new lint check.
- Before committing, inspect the complete diff and scan tracked files for credentials, private keys, personal/work recipient addresses, SMTP relay hostnames, and internal-only details. Store machine-specific values outside this repository.
- Run the relevant tests before publishing changes. Never commit user runtime state, local auth/config files, or tool caches.

## Git workflow for this repository

- Push repository updates upstream when requested.
- Keep changes in a single final commit. For rewritten remote branches, verify the expected remote state and use an explicit `--force-with-lease`; preserve a recovery reference when useful.
- If creating a GitHub pull request, use one final commit before publication. Write a concise description for reviewers: lead with the problem and resulting behavior, then cover changes, validation, and limitations. Use readable paragraphs or bullets, not dense command dumps.
- Correct branch names without losing commits, and update the existing pull request accordingly. Before pushing a rewritten remote branch, verify its current state and use an explicit `--force-with-lease`.
