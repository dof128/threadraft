#Requires -Version 7.0
[CmdletBinding()]
param([switch]$WithQmd)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$tool = Join-Path $repo 'scripts/Invoke-Vault.ps1'
$root = Join-Path ([IO.Path]::GetTempPath()) "Threadraft test $([Guid]::NewGuid())"
$vault = Join-Path $root '합성 Vault'
$outside = Join-Path $root 'outside'
$junction = Join-Path $vault 'raw/redirected'
$cache = $null

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

function Assert-Rejected([scriptblock]$Operation, [string]$Message) {
    try { & $Operation | Out-Null }
    catch {
        if ($_.Exception.Message -like "*$Message*") { return }
        throw
    }
    throw "Operation unexpectedly succeeded. Expected: $Message"
}

try {
    & git -C $repo check-ignore --no-index -q -- vault/synthetic.md
    Assert-True ($LASTEXITCODE -eq 0) 'Git does not ignore vault/.'
    & git -C $repo check-ignore --no-index -q -- .cache/synthetic.db
    Assert-True ($LASTEXITCODE -eq 0) 'Git does not ignore .cache/.'
    $tracked = & git -C $repo ls-files -- vault .cache
    Assert-True ($LASTEXITCODE -eq 0 -and -not $tracked) 'Git tracks a private path.'

    Assert-Rejected { & $tool -Action Init -VaultPath (Join-Path $repo 'tests') } 'outside the Threadraft checkout'
    & $tool -Action Init -VaultPath $vault
    & $tool -Action Validate -VaultPath $vault

    $raw = Join-Path $vault 'raw/notes/합성.md'
    '원본 기록 marmotquasar. This fixture contains invented project data.' |
        Set-Content -LiteralPath $raw -Encoding utf8
    $wiki = Join-Path $vault 'wiki'
    $index = Join-Path $wiki 'index.md'
    @'
# Synthetic Index

- [합성 기록](sources/note.md)
- [Sample concept](concepts/sample.md)
'@ | Set-Content -LiteralPath $index -Encoding utf8
    @'
---
title: 합성 기록
type: source
source_file: raw/notes/합성.md
---
A synthetic source with the marker marmotquasar. This links to [[sample]]
because the source illustrates the sample concept.
'@ | Set-Content -LiteralPath (Join-Path $wiki 'sources/note.md') -Encoding utf8
    @'
---
title: Sample concept
type: concept
sources: [note]
---
This synthetic concept links to [[note]] because that note demonstrates the
invented example. The searchable token is marmotquasar.
'@ | Set-Content -LiteralPath (Join-Path $wiki 'concepts/sample.md') -Encoding utf8
    Add-Content -LiteralPath (Join-Path $wiki 'log.md') -Encoding utf8 -Value @'

## [2026-01-01] ingest | 합성 기록
'@
    $rawHash = (Get-FileHash -LiteralPath $raw).Hash
    $indexHash = (Get-FileHash -LiteralPath $index).Hash
    & $tool -Action Init -VaultPath $vault
    Assert-True ((Get-FileHash -LiteralPath $index).Hash -eq $indexHash) 'Init changed the index.'

    $health = (& $tool -Action Health -VaultPath $vault) | ConvertFrom-Json
    Assert-True ($health.total_pages -eq 3) 'Health inspected an unexpected number of pages.'
    Assert-True ($health.index_sync.on_disk_not_in_index.Count -eq 0) 'Health reported an index mismatch.'
    $lint = (& $tool -Action Lint -VaultPath $vault) | ConvertFrom-Json
    Assert-True ($lint.broken_links.Count -eq 0) 'Lint reported broken links.'
    $concept = Join-Path $wiki 'concepts/sample.md'
    $conceptText = Get-Content -LiteralPath $concept -Raw
    Add-Content -LiteralPath $concept -Value '[[missing-page]]'
    Assert-Rejected { & $tool -Action Lint -VaultPath $vault } 'exit code 1'
    [IO.File]::WriteAllText($concept, $conceptText)

    & $tool -Action Graph -VaultPath $vault
    $graph = Get-Content -LiteralPath (Join-Path $vault 'graph/graph.json') -Raw | ConvertFrom-Json
    Assert-True (@($graph.edges | Where-Object type -eq 'EXTRACTED').Count -gt 0) 'Graph lacks Wikilink edges.'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $vault 'graph/graph.html'))) 'Graph generated HTML.'
    Assert-True ((Get-FileHash -LiteralPath $raw).Hash -eq $rawHash) 'A tool modified the raw note.'

    $locked = [IO.File]::Open((Join-Path $vault '.threadraft.lock'), 'Open', 'ReadWrite', 'None')
    try { Assert-Rejected { & $tool -Action Init -VaultPath $vault } 'Cannot lock the Vault' }
    finally { $locked.Dispose() }

    [void][IO.Directory]::CreateDirectory($outside)
    $linkType = if ($IsWindows) { 'Junction' } else { 'SymbolicLink' }
    New-Item -ItemType $linkType -Path $junction -Target $outside | Out-Null
    Assert-Rejected { & $tool -Action Init -VaultPath $vault } 'Linked or redirected'
    Assert-Rejected { & $tool -Action Init -VaultPath (Join-Path $junction 'child') } 'Linked or redirected'
    Assert-True (-not (Test-Path -LiteralPath (Join-Path $outside 'child'))) 'A redirected write escaped the Vault.'
    [IO.Directory]::Delete($junction)

    if ($WithQmd) {
        $identity = if ($IsWindows) { $vault.ToUpperInvariant() } else { $vault }
        $id = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
            [Text.Encoding]::UTF8.GetBytes($identity))).ToLowerInvariant()
        $cache = Join-Path $repo ".cache/qmd/$id"
        & $tool -Action Index -VaultPath $vault
        $result = (& $tool -Action Search -VaultPath $vault -Query 'marmotquasar') -join "`n"
        Assert-True ($result -match 'threadraft-wiki' -and $result -notmatch 'threadraft-raw') 'Wiki search scope is incorrect.'
        $result = (& $tool -Action Search -VaultPath $vault -Query 'marmotquasar' -Collection Raw) -join "`n"
        Assert-True ($result -match 'threadraft-raw' -and $result -notmatch 'threadraft-wiki') 'Raw search scope is incorrect.'
        $result = (& $tool -Action Search -VaultPath $vault -Query '원본' -Collection Raw) -join "`n"
        Assert-True ($result -match 'threadraft-raw') 'Raw search did not find the Korean keyword.'
        Add-Content -LiteralPath $concept -Value 'refreshmarker'
        & $tool -Action Index -VaultPath $vault
        $result = (& $tool -Action Search -VaultPath $vault -Query 'refreshmarker') -join "`n"
        Assert-True ($result -match 'threadraft-wiki') 'Index refresh did not find the edited Wiki page.'
    }
    Write-Output 'Synthetic Vault tests passed.'
}
finally {
    if (Test-Path -LiteralPath $junction) { [IO.Directory]::Delete($junction) }
    if (Test-Path -LiteralPath $root) { Remove-Item -LiteralPath $root -Recurse -Force }
    if ($cache -and (Test-Path -LiteralPath $cache)) { Remove-Item -LiteralPath $cache -Recurse -Force }
}
