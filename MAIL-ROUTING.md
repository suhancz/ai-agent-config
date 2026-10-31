# Shared mail routing and agent setup

## Scope and precedence

This policy applies to every current and successor agent, including Codex, Copilot, VS Code, and Perplexity. Read it at every task start, during setup, and before sending email. It supersedes older agent-specific requirements to always send through the local relay. Preserve existing reporting content, sender/recipient constraints, HTML validation, and mandatory platform confirmations.

## Identity and context

- Default email routing to the personal account unless work context is verified. Missing Git configuration, unavailable GitHub access, or incomplete identity information does not by itself block personal routing or establish work context. This explicitly replaces the former ask-on-unknown rule.
- Resolve the Git email in the repository being worked on, not the configuration repository merely because setup runs there. Use the repository's effective email configuration first, falling back to the global Git email when unset. Preserve the caller's working directory during setup. Do not modify Git identity to make a comparison succeed.
- Retrieve personal email addresses from the authenticated GitHub user's profile and, when authorized and available, the supported authenticated account-email listing. Compare the effective Git email against those personal addresses using address-aware comparison; do not guess aliases, strip plus tags, or substitute a username or a commit author address. Do not print or publish retrieved addresses.
- A match with a retrieved personal address identifies personal context. An effective Git email verified not to belong to the authenticated user's personal GitHub addresses identifies work context under the user's routing preference. A missing public profile email or an incomplete account-email listing is not proof of a nonmatch.
- A privately configured work identity or a known work computer also establishes work context. If explicit verified work and personal signals conflict, ask for clarification rather than silently crossing account boundaries. Missing evidence alone uses the personal default, not a clarification prompt.
- Apply known private work-host restrictions independently of task context. A personal repository on a known work computer does not authorize personal MCP configuration. If host eligibility is uncertain, do not register a personal connection until resolved; the personal routing default does not authorize an otherwise prohibited host-configuration write.
- Keep addresses, work-identity mappings, host classification, and identity cache data outside tracked files. Do not infer a specific employer from an arbitrary email domain.

## Transport selection

- Personal context, including the default when work context is not verified: prefer the existing designated personal MCP connection when the agent supports it and authentication is already configured for that agent. Otherwise use the existing personal SMTP setup.
- Work context: discover configured connectors available to that agent. Prefer a suitable already authenticated work-mail connector over the existing work SMTP setup. Never substitute a personal connector for work email.
- A suitable connector must support sending, the intended sender identity, and the required message format. Do not treat a connected status or read-only mailbox access as proof that sending is supported.
- If multiple suitable connectors exist, use a private explicit preference; otherwise ask rather than selecting arbitrarily. Never silently substitute a connector's default sender for the required sender.
- Missing MCP support, missing preconfigured authentication, or no suitable connector means use the SMTP setup for the same context, subject to the same sender, recipient, format, and approval requirements. Do not request a new token merely to enable the connector path.
- Missing SMTP configuration means report the blocker. Personal-default routing does not authorize inventing sender or recipient addresses, bypassing approvals, or ignoring verified work restrictions.
- Do not automatically retry by SMTP after an uncertain connector submission, timeout, or ambiguous delivery result. Determine whether submission occurred first to avoid duplicate messages. Report accepted submission separately from verified delivery.
- Connector MIME handling must not be claimed equivalent to raw MIME validation without evidence. Retain the existing report helper and its validation for the SMTP fallback.

## Setup responsibilities for every agent

- During initial setup and request-time setup, the calling agent reads this policy, determines task context and host eligibility, discovers its own supported connector/MCP facilities, and inspects authentication availability without displaying secret values.
- On an eligible non-work host, configure the existing personal MCP server for each selected supported agent using authentication already preconfigured for that agent. Reuse privately available server metadata. Do not redeploy the server or install a local bridge merely to connect to it.
- Use the client's supported configuration mechanism and existing credential references. Preserve unrelated registrations and user edits. Make repeated setup idempotent. Do not copy a token from another agent, place it in command-line arguments or logs, or create a new shared token store.
- Missing preconfigured authentication, unavailable private server metadata, or unsupported clients select the existing same-context SMTP fallback. Report configuration as skipped or blocked rather than falsely complete.
- On a work host, do not register or enable the personal MCP connection. Discover suitable existing work connectors and retain work SMTP as fallback. Do not remove unrelated existing registrations automatically.
- Follow mandatory approval and trust gates for configuration writes and connector use. Do not send test mail as a setup probe without the required approval. Prefer supported read-only capability and identity checks.
- Report per-agent configuration, existing authentication availability, selected route, skipped work, and verification limitations without exposing private values. Configuration success is not proof of mail delivery.

## Privacy and implementation boundary

Keep connector identities, endpoints, email addresses, company identities, tokens, and machine-specific settings in private runtime configuration. This document intentionally records only generic behavior.

The setup script surfaces this policy to the calling agent. It does not implement a universal MCP registrar or run other agents autonomously. Client-specific configuration must be performed by an agent with supported host access and permissions; shell-only setup cannot complete that step by printing instructions. Report that step as pending until actually performed and verified. No automatic cross-session loading or continuous synchronization is implied.
