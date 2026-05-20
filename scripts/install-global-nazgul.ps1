param(
    [switch]$Force,
    [switch]$DryRun,
    [switch]$RunChecks,
    [string]$LogPath
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
# If the script lives inside a 'scripts' folder, prefer the parent directory (repo root)
if (-not (Test-Path -Path (Join-Path $root 'agents'))) {
    $maybeRoot = Split-Path -Parent $root
    if (Test-Path -Path (Join-Path $maybeRoot 'agents')) { $root = $maybeRoot }
}
Write-Host "Nazgul installer root: $root"

$agentsDir = Join-Path $env:USERPROFILE ".copilot\agents"
$nazgulDocDir = Join-Path $env:USERPROFILE ".copilot\nazgul"

if (-not (Test-Path -Path (Join-Path $root 'agents'))) { Write-Error 'Missing agents/ directory in installer root.'; exit 1 }
if (-not (Test-Path -Path (Join-Path $root 'prompts'))) { Write-Error 'Missing prompts/ directory in installer root.'; exit 1 }

function Copy-ItemSafe($source, $dest, $force, $dry) {
    if (-not (Test-Path $source)) { return @{copied = @(); skipped = @($source); warning = "$source missing" } }
    if ($dry) { return @{copied = @(); skipped = @($source) } }
    $destDir = Split-Path -Parent $dest
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    if ((Test-Path $dest) -and (-not $force)) { return @{copied = @(); skipped = @($dest) } }
    Copy-Item -Path $source -Destination $dest -Force:$force
    return @{copied = @($dest); skipped = @(); warning = $null } 
}

$summary = [ordered]@{copied = @(); skipped = @(); warnings = @() }

if (-not $DryRun) {
    if (-not (Test-Path $agentsDir)) { New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null }
    if (-not (Test-Path $nazgulDocDir)) { New-Item -ItemType Directory -Path $nazgulDocDir -Force | Out-Null }
}

# copy agents
Get-ChildItem -Path (Join-Path $root 'agents') -Filter *.agent.md -File | ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $agentsDir $_.Name
    $r = Copy-ItemSafe $src $dest $Force $DryRun
    $summary.copied += $r.copied
    $summary.skipped += $r.skipped
    if ($r.warning) { $summary.warnings += $r.warning }
}

# copy prompts
$promptsDest = Join-Path $nazgulDocDir 'prompts'
if (-not $DryRun) { if (-not (Test-Path $promptsDest)) { New-Item -ItemType Directory -Path $promptsDest -Force | Out-Null } }
Get-ChildItem -Path (Join-Path $root 'prompts') -Filter *.md -File | ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $promptsDest $_.Name
    $r = Copy-ItemSafe $src $dest $Force $DryRun
    $summary.copied += $r.copied
    $summary.skipped += $r.skipped
    if ($r.warning) { $summary.warnings += $r.warning }
}

# ensure common template/example prompt files are included even if patterns differ
$extraPrompts = @('khamul-proposal.template.md', 'khamul-proposal-examples.md')
foreach ($ename in $extraPrompts) {
    $src = Join-Path (Join-Path $root 'prompts') $ename
    $dest = Join-Path $promptsDest $ename
    $r = Copy-ItemSafe $src $dest $Force $DryRun
    $summary.copied += $r.copied
    $summary.skipped += $r.skipped
    if ($r.warning) { $summary.warnings += $r.warning }
}

# copy docs (copy contents of repo docs into target docs to avoid nested docs/docs)
$docsSrc = Join-Path $root 'docs'
$docsDest = Join-Path $nazgulDocDir 'docs'
if ($DryRun) {
    if (-not (Test-Path $docsSrc)) { $summary.warnings += "$docsSrc missing" }
    else { $summary.skipped += $docsSrc }
}
else {
    if (Test-Path $docsSrc) {
        if (-not (Test-Path $docsDest)) { New-Item -ItemType Directory -Path $docsDest -Force | Out-Null }
        Get-ChildItem -Path $docsSrc -Force | ForEach-Object {
            $srcPath = $_.FullName
            $destPath = Join-Path $docsDest $_.Name
            if ((Test-Path $destPath) -and (-not $Force)) {
                $summary.skipped += $destPath
            }
            else {
                if ($_.PSIsContainer) { Copy-Item -Path $srcPath -Destination $destPath -Recurse -Force:$Force } else { Copy-Item -Path $srcPath -Destination $destPath -Force:$Force }
                $summary.copied += $destPath
            }
        }
    }
}

# copy root README
$rootReadmeSrc = Join-Path $root 'README.md'
$rootReadmeDest = Join-Path $nazgulDocDir 'README.md'
if ($DryRun) { if (-not (Test-Path $rootReadmeSrc)) { $summary.warnings += "$rootReadmeSrc missing" } else { $summary.skipped += $rootReadmeSrc } } else { Copy-ItemSafe $rootReadmeSrc $rootReadmeDest $Force $DryRun | Out-Null }

Write-Host "\nInstall summary:" -ForegroundColor Cyan
Write-Host "Global agents path: $agentsDir"
Write-Host "Documentation path: $nazgulDocDir"
Write-Host "Copied files:" -ForegroundColor Green
$summary.copied | ForEach-Object { Write-Host " - $_" }
Write-Host "Skipped files:" -ForegroundColor Yellow
$summary.skipped | ForEach-Object { Write-Host " - $_" }
if ($summary.warnings.Count -gt 0) { Write-Host "Warnings:" -ForegroundColor Red; $summary.warnings | ForEach-Object { Write-Host " - $_" } }

# Optional post-install validation
if ($RunChecks) {
    $checkScript = Join-Path (Join-Path $root 'scripts') '_check_agents.ps1'
    if (-not (Test-Path $checkScript)) { Write-Host "Check script not found: $checkScript" -ForegroundColor Yellow }
    else {
        $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        if ([string]::IsNullOrWhiteSpace($LogPath)) { $logFile = Join-Path $nazgulDocDir "install_log_$timestamp.txt" } else { $logFile = $LogPath }
        Write-Host "\nRunning post-install checks (logging to $logFile)..." -ForegroundColor Cyan
        try {
            & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript 2>&1 | Tee-Object -FilePath $logFile
            Write-Host "Post-install checks complete. Log: $logFile" -ForegroundColor Green
        }
        catch {
            Write-Host "Post-install checks failed: $_" -ForegroundColor Red
        }
    }
}
