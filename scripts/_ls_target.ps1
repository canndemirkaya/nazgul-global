param([string]$Path)
if (-not $Path) { Write-Error 'No path provided'; exit 1 }
Set-Location -Path $Path
Write-Host "CWD=$(Get-Location)"
Get-ChildItem -Force | ForEach-Object { Write-Host $_.Name }
