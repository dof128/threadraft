---
name: task-integrate
description: Review a Beads Task diff, record a handoff, resume work, or integrate approved changes under project policy.
---

Confirm the approved action and project instructions. Identify the full Beads Task ID, repository, worktree and branch.

- For review, query the Task and verify the current worktree HEAD, baseline SHA and staged, unstaged and untracked state. Review the scoped diff and validation evidence. Record which commit and files were reviewed.
- For handoff, record the full Task ID, spec and tasks list paths when applicable, worktree, branch, baseline and current SHA, uncommitted changes, validation results, outstanding work and next action.
- Before resuming, compare the handoff with `bd show`, `git worktree list --porcelain` and the worktree status and HEAD. Resolve a Spec Kit feature from its recorded directory. Set `SPECIFY_FEATURE_DIRECTORY` in the current process when the worktree lacks the local feature pointer.
- Integrate only the reviewed scope under the project policy and applicable user authorization. Recheck the exact base and reviewed Task SHA. Stop on conflict or partial failure and preserve the current state for recovery.
- Report the actual action, verification, and remaining work under **Result** and **Evidence**.
