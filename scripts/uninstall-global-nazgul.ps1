param(
    [switch]$DryRun
)

$agents = @(
    'witch-king.agent.md',
    'morgul.agent.md',
    'khamul.agent.md',
    'akhorahil.agent.md',
    'fellbeast.agent.md'
)

$agentsDir = Join-Path $env:USERPROFILE ".copilot\agents"
$nazgulDir = Join-Path $env:USERPROFILE ".copilot\nazgul"

Write-Host "Uninstalling Nazgul from user Copilot folders"

foreach ($a in $agents) {
    $path = Join-Path $agentsDir $a
    if ($DryRun) { Write-Host "DRYRUN remove $path" } else { if (Test-Path $path) { Remove-Item $path -Force; Write-Host "Removed $path" } else { Write-Host "Missing $path" } }
}

if ($DryRun) { Write-Host "DRYRUN remove $nazgulDir" } else { if (Test-Path $nazgulDir) { Remove-Item $nazgulDir -Recurse -Force; Write-Host "Removed $nazgulDir" } else { Write-Host "Missing $nazgulDir" } }

Write-Host "Uninstall complete. No other Copilot customizations were changed."
