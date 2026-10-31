# Shared non-sensitive agent memory

Read this file whenever the user asks for something, together with the canonical root and applicable agent instructions. All entries must satisfy the root sensitive-data exclusion policy.

## Confirmed enduring preferences

- Every agent saves durable, useful, non-sensitive user memory in the canonical repository and retrieves the current shared memory for every user request.
- Sensitive data must not be saved in the repository at all. This includes personal names, postal and internet addresses, login names, account identifiers, passwords, credentials, tokens, and keys. Explicit exclusions take precedence over persistence.
- Keep memories concise and accurate. Preserve unrelated entries, resolve ambiguous preference conflicts with the user, and keep temporary task overrides scoped to their stated purpose.

## Scope and limitations

This file initially records only the confirmed memory and privacy preferences above. It is not a migration of historical conversations or other agents' private memories. Repository instructions do not themselves install automatic loading or background synchronization.
