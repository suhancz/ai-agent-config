# Firecrawl adapter and setup

Read [entry instructions](AGENTS.md), [shared setup](../SETUP.md), [reporting](../REPORTING.md) and the caller's adapter. This integration reuses shared policies and helpers while specifying separate service-credit forecasts and credential-expiry reporting for every connected agent. It does not install a background monitor.

## Existing connector setup

1. Load complete current canonical policies before task execution. Use the accessible configured checkout or authorized repository connector, retain the revision, and respect private override boundaries.
2. Discover the current client's connection, authentication state, exposed tool schemas, credit-status access and non-secret credential-expiry/managed-refresh metadata through supported read-only interfaces. A connected inventory is not proof of successful execution or billing/expiry access. Report each capability separately.
3. Reuse the existing authorized connection. Do not copy another agent's credentials, inspect secret stores, initiate OAuth or register a server merely because this adapter exists. Disconnected surfaces use their approved connector flow subject to permissions and host restrictions.
4. Add the bootstrap below through supported global agent instructions. Where only project/container instructions exist, configure authorized reachable containers and report remaining surfaces as unconfigured. Preserve unrelated instructions and overrides. Include this adapter alongside the caller's existing adapter; do not replace it.
5. Set up authorized private non-secret sample history only where host/platform state access exists. Separate pools and billing periods for credits, and connections/generations for credential dates. Apply the entry instructions' sample deduplication, concurrency and user-only storage rules. Do not share credentials across agents. Without persistent state, report the limit and use only actual accessible observations; do not claim cross-session recording.
6. Verify loading on two requests in one session and a new session where supported. Verify calculations with synthetic data before relying on live alerts, and verify actual balance/expiry metadata only through supported authorized status interfaces. No billable crawl, token refresh, reconnect or test mail is a setup probe.

## Bootstrap text

Resolve the canonical source privately without publishing paths or account details.

> Before every request, load current root AGENTS.md, instructions/global-preferences.instructions.md, instructions/all-agents.instructions.md, memory/MEMORY.md, SETUP.md, REPORTING.md, MAIL-ROUTING.md, GIT-CONFIG-SAFETY.md, the caller's adapter, firecrawl/AGENTS.md, firecrawl/README.md and applicable linked policies from the configured canonical repository. Use accessible local files first and authorized repository access otherwise. Preserve accessible private backup overrides. Apply the complete shared preferences, refresh applicable policy before final reporting and compare latest Git before edits. On every connected query, report the caller's own quota, a separate Firecrawl service-credit depletion forecast, and evidence-based credential-expiry/refresh status, with warnings or concrete unavailable reasons in final chat and HTML reports. Do not inspect secrets, fabricate samples or expiry dates, or refresh credentials merely for status. Failed policy retrieval blocks substantive work. Saved policy alone does not configure runtime monitoring.

## Helpers and dependency setup

There is no new setup.sh selector or purported native Firecrawl instruction path. Tool connections are configured in calling clients; staging AGENTS.md does not make the service read it. Use the selected caller's existing setup and private allowlist, preserving other selections:

```sh
bash setup.sh
bash setup.sh --request
```

Resolve the checkout through setup.sh. Initial setup installs existing Python requirements and selected links/hooks; request setup does not fetch Git, install software or authenticate clients. Existing setup reports missing required/optional external binaries and their purposes. Install non-Python binaries manually, not through requirements.txt.

Reuse helpers/track_agent_usage.py only for a supported real own-agent quota source and helpers/send-completion-report.py for authorized local SMTP fallback. Resolve adapter commands and the identical private sender/recipient first. Neither helper discovers Firecrawl credentials, samples service credits, persists service history or refreshes tokens. Agents perform the separately specified credit arithmetic and expiry countdowns through supported computation/state capabilities. This change adds instructions, not executable automation or guaranteed collection; missing runtime support must remain explicit. No new package, executable, executable-manifest entry or required environment variable is introduced.

## Environment and privacy

Existing TZ, AI_AGENT_REPORT_ADDRESS_FILE, AI_AGENT_QUOTA_METRICS and SSH_AUTH_SOCK retain their shared meanings and limits. Keep real timezone, sender, connector settings, pool/connection mappings, expiry dates, samples and runtime state private and outside Git. Store only minimal non-secret metadata with user-only access; preserve its source and original timestamps. No Firecrawl environment variable is required for an authenticated connector.

For separately approved direct API/SDK use, FIRECRAWL_API_KEY is the documented variable where that client supports it. Supply it through approved private configuration, never repository text, command-line arguments or logs. A shell export does not configure an existing cloud connector. Do not require a new API key for an authorized connection or implicitly install CLIs, skills or packages.

## Status, forecasts and validation

GET /v2/team/credit-usage exposes team credits, not the caller's allowance; a connector may expose content tools without this endpoint or credential dates. Follow the entry instructions for raw-credit linear depletion, same-day samples at least five minutes apart, replenishment/pool/period resets, stale-data rejection and warnings. Report source, time and limitations separately from the caller's own quota. Do not fabricate a percentage or log a team balance under an individual agent.

Credential status uses supported expiry/issuance metadata, not token inspection or usage trends. Distinguish API keys, OAuth access and rotating refresh tokens, and managed connector sessions. Known countdowns, unknown dates and verified renewal are different states. Never treat routine access-token renewal as inevitable connection loss or claim an undocumented key is non-expiring. Status checks do not refresh or rotate credentials.

Validate calculation implementations with synthetic cases: insufficient or stale samples; five-minute boundary; positive/zero balance and positive/zero rate; replenishment and period/pool changes; duplicate/conflicting timestamps and concurrent writers; local midnight and daylight-saving changes; known/unknown/expired credential dates; missing clocks/timezones; renewable versus unverified access tokens; changed credential generation and API keys without expiry metadata. Synthetic checks do not prove real authentication or expiry access.

Reusing shared instruction and reporting conventions is assumed-compatible until verified in actual clients. Native loading, balance sampling, private persistence, cross-agent pool matching, credential metadata/renewal, repeated requests, HTML submission and delivery require separate evidence. No automated regression suite or live-client test is claimed by this documentation update.

## Product references

- [Firecrawl MCP setup](https://docs.firecrawl.dev/mcp-server)
- [Firecrawl AI integration guide](https://docs.firecrawl.dev/ai-onboarding)
- [Firecrawl team credit usage](https://docs.firecrawl.dev/api-reference/endpoint/credit-usage)
- [Firecrawl OAuth lifecycle](https://docs.firecrawl.dev/oauth)

Product references document interfaces; they do not override privacy, installation or approval policy.
