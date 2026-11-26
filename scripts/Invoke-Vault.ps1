#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet('Init', 'Validate', 'Health', 'Lint', 'Graph', 'Index', 'Embed', 'Search')]
    [string]$Action,

    [string]$VaultPath,
    [string]$Query,
    [ValidateSet('Wiki', 'Raw')]
    [string]$Collection = 'Wiki',
    [ValidateSet('Keyword', 'Vector', 'Hybrid')]
    [string]$SearchMode = 'Keyword'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repo = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$defaultVault = Join-Path $repo 'vault'
if (-not $VaultPath) { $VaultPath = $defaultVault }
if ($VaultPath -match '^[\\/]{2}') { throw 'Use a local Vault path.' }
if (-not $IsWindows -and $VaultPath.Contains([char]92)) { throw 'Use forward slashes on this platform.' }
$vault = [IO.Path]::TrimEndingDirectorySeparator(
    [IO.Path]::GetFullPath($VaultPath, (Get-Location).ProviderPath))

function Test-WithinPath([string]$Parent, [string]$Child) {
    $relative = [IO.Path]::GetRelativePath($Parent, $Child)
    $first = ($relative -split '[/\\]', 2)[0]
    return -not [IO.Path]::IsPathRooted($relative) -and $first -ne '..'
}

function Assert-SafeItem($Item) {
    if ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        throw "Linked or redirected paths are unsupported: $($Item.FullName)"
    }
}

function Assert-SafePath([string]$Path) {
    $root = [IO.Path]::GetPathRoot($Path)
    $current = $root
    foreach ($component in ($Path.Substring($root.Length) -split '[/\\]')) {
        if (-not $component) { continue }
        if ($IsWindows -and $component -match '[:*?"<>|]|[. ]$|^(?i:CON|PRN|AUX|NUL|COM[1-9¹²³]|LPT[1-9¹²³])(?:\.|$)') {
            throw "Unsupported Windows path component: $component"
        }
        $current = Join-Path $current $component
        $item = Get-Item -LiteralPath $current -Force -ErrorAction SilentlyContinue
        if ($null -ne $item) { Assert-SafeItem $item }
    }
}

function Assert-SafeTree([string]$Directory) {
    $pending = [Collections.Generic.Stack[string]]::new()
    $pending.Push($Directory)
    while ($pending.Count -gt 0) {
        foreach ($item in Get-ChildItem -LiteralPath $pending.Pop() -Force) {
            Assert-SafeItem $item
            if ($item.PSIsContainer) { $pending.Push($item.FullName) }
        }
    }
}

function Invoke-Native([string]$Executable, [string[]]$Arguments) {
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "$Executable failed with exit code $LASTEXITCODE."
    }
}

$relativeVault = [IO.Path]::GetRelativePath($defaultVault, $vault)
if ($relativeVault -ne '.' -and
    ((Test-WithinPath $repo $vault) -or (Test-WithinPath $vault $repo))) {
    throw 'Use the default vault/ or a directory outside the Threadraft checkout.'
}
Assert-SafePath $vault

$directories = @(
    '.obsidian', 'raw/articles', 'raw/papers', 'raw/docs', 'raw/notes', 'raw/ideas',
    'wiki/sources', 'wiki/entities', 'wiki/concepts', 'wiki/syntheses', 'graph', 'reports'
)
$seedNames = @('index.md', 'overview.md', 'log.md')
if ($Action -eq 'Init') { [void][IO.Directory]::CreateDirectory($vault) }
if (-not [IO.Directory]::Exists($vault)) { throw 'Vault directory is missing. Run Init first.' }

$lockPath = Join-Path $vault '.threadraft.lock'
Assert-SafePath $lockPath
try {
    $lock = [IO.File]::Open($lockPath, 'OpenOrCreate', 'ReadWrite', 'None')
}
catch [IO.IOException] {
    throw "Cannot lock the Vault. Another Threadraft process may be using it. $($_.Exception.Message)"
}

try {
    Assert-SafeTree $vault
    if ($Action -eq 'Init') {
        foreach ($directory in $directories) {
            [void][IO.Directory]::CreateDirectory((Join-Path $vault $directory))
        }
        foreach ($name in $seedNames) {
            $destination = Join-Path $vault "wiki/$name"
            if ([IO.File]::Exists($destination)) { continue }
            $temporary = Join-Path $vault "wiki/$([guid]::NewGuid()).tmp"
            try {
                [IO.File]::Copy((Join-Path $repo "templates/vault/wiki/$name"), $temporary)
                [IO.File]::Move($temporary, $destination)
            }
            finally {
                [IO.File]::Delete($temporary)
            }
        }
    }

    foreach ($directory in $directories) {
        if (-not [IO.Directory]::Exists((Join-Path $vault $directory))) {
            throw "Missing Vault directory: $directory"
        }
    }
    foreach ($name in $seedNames) {
        if (-not [IO.File]::Exists((Join-Path $vault "wiki/$name"))) {
            throw "Missing Wiki file: $name"
        }
    }

    if ($Action -in @('Health', 'Lint', 'Graph')) {
        $savedVault = $env:THREADRAFT_VAULT
        try {
            $env:THREADRAFT_VAULT = $vault
            $tool = Join-Path $repo 'tools/llm-wiki-agent'
            $arguments = switch ($Action) {
                'Health' { '-X'; 'utf8'; '-B'; (Join-Path $tool 'tools/health.py'); '--json' }
                'Lint' { '-X'; 'utf8'; '-B'; (Join-Path $tool 'lint-local.py') }
                'Graph' { '-X'; 'utf8'; '-B'; (Join-Path $tool 'tools/build_graph.py'); '--no-infer'; '--json-only' }
            }
            Invoke-Native 'python' $arguments
        }
        finally {
            $env:THREADRAFT_VAULT = $savedVault
        }
    }

    if ($Action -in @('Index', 'Embed', 'Search')) {
        $qmd = (Get-Command qmd -CommandType Application).Source | Select-Object -First 1
        if ($IsWindows) {
            # npm installs qmd.cmd. Invoke the JS entry point directly to avoid cmd.exe
            # interpreting the search query, paths, or environment variables.
            $qmdPackage = Join-Path (Split-Path $qmd) 'node_modules/@tobilu/qmd'
            $manifest = Get-Content -LiteralPath (Join-Path $qmdPackage 'package.json') -Raw |
                ConvertFrom-Json
            $entry = Join-Path $qmdPackage $manifest.bin.qmd
            $qmd = (Get-Command node -CommandType Application | Select-Object -First 1).Source
        }
        else { $entry = $null }

        $identity = if ($IsWindows) { $vault.ToUpperInvariant() } else { $vault }
        $id = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
            [Text.Encoding]::UTF8.GetBytes($identity))).ToLowerInvariant()
        $cache = Join-Path $repo ".cache/qmd/$id"
        Assert-SafePath $cache
        [void][IO.Directory]::CreateDirectory($cache)
        Assert-SafeTree $cache

        $config = Join-Path $cache 'index.yml'
        $collections = @{ collections = [ordered]@{
            'threadraft-wiki' = @{ path = (Join-Path $vault 'wiki'); pattern = '**/*.md' }
            'threadraft-raw' = @{
                path = (Join-Path $vault 'raw'); pattern = '**/*.md'; includeByDefault = $false
            }
        } }
        $json = $collections | ConvertTo-Json -Depth 5
        [IO.File]::WriteAllText($config, $json)

        $savedConfig = $env:QMD_CONFIG_DIR
        $savedCache = $env:XDG_CACHE_HOME
        Push-Location -LiteralPath $cache
        try {
            $env:QMD_CONFIG_DIR = $cache
            $env:XDG_CACHE_HOME = $cache
            $arguments = switch ($Action) {
                'Index' { 'update' }
                'Embed' { 'embed' }
                'Search' {
                    if ([string]::IsNullOrWhiteSpace($Query)) { throw 'Search requires -Query.' }
                    switch ($SearchMode) {
                        'Keyword' { 'search' }
                        'Vector' { 'vsearch' }
                        'Hybrid' { 'query' }
                    }
                    '-c'
                    "threadraft-$($Collection.ToLowerInvariant())"
                    '--'
                    $Query
                }
            }
            if ($entry) { $arguments = @($entry) + $arguments }
            Invoke-Native $qmd $arguments
        }
        finally {
            $env:QMD_CONFIG_DIR = $savedConfig
            $env:XDG_CACHE_HOME = $savedCache
            Pop-Location
        }
    }

    if ($Action -in @('Init', 'Validate')) { Write-Output "Vault layout verified: $vault" }
}
finally {
    $lock.Dispose()
}
