#!/usr/bin/env pwsh
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

function Read-FrontMatter($path) {
    if (-not (Test-Path $path)) { return $null }
    $content = Get-Content -Path $path -Raw -ErrorAction SilentlyContinue
    $m = [regex]::Match($content, '(?ms)^---\s*(.*?)\s*^---')
    if (-not $m.Success) { return $null }
    $fmText = $m.Groups[1].Value
    $lines = $fmText -split "\r?\n"
    $out = @{}
    $currentKey = $null
    foreach ($line in $lines) {
        if ($line -match '^([a-zA-Z0-9_-]+):\s*(.*)$') {
            $currentKey = $matches[1];
            $val = $matches[2].Trim()
            # support inline arrays like [ 'a', 'b' ]
            if ($val -match '^\[.*\]$') {
                $inner = $val.Trim().TrimStart('[').TrimEnd(']')
                $items = $inner -split ',' | ForEach-Object { $s = $_.Trim(); $s = $s -replace "^[\x27\x22]|[\x27\x22]$", ''; $s } | Where-Object { $_ -ne '' }
                $out[$currentKey] = [System.Collections.ArrayList]@()
                foreach ($it in $items) { $out[$currentKey].Add($it) | Out-Null }
            }
            else {
                $out[$currentKey] = $val
            }
        }
        elseif ($line -match '^\s*-\s*(.+)$') {
            if ($currentKey) {
                if (-not ($out[$currentKey] -is [System.Collections.ArrayList])) { $out[$currentKey] = [System.Collections.ArrayList]@($out[$currentKey]) }
                $out[$currentKey].Add($matches[1].Trim()) | Out-Null
            }
        }
    }
    return $out
}

$witchPath = Join-Path $repoRoot 'agents\witch-king.agent.md'
$wk = Read-FrontMatter $witchPath
if (-not $wk) { Write-Host "ERROR: cannot read frontmatter from $witchPath"; exit 1 }

Write-Host "Witch-King frontmatter parsed:" -ForegroundColor Cyan
Write-Host " - name: $($wk.name)"
Write-Host " - description: $($wk.description)"
if ($wk.agents) { Write-Host " - agents: $(($wk.agents -join ', '))" }

# quick checks
$required = @('khamul', 'morgul', 'akhorahil', 'fellbeast')
$missing = @()
foreach ($r in $required) { if (-not ($wk.agents -contains $r)) { $missing += $r } }
if ($missing.Count -gt 0) { Write-Host "WARNING: Witch-King frontmatter missing expected agents: $($missing -join ', ')" -ForegroundColor Yellow }
else { Write-Host "All expected agents are referenced in Witch-King frontmatter." -ForegroundColor Green }

# Simulate a PO proposal from khamul
$proposal = @"
Title: Add status endpoint for service Z
Owner: khamul
Tasks:
- Backend: Add GET /api/z/status
- Frontend: Add StatusCard component and route
- Tests: Add unit tests and an integration smoke test
Validation:
- dotnet test ./src/ServiceZ.Tests
- npm --prefix ./web run test
"@

Write-Host "\nSimulating PO proposal from `khamul`..." -ForegroundColor Cyan
Write-Host $proposal

# Witch-King 'approves' and assigns to implementers based on simple keyword routing
$assignments = @()
if ($proposal -match '(?mi)Backend: (.+)') { $assignments += @{who = 'morgul'; task = $matches[1].Trim() } }
if ($proposal -match '(?mi)Frontend: (.+)') { $assignments += @{who = 'akhorahil'; task = $matches[1].Trim() } }
if ($proposal -match '(?mi)Tests: (.+)') { $assignments += @{who = 'fellbeast'; task = $matches[1].Trim() } }

Write-Host "\nWitch-King assignment (simulated):" -ForegroundColor Green
foreach ($a in $assignments) { Write-Host " - $($a.who): $($a.task)" }

# include validation commands for reviewer
if ($proposal -match '(?mi)Validation:\s*(.+)$') { }
Write-Host "\nReviewer validation steps:" -ForegroundColor Cyan
Write-Host " - dotnet test ./src/ServiceZ.Tests"
Write-Host " - npm --prefix ./web run test"

$outPath = Join-Path $repoRoot 'scripts\workflow_test_result.txt'
@("Witch-King parsed frontmatter:", "name: $($wk.name)", "description: $($wk.description)", "agents: $($(if ($wk.agents) { $wk.agents -join ', ' } else { '' }))", "", "Simulated proposal:", $proposal, "", "Assignments:") | Set-Content -Path $outPath -Force
foreach ($a in $assignments) { "- $($a.who): $($a.task)" | Add-Content -Path $outPath }
Add-Content -Path $outPath -Value "`nValidation steps:`n- dotnet test ./src/ServiceZ.Tests`n- npm --prefix ./web run test"

Write-Host "\nResult written to $outPath" -ForegroundColor Cyan

exit 0
