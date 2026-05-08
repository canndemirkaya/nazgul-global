param(
    [switch]$Force,
    [switch]$DryRun,
    [string]$BackupDir,
    [switch]$RunChecks
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Nazgul updater root: $root"

$agentsDir = Join-Path $env:USERPROFILE ".copilot\agents"
$nazgulDir = Join-Path $env:USERPROFILE ".copilot\nazgul"

if (-not (Test-Path -Path (Join-Path $root 'agents'))) { Write-Error 'Missing agents/ directory in updater root.'; exit 1 }
if (-not (Test-Path -Path (Join-Path $root 'prompts'))) { Write-Error 'Missing prompts/ directory in updater root.'; exit 1 }

if (-not $BackupDir) { $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'; $BackupDir = Join-Path $nazgulDir "backups\$timestamp" }

function _ensure($path) { if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path -Force | Out-Null } }
_ensure $agentsDir
_ensure $nazgulDir
_ensure (Split-Path -Parent $BackupDir)

$summary = [ordered]@{updated = @(); skipped = @(); backedup = @(); warnings = @() }

function Copy-IfNewer($src, $dest) {
    if (-not (Test-Path $src)) { return @{action = 'missing'; src = $src; dest = $dest } }
    $doCopy = $false
    if (-not (Test-Path $dest)) { $doCopy = $true }
    elseif ($Force) { $doCopy = $true }
    else {
        $s = Get-Item $src
        $d = Get-Item $dest
        if ($s.LastWriteTime -gt $d.LastWriteTime) { $doCopy = $true }
    }
    if (-not $doCopy) { return @{action = 'skip'; src = $src; dest = $dest } }

    # backup existing
    if ((Test-Path $dest) -and -not $DryRun) {
        $bd = Join-Path $BackupDir ((Split-Path $dest -Leaf) + '.' + (Get-Date -Format 'yyyyMMddHHmmss') + '.bak')
        _ensure (Split-Path -Parent $bd)
        Copy-Item -Path $dest -Destination $bd -Force
        $summary.backedup += $bd
    }

    if ($DryRun) { return @{action = 'would-copy'; src = $src; dest = $dest } }
    Copy-Item -Path $src -Destination $dest -Force
    return @{action = 'copied'; src = $src; dest = $dest }
}

Write-Host "Updating agents..." -ForegroundColor Cyan
Get-ChildItem -Path (Join-Path $root 'agents') -Filter *.agent.md -File | ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $agentsDir $_.Name
    $r = Copy-IfNewer $src $dest
    switch ($r.action) {
        'copied' { $summary.updated += $r.dest; Write-Host "Updated: $($r.dest)" -ForegroundColor Green }
        'would-copy' { Write-Host "Would update: $($r.dest)" -ForegroundColor Yellow; $summary.skipped += $r.dest }
        'skip' { $summary.skipped += $r.dest }
        default { $summary.warnings += "$($r.src) -> $($r.dest): $($r.action)" }
    }
}

Write-Host "Updating prompts..." -ForegroundColor Cyan
$promptsDest = Join-Path $nazgulDir 'prompts'
_ensure $promptsDest
Get-ChildItem -Path (Join-Path $root 'prompts') -Include *.prompt.md, *.md -File | ForEach-Object {
    $src = $_.FullName
    $dest = Join-Path $promptsDest $_.Name
    $r = Copy-IfNewer $src $dest
    switch ($r.action) {
        'copied' { $summary.updated += $r.dest; Write-Host "Updated: $($r.dest)" -ForegroundColor Green }
        'would-copy' { Write-Host "Would update: $($r.dest)" -ForegroundColor Yellow; $summary.skipped += $r.dest }
        'skip' { $summary.skipped += $r.dest }
        default { $summary.warnings += "$($r.src) -> $($r.dest): $($r.action)" }
    }
}

Write-Host "Updating docs..." -ForegroundColor Cyan
$docsSrc = Join-Path $root 'docs'
if (Test-Path $docsSrc) {
    $docsDest = Join-Path $nazgulDir 'docs'
    Get-ChildItem -Path $docsSrc -Force | ForEach-Object {
        $srcPath = $_.FullName
        $destPath = Join-Path $docsDest $_.Name
        if ($DryRun) { Write-Host "Would copy docs: $srcPath -> $destPath"; $summary.skipped += $destPath; return }
        if ((Test-Path $destPath) -and (-not $Force)) { $summary.skipped += $destPath } else { if ($_.PSIsContainer) { Copy-Item -Path $srcPath -Destination $destPath -Recurse -Force } else { Copy-Item -Path $srcPath -Destination $destPath -Force } ; $summary.updated += $destPath }
    }
}

Write-Host "\nUpdate summary:" -ForegroundColor Cyan
Write-Host "Updated files:" -ForegroundColor Green
$summary.updated | ForEach-Object { Write-Host " - $_" }
Write-Host "Skipped/unmodified:" -ForegroundColor Yellow
$summary.skipped | ForEach-Object { Write-Host " - $_" }
if ($summary.backedup.Count -gt 0) { Write-Host "Backups:" -ForegroundColor Cyan; $summary.backedup | ForEach-Object { Write-Host " - $_" } }
if ($summary.warnings.Count -gt 0) { Write-Host "Warnings:" -ForegroundColor Red; $summary.warnings | ForEach-Object { Write-Host " - $_" } }

if ($RunChecks) {
    $checkScript = Join-Path (Join-Path $root 'scripts') '_check_agents.ps1'
    if (-not (Test-Path $checkScript)) { Write-Host "Check script not found: $checkScript" -ForegroundColor Yellow }
    else {
        Write-Host "Running post-update checks..." -ForegroundColor Cyan
        & powershell -NoProfile -ExecutionPolicy Bypass -File $checkScript
    }
}

exit 0
