# llm-wiki-agent upstream

Source: https://github.com/SamurAIGPT/llm-wiki-agent/tree/86ab47d7cfe3b41e604df6bf19afbd9a911b9068 (MIT, see LICENSE).

The upstream schema and workflow are in AGENTS.md. The shared Python utility
takes the Vault root from `THREADRAFT_VAULT` and reads the schema from this
directory. The graph tool adds a JSON-only option so the wrapper can skip
upstream HTML output and its CDN dependency. The other Python files and the
three initial Wiki documents are copied from upstream. Use Threadraft's
PowerShell wrapper so path checks and locking apply.

Health, structural lint, and link graph generation run locally.
Semantic lint is available through the agent workflow. The upstream Python
lint script uses an LLM and remains reference code pending a decision on
external access. Automated upstream Ingest and Query CLIs are outside this
integration. Follow the agent workflow under the repository policies.

The upstream update process remains open. For a proposed update, review the
upstream diff, preserve the license and review the local adaptations, and rerun
synthetic tests before changing the recorded commit.
