# Shared non-sensitive agent memory

Read this file whenever the user asks for something, together with the canonical root and applicable agent instructions. All entries must satisfy the root sensitive-data exclusion policy.

## Confirmed enduring preferences

- Every agent prefixes every assistant-authored user-facing chat message and report with the user's local timestamp and timezone, records each request's supplied timestamp in its acknowledgment and reports, distinguishes request/receipt/response/operation/completion times, and labels unavailable clocks or precision instead of inventing them. The user's timezone takes precedence over the host default. This applies to all agents and successor surfaces; follow the root timestamp policy.
- Every agent saves durable, useful, non-sensitive user memory in the canonical repository and retrieves the current shared memory for every user request.
- Sensitive data must not be saved in the repository at all. This includes personal names, company and organization names, employer and client identities, postal and internet addresses, login names, account identifiers, passwords, credentials, tokens, keys, and all other personally identifiable information. Explicit exclusions take precedence over persistence.
- Exclude information that identifies, singles out, locates, or can reasonably be linked to a person, directly or in combination with other details. This includes identifying employment, family, contact, location, device, account, and biographical details. A detail being public does not make it eligible for repository storage.
- Apply these exclusions to every agent and all proposed repository content, including memory, instructions, examples, fixtures, reports, filenames, and commit messages. Use only generic non-identifying descriptions or placeholders. If sensitivity or re-identification risk is uncertain, omit the detail and ask for clarification before publication. Do not commit sensitive data temporarily or assume a later deletion removes it from Git history.
- Keep memories concise and accurate. Preserve unrelated entries, resolve ambiguous preference conflicts with the user, and keep temporary task overrides scoped to their stated purpose.

## Scope and limitations

This file records confirmed memory and privacy preferences. It is not a migration of historical conversations or other agents' private memories. Repository instructions do not themselves install automatic loading or background synchronization. These exclusions govern future repository writes; they do not establish that existing content or history has been audited or sanitized.
