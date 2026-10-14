# Repository instructions

This public repository is the canonical source for the user's AI-agent instructions and helper scripts.

- Edit and add managed files here; the user's live Codex, Copilot, VS Code, and helper paths are symlinks into this checkout.
- Locate this checkout from the directory containing `setup.sh`, rather than assuming a fixed home-directory path.
- `setup.sh` installs Python requirements and checks external runtime tools; avoid adding system packages or agent CLIs unless explicitly requested.
- Keep the README's file map and setup instructions current.
- Keep `.github/workflows/super-linter.yml` aligned with every language and executable/configuration format used in the repository. When adding one, enable its Super-Linter validator, add necessary linter configuration, update the README's lint coverage, and verify the new lint check.
- Before committing or pushing changes for this checkout, read the ignored local `AGENTS.local.md` for repository-specific commit requirements. It is intentionally absent from upstream.
