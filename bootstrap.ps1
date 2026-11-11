[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectPath,
    [string]$GitPath, [string]$SpecifyPath, [string]$BeadsPath,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$result = [ordered]@{
    projectPath = $ProjectPath; status = 'blocked'; tools = @()
    stages = [ordered]@{ preflight = 'blocked'; git = 'blocked'; beads = 'blocked'; specify = 'blocked'; skills = 'blocked'; agents = 'blocked'; gitignore = 'blocked' }
    conflicts = @(); nextAction = ''
}
$exitCode = 2
$scratch = $null
$mutex = $null
$held = $false
$active = 'preflight'

function Invoke-Tool([string]$Exe, [string[]]$Arguments, [string]$Directory) {
    Push-Location -LiteralPath $Directory
    try {
        $output = @(& $Exe @Arguments 2>&1 | ForEach-Object { $_.ToString() })
        return @{ code = $LASTEXITCODE; output = $output -join [Environment]::NewLine }
    } finally { Pop-Location }
}

function Assert-Success($Run, [string]$Action) {
    if ($Run.code -ne 0) { throw "$Action (exit $($Run.code)): $($Run.output)" }
}

function Assert-LocalPath([string]$Path) {
    for ($p = [IO.Path]::GetFullPath($Path); $p; $p = [IO.Path]::GetDirectoryName($p)) {
        $entry = Get-Item -LiteralPath $p -Force -ErrorAction SilentlyContinue
        if ($entry -and ($entry.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw "Reparse point: $p" }
    }
}

function Assert-Directory([string]$Path) {
    Assert-LocalPath $Path
    if ((Test-Path -LiteralPath $Path) -and -not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "Expected a directory: $Path"
    }
}

function Test-Inside([string]$Child, [string]$Parent) {
    return $Child -eq $Parent -or $Child.StartsWith($Parent.TrimEnd('\') + '\', [StringComparison]::OrdinalIgnoreCase)
}

function Get-AgentName([string]$Path) {
    $pattern = '(?m)^\s*(?:name|"name"|''name'')\s*=\s*(?:"([^"\\]+)"|''([^'']+)'')\s*(?:#.*)?$'
    $found = [regex]::Matches([IO.File]::ReadAllText($Path), $pattern)
    if ($found.Count -ne 1) { throw "Cannot identify a unique agent name: $Path" }
    return $found[0].Groups[1].Value + $found[0].Groups[2].Value
}

function Add-Candidate([string]$Source, [string]$RelativePath, [string]$Stage) {
    $destination = Join-Path $target $RelativePath
    Assert-Directory ([IO.Path]::GetDirectoryName($destination))
    Assert-LocalPath $destination
    if (Test-Path -LiteralPath $destination) {
        if (Test-Path -LiteralPath $destination -PathType Leaf) {
            if ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $destination).Hash) { return }
            if ($Stage -in @('skills','agents')) {
                $lf = [string][char]10
                $crlf = [string][char]13 + $lf
                $sourceText = [IO.File]::ReadAllText($Source).Replace($crlf,$lf)
                $targetText = [IO.File]::ReadAllText($destination).Replace($crlf,$lf)
                if ($Stage -eq 'agents') {
                    $modelLines = '(?m)^[ \t]*(?:model|model_reasoning_effort)[ \t]*=.*(?:\n|$)'
                    $targetText = [regex]::Replace($targetText, $modelLines, '')
                }
                if ($sourceText -ceq $targetText) { return }
            }
        }
        $result.conflicts += $RelativePath
        return
    }
    $pending.Add(@{ source = $Source; destination = $destination; stage = $Stage })
}

function Install-Files([string]$Stage) {
    $files = @($pending | Where-Object stage -eq $Stage)
    # Publish the Spec Kit integration marker after its files so interrupted installs can resume.
    $files = @($files | Sort-Object { [IO.Path]::GetFileName($_.destination) -eq 'integration.json' })
    foreach ($file in $files) {
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($file.destination)) | Out-Null
        [IO.File]::Copy($file.source,$file.destination,$false)
    }
    if ($files.Count) { return 'created' }
    return 'preserved'
}

function Get-IgnoreAppend([string]$Path) {
    [byte[]]$bytes = @()
    if (Test-Path -LiteralPath $Path -PathType Leaf) { $bytes = [IO.File]::ReadAllBytes($Path) }
    $encoding = [Text.UTF8Encoding]::new($false)
    $offset = 0
    $encodings = @([Text.Encoding]::UTF32, [Text.UTF32Encoding]::new($true,$true),
        [Text.Encoding]::Unicode,[Text.Encoding]::BigEndianUnicode,[Text.Encoding]::UTF8)
    foreach ($candidate in $encodings) {
        $bom = $candidate.GetPreamble()
        if ($bom.Length -and $bytes.Length -ge $bom.Length -and
            [Convert]::ToBase64String($bytes,0,$bom.Length) -eq [Convert]::ToBase64String($bom)) {
            $encoding = $candidate
            $offset = $bom.Length
            break
        }
    }
    $content = $encoding.GetString($bytes,$offset,$bytes.Length-$offset)
    $rules = @('/.worktrees/','/.beads.gate.lock','/.beads-bootstrap-*/','/.env') | Where-Object { $_ -cnotin ($content -split '\r\n|\n|\r') }
    if (-not $rules) { return }
    $cr = [string][char]13
    $lf = [string][char]10
    $crlf = $cr + $lf
    $nl = if ($content.Contains($crlf)) { $crlf } elseif ($content.Contains($lf)) { $lf }
        elseif ($content.Contains($cr)) { $cr } else { [Environment]::NewLine }
    $prefix = if ($content -and $content -notmatch '[\r\n]$') { $nl } else { '' }
    return $encoding.GetBytes($prefix + ($rules -join $nl) + $nl)
}

try {
    if ($PSVersionTable.PSVersion.Major -ne 7) { throw 'Use PowerShell 7 (pwsh) on Windows.' }
    $package = [IO.Path]::TrimEndingDirectorySeparator([IO.Path]::GetFullPath($PSScriptRoot))
    $target = [IO.Path]::TrimEndingDirectorySeparator($ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ProjectPath))
    $result.projectPath = $target
    $manifest = Get-Content -Raw -LiteralPath (Join-Path $package 'requires.json') | ConvertFrom-Json
    if (($manifest.requiredTools.id -join ',') -ne 'git,specify,beads') { throw 'Unexpected required-tool manifest.' }
    if ($manifest.schemaVersion -ne 1 -or -not $IsWindows -or $manifest.platform.os -ne 'Windows' -or
        $manifest.platform.shellMajorVersion -ne $PSVersionTable.PSVersion.Major) { throw 'Use Windows and PowerShell 7.' }
    if ($target -eq [IO.Path]::GetPathRoot($target) -or (Test-Inside $target $package) -or (Test-Inside $package $target)) {
        throw 'Choose a project directory separate from the package and its ancestors.'
    }
    Assert-Directory $target
    $routing = @('GIT_DIR','GIT_WORK_TREE','GIT_COMMON_DIR','GIT_INDEX_FILE','BEADS_DIR','SPECIFY_INIT_DIR')
    if (Get-ChildItem Env: | Where-Object { $_.Name -in $routing -or $_.Name -like 'BEADS_DOLT_*' }) {
        throw 'Clear workspace routing environment overrides and retry.'
    }

    $key = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($target.ToUpperInvariant())))
    $mutex = [Threading.Mutex]::new($false,"Local\AgentBootstrap-$key")
    try { $held = $mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held = $true }
    if (-not $held) { throw 'Bootstrap is already running for this target.' }

    $overrides = @{ git = $GitPath; specify = $SpecifyPath; beads = $BeadsPath }
    $exe = @{}
    foreach ($tool in $manifest.requiredTools) {
        $lookup = $overrides[$tool.id]
        if ($lookup) { $lookup = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($lookup) }
        else { $lookup = $tool.command }
        $entry = Get-Command -Name $lookup -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        $state = 'missing'
        $detail = "Command unavailable: $lookup"
        if ($entry) {
            $run = Invoke-Tool $entry.Source $tool.versionArgs $package
            $state = if ($run.code -eq 0) { 'ready' } else { 'failed' }
            $detail = $run.output
            if ($state -eq 'ready') { $exe[$tool.id] = $entry.Source }
        }
        $result.tools += [ordered]@{ id = $tool.id; status = $state; detail = $detail }
    }
    if ($exe.Count -ne $manifest.requiredTools.Count) { throw 'Install the reported required tools or supply their executable paths.' }

    foreach ($name in @('.git','.gitignore','AGENTS.md')) { Assert-LocalPath (Join-Path $target $name) }
    foreach ($name in @('.beads','.specify','.agents/skills','.codex/agents')) { Assert-Directory (Join-Path $target $name) }
    $probe = $target
    while (-not (Test-Path -LiteralPath $probe -PathType Container)) { $probe = [IO.Path]::GetDirectoryName($probe) }
    $run = Invoke-Tool $exe.git @('rev-parse','--show-toplevel') $probe
    $hasGit = $run.code -eq 0
    if ($hasGit -and [IO.Path]::GetFullPath($run.output.Trim()) -ne $target) { throw 'Target belongs to another Git repository.' }
    if (-not $hasGit -and ((Test-Path -LiteralPath (Join-Path $target '.git')) -or $run.output -notmatch 'not a git repository')) {
        throw "Unable to confirm target Git state: $($run.output)"
    }

    $pending = [Collections.Generic.List[hashtable]]::new()
    foreach ($skill in @('task-open','task-integrate','task-close')) {
        $relative = ".agents/skills/$skill/SKILL.md"
        Add-Candidate (Join-Path $package $relative) $relative 'skills'
    }
    $roles = @('researcher','scout','implementer','reviewer','verifier')
    $roleDir = Join-Path $target '.codex/agents'
    if (Test-Path -LiteralPath $roleDir) {
        foreach ($file in Get-ChildItem -LiteralPath $roleDir -Filter '*.toml' -File -Force) {
            Assert-LocalPath $file.FullName
            $name = Get-AgentName $file.FullName
            if ($name -in $roles -and $file.BaseName -ne $name) {
                $result.conflicts += ".codex/agents/$($file.Name)"
            }
        }
    }
    foreach ($role in $roles) {
        $relative = ".codex/agents/$role.toml"
        Add-Candidate (Join-Path $package $relative) $relative 'agents'
    }
    $ignore = Join-Path $target '.gitignore'
    if (Test-Path -LiteralPath $ignore -PathType Container) { $result.conflicts += '.gitignore' }
    if ($result.conflicts.Count) { throw 'Resolve the listed conflicts and retry.' }
    $ignoreAppend = @(Get-IgnoreAppend $ignore)

    $beads = Join-Path $target '.beads'
    $hasBeads = Test-Path -LiteralPath $beads
    if ($hasBeads) {
        $run = Invoke-Tool $exe.beads @('--sandbox','where','--json') $target
        Assert-Success $run 'Existing Beads lookup failed'
        $location = $run.output | ConvertFrom-Json
        $database = [IO.Path]::GetFullPath($location.database_path)
        if ([IO.Path]::GetFullPath($location.path) -ne $beads -or -not (Test-Inside $database $beads)) {
            throw 'Existing Beads workspace or database is outside the target.'
        }
        Assert-LocalPath $database
    }

    $integration = Join-Path $target '.specify/integration.json'
    Assert-LocalPath $integration
    $hasSpecify = Test-Path -LiteralPath $integration -PathType Leaf
    if ($hasSpecify) {
        $settings = Get-Content -Raw -LiteralPath $integration | ConvertFrom-Json
        $requiredSpecFiles = @('.specify/scripts/powershell/resolve-template.ps1','.specify/scripts/powershell/check-prerequisites.ps1',
            '.agents/skills/speckit-specify/SKILL.md','.agents/skills/speckit-plan/SKILL.md','.agents/skills/speckit-tasks/SKILL.md')
        $missingSpecFiles = @($requiredSpecFiles | Where-Object {
            $path = Join-Path $target $_
            Assert-LocalPath $path
            -not (Test-Path -LiteralPath $path -PathType Leaf)
        })
        if ('codex' -notin @($settings.installed_integrations) -or $settings.integration_settings.codex.script -ne 'ps' -or $missingSpecFiles.Count) {
            $result.conflicts += '.specify/integration.json'
            throw 'Existing Specify integration needs Codex PowerShell support.'
        }
    }

    $scratch = Join-Path ([IO.Path]::GetTempPath()) ('agent-bootstrap-' + [guid]::NewGuid().ToString('N'))
    Assert-LocalPath $scratch
    if (-not $hasSpecify) {
        $specStage = Join-Path $scratch 'specify'
        [IO.Directory]::CreateDirectory($specStage) | Out-Null
        $run = Invoke-Tool $exe.specify @('init','--here','--non-interactive','--integration','codex','--script','ps','--ignore-agent-tools') $specStage
        if ($run.code -ne 0) {
            $exitCode = 1
            $result.status = 'failed'
            $active = 'specify'
            Assert-Success $run 'Specify preparation failed'
        }
        foreach ($directory in @('.specify','.agents/skills')) {
            foreach ($file in Get-ChildItem -LiteralPath (Join-Path $specStage $directory) -Recurse -Force) {
                Assert-LocalPath $file.FullName
                if (-not $file.PSIsContainer) {
                    Add-Candidate $file.FullName ([IO.Path]::GetRelativePath($specStage,$file.FullName)) 'specify'
                }
            }
        }
    }
    if ($result.conflicts.Count) { throw 'Resolve the listed Spec Kit conflicts and retry.' }
    $result.stages.preflight = 'ready'
    $exitCode = 1
    $result.status = 'failed'
    $active = 'beads'
    if (-not $hasBeads) {
        $stage = Join-Path $scratch 'beads'
        [IO.Directory]::CreateDirectory($stage) | Out-Null
        $prefix = [regex]::Replace([IO.Path]::GetFileName($target).ToLowerInvariant(),'[^a-z0-9]+','-').Trim('-')
        if (-not $prefix) { $prefix = 'task' }
        $prefix = $prefix.Substring(0,[Math]::Min(20,$prefix.Length)).TrimEnd('-')
        Assert-Success (Invoke-Tool $exe.beads @('--sandbox','init','--non-interactive','--prefix',$prefix,'--skip-agents','--skip-hooks') $stage) 'Beads preparation failed'
        $stagedBeads = Join-Path $stage '.beads'
        Assert-Directory $stagedBeads
        if (-not (Test-Path -LiteralPath (Join-Path $stagedBeads 'metadata.json') -PathType Leaf) -or
            (Get-ChildItem -LiteralPath $stagedBeads -Recurse -Force -Attributes ReparsePoint)) { throw 'Unexpected staged Beads layout.' }
    } else {
        Assert-Success (Invoke-Tool $exe.beads @('--sandbox','ready','--json') $target) 'Existing Beads readiness check failed'
    }

    $active = 'git'
    [IO.Directory]::CreateDirectory($target) | Out-Null
    if (-not $hasGit) { Assert-Success (Invoke-Tool $exe.git @('init','-b','main') $target) 'Git initialization failed' }
    $result.stages.git = if ($hasGit) { 'preserved' } else { 'created' }
    $active = 'beads'
    if (-not $hasBeads) {
        $incoming = Join-Path $target ('.beads-bootstrap-' + [guid]::NewGuid().ToString('N'))
        try {
            Copy-Item -LiteralPath $stagedBeads -Destination $incoming -Recurse
            [IO.Directory]::Move($incoming,$beads)
        } catch { throw "Beads transfer failed. Inspect $incoming before retrying. $_" }
        Assert-Success (Invoke-Tool $exe.beads @('--sandbox','ready','--json') $target) 'New Beads readiness check failed'
    }
    $result.stages.beads = if ($hasBeads) { 'preserved' } else { 'created' }
    foreach ($stage in @('specify','skills','agents')) {
        $active = $stage
        $result.stages[$stage] = Install-Files $stage
    }
    $active = 'gitignore'
    if ($ignoreAppend.Count) {
        $stream = [IO.File]::Open($ignore,[IO.FileMode]::Append,[IO.FileAccess]::Write,[IO.FileShare]::Read)
        try { $stream.Write([byte[]]$ignoreAppend,0,$ignoreAppend.Count) } finally { $stream.Dispose() }
    }
    $result.stages.gitignore = if ($ignoreAppend.Count) { 'created' } else { 'preserved' }
    $result.status = 'ready'
    $result.nextAction = 'Open the target in Codex. Review project policy and prepare a Git baseline before opening a Task worktree.'
    $exitCode = 0
} catch {
    if ($exitCode -eq 1) { $result.stages[$active] = 'failed' }
    $result.nextAction = $_.Exception.Message
} finally {
    if ($scratch -and [IO.Path]::GetDirectoryName($scratch) -eq [IO.Path]::TrimEndingDirectorySeparator([IO.Path]::GetTempPath()) -and
        [IO.Path]::GetFileName($scratch) -match '^agent-bootstrap-[a-f0-9]{32}$' -and (Test-Path -LiteralPath $scratch)) {
        Remove-Item -LiteralPath $scratch -Recurse -Force -ErrorAction SilentlyContinue
    }
    if ($held) { $mutex.ReleaseMutex() }
    if ($mutex) { $mutex.Dispose() }
}

if ($Json) { $result | ConvertTo-Json -Depth 8 }
else {
    Write-Output ("{0}: {1}" -f $result.status,$result.projectPath)
    foreach ($tool in $result.tools) { Write-Output ("  {0}: {1}" -f $tool.id,$tool.status) }
    foreach ($stage in $result.stages.Keys) { Write-Output ("  {0}: {1}" -f $stage,$result.stages[$stage]) }
    foreach ($conflict in $result.conflicts) { Write-Output "  conflict: $conflict" }
    Write-Output $result.nextAction
}
exit $exitCode
