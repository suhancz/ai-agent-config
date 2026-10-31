---
name: Global Agent Preferences
description: Shared writing, reporting, timestamp, privacy, synchronization, and validation preferences for any answering agent.
applyTo: "**"
---

# Global agent preferences

Resolve this file's canonical location to find the repository root. For every request, read and apply [root instructions](../AGENTS.md), [shared memory](../memory/MEMORY.md), [mail routing](../MAIL-ROUTING.md), [Git safety](../GIT-CONFIG-SAFETY.md), and [reporting](../REPORTING.md), subject to higher-priority platform permissions. Read the current answering agent's applicable entry instructions via the [adapter index](../README.md#adapter-documentation). Shared policies are authoritative over older narrower adapter wording.

Whenever reading the live main instructions, also read the adjacent private .local-overrides.md loader and its listed instruction backups. Apply the precedence and privacy rules in shared memory. Report inaccessible host files or stale revisions rather than claiming compliance. Explicit current instructions remain scoped overrides; private backups must not be published or executed.

Use the user's local timezone, not the host default. Prefix every assistant-authored message and report with the current timestamp when available, record request time separately, preserve precision, and label missing clocks. Send required timestamped HTML reports with identical private sender/recipient identities, respecting mail routing and mandatory approval gates. Preserve MIME validation for SMTP fallback and report actual submission evidence.

Use only the answering agent's supported quota/status helper and tracker adapter. Follow its adapter-specific commands and capability limits; never query another agent's balance or infer a quota API. Include SSH fingerprint access state, own-agent quota/reset status, forecast warnings or unavailability, and the exact own-agent status line when available.

Use SSH Git transport and ignored local workstation preferences. Compare against the latest canonical Git configuration before editing and again before publishing. Preserve concurrent and dirty work, inspect complete diffs, scan for sensitive values, run relevant tests and lint, and keep related work in one final commit. Do not add one-off helper/validation scripts to projects unless requested; keep temporary testing outside tracked files.

When an authorized authenticated work-item tool is available, perform the required assigned-work checks and verify relevant native assignment/status. Distinguish authentication failures from network/policy restrictions; use approved support processes and never disable security controls. Product commands belong in the relevant adapter guide.

Write concise, direct, factual prose with useful results first. Avoid generic introductions, filler, repeated conclusions, and unverified success claims. Keep paragraphs short and use headings/lists only where useful. Preserve necessary commands, caveats, and technical detail in documentation without duplicating provider-specific instructions in shared files.

Synchronize confirmed non-sensitive enduring preferences across affected adapters and canonical memory while preserving unrelated content. Ask when an apparent preference conflict is ambiguous. Keep private values, raw transcripts, runtime state, third-party skills, and credentials outside Git. Report unsupported operations and incomplete automation explicitly.
