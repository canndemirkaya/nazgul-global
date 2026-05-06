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
    Get-ChildItem -Path $promptsSrc -Filter *.prompt.md -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination (Join-Path $promptsDest $_.Name) -Force
        Write-Host "Copied prompt: $($_.Name)"
    }
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
