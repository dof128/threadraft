---
name: task-close
description: Close an authorized Beads Task and, when requested and safe, remove its Git worktree and branch.
---

Read project instructions. Use the full Task ID and query its actual status.

1. Confirm acceptance criteria, evidence, remaining work, and whether close or worktree cleanup was requested. Record the outcome on the Task.
2. For a state change, use `bd close <ID>` and confirm the result with `bd show <ID>`. An already closed Task can be reported without a repeated state change.
3. For authorized cleanup, identify the exact worktree and branch. Check staged, unstaged, untracked, and ignored contents and confirm the Task commits are preserved under the project's integration or retention policy. If this cannot be confirmed, preserve the worktree and branch and report the blocker.
4. Remove the verified worktree with `git worktree remove` and the verified branch with `git branch -d` when those commands accept the current state. Verify the resulting state.
5. Report Beads status, cleanup status and evidence under **Result** and **Evidence**.
