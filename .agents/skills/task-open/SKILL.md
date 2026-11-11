---
name: task-open
description: Prepare an authorized Beads Task and its Git worktree, linking a Spec Kit feature when available.
---

Read the project's instructions. Resolve the repository root, approved scope, Beads workspace, title, acceptance criteria, and the full Task ID when supplied.

1. Check for an existing Task by the full ID or by matching scope and title. Reuse a confirmed match. If no Task exists, use `bd create` for the authorized scope and capture the full ID. If the command outcome is uncertain, query Beads before retrying.
2. Record repository-relative links to the feature's spec, plan, and tasks list when available. Add the full Beads ID to the linked tasks list when the user requests that link. Record what is still unverified.
3. Check `git status --short --branch`, staged and unstaged changes, and `git worktree list --porcelain`. Resolve the project-approved baseline to a full SHA. A new repository needs a baseline commit before it can create a Task worktree.
4. Reuse an existing matching branch and worktree. Otherwise use the project naming convention or use branch `task/<ID>` and directory `.worktrees/<ID>` with `git worktree add -b`. Verify branch, HEAD and path. Preserve existing user changes and report collisions.
5. Update Beads status when starting the Task. Report its full ID, spec path, worktree, branch, baseline and remaining checks under **Result** and **Evidence**.
