#!/usr/bin/env pwsh
param([string]$Mode = 'request')
$ErrorActionPreference = 'Stop'
if ($Mode -notin @('initial','request')) { exit 2 }
$config = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'ai-agent-config' } else { Join-Path $env:USERPROFILE '.config/ai-agent-config' }
$binFile = Join-Path $config 'twg-bin'
if (-not (Test-Path $binFile)) {
  Write-Error 'TWG pending: configure an approved standalone binary in the private twg-bin file.'
  exit 0
}
$twg = (Get-Content -Raw -Encoding UTF8 $binFile).Trim()
if ([string]::IsNullOrWhiteSpace($twg) -or -not (Test-Path $twg)) {
  Write-Error 'TWG skipped: private twg-bin must name one executable path.'
  exit 1
}
$resolved = try { (Resolve-Path $twg).Path } catch { $twg }
if ($resolved -match '[\\/]\\.rovo[\\/]|[\\/]\\.rovodev[\\/]') {
  Write-Error 'TWG skipped: do not independently manage a Rovo-bundled binary.'
  exit 1
}
if ($Mode -eq 'initial') {
  & $twg skills install --global
  & $twg doctor
} else {
  Write-Error 'Standalone TWG selected; request mode does not install skills or start login.'
}
