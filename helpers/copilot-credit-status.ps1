#!/usr/bin/env pwsh
$ErrorActionPreference = 'Stop'

$copilot = Get-Command copilot -ErrorAction SilentlyContinue
if (-not $copilot) {
  Write-Error 'GitHub Copilot CLI is required to read Copilot credits.'
  exit 127
}
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
  Write-Error 'Node.js is required to read Copilot credits.'
  exit 127
}

$copilotPath = $copilot.Source
try { $copilotPath = (Resolve-Path $copilotPath).Path } catch { $copilotPath = $copilot.Source }
$prefix = Split-Path -Parent (Split-Path -Parent $copilotPath)
$sdk = Join-Path $prefix 'lib/node_modules/@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js'
if (-not (Test-Path $sdk)) {
  # Windows/global npm layouts vary; try common locations
  $npm = Get-Command npm -ErrorAction SilentlyContinue
  if ($npm) {
    try {
      $root = (& npm root -g).Trim()
      $candidates = @(
        (Join-Path $root '@github/copilot/node_modules/@github/copilot-win32-x64/copilot-sdk/index.js'),
        (Join-Path $root '@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js'),
        (Join-Path $root '@github/copilot-sdk/index.js')
      )
      foreach ($c in $candidates) { if (Test-Path $c) { $sdk = $c; break } }
    } catch {
      # Best effort: continue with default SDK path and fail below if unavailable.
      $null = $_
    }
  }
}
if (-not (Test-Path $sdk)) {
  Write-Error 'The Copilot CLI SDK quota API is unavailable at the installed CLI path.'
  exit 1
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& node (Join-Path $scriptDir 'copilot-credit-status.mjs') $sdk
exit $LASTEXITCODE
