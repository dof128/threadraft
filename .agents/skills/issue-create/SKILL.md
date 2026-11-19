---
name: issue-create
description: Create or resume a document-backed issue and prepare its Git worktree.
---

1. Confirm the active repository with `git rev-parse --show-toplevel`. Read the project's issue and worktree conventions. Use the requested issue key or the linked Spec Kit feature directory name. For new work without a supplied key or feature directory, choose a short descriptive key and check it against existing issue records and branches.
2. Use the project's existing issue document, or use `docs/issues/<key>.md` at the project root as the default record. Keep the record accessible independently of the worktree. Reuse the record for a matching issue. Create it only for requested new work. Record the key, agreed scope and acceptance criteria, linked artifact paths, and pending checks. For work without Spec Kit artifacts, record the agreed scope and criteria directly.
3. Resolve the approved Git starting point to a commit. Check that linked artifacts needed in the worktree are available at that commit. Report missing commits or artifacts before creating the worktree. Preserve local changes.
4. Use the project's naming policy, or default to `issue/<key>` and `.worktrees/<key>`. Compare existing records, local branches, and `git worktree list --porcelain`. Reuse a verified worktree. Use `git worktree add -b <branch> <path> <base>` for a new branch or `git worktree add <path> <branch>` to attach a verified existing branch. Resolve an unexplained collision before creating anything at that path.
5. Record and verify the project-relative worktree path, branch, and base commit in the issue document. On resumption, compare the record with Git and update status, blockers, verification results, and the next action as work progresses. Update the linked `tasks.md` checklist when one exists. If setup is incomplete, report which steps succeeded so a retry can reuse them.
