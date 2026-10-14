---
name: Global Codex and Copilot Preferences
description: "Always apply the user's synchronized global Codex and Copilot preferences: concise factual writing, timestamps, completion e-mail, SSH-key and credit footer, cross-agent synchronization, and testing."
applyTo: "**"
---

# Global Codex and Copilot Preferences

Apply these instructions to every task unless a later user instruction explicitly changes them. Keep this file, the user's Codex instructions, and Copilot instructions synchronized as one set of user-global preferences. When the user changes a global preference, update all three files together and preserve unrelated preferences.

## Git transport and branch naming

- Use SSH for Git remote operations; do not switch to HTTPS.
- Name new branches `ab/${branch_type}/${jira_ticket}-${summary}`. Allowed types are `feature`, `bugfix`, and `hotfix`; keep the summary brief and dash-separated.
- Use the Jira ticket supplied by the user. Otherwise, check assigned Jira work for a relevant ticket; if the mapping is unclear, ask before creating the branch.
- When updating an agent configuration that is symlinked into this repository, resolve the repository directory from the symlink target instead of assuming a checkout path. Read that repository's `AGENTS.md` and ignored `AGENTS.local.md` alongside these global instructions before editing; make the change in the repository source, then commit and push it using the applicable local and global Git requirements. Never publish ignored local instructions, credentials, or other sensitive data.

## Timestamps

- Begin every user-facing commentary update and every final response with an accurate local timestamp formatted as `[YYYY-MM-DD HH:MM:SS TZ]`.
- Use the machine's local timezone for all report timestamps and quota-reset times; do not report UTC/GMT unless the user explicitly asks for it.
- Obtain the actual current time before reporting; do not estimate or invent timestamps.
- In completion reports, include the query timestamp when the interface exposes it. If it does not, say that the exact transport timestamp is unavailable.
- Include timestamps for material subtasks and the final completion time.

## Internal access checks and Jira context

- At the start of every task, use `twg` to check the current user's assigned Jira work when the tool is available and authenticated. When a Jira key is supplied or relevant to the request, retrieve its native workitem details and verify current assignee and status; report access or coverage gaps instead of inferring.
- For internal-service connectivity issues, inspect the response and available evidence to distinguish authentication/authorization errors from network or proxy blocks. If  interference is indicated, explain the evidence and use the approved administrator/support process; never disable or bypass  or other security controls.
- Apply these checks in both Codex and Copilot sessions.

## Completion e-mail

- At the end of every fully completed task, send an HTML report through the locally configured sendmail-compatible relay.
- If the local report-recipient file does not exist, address the report to the current user's sSMTP sender mapping or configured `root` mailbox.
- The user pre-approves required report-related e-mails; do not ask for confirmation. If work is blocked or incomplete after execution, send a concise status report as well, unless a required delivery capability is unavailable.
- Always refresh the actual local date/time and the current agent's credit/quota status immediately before each final response; do not ask the user whether to perform these checks.
- Use the local report recipient configured outside the repository; never hard-code it in tracked files.
- Use a concise briefing of the query as the subject.
- Include the original query, detailed response, material subtask timestamps, changes, verification results, warnings, clickable links, available SSH-agent keys, and the Codex credit footer.
- Generate a valid MIME message with `MIME-Version: 1.0`, `Content-Type: text/html; charset=UTF-8`, and `Content-Transfer-Encoding: 8bit`.
- Prepare reports with canonical CRLF MIME, then use `python3.12 $HOME/code/.codex-tools/send-completion-report.py` to prepare, validate, and send them through `/usr/sbin/sendmail -v -i -t`. The send helper converts CRLF to LF for the local relay, which generates SMTP CRLF; never apply `curl --crlf`.
- Configure the report recipient in `$HOME/.config/ai-agent-config/report-address` and configure the local relay in the operating system's mail-client configuration. Keep both values out of the repository. If the file is absent, the helper uses the current user's sSMTP sender mapping or configured `root` mailbox. The helper requires an explicit queued SMTP response.
- Before sending, parse the final MIME bytes and verify a nonempty visible HTML body, valid UTF-8/8bit headers, the header/body separator, canonical CRLF with no doubled carriage returns, and lines no longer than 998 octets. Refuse to send if any check fails.
- Treat SMTP queuing as transport confirmation only; do not claim that mailbox rendering has been verified. If a report is reported empty, correct and resend it after validating the MIME and upload path.
- Confirm successful queuing only when the SMTP server returns `250 2.6.0` and explicitly says the message was queued.
- Never claim an e-mail was sent if SMTP or network access was unavailable; report that limitation instead.
- Keep the e-mail format synchronized with later user preference changes without adding local recipient or relay values to tracked files.

## Final footer

- Immediately before every final response, run `ssh-add -l` and report the available SSH-agent key fingerprints. If no agent or keys are available, report that exact state.
- Identify which AI agent is answering and always use only that agent's credit footer in both the final response and completion e-mail: use the Codex credit status below for Codex, and the corresponding Copilot credit status for Copilot. Do not report the other agent's balance.
- On Codex, after checking SSH keys and immediately before sending the final response, run this authenticated, read-only command with escalated sandbox permission:

  `$HOME/code/.codex-tools/codex-credit-status.sh`

- On Copilot, after checking SSH keys and immediately before sending the final response, run:

  `$HOME/code/.codex-tools/copilot-credit-status.sh`

- The Copilot helper uses the authenticated GitHub Copilot CLI SDK quota endpoint and emits only the concise quota status; it never prints credentials. If Copilot's helper fails or reports unauthenticated/no quota, append exactly: `Copilot credits: percentage and renewal unavailable.`
- For any agent surface, use only that agent's own credit-status helper. If its helper is missing, attempt to create an agent-owned helper using that agent's supported, authenticated quota interface. Do not inspect or expose credentials, call another agent's helper, or use unsupported/private interfaces. If a safe helper cannot be created or its status remains unavailable, report that limitation.
- Append the current agent's exact one-line credit output as the final line of the response.
- Do not inspect or expose authentication data to obtain usage information.
- If Codex's command fails, append exactly: `Codex credits: percentage and renewal unavailable.`

## Capability boundary

- Perform these actions only when the current surface provides the required local shell, network, SMTP, and authentication capabilities.
- If a capability is unavailable, preserve the response format where possible and state precisely which footer or delivery action could not be completed.

## Repository scope and testing

- Do not add extra helper or validation scripts to repositories unless the user explicitly requests them.
- Keep one-off testing and comparison tooling outside the repository, for example in `/tmp`.

## Writing preferences

- Write concise, direct prose. Put the useful information first.
- Omit generic introductions, conclusions, filler, and repeated summaries.
- Keep paragraphs short; use headings and bullets only when they help scanning.
- In READMEs and documentation, keep necessary setup steps, examples, caveats, and technical detail, while removing repetition.
- Be specific and factual. Don’t claim tests passed or behavior was verified unless they were.
- Prefer the shortest wording that remains complete and accurate.
