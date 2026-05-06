param(
    [string]$ProposalFile = "prompts\khamul-proposal-examples.md"
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$proposalPath = Join-Path $root "..\$ProposalFile"
if (-not (Test-Path $proposalPath)) { Write-Host "Proposal file not found: $proposalPath" -ForegroundColor Red; exit 1 }

$text = Get-Content -Path $proposalPath -Raw
$report = @()

function Parse-FrontMatter($content) {
    $m = [regex]::Match($content, '(?ms)^---\s*(.*?)\s*---')
    if (-not $m.Success) { return $null }
    $fmText = $m.Groups[1].Value
    $lines = $fmText -split "\r?\n"
    $out = @{}
    foreach ($line in $lines) {
        if ($line -match '^([A-Za-z0-9_-]+):\s*(.*)$') {
            $k = $matches[1].Trim().ToLower()
            $v = $matches[2].Trim()
            if ($v -match '^\[.*\]$') {
                $inner = $v.Trim().TrimStart('[').TrimEnd(']')
                $items = $inner -split ',' | ForEach-Object { ($_ -replace "^[\x27\x22]|[\x27\x22]$",'').Trim() } | Where-Object { $_ -ne '' }
                $out[$k] = [System.Collections.ArrayList]@()
                foreach ($it in $items) { $out[$k].Add($it) | Out-Null }
            } else {
                $out[$k] = $v
            }
        }
    }
    return $out
}

$sections = $text -split "\n---\n"
foreach ($sec in $sections) {
    $sec = $sec.Trim()
    if ($sec -eq '') { continue }
    $fm = Parse-FrontMatter $sec
    if ($fm) {
        $title = $fm['title']
        $bc = $false
        if ($fm.ContainsKey('breakingchange') -and ($fm['breakingchange'] -match 'true')) { $bc = $true }
        $dl = ''
        if ($fm.ContainsKey('datalossrisk')) { $dl = $fm['datalossrisk'] }
        $pref = ''
        if ($fm.ContainsKey('preferredimplementer')) { $pref = $fm['preferredimplementer'] }
    } else {
        # fallback: plain text key:value lines
        $title = $null; $bc = $false; $dl = ''; $pref = ''
        $lines = $sec -split "\r?\n"
        foreach ($l in $lines) {
            if ($l -match '^\s*Title:\s*(.+)$') { $title = $matches[1].Trim() }
            if ($l -match '^\s*BreakingChange:\s*(true|false)') { if ($matches[1] -eq 'true') { $bc = $true } }
            if ($l -match '^\s*DataLossRisk:\s*(none|low|medium|high)') { $dl = $matches[1] }
            if ($l -match '^\s*PreferredImplementer:\s*(\w+)') { $pref = $matches[1] }
        }
    }

    if (-not $title) { continue }

    if ($bc -or $dl -in @('medium','high')) {
        $report += "[ESCALATE] $title -> BreakingChange=$bc DataLossRisk=$dl"
    } else {
        $assign = if ($pref -and $pref -ne '') { $pref } else { 'khamul/witch-king decide' }
        $report += "[APPROVED_BY_WITCH-KING] $title -> assign to $assign"
    }
}

$outPath = Join-Path $root 'witchking_approval_report.txt'
$report | Set-Content -Path $outPath -Force
Write-Host "Witch-King approval report written to $outPath" -ForegroundColor Cyan
exit 0
