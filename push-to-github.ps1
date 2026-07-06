# Push content-pipeline to GitHub
# Usage: $env:GITHUB_TOKEN = "github_pat_..." ; .\push-to-github.ps1

param(
    [string]$Token = $env:GITHUB_TOKEN
)

$ErrorActionPreference = "Stop"
$git = "C:\Users\iv.potapov\Desktop\Cursor\.tools\mingit\cmd\git.exe"
if (-not (Test-Path $git)) { $git = "git" }

$repo = "https://github.com/guacamolotow-mcbarren/content-pipeline.git"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if (-not $Token) {
    Write-Host "Need GITHUB_TOKEN with repo write access."
    Write-Host 'Set: $env:GITHUB_TOKEN = "github_pat_..." ; .\push-to-github.ps1'
    exit 1
}

Set-Location $root
& $git add -A
$status = & $git status --porcelain
if ($status) {
    & $git -c user.name="guacamolotow-mcbarren" -c user.email="guacamolotow-mcbarren@users.noreply.github.com" commit -m "Update content-pipeline framework."
}

$remote = & $git remote get-url origin 2>$null
if (-not $remote) {
    & $git remote add origin $repo
}

$pushUrl = "https://x-access-token:${Token}@github.com/guacamolotow-mcbarren/content-pipeline.git"
& $git push -u $pushUrl main --force
Write-Host "Done: https://github.com/guacamolotow-mcbarren/content-pipeline"
