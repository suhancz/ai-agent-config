# Rovo adapter

See [shared setup](../SETUP.md), [reporting](../REPORTING.md), [entry instructions](AGENTS.md), and the existing [Atlassian integration policy](../ATLASSIAN.md).

Selector: `rovo`. Without an allowlist, detection requires the rovo executable and ~/.rovo/config.yml. Setup links entry instructions to ~/.rovo/AGENTS.md and refreshes the private backup loader. It does not install the CLI, authenticate an account, repair keychain persistence, or modify tool-managed runtime configuration. Browser authorization followed by a credential-write error is not persistent-login success.

At every request run `bash helpers/rovo-request.sh` from the checkout, or its link under `$HOME/code/.codex-tools/`, and apply the printed current policies. That historical shared helper directory is retained for compatibility. Verify native user-memory loading in the installed client.

Inspect /hooks before configuring a per-prompt command using bash and the absolute helper path. No guessed schema is installed automatically. Test two prompts in one session and a new session; until verified, instruction-driven execution is required but automatic enforcement is unverified.

Rovo manages its bundled TWG authentication/version through rovo login. Do not independently change the bundle's login, consent, update, or uninstall lifecycle. See the [standalone tool guide](../twg/README.md) for the distinct installation.

No verified machine-readable quota sampler or tracker adapter is configured. Do not pass --agent rovo to the current tracker or call another agent's helper. The exact unavailable line is: `Rovo credits: percentage and renewal unavailable. Forecast unavailable.` Organization credits are not a personal balance.
