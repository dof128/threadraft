---
name: issue-close
description: Close a Beads issue and safely clean up its linked Git worktree.
---

1. Confirm the active Git repository and Beads workspace. Load the issue with `bd show <id>` and compare its recorded branch and worktree with `git worktree list --porcelain`. Review linked artifacts and acceptance evidence.
2. For an authorized close, record the outcome, acceptance evidence, and any outstanding work. Record the reason for an authorized abandonment. If disposition is unresolved, keep the issue open. Before cleanup, verify that the worktree and branch belong to this issue and that the worktree has no staged, unstaged, untracked, or ignored changes to preserve. Confirm the branch tip is preserved on a project-approved durable ref. If a check fails, retain the worktree and branch and record the blocker.
3. Close the authorized Beads issue with `bd close <id>` and verify with `bd show <id>`. For authorized cleanup, run `git worktree remove <path>` from outside the issue worktree, then `git branch -d <branch>` if branch deletion is in scope. Use the non-forcing commands. If cleanup is blocked or partially succeeds, record what remains in Beads and report it. For an issue already closed, verify its state and resume pending cleanup without repeating the close.
4. Verify the final Beads status and Git worktree and branch state. Retain the issue's artifact references and closure evidence in Beads. Report the full ID, status, and any remaining cleanup.
