#!/usr/bin/env pwsh
param([Parameter(ValueFromRemainingArguments=$true)][string[]]$Args)
$ErrorActionPreference = 'Stop'
$config = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'ai-agent-config' } else { Join-Path $env:USERPROFILE '.config/ai-agent-config' }
$agents = Join-Path $config 'agents'
if (-not (Test-Path $agents) -or -not (Select-String -Path $agents -SimpleMatch -Pattern 'pplx' -Quiet)) {
  Write-Error 'Enable configured pplx explicitly in the private agents file first.'
  exit 1
}
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repo = (Resolve-Path (Join-Path $scriptDir '..')).Path
$setup = Join-Path $repo 'setup.ps1'
if (Test-Path $setup) { & powershell -NoProfile -ExecutionPolicy Bypass -File $setup --request 1>&2 }
$pplx = Get-Command pplx -ErrorAction SilentlyContinue
if (-not $pplx) { Write-Error 'Configured pplx CLI required.'; exit 1 }
& $pplx.Source @Args
exit $LASTEXITCODE
