# Spec Kit workflow

English · [한국어](spec-kit-workflow.ko.md)

Use this workflow to move from a request to a verified change. Spec Kit records the intended behavior, implementation plan, and steps. The issue document records scope, status, blockers, and verification results.

## Choose a starting point

| Request | Start with | Outcome |
| --- | --- | --- |
| Scope and acceptance criteria are clear | Use `issue-create` when the work needs tracking. | An issue document with enough context to start and verify the work. |
| A feature needs clearer behavior or a design | Use Spec Kit's feature workflow. | A specification, plan, and implementation checklist. |
| Existing behavior is broken and the cause or reproduction is unclear | Use the optional Spec Kit bug extension's assessment step. | Observed and expected behavior, reproduction evidence, open questions, and a proposed repair scope. |
| An idea needs a decision before planning | Use the optional Spec Kit assess extension. | A decision to proceed, clarify, or stop, with the evidence and rationale. Start feature specification when the team decides to proceed. |

Choose the smallest process that resolves the uncertainty. An assessment can be the final deliverable. Use the installed agent integration's command syntax. [Feature workflow](https://github.github.io/spec-kit/reference/agentic-sdd.html) · [Bug assessment](https://github.github.io/spec-kit/guides/bugfix.html) · [Idea assessment](https://github.github.io/spec-kit/reference/agentic-assessment.html)

## Prepare and link the work

1. For a feature, run `specify` to define expected behavior and acceptance criteria. Use `clarify` where answers would change the work, then run `plan` and `tasks`. Review the resulting `spec.md`, `plan.md`, and `tasks.md` together. Use `analyze` for a cross-document consistency check when warranted. These are Spec Kit agent actions. [Agentic SDD reference](https://github.github.io/spec-kit/reference/agentic-sdd.html)
2. Keep the reviewed documents at stable, repository-relative paths. For a bug, link the reviewed assessment and record the approved repair scope, reproduction steps, and verification criteria.
3. Reuse an issue document with the same scope, or record the agreed scope, acceptance criteria, pending checks, and links to the reviewed documents in a new issue document. Use the project's convention or `docs/issues/<key>.md` at the project root.
4. Use one issue document for a change that can be assigned and accepted as a unit. Use the checklist for its implementation steps. Use separate issue documents and record dependencies when work must be scheduled, assigned, or accepted independently.

For example, a CSV export feature might use `specs/csv-export/spec.md`, `specs/csv-export/plan.md`, and `specs/csv-export/tasks.md`. An issue document at `docs/issues/csv-export.md` can link those three files and record an acceptance criterion such as “a CSV export contains only the filtered rows.” Its checklist can cover row selection, serialization, and a regression test.

## Implement, verify, and close

1. Use `issue-create` to start or resume an issue and prepare its Git worktree. Record the worktree, branch, base commit, and reviewed artifact paths in the issue document.
2. Update checklist items as implementation proceeds. Record issue status and blockers in the issue document. When scope or acceptance criteria change, update the governing documents and the issue document together.
3. Verify the result against the acceptance criteria. Record what was checked, where the evidence is available, and which checks remain pending. For handoff, include the issue key, artifact links, blockers, and the next action.
4. Use `issue-close` to record the outcome once the project's acceptance and integration conditions are met or the decision to abandon the work is authorized. Link the relevant commit or pull request. Verify that the changes and branch tip are preserved before cleaning up the linked worktree and branch. Record any blocked cleanup in the issue document.

## Publish in a public repository

Publish reviewed specifications, acceptance criteria, and verification summaries that contributors can use. Use synthetic examples and repository-relative paths. Before committing, review the diff and attachments for credentials, personal data, private ticket links, internal paths, and raw logs. Keep private evidence and temporary agent output out of the public commit.
