#!/usr/bin/env pwsh
param(
  [Parameter(Mandatory=$true)][string]$Repo,
  [Parameter(Mandatory=$true)][int]$Request
)
$ErrorActionPreference = 'Stop'
function Link-FileSafe([string]$Source,[string]$Target,[switch]$BackupExisting) {
  if (-not (Test-Path $Source)) { throw "Missing source: $Source" }
  $src = (Resolve-Path $Source).Path
  if (Test-Path $Target) {
    $item = Get-Item $Target -Force
    $resolved = try { (Resolve-Path $Target).Path } catch { '' }
    if ($item.LinkType -and $resolved -eq $src) { return }
    if (-not $BackupExisting) { throw "Refusing to replace $Target; review it and use -BackupExisting if appropriate." }
    $backup = "$Target.backup.$([DateTime]::UtcNow.ToString('yyyyMMddHHmmss'))"
    $i=0; while (Test-Path "$backup.$i") { $i++ }
    Move-Item -Force $Target "$backup.$i"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
  try { New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null }
  catch { New-Item -ItemType HardLink -Path $Target -Target $Source -Force | Out-Null }
}
function Link-Instruction([string]$Source,[string]$Target) {
  Link-FileSafe -Source $Source -Target $Target
  $py = Get-Command python3.12 -ErrorAction SilentlyContinue; if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
  if (-not $py) { throw 'Python required for backup loader generation.' }
  & $py.Source (Join-Path $Repo 'helpers/write-backup-loader.py') --source $Source --target $Target
}
$family = $null
$verPy = Join-Path $Repo 'helpers/opencode-version.py'
$verPs1 = Join-Path $Repo 'helpers/opencode-version.ps1'
$py = Get-Command python3.12 -ErrorAction SilentlyContinue; if (-not $py) { $py = Get-Command python -ErrorAction SilentlyContinue }
if ($py) {
  $family = (& $py.Source $verPy 2>$null)
  if ($LASTEXITCODE -ne 0) { $family = $null }
  if ($family) { $family = $family.Trim() }
}
if (-not $family -and (Test-Path $verPs1)) { $family = (& powershell -NoProfile -ExecutionPolicy Bypass -File $verPs1).Trim() }
if (-not $family) { throw 'OpenCode version detection failed.' }
$configDir = if ($env:XDG_CONFIG_HOME) { Join-Path $env:XDG_CONFIG_HOME 'opencode' } else { Join-Path $env:USERPROFILE '.config/opencode' }
if ($env:OPENCODE_CONFIG_DIR) { throw 'Custom OPENCODE_CONFIG_DIR requires verified discovery support; refusing automatic setup.' }
$pluginDir = Join-Path $configDir 'plugins'
$v1Target = Join-Path $pluginDir 'ai-agent-config.js'
$v2Target = Join-Path $pluginDir 'ai-agent-config/index.js'
if ($family -eq '1') { $wanted=$v1Target; $stale=$v2Target; $source=(Join-Path $Repo 'opencode/v1.js') }
else { $wanted=$v2Target; $stale=$v1Target; $source=(Join-Path $Repo 'opencode/v2.js') }
if ($Request -ne 0) {
  if (-not (Test-Path $wanted)) { throw 'OpenCode hook missing or API family changed; rerun initial setup and restart OpenCode.' }
  $item = Get-Item $wanted -Force
  $resolved = try { (Resolve-Path $wanted).Path } catch { '' }
  $src = (Resolve-Path $source).Path
  if (-not $item.LinkType -or $resolved -ne $src) { throw 'OpenCode hook missing or API family changed; rerun initial setup and restart OpenCode.' }
} else {
  if (Test-Path $stale) {
    $staleItem = Get-Item $stale -Force
    $staleResolved = try { (Resolve-Path $stale).Path } catch { '' }
    $ok = $false
    if ($staleItem.LinkType) {
      $v1=(Resolve-Path (Join-Path $Repo 'opencode/v1.js')).Path; $v2=(Resolve-Path (Join-Path $Repo 'opencode/v2.js')).Path
      if ($staleResolved -eq $v1 -or $staleResolved -eq $v2) { $ok=$true }
    }
    if (-not $ok) { throw 'Conflicting inactive OpenCode hook; review it manually before migration.' }
    Link-FileSafe -Source $source -Target $wanted
    Remove-Item -Force $stale
  } else {
    Link-FileSafe -Source $source -Target $wanted
  }
}
Link-Instruction -Source (Join-Path $Repo 'opencode/AGENTS.md') -Target (Join-Path $configDir 'AGENTS.md')
[Console]::Error.WriteLine("OpenCode API family $family selected; restart and verify prompt-hook loading.")
