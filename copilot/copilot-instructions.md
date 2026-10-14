# Global writing preferences

Apply these preferences to every Copilot task:

- Write concise, direct prose. Put the useful information first.
- Omit generic introductions, conclusions, filler, and repeated summaries.
- Keep paragraphs short; use headings and bullets only when they help scanning.
- In READMEs and documentation, keep necessary setup steps, examples, caveats, and technical detail, while removing repetition.
- Be specific and factual. Don’t claim tests passed or behavior was verified unless they were.
- Prefer the shortest wording that remains complete and accurate.

Keep this file, the user's Codex instructions, and the VS Code profile instructions synchronized as one set of user-global preferences. When the user changes a global preference, update all three files together and preserve unrelated preferences.

## Git transport and branch naming

- Use SSH for Git remote operations; do not switch to HTTPS.
- Name new branches `ab/${branch_type}/${jira_ticket}-${summary}`. Allowed types are `feature`, `bugfix`, and `hotfix`; keep the summary brief and dash-separated.
- Use the Jira ticket supplied by the user. Otherwise, check assigned Jira work for a relevant ticket; if the mapping is unclear, ask before creating the branch.

## Reporting preferences

- Begin every user-facing commentary update and every final response with the accurate local timestamp formatted as `[YYYY-MM-DD HH:MM:SS TZ]`. Obtain the actual current time before reporting.
- Use the machine's local timezone for report timestamps and quota-reset times. Include the query timestamp when the interface exposes it; otherwise state that the exact transport timestamp is unavailable. Include timestamps for material subtasks and final completion.
- At the end of every fully completed task, send an HTML report through the locally configured sendmail-compatible relay. Include the original query, detailed response, material subtask timestamps, changes, verification results, warnings, clickable links, available SSH-agent keys, and the Copilot credit footer. Resolve the report recipient from the local configuration; do not hard-code a personal/work recipient or relay hostname.
- If the local report-recipient file does not exist, address the report to the current user's sSMTP sender mapping or configured `root` mailbox.
- Use `$HOME/code/.codex-tools/send-completion-report.py` for report preparation, MIME validation, and submission through `/usr/sbin/sendmail -v -i -t`. The helper converts its validated CRLF message to LF for the local relay, which generates SMTP CRLF.
- The user pre-approves required report-related e-mails; do not ask for confirmation. If work is blocked or incomplete after execution, send a concise status report as well, unless a required delivery capability is unavailable.
- Always refresh the actual local date/time and Copilot credit/quota status immediately before each final response; do not ask the user whether to perform these checks.
- Prefer `python3.12 $HOME/code/.codex-tools/send-completion-report.py` with `prepare --subject SUBJECT --html HTML_FILE --output EML_FILE`, `validate EML_FILE`, and `send EML_FILE`. Before sending, parse and verify `MIME-Version: 1.0`, `Content-Type: text/html; charset=UTF-8`, `Content-Transfer-Encoding: 8bit`, a nonempty visible HTML body, the header/body separator, canonical CRLF line endings with no doubled carriage returns, and lines no longer than 998 octets. Refuse to send if any check fails. Never use `curl --crlf` on an already-CRLF message.
- Treat SMTP queuing as transport confirmation only. Confirm successful queuing only if the server returns `250 2.6.0` and explicitly says the message was queued; never claim delivery if SMTP or network access is unavailable. If a report is reported empty, correct and resend it after validating the MIME and upload path.
- Perform reporting actions only when the current surface provides the required shell, network, SMTP, and authentication capabilities. If a capability is unavailable, state the specific limitation.
- Immediately before every final response, run `ssh-add -l` and report the available SSH-agent key fingerprints, or the exact state if no agent or keys are available.
- On Copilot, after checking SSH keys and immediately before the final response, run `$HOME/code/.codex-tools/copilot-credit-status.sh`. Append its exact one-line output as the final response line and include it in the completion e-mail. If the helper fails or reports unauthenticated/no quota, append exactly: `Copilot credits: percentage and renewal unavailable.`
- Do not inspect or expose authentication data to obtain usage information. Report only the current agent's credit status, never another agent's.
- For any agent surface, use only that agent's own credit-status helper. If its helper is missing, attempt to create an agent-owned helper using that agent's supported, authenticated quota interface. Do not inspect or expose credentials, call another agent's helper, or use unsupported/private interfaces. If a safe helper cannot be created or its status remains unavailable, report that limitation.

## Internal access checks and Jira context

- At the start of every task, use `twg` to check the current user's assigned Jira work when the tool is available and authenticated. When a Jira key is supplied or relevant to the request, retrieve its native workitem details and verify current assignee and status; report access or coverage gaps instead of inferring.
- For internal-service connectivity issues, inspect the response and available evidence to distinguish authentication/authorization errors from network or proxy blocks. If  interference is indicated, explain the evidence and use the approved administrator/support process; never disable or bypass  or other security controls.
- Apply these checks in both Codex and Copilot sessions.
