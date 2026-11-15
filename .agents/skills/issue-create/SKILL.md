---
name: issue-create
description: Create or resume a Beads issue, link its Spec Kit artifacts and Git worktree, and record progress.
---

1. From the project root, confirm the active Git repository and Beads workspace with `git rev-parse --show-toplevel` and `bd where`. Read the reviewed Spec Kit feature documents or bug assessment when available. For a request without artifacts, use the agreed scope and acceptance criteria.
2. Resolve the project's approved Git starting point to a commit. Confirm that any linked artifacts are available at that commit so they will be visible in the new worktree. If an initial commit or artifact publication is needed, report the gap before creating the issue. Preserve local changes.
3. Use `bd show <id>` or `bd list` to find a matching issue. Reuse its full ID. When creation is requested and no match exists, use `bd create`. If a write has an uncertain result, query Beads before retrying.
4. Use the project's branch and worktree naming policy, or default to `issue/<full-id>` and `.worktrees/<full-id>`. Check `git worktree list --porcelain` and local branches. Reuse a verified issue worktree. Create a new branch and worktree with `git worktree add -b <branch> <path> <base>`, or attach a verified existing issue branch with `git worktree add <path> <branch>`. Stop on a path or branch collision that cannot be attributed to the issue.
5. Use `bd update` to record scope, acceptance criteria, outstanding checks, project-relative artifact and worktree paths, branch, and base commit. Preserve existing details. Put the full Beads ID near the top of the issue worktree's linked `tasks.md` when it exists, preserving its checklist. Resolve a conflicting ID before editing.
6. Verify the Beads record with `bd show <id>` and compare it with `git worktree list --porcelain` and the linked artifacts. Report the full ID, worktree, branch, and remaining checks. If setup partially succeeds, keep and report the created issue or worktree so a retry can resume it.

## Resume or update an issue

1. Confirm the project Git repository and Beads workspace. Use `bd ready` to find eligible work or `bd show <id>` to inspect an issue. Compare its recorded branch and worktree with `git worktree list --porcelain` before operating there. Read linked Spec Kit artifacts and check scope and blockers.
2. Use `bd update` to record authorized status changes, blockers, verification results, remaining checks, and the next action. Preserve existing issue details. Update the linked `tasks.md` checklist in the worktree as implementation steps are completed.
