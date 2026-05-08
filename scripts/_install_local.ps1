$srcRoot='C:\workspaces\_agent-packs\nazgul-global'
$agentsSrc = Join-Path $srcRoot 'agents'
$promptsSrc = Join-Path $srcRoot 'prompts'
$docsSrc = Join-Path $srcRoot 'docs'
$agentsDest= Join-Path $env:USERPROFILE '.copilot\agents'
$nazgulDest = Join-Path $env:USERPROFILE '.copilot\nazgul'
$promptsDest = Join-Path $nazgulDest 'prompts'
$docsDest = Join-Path $nazgulDest 'docs'
New-Item -ItemType Directory -Path $agentsDest -Force | Out-Null
New-Item -ItemType Directory -Path $promptsDest -Force | Out-Null
New-Item -ItemType Directory -Path $docsDest -Force | Out-Null
if (Test-Path $agentsSrc) {
    Get-ChildItem -Path $agentsSrc -Filter *.agent.md -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $agentsDest $_.Name) -Force
        Write-Host "Copied agent: $($_.Name)"
    }
} else {
    Write-Host "Agents source missing: $agentsSrc"
}
if (Test-Path $promptsSrc) {
    # copy common prompt files (both *.prompt.md and other .md templates)
    Get-ChildItem -Path $promptsSrc -Include *.prompt.md,*.md -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $promptsDest $_.Name) -Force
        Write-Host "Copied prompt: $($_.Name)"
    }
    # copy promposals folder if present
    $promposalsSrc = Join-Path $srcRoot 'promposals'
    if (Test-Path $promposalsSrc) {
        Copy-Item -Path $promposalsSrc -Destination (Join-Path $nazgulDest 'promposals') -Recurse -Force
        Write-Host "Copied promposals folder"
    }
    # copy repo-level copilot instructions if present
    $copilotIns = Join-Path $srcRoot '.github\copilot-instructions.md'
    if (Test-Path $copilotIns) { Copy-Item -Path $copilotIns -Destination (Join-Path $nazgulDest 'copilot-instructions.md') -Force; Write-Host "Copied copilot-instructions.md" }
} else {
    Write-Host "Prompts source missing: $promptsSrc"
}
if (Test-Path $docsSrc) {
    Copy-Item -Path $docsSrc -Destination $docsDest -Recurse -Force
    Write-Host "Copied docs to $docsDest"
} else {
    Write-Host "Docs source missing: $docsSrc"
}
Write-Host 'Copy finished'
