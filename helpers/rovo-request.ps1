#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = (Resolve-Path (Join-Path $scriptDir '..')).Path
$setup = Join-Path $repo 'setup.ps1'
$setupSh = Join-Path $repo 'setup.sh'
if (Test-Path $setup) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $setup -Request
} elseif (Get-Command bash -ErrorAction SilentlyContinue) {
  & bash $setupSh --request
}
$files = @('AGENTS.md','memory/MEMORY.md','MAIL-ROUTING.md','GIT-CONFIG-SAFETY.md','ATLASSIAN.md','rovo/AGENTS.md')
foreach ($f in $files) {
  Write-Output ""
  Write-Output "--- $f ---"
  Get-Content -Raw -Encoding UTF8 (Join-Path $repo $f)
}
