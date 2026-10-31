# Rovo global instructions

## Shared policies and every-request bootstrap

Rovo belongs to the synchronized instruction set alongside Codex, Copilot, VS Code, and Perplexity. Apply root AGENTS.md in full, including higher-priority platform permissions, non-sensitive memory persistence, privacy exclusions, preference synchronization, and temporary override scope. Also read MAIL-ROUTING.md, GIT-CONFIG-SAFETY.md, and ATLASSIAN.md. The shared mail policy supersedes older SMTP-first requirements.

Resolve this file's symlink target to locate the canonical checkout. At the start of every user request, run `bash helpers/rovo-request.sh` from that checkout or `bash "$HOME/code/.codex-tools/rovo-request.sh"`. Read and apply its output: it runs lightweight setup and prints root instructions, shared memory, mail routing, latest-Git safety, Atlassian policy, and this file. Do not recurse merely because the helper prints this instruction.

Refresh current applicable canonical policies and shared memory before final reporting and publishing. Fetch/compare with latest Git before changing configuration and recheck after approvals, preserving unrelated concurrent changes and dirty work. A local checkout alone is not proof of upstream freshness. Report missing access or stale revisions honestly.

Persist confirmed enduring non-sensitive preferences and useful memory in the canonical repository. Preserve unrelated policies, synchronize affected entries, identify conflicting requests, and ask when a change of mind is ambiguous. Never store sensitive data anywhere in tracked content or history.

## Loading and private runtime state

Setup links this file to ~/.rovo/AGENTS.md only on selected hosts. Verify loading through the installed client's user-memory view. Keep config.yml, MCP registrations, authentication/keychain state, hooks, sessions, and skills private and tool-managed. Existing conflicting instructions must be reviewed before backup replacement. Setup does not authenticate Rovo or fix keychain storage. Browser authorization followed by a keychain write error is not persistent-login success.

This integration targets rovo, not legacy acli rovodev. No automatic Rovo hook installation is claimed. Inspect `/hooks` in the installed version before configuring a per-user-prompt command using bash and the absolute rovo-request.sh path. Use only verified schema and quoting. Test two prompts in one session and another new session. A session-start-only hook does not satisfy every request. Until verified, execute the helper through these instructions and report that automatic enforcement is unverified.

Use Rovo-managed authentication for its bundled TWG; do not independently change the bundle's credentials, consent, or version. Standalone TWG is separate. Retrieve authorized Jira context when required, verify actual assignment/status, and report unavailable access without bypassing security controls.

## Git, communication, and completion

Read ignored AGENTS.local.md before Git changes when available; never publish it. Preserve SSH transport and unrelated edits. Inspect the full diff, scan for sensitive values, run relevant tests and lint, and keep related work in one final commit. Respect approvals and branch protections. Follow GIT-CONFIG-SAFETY.md for concurrent updates and unavailable expected-head guards.

Write concise, direct prose with results first. Distinguish completed, pending, blocked, and failed work. Timestamp CLI progress/final responses with actual local time in `[YYYY-MM-DD HH:MM:SS TZ]` format; never invent missing timestamps or test results.

At completion, send the required HTML completion or blocked-status report through the verified same-context route in MAIL-ROUTING.md, subject to mandatory exact-message confirmation gates. Configure supported selected clients only with existing private authentication and metadata, respecting work-host restrictions. Setup printing instructions is not automatic connector registration.

Include the original request with appropriate redaction, detailed outcome, actual query/material-step/completion times, changed files/revision, validation and unexecuted tests, errors and limitations, source/artifact links, SSH fingerprints only, own-agent quota/reset status, forecast warnings, and submission evidence. Missing delivery capability means report the blocker, not a fabricated send. Never silently substitute sender or recipient.

For SMTP fallback, use the canonical send-completion-report.py helper and its MIME validation: MIME-Version 1.0, text/html UTF-8, 8bit encoding, visible nonempty body, valid separator, canonical CRLF without doubled carriage returns, and the 998-octet line limit. Never use curl --crlf on prepared MIME. Require the canonical explicit queued SMTP response for a local send; distinguish queued submission from verified delivery/rendering. An opaque connector result does not prove raw-MIME compliance or SMTP evidence.

Before each CLI response/report, run ssh-add -l when permitted; report fingerprints only and distinguish inaccessible from empty. Include an agent-identifying footer.

## Quota boundaries

Use only a documented, supported Rovo quota interface. Rovo organization credits are not an individual balance; context-window usage is not a credit allowance. Do not inspect OAuth/keychain secrets or use another agent's quota helper. No verified machine-readable Rovo sampler is configured here.

The current tracker supports Codex and Copilot only. Do not pass --agent rovo or fabricate percentages. Record genuine Rovo samples and forecasts only after a supported interface and tested tracker adapter exist. Until then, report private sampling/forecasting unavailable and end with: `Rovo credits: percentage and renewal unavailable. Forecast unavailable.`
