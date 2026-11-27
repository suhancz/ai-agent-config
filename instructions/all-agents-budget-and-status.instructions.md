# All-agent contract: budget and work status

Part of the all-agent contract in [all-agents.instructions.md](all-agents.instructions.md). Read it on every request together with that file.

## Budget checks and unfinished-work handoff

- Every current and successor agent runs the token and quota prediction check before every action as well as after it. The check is the answering agent's own quota and forecast status from the [generic quota interface](all-agents-scripts-and-quota.instructions.md#generic-quota-and-forecast-interface), together with an estimate of what the planned action costs in tokens, steps, and time. Use fresh status when the supported source allows it. The tracker's minimum sampling interval still applies to recording; when a new sample is not allowed, reuse the latest one and say so. Unknown quota, reset, or forecast stays unavailable and is never invented.
- When the check shows that the full action cannot be finished before the allowance runs out, do what can still be finished safely, and stop before a step that would leave a half-applied change. Do not start work that cannot be completed or cleanly reverted within the remaining allowance.
- Save everything that is still to be done in the WIP/TODO status file of the repository the agent is working on, whichever repository that is, including repositories whose own instructions do not mention it. Record the goal, the current state and revision, the remaining steps in order, open decisions, and a ready prompt that lets the user or a later agent resume.
- Push that file to origin before the allowance runs out. Push it to the task branch, never directly to the default branch, using the repository's configured transport. The push is an external write: follow the platform's confirmation gates and ask for approval early enough that the push can still happen. When the push is impossible, because of missing write access, a missing approval, or an exhausted allowance, say so and put the same content in the final response.
- Keep sensitive data, raw transcripts, and private runtime state out of the file, as the sensitive-data rules require. Use generic descriptions or placeholders.
- This section takes precedence over the rule that removes the WIP/TODO status file before a pull request or merge request, but only for work that is handed off unfinished: keep the file in that case and say so. Remove it as usual once the work is complete.
- Report the forecast, what was completed, what was saved, and where it was pushed. State separately anything that was not saved or not pushed.
- This applies to work in every repository and project, including those whose own instructions do not mention it.

## Work-status marks and immediate updates

- Every current and successor agent that keeps a WIP/TODO status file, or any other task list that tracks its work, marks each item with exactly one of three states: done (`[x]`), to do (`[ ]`), and in progress (`[ ] in progress:` at the start of the item text). There is no other state, such as probably done or partly done.
- Mark an item done only when its success is verified: a test, a CI run, a log, or a check on the target system proved it. Work that was written but not yet proven is not done.
- Whenever the agent is unsure that an item succeeded, the item is in progress. This includes work that waits for a CI run, work that was proven only for an older version of the change, work that depends on a system the agent cannot reach, and a result that is only reported by the user or by an automatic summary and not read in the real log. Say in the item what is missing for it to become done.
- An in-progress item becomes done only when the missing proof exists. When a result turns red, the item goes back to in progress or to do together with the fix that is planned, never to done.
- Update the status file immediately. Whatever is already done is marked done in the same step, and whatever starts waiting for CI or becomes uncertain is marked in progress in the same step. Do not batch status updates for later and do not leave the file behind the real state at the end of a task.
- A commit that changes the work also carries the update of the status file. Do not push the status update as a separate commit afterwards. When a CI result arrives later, update the file in the next commit, or in a status-only commit when no other change is due.
- Never record an item as done to make a report look complete. Report in-progress items separately from done items, together with what is missing.
- A repository or the user may add more states or narrower rules in its own instructions only with the user's explicit approval; the three states here stay valid.
- Keep sensitive data out of the file, as the sensitive-data rules require.
- This applies to work in every repository and project, including those whose own instructions do not mention it.
