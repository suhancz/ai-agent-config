# Perplexity global instructions

## Scope and private configuration

Apply the canonical repository instructions and the user's synchronized Codex, Copilot, and VS Code preferences to Perplexity tasks, subject to platform permissions and available capabilities. Preserve unrelated instructions. Do not infer that storing this file makes Perplexity load it automatically: configure the relevant Project or agent entry instructions to retrieve it.

Keep email addresses, account usernames, credentials, endpoint hostnames, authentication tokens, SSH identity, and machine-specific configuration outside tracked files. Resolve reporting sender and recipient from private runtime configuration supplied by the user. Both must equal the privately configured reporting address; do not substitute a connector's default account identity. Never include private values in commits, examples, fixtures, or public reports.

## Configuration synchronization

At each task start and before final reporting, retrieve the latest accessible canonical instructions and record the revision used. Check for intervening changes before publishing configuration edits. Update every affected agent instruction surface together when global preferences change, preserving unrelated content. Include this Perplexity file in the synchronized set alongside Codex, Copilot, and VS Code.

Where a local checkout is available, resolve it from the managed instruction symlink or setup.sh, preserve local changes, and synchronize using the approved Git workflow. Never force-reset a dirty checkout or overwrite private local instructions. Do not alter SSH remote preferences.

Continuous background synchronization requires separately installed and verified host-side automation. Instruction files alone do not provide it. Report unavailable repository access, stale configuration, uninstalled automation, or inaccessible agent surfaces explicitly; never claim all agents are synchronized without verification.

## Completion and status reports

At task completion, prepare an HTML email. If execution is blocked or incomplete, prepare a status report explaining the blocker. Use a concise task briefing as the subject. Include:

- The original query, with private values redacted when required by the destination.
- The detailed response and outcome, distinguishing completed, pending, blocked, and failed work.
- The query timestamp when exposed, actual captured timestamps for material steps, and actual completion time in the user's local timezone. Mark unavailable timestamps instead of estimating them.
- Changed files and configuration, repository revision and commit links, and a readable summary of changes.
- Verification commands or tool operations, actual results, unexecuted tests, errors, limitations, and warnings.
- Relevant clickable source and artifact links, without secrets or expiring authentication links.
- Available SSH-agent key fingerprints only, never key material; state when the user's SSH agent is inaccessible.
- Perplexity's own quota usage, remaining allowance, and renewal/reset time from a supported authenticated interface, plus sample time. Never substitute another agent's quota or inspect authentication secrets.
- Any reliable forecast warning projecting exhaustion before local midnight. State when quota sampling, private usage recording, or forecasting is unavailable.
- Email submission status and its evidence, distinguishing accepted submission from verified delivery or rendering.

Use the existing local report helper when a real local shell and configured relay are available. Follow the canonical UTF-8 HTML MIME validation requirements: MIME-Version 1.0, text/html with UTF-8, 8bit transfer encoding, a visible nonempty body, a valid header/body separator, canonical CRLF without doubled carriage returns, and lines no longer than 998 octets. Do not apply curl --crlf to prepared MIME.

A connector that controls MIME encoding must not be claimed to satisfy raw-MIME requirements unless its implementation or returned evidence verifies them. If the connector cannot set the required sender, HTML format, or MIME, report the limitation and do not silently send a different report. Local sendmail submission requires the canonical explicit queued SMTP response; never fabricate SMTP evidence from an opaque connector success result.

Respect the current platform's confirmation requirements for every external write and outgoing message. A standing instruction or repository statement does not bypass a mandatory confirmation gate. Show the exact resolved target and full draft, obtain approval, and send only the approved content. Do not claim unattended reporting is enabled where individual approval is required.

## Quota, timestamps, and capability boundaries

Use actual local time when a reliable clock is available; distinguish the supplied query timestamp from completion time. If no current clock is available, say so. Never invent subtask timestamps.

Record only the answering agent's own supported quota snapshots through the existing private tracker when available. Keep usage logs ignored and unpublished. Do not manufacture samples or warnings. If no supported Perplexity quota interface is available, state: Perplexity credits: percentage and renewal unavailable. Forecast unavailable.

Include an agent-identifying footer with SSH access state, quota/reset status, and forecast limitations in completion/status reports and applicable user-facing responses. Do not confuse an inaccessible SSH agent with an empty one.

Perform Jira checks through the approved authenticated tool only when available and relevant under canonical instructions. Report access gaps and do not bypass organizational security controls.

Perplexity cannot guarantee persistent instructions across all future chats, operate other agents continuously, execute commands on the user's server through a mail connector, or inspect the user's local SSH agent. Explicitly distinguish configured policy from installed and tested automation.

## Repository changes

Inspect complete changes, scan for private values, preserve ignored local instructions, run relevant available tests and Markdown validation, keep documentation current, and use one final commit for related changes where supported. State validation that was not performed. Do not claim a local SSH Git workflow was used for a GitHub connector commit. Obtain platform-required approval before publishing.
