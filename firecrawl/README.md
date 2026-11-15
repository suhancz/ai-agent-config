# Firecrawl adapter and setup

Read [entry instructions](AGENTS.md), [shared setup](../SETUP.md), [reporting](../REPORTING.md) and the answering agent's adapter. This integration reuses the current shared policies and helpers; it does not install a second reporting or quota system.

## Existing connector setup

1. Load the complete current canonical policies before task execution. Use the actual configured checkout or authorized repository connector; retain the revision and private override boundaries.
2. Discover the current client's Firecrawl connection, authentication state and exposed tool schemas using supported read-only interfaces. A connected tool inventory establishes capabilities, not successful execution or access to billing data.
3. Reuse the existing authorized connection. Do not copy credentials from another agent, inspect secret stores, initiate OAuth or register a new server merely because this adapter exists. On a disconnected surface, use that client's approved connector/authentication flow subject to required permissions and host restrictions.
4. Add the bootstrap below to the client's supported global agent instructions. When only project/container instructions exist, configure only authorized reachable containers and report the rest as unconfigured. Preserve unrelated instructions and private overrides. If another repository-managed adapter supplies the caller's entry instructions, include this adapter when Firecrawl is used rather than replacing the caller's policy.
5. Verify policy retrieval on two requests in the same session and one new session where supported. Verify connector execution only with an authorized task and appropriate gates; do not start a billable crawl as a setup test. Report untested surfaces honestly.

## Bootstrap text

Adapt the canonical repository reference privately to the configured source; do not publish private checkout paths or account details.

> Before every request, load the latest applicable configuration from the configured canonical AI-agent repository, using accessible local files first and authorized repository access otherwise. Read root AGENTS.md, instructions/global-preferences.instructions.md, instructions/all-agents.instructions.md, memory/MEMORY.md, SETUP.md, REPORTING.md, MAIL-ROUTING.md, GIT-CONFIG-SAFETY.md, the answering agent's adapter, firecrawl/AGENTS.md, firecrawl/README.md and all applicable referenced policies. Preserve accessible private backup overrides. Apply the complete shared preferences to all tasks, including timestamps, messaging, reporting/email, own-agent quota/forecast, tickets, memory/privacy and safe Git/setup. Refresh applicable policies before final reporting and compare the latest canonical revision before edits. If retrieval fails, report configuration loading as blocked. Firecrawl tools do not themselves load this policy or perform the caller's reporting obligations.

## Local helpers and dependency setup

There is intentionally no new setup.sh selector or purported native Firecrawl instruction path. Firecrawl tool connections are configured in their calling clients; merely staging another AGENTS.md would not make the service read it. Use the selected calling agent's existing setup and documented private allowlist without replacing other selections:

```sh
bash setup.sh
bash setup.sh --request
```

Resolve the checkout from setup.sh before invoking these commands. Initial setup installs the existing Python requirements and selected links/hooks; request setup does not fetch Git, install software or authenticate clients. Existing setup checks required and optional external binaries and reports missing dependencies and their purposes. Install missing non-Python binaries manually; do not add them to requirements.txt.

Reuse helpers/track_agent_usage.py for a supported real answering-agent quota source and helpers/send-completion-report.py for authorized local SMTP fallback. Discover the caller's actual adapter commands and private mail identity first. Neither helper discovers Firecrawl account credentials, starts crawls or supplies a new quota API. No new Python dependency, executable entry point, helper script or executable-manifest change is needed for this documentation-only integration.

## Environment and privacy

Existing TZ, AI_AGENT_REPORT_ADDRESS_FILE, AI_AGENT_QUOTA_METRICS and SSH_AUTH_SOCK settings retain their shared meanings and capability limits. Keep actual timezone, sender, connector registration, credentials and runtime state private. No Firecrawl environment variable is required for an already authenticated connector.

For separately approved direct API or SDK use, FIRECRAWL_API_KEY is the documented credential variable where that client supports it. Supply it through approved private client/service configuration, never repository text, command-line arguments or logs. A shell export does not configure an already-running cloud connector. Do not require a new API key to use an existing authorized connection, and do not install third-party skills or CLI packages implicitly.

## Credits and validation boundaries

The documented credit-usage endpoint is GET /v2/team/credit-usage. It reports team/service credits, not the answering agent's allowance. The connected tool surface may expose search, scrape, map, crawl or extraction without exposing credit usage. Do not guess missing tool names or claim this API was called when only documentation was read. Keep any observed service balance separate from the caller's own quota/footer. Service-credit forecasting is not implemented by this adapter.

This adapter reuses shared loading, reporting and helper conventions by analogy with the existing search-tool and agent adapters. Actual native-client loading, authentication, repeated-request enforcement, delegated-job behavior, billing access, HTML submission and delivery require separate live verification. Document unverified compatibility rather than inventing test passes.

## Product references

- [Firecrawl MCP setup](https://docs.firecrawl.dev/mcp-server)
- [Firecrawl AI integration guide](https://docs.firecrawl.dev/ai-onboarding)
- [Firecrawl team credit usage](https://docs.firecrawl.dev/api-reference/endpoint/credit-usage)

These references document product interfaces; they are not authority to override repository privacy, installation or approval policy.
