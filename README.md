# Agent Bootstrap

Prepare a Windows project for Spec Kit, Beads and Codex with PowerShell 7. The package provides three Task skills and five project-scoped Codex agents.

## Run

Install Git, [Specify CLI](https://github.github.io/spec-kit/installation.html) and [Beads](https://github.com/gastownhall/beads), and open PowerShell 7. Clone the package repository or extract its ZIP. Run the same command from either copy with a separate target directory.

```powershell
pwsh -NoProfile -File .\bootstrap.ps1 -ProjectPath 'C:\Projects\my-project' -Json
```

The target may be absent or may already contain project files. Use `-GitPath`, `-SpecifyPath` or `-BeadsPath` for executables outside PATH. [requires.json](requires.json) lists required CLI and optional CLI and MCP tools.

Bootstrap reports completed steps, conflicts and the next action. Exit 0 means the target is ready. Exit 2 means preflight blocked the run. Exit 1 means a preparation or apply step failed. Fix the reported cause and rerun the same command. A conflicting file is preserved. A failed Beads transfer reports the path of any incoming copy for inspection.

## Use the project

Open the target in Codex. Prepare a Git baseline commit before the first Task worktree. Write your project's scope, paths, verification commands and integration policy in its own `AGENTS.md`. See the [OpenAI guide and minimal example](https://developers.openai.com/codex/guides/agents-md). Bootstrap preserves the file's existing content or absence.

1. Create a feature specification with the installed Spec Kit integration.
2. Use `task-open` to link the full Beads ID and feature path to a worktree.
3. Use `task-integrate` for review, handoff, resumption and approved integration.
4. Use `task-close` when the Task's acceptance criteria and project closure conditions are met.

The project-local TOML files in `.codex/agents/` define researcher, scout, implementer, reviewer and verifier roles. Set `model` and `model_reasoning_effort` per role when needed. Codex resolves the defaults when these keys are omitted. Re-running Bootstrap preserves those settings. For other local edits or name collisions, review the conflict and choose the desired file before retrying. [OpenAI custom agents](https://developers.openai.com/codex/subagents)

The package prepares new embedded Beads data in isolation. Keep the target's Beads database with that project and follow Beads' backup process for durable copies.
