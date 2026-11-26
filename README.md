# Threadraft

[한국어](README.ko.md)

Threadraft is an agent-assisted knowledge management framework. Git tracks
the operating instructions, policies, templates, integration code, and
synthetic tests. A separate Markdown Vault holds personal knowledge.
llm-wiki-agent provides the Wiki schema and maintenance workflow, QMD
provides local search, and Obsidian provides editing and link navigation.

## Get started

Use PowerShell 7 and Git. Install Python 3.10+ for the local Wiki checks and
graph. From the repository root:

```powershell
./scripts/Invoke-Vault.ps1 -Action Init
./scripts/Invoke-Vault.ps1 -Action Validate
./scripts/Invoke-Vault.ps1 -Action Health
```

Open the resulting `vault/` directory in Obsidian. Pass `-VaultPath` to work
with a different local directory outside the repository. Initialization
adds missing directories and seed files and preserves existing content.
Review the [Vault policy](policies/vault.ko.md) before giving an agent access.

## Search and maintenance

```powershell
npm install --global @tobilu/qmd@2.9.0
./scripts/Invoke-Vault.ps1 -Action Index
./scripts/Invoke-Vault.ps1 -Action Search -Query 'my topic'
./scripts/Invoke-Vault.ps1 -Action Search -Collection Raw -Query 'original source'
./scripts/Invoke-Vault.ps1 -Action Lint
./scripts/Invoke-Vault.ps1 -Action Graph
```

QMD indexes Markdown in Wiki and Raw, stores its private cache separately
for each Vault, and searches Wiki by default. Lint runs the local Wiki link
checks. Graph generates link data at `graph/graph.json`. See the
[Korean guide](README.ko.md) for operational details and the
[implementation record](docs/implementation.ko.md) for verification status.

## Develop

```powershell
pwsh -NoProfile -File tests/Test-SyntheticVault.ps1
pwsh -NoProfile -File tests/Test-SyntheticVault.ps1 -WithQmd
```

Tests create disposable synthetic data. The QMD variant requires the QMD CLI.

The [architecture](docs/architecture.ko.md) is available in Korean. The
[previous development template](https://github.com/dof128/threadraft/tree/e28b0d558a46876c4a3f4af77e9344685d6fa51e)
is available at the base commit while its long-term distribution remains open.

[MIT license](LICENSE)
