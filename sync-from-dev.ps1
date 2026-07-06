# Sync dev files from workspace .cursor/ into publishable repo
# Run from content-pipeline/ before commit or push

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$workspace = Split-Path -Parent $root

$srcSkill = Join-Path $workspace ".cursor\skills\content-pipeline"
$srcAgents = Join-Path $workspace ".cursor\agents"
$dstSkill = Join-Path $root ".cursor\skills\content-pipeline"
$dstAgents = Join-Path $root ".cursor\agents"

if (-not (Test-Path $srcSkill)) {
    Write-Error "Skill not found: $srcSkill"
}

Copy-Item -Path "$srcSkill\*" -Destination $dstSkill -Recurse -Force
Copy-Item -Path "$srcAgents\content-*.md" -Destination $dstAgents -Force

Write-Host "Synced from workspace to content-pipeline/"
