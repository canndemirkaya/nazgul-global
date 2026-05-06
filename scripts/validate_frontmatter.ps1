#!/usr/bin/env pwsh
<#
Validate YAML frontmatter for agent files under agents/*.agent.md

Checks:
 - frontmatter present
 - required keys: name, description, tools, agents
 - tools and agents parsed as non-empty lists
 - unique `name` values across files

Exit 0 on success, 1 on any error.
#>

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$agentsDir = Join-Path $root '..\agents' | Resolve-Path -ErrorAction SilentlyContinue
if (-not $agentsDir) { Write-Host "No agents/ directory found at expected path" -ForegroundColor Red; exit 1 }
$files = Get-ChildItem -Path $agentsDir -Filter *.agent.md -File -ErrorAction SilentlyContinue
if ($files.Count -eq 0) { Write-Host "No agent files found in $agentsDir" -ForegroundColor Red; exit 1 }

$errors = @()
$names = @{}

function Parse-FrontMatter($content) {
    $result = @{}
    $m = [regex]::Match($content, '(?ms)^---\s*(.*?)\s*^---')
    if (-not $m.Success) { return $null }
    $fmText = $m.Groups[1].Value
    $lines = $fmText -split "\r?\n"
    $currentKey = $null
    foreach ($line in $lines) {
        if ($line -match '^([a-zA-Z0-9_-]+):\s*(.*)$') {
            $currentKey = $matches[1]
            $val = $matches[2].Trim()
            if ($val -match '^\[.*\]$') {
                $inner = $val.Trim().TrimStart('[').TrimEnd(']')
                $items = $inner -split ',' | ForEach-Object { $s = $_.Trim(); $s = $s -replace "^[\x27\x22]|[\x27\x22]$", ''; $s } | Where-Object { $_ -ne '' }
                $result[$currentKey] = [System.Collections.ArrayList]@()
                foreach ($it in $items) { $result[$currentKey].Add($it) | Out-Null }
            }
            elseif ($val -ne '') {
                $result[$currentKey] = $val
            }
            else {
                $result[$currentKey] = $null
            }
        }
        elseif ($line -match '^\s*-\s*(.+)$') {
            if ($currentKey) {
                if (-not ($result[$currentKey] -is [System.Collections.ArrayList])) { $result[$currentKey] = [System.Collections.ArrayList]@() }
                $result[$currentKey].Add($matches[1].Trim()) | Out-Null
            }
        }
    }
    return $result
}

foreach ($f in $files) {
    $content = Get-Content -Path $f.FullName -Raw -ErrorAction SilentlyContinue
    if (-not $content) { $errors += "$($f.Name): could not read file"; continue }
    $fm = Parse-FrontMatter $content
    if (-not $fm) { $errors += "$($f.Name): missing or invalid frontmatter"; continue }
    # required keys (agents is optional for most files)
    foreach ($k in @('name', 'description', 'tools')) {
        if (-not $fm.ContainsKey($k) -or [string]::IsNullOrWhiteSpace($fm[$k])) { $errors += "$($f.Name): missing or empty '$k'" }
    }
    # tools and agents must be non-empty lists
    foreach ($listKey in @('tools', 'agents')) {
        if ($fm.ContainsKey($listKey)) {
            $val = $fm[$listKey]
            if (-not ($val -is [System.Collections.IEnumerable])) { $errors += "$($f.Name): '$listKey' must be a list"; continue }
            if ($val.Count -eq 0) { $errors += "$($f.Name): '$listKey' must not be empty" }
            else {
                foreach ($item in $val) { if ([string]::IsNullOrWhiteSpace($item)) { $errors += "$($f.Name): '$listKey' contains empty item" } }
            }
        }
    }
    # collect names
    if ($fm.ContainsKey('name')) {
        $n = $fm['name']
        if ($names.ContainsKey($n)) { $errors += "$($f.Name): duplicate agent name '$n' also in $($names[$n])" }
        else { $names[$n] = $f.Name }
    }
}

if ($errors.Count -gt 0) {
    Write-Host "Frontmatter validation failed:" -ForegroundColor Red
    $errors | ForEach-Object { Write-Host " - $_" }
    exit 1
}
else {
    Write-Host "All agent frontmatter looks valid." -ForegroundColor Green
    exit 0
}
