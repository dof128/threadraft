---
name: issue-close
description: Record the authorized outcome of a document-backed issue and safely clean up its Git worktree.
---

1. Confirm the active Git repository and load the issue's existing document, typically `docs/issues/<key>.md`. Compare the recorded branch and worktree with `git worktree list --porcelain`. Review the linked artifacts and acceptance evidence.
2. Record the authorized completion or abandonment in the issue document, with the reason, evidence, and outstanding checks. Keep the record outside the worktree being removed. Keep the issue open while the outcome is unresolved. Before cleanup, verify that the worktree and branch belong to the issue, that the worktree has no staged, unstaged, untracked, or ignored changes to preserve, and that the branch tip is preserved on a project-approved durable ref.
3. For authorized cleanup, run `git worktree remove <path>` from outside the issue worktree. Use `git branch -d <branch>` if branch deletion is in scope. If cleanup is blocked or partially succeeds, record what remains in the issue document. For an issue already closed, confirm the recorded outcome and resume only the pending cleanup.
4. Verify the recorded outcome and the final Git worktree and branch state. Report the issue key, status, and any remaining cleanup.
