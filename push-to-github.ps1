# Push content-pipeline to GitHub
# Usage: $env:GITHUB_TOKEN = "ghp_..." ; .\push-to-github.ps1

param(
    [string]$Token = $env:GITHUB_TOKEN
)

$ErrorActionPreference = "Stop"
$git = "C:\Users\iv.potapov\Desktop\Cursor\.tools\mingit\cmd\git.exe"
if (-not (Test-Path $git)) { $git = "git" }

$repo = "https://github.com/jet-marketing-pr-ai-utilities/content-pipeline.git"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$work = Join-Path (Split-Path -Parent $root) "content-pipeline-push"

if (-not $Token) {
    Write-Host "Нужен GitHub token с правом write на репозиторий."
    Write-Host 'Создайте: GitHub → Settings → Developer settings → Personal access tokens'
    Write-Host 'Затем: $env:GITHUB_TOKEN = "ghp_..." ; .\push-to-github.ps1'
    exit 1
}

if (-not (Test-Path "$work\.git")) {
    & $git clone $repo $work 2>$null
    if (-not (Test-Path "$work\.git")) {
        New-Item -ItemType Directory -Force -Path $work | Out-Null
        Set-Location $work
        & $git init -b main
        & $git remote add origin $repo
    }
}

Copy-Item -Path "$root\*" -Destination $work -Recurse -Force
Set-Location $work
& $git add -A
$status = & $git status --porcelain
if ($status) {
    & $git -c user.name="jet-marketing-pr-ai-utilities" -c user.email="jet-marketing-pr-ai-utilities@users.noreply.github.com" commit -m "Update content-pipeline framework."
}

$pushUrl = "https://x-access-token:${Token}@github.com/jet-marketing-pr-ai-utilities/content-pipeline.git"
& $git push -u $pushUrl main
Write-Host "Done: https://github.com/jet-marketing-pr-ai-utilities/content-pipeline"
