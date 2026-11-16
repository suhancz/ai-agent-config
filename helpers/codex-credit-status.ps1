#!/usr/bin/env pwsh
# Windows-native helper: best-effort Codex credit status. Falls back to unavailable when required tools/state are missing.
$ErrorActionPreference = 'SilentlyContinue'

function Unavailable {
  Write-Output 'Codex credits: percentage and renewal unavailable (not exposed by this account).'
  exit 0
}

$codex = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codex) { Unavailable }

# If running in Git Bash/WSL context from Windows, prefer Linux helper via bash when available for accurate parsing.
$bash = Get-Command bash -ErrorAction SilentlyContinue
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sh = Join-Path $scriptDir 'codex-credit-status.sh'
if ($bash -and (Test-Path $sh)) {
  try {
    & bash $sh
    exit $LASTEXITCODE
  } catch { }
}

# Native PowerShell path: attempt lightweight inspection of local session snapshots if jq/python available.
$state = if ($env:CODEX_CREDITS_STATE_DIR) { $env:CODEX_CREDITS_STATE_DIR } elseif ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
$sessions = Join-Path $state 'sessions'
if (-not (Test-Path $sessions)) { Unavailable }

# Without jq/complex parsing parity, report unavailable rather than guessing.
Unavailable
