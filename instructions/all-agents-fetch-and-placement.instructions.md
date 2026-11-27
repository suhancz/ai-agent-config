# All-agent contract: fetch and placement

Part of the all-agent contract in [all-agents.instructions.md](all-agents.instructions.md). Read it on every request together with that file.

## Fetching origin first

- Every current and successor agent fetches the verified origin before every action and compares the local revision with the fetched one. Fast-forward the checkout only when the working tree is clean and there are no unpushed local commits.
- Never run a pull that merges, rebases, resets, or overwrites local changes. When the checkout has local changes or has diverged from origin, keep the local version, compare it with the fetched revision, and report which one applied, as the local-changes rule in the root AGENTS.md requires.
- Before creating or publishing a task branch, fetch again and base the branch on the latest default branch. Before pushing, verify that the remote branch is still in the expected state.
- A checkout that cannot be updated safely is reported as stale, together with the revision that was actually used.
- This applies to work in every repository and project, including those whose own instructions do not mention it.

## Where instructions live

- Every current and successor agent puts AI instructions and preferences that are not specific to one agent or product into the common instructions directory, in the file whose scope fits. Use all-agents.instructions.md, or the section file linked from it whose topic fits, for rules that apply to every agent. Do not add such rules to the root AGENTS.md, the README, or an adapter file.
- Instructions that are specific to one agent or product go to that agent's adapter or entry instructions, which the adapter index links.
- The root AGENTS.md keeps only the rules that define how instructions are found and loaded, plus short pointers with links into the instructions directory. A general rule that still sits in the root file moves into the instructions directory the next time it is changed, and a pointer stays behind.
- Keep memory/MEMORY.md and the README file map in step with every such change. The shared preferences entry point makes every agent read the instructions directory on every request, so this applies to every session.
- Sensitive-data exclusions, platform confirmation gates, and the Git workflow rules still apply to these changes.
