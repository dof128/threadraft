# Threadraft

Set up a new Windows project for Codex with Spec Kit, EGM, and two issue workflow skills. Open the destination as a trusted project in Codex and paste this entire README into the chat. Start with an empty project or a new project with a few files already in place.

## Set up the open project

If this README was pasted into Codex, carry out the setup below in the currently open project. Report the result in the chat.

1. **Confirm the destination.** Identify the absolute project path and check its Git root if one exists. Ask which project to use if the path is unclear. Stop before writing if the destination is the Threadraft source, a drive root, or a folder under a different Git root. Distinguish the normal “not a git repository” result from other Git errors. Check for filesystem redirection in the destination and its parent paths, including Windows junctions, and for routing overrides such as `GIT_DIR`, `GIT_WORK_TREE`, `GIT_COMMON_DIR`, `GIT_INDEX_FILE`, and `SPECIFY_INIT_DIR`. Stop before project writes and report any unsafe path or override.
2. **Check the tools.** Verify Git and Specify with `git --version` and `specify version`. Check whether EGM is installed in the Codex environment in use. Reuse working installations. Prepare missing Spec Kit and EGM through their official installation routes. For Codex desktop, use the published EGM plugin; for CLI, follow the EGM guide's marketplace and plugin commands. If Git is unavailable, use its official guide. If a required installation or a new session needs user action, report what is pending and how to continue before writing to the project. With the tools ready, no visit to the guide pages is needed. [Git installation](https://git-scm.com/install/) · [Spec Kit installation](https://github.github.io/spec-kit/installation.html) · [Spec Kit for Codex](https://github.github.io/spec-kit/integrations/codex.html) · [EGM installation](https://github.com/google/elephant-goldfish-model#install)
3. **Prepare files outside the destination.** In a clean temporary folder, run `specify init --here --integration codex --non-interactive`. Use a Spec Kit script type that runs in the target environment. Let Specify choose its default when suitable, or use its supported `--script` option. If the active Codex session is already available and Specify only fails to detect its executable, rerun in a clean temporary folder with `--ignore-agent-tools`. Use only regular files generated under `.specify/` and `.agents/skills/speckit-*/`. Fetch `refs/heads/main` from `https://github.com/dof128/threadraft.git` into a separate temporary Git repository, resolve `FETCH_HEAD` to one commit, and take the following two files from that commit. Preserve their paths and content.

   ```text
   .agents/skills/issue-create/SKILL.md
   .agents/skills/issue-close/SKILL.md
   ```

4. **Compare before the first write.** Verify that the required tools and source files are available, generated files are complete, and all resolved destinations stay within the project. Compare every candidate with existing paths. Reuse identical files and skill files that differ only in line endings. Preserve `AGENTS.md` and user files. If a file or directory conflicts, report the path and stop before any project writes, including Git initialization.
5. **Apply missing files.** Initialize Git at the destination only if needed. Before each write, recheck the destination and use a create-only operation for missing files. Write `.specify/integration.json` after its required files. If `/.worktrees/` or `/.env` is missing, append only the missing rules after rechecking `.gitignore`, preserving its existing content and format. If something changes after preflight, stop further writes and report what was applied. Leave commits to the project owner.
6. **Verify and report.** Check the Git root, the Codex integration and selected script type in `.specify/integration.json`, the generated template resolver and prerequisite checker, the `speckit-specify`, `speckit-plan`, and `speckit-tasks` skills, and the two Threadraft skill files. Report the project path, source commit, configured and reused items, conflicts or blockers, and verification evidence. Record EGM installation and any skills actually discovered in a new trusted Codex session separately from file checks. If plugin installation or a new session is pending, say what remains. Leave EGM reviews for later, when the user requests one. For the first issue, point to the [skill usage guide on `main`](https://github.com/dof128/threadraft/blob/main/docs/skill-usage.ko.md) (Korean).

## Use the project

English · [한국어](README.ko.md)

Use the [Spec Kit workflow](docs/spec-kit-workflow.md) to choose a starting point, link artifacts to an issue, and record verification. The [skill usage guide](docs/skill-usage.ko.md) includes examples for opening an issue, reviewing a design with EGM, and closing the work.

Record project scope, verification commands, and integration policy in the project's own `AGENTS.md`. [OpenAI AGENTS.md guide](https://developers.openai.com/codex/guides/agents-md)

The [tool inventory](requires.json) lists required CLI and optional CLI and MCP tools.

## License

Threadraft is distributed under the [MIT License](LICENSE).
