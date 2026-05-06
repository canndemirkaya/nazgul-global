$u = $env:USERPROFILE
Write-Host "USERPROFILE=$u"
$agents = Join-Path $u '.copilot\agents'
Write-Host "AgentsPath=$agents"
if (-not (Test-Path $agents)) {
    Write-Host "No agents directory found at $agents"
    exit 0
}

Get-ChildItem -Path $agents -Filter *.agent.md -File | ForEach-Object {
    $file = $_.FullName
    $name = $_.Name
    $content = Get-Content -Path $file -Raw -ErrorAction SilentlyContinue
    $agentName = $null
    $agentDesc = $null
    if ($content) {
        $m = [regex]::Match($content, '(?ms)^---\s*(.*?)\s*^---')
        if ($m.Success) {
            $fmText = $m.Groups[1].Value
            $fmLines = $fmText -split "\r?\n"
            foreach ($line in $fmLines) {
                if ($line -match '^name:\s*(.+)$') { $agentName = $matches[1].Trim() }
                if ($line -match '^description:\s*(.+)$') { $agentDesc = $matches[1].Trim() }
            }
        }
    }

    if ($agentName) {
        Write-Host "AGENT: $name -> $agentName - $agentDesc"
    }
    else {
        Write-Host "AGENT: $name"
    }
}
