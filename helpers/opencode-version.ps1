#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'
$opencode = Get-Command opencode -ErrorAction SilentlyContinue
if (-not $opencode) { Write-Error 'OpenCode version detection failed: opencode not found'; exit 1 }
$out = & $opencode.Source --version 2>$null
if ($LASTEXITCODE -ne 0) { Write-Error 'OpenCode version detection failed'; exit 1 }
if ($out -match '(?:opencode\s+)?v?([12])\.(\d+)\.(\d+)(?:\+[0-9A-Za-z.-]+)?') {
  Write-Output $Matches[1]
  exit 0
}
Write-Error 'Unsupported OpenCode version; no hook changes made'
exit 1
