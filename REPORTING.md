# Shared reporting

Apply root [instructions](AGENTS.md), [mail routing](MAIL-ROUTING.md), [shared memory](memory/MEMORY.md), and the answering adapter's capability limits. These generic rules are shared; product-specific quota commands belong in adapter documentation.

## Completion and status email

At every completed task, send the required HTML completion report; for blocked/incomplete execution, send a status report when the delivery capability exists. Resolve the context and approved private reporting identity under mail routing. Sender and recipient must be identical. Do not silently substitute an account default or move work data to a personal route. Standing consent does not bypass mandatory exact-target/message approval. Present a pending report when a gate requires approval rather than silently omitting it.

For every current and successor agent, always derive the report recipient from the resolved actual sender address. Once the appropriate authenticated sender is established under mail routing and current user instructions, use that exact address as the sole report recipient; do not ask for a separate recipient merely because no independent recipient setting exists. Preserve the full address, including any plus tag, and do not add CC/BCC recipients. A configured report address remains an identity constraint, not permission to send from one address to another. Resolve genuine sender/context conflicts before sending and retain mandatory exact-message approval. Keep actual addresses and connector identities outside the repository.

Prefix messages and report bodies with the user's actual local timestamp and timezone. Record the supplied request timestamp, captured material steps, and completion time separately; mark missing clocks/precision rather than inventing them. Include the original request with needed redaction, detailed outcome, changed files/revisions, verification and unrun tests, errors, limitations, warnings, relevant links, SSH fingerprints only, own-agent quota/reset status, and actual submission evidence.

Prefer an appropriate already authenticated connector; retain the same-context SMTP fallback. Never retry via a second transport after an uncertain submission until duplicate-delivery risk is resolved. Distinguish accepted submission, a saved Sent copy, verified inbox delivery, and verified rendering.

## Private SMTP fallback

The fallback uses helpers/send-completion-report.py and `/usr/sbin/sendmail`. The local report-address file defaults to `$HOME/.config/ai-agent-config/report-address`; restrict it to mode 0600. Override its path with AI_AGENT_REPORT_ADDRESS_FILE. Without the file, the helper uses the current user's outgoing mapping in /etc/ssmtp/revaliases, then the configured root mailbox in /etc/ssmtp/ssmtp.conf. Apply stricter identity constraints from current instructions; keep relay configuration and addresses private.

Invoke the helper with Python 3.12 and its prepare, validate, and send commands. Prepare a concise subject and nonempty visible HTML body. Require MIME-Version 1.0, text/html with UTF-8, 8bit transfer encoding, a valid header/body separator, canonical CRLF without doubled carriage returns, and lines no longer than 998 octets. Never apply curl --crlf to prepared MIME. The helper validates CRLF, converts to LF for local sendmail, and requires the canonical explicit queued SMTP response: 250 2.6.0 explicitly stating queuing. Do not invent that evidence for an opaque connector result or claim raw-MIME compliance when a connector's encoding cannot be inspected.

A reported empty message requires MIME/upload-path validation before an authorized corrective send. A failed Sent-copy operation after successful sending is not a reason to resend.

## Own-agent status and private usage tracking

Identify the answering agent. Run ssh-add -l when supported and permitted; list fingerprints only, never key text. Distinguish an inaccessible agent from an empty one. Use only a documented authenticated quota interface for the answering agent, never another agent's helper, secrets, API-key decoding, or context-window usage. Report unavailable quota/reset/forecast rather than fabricating them. Adapter documents contain supported commands and exact fallback lines.

At query end, refresh the agent's supported quota sample and record it through helpers/track_agent_usage.py only for a supported agent identifier. The tracker currently accepts two adapters, documented in their guides. Do not pass unsupported names. Keep .agent-usage.jsonl private, ignored, and never staged. Include generated forecast warnings in final responses and reports. For progress updates reuse the latest own-agent sample with its sample time rather than making redundant status queries.

Forecasts require two same-day samples at least five minutes apart. A detected replenishment starts a new trend. Linear-depletion estimates can warn about exhaustion before user-local midnight but cannot predict future workload changes or unobserved resets. Report insufficient data or unavailable recording honestly. The current agent's exact quota-status line remains the final line when available.
