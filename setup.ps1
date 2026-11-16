#!/usr/bin/env pwsh
param(
  [switch]$BackupExisting,
  [switch]$Request,
  [switch]$Help
)
$ErrorActionPreference = 'Stop'

function Usage {
  Write-Output "Usage: pwsh ./setup.ps1 [--backup-existing | --request]"
}

if ($Help) { Usage; exit 0 }
if ($BackupExisting -and $Request) { Usage; [Console]::Error.WriteLine('Choose at most one mode.'); exit 2 }

$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
try { $repo = (Resolve-Path $repo).Path } catch {}
$configHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $env:USERPROFILE '.config' }
$configDir = Join-Path $configHome 'ai-agent-config'
$backupExistingMode = [bool]$BackupExisting
$requestMode = [bool]$Request

$missing = @()
$requiredMissing = $false
function Check-Dep([string]$Name,[string]$Purpose,[bool]$Required=$false) {
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    $script:missing += "${Name}: $Purpose"
    if ($Required) { $script:requiredMissing = $true }
  }
}

foreach ($u in @('git','python','python3.12')) { }
Check-Dep 'git' 'required for backup-loader tracked-file safety checks and repository operations' $true
$pyCmd = Get-Command python3.12 -ErrorAction SilentlyContinue
if (-not $pyCmd) { $pyCmd = Get-Command python -ErrorAction SilentlyContinue }
if (-not $pyCmd) { $missing += 'python3.12/python: required for Python helpers and instruction setup'; $requiredMissing = $true }
foreach ($a in @('codex','copilot','opencode','qwen','kilo','rovo','pplx','wsl')) {
  Check-Dep $a "$a integration (only needed when selected or for WSL-shared setup)" $false
}

function Get-DefaultWslDistro {
  $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
  if (-not $wsl) { $wsl = Get-Command wsl -ErrorAction SilentlyContinue }
  if (-not $wsl) { return $null }
  try {
    $raw = & $wsl.Source -l -q 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $raw) { return $null }
    # wsl.exe may emit UTF-16 with NULs; normalize
    $text = ($raw | Out-String) -replace "`0", ""
    $lines = $text -split "(`r`n|`n|`r)" | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' }
    if ($lines.Count -gt 0) { return $lines[0] }
  } catch { }
  return $null
}

function Get-WslDistroFromPath([string]$Path) {
  if ($Path -match '^\\\\wsl\.localhost\\([^\\]+)\\') { return $Matches[1] }
  if ($Path -match '^\\\\wsl\$\\([^\\]+)\\') { return $Matches[1] }
  return $null
}

function Convert-WslUncToLinuxPath([string]$Path) {
  if ($Path -match '^\\\\wsl\.localhost\\[^\\]+\\(.+)$') { return '/' + ($Matches[1] -replace '\\','/') }
  if ($Path -match '^\\\\wsl\$\\[^\\]+\\(.+)$') { return '/' + ($Matches[1] -replace '\\','/') }
  return $null
}

function Invoke-WslLinuxSetup([string]$Distro,[string]$LinuxRepoPath) {
  $wsl = Get-Command wsl.exe -ErrorAction SilentlyContinue
  if (-not $wsl) { $wsl = Get-Command wsl -ErrorAction SilentlyContinue }
  if (-not $wsl) { throw 'WSL executable not found.' }
  $modeArg = if ($script:requestMode) { '--request' } elseif ($script:backupExistingMode) { '--backup-existing' } else { '' }
  $cmd = "cd '$LinuxRepoPath' && bash ./setup.sh $modeArg"
  [Console]::Error.WriteLine("Running Linux setup in WSL distro '$Distro': $cmd")
  & $wsl.Source -d $Distro -- bash -lc $cmd
  if ($LASTEXITCODE -ne 0) { throw "WSL Linux setup failed with exit code $LASTEXITCODE" }
}

function Test-Selected([string]$Agent) {
  $agentsFile = Join-Path $configDir 'agents'
  if (Test-Path $agentsFile) {
    return (Select-String -Path $agentsFile -SimpleMatch -Pattern $Agent -Quiet)
  }
  switch ($Agent) {
    'codex' { return ((Get-Command codex -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $env:USERPROFILE '.codex/config.toml'))) }
    'copilot' { $h = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE '.copilot' }; return ((Get-Command copilot -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $h 'config.json'))) }
    'opencode' { $d = Join-Path $configHome 'opencode'; return ((Get-Command opencode -ErrorAction SilentlyContinue) -and ((Test-Path (Join-Path $d 'opencode.json')) -or (Test-Path (Join-Path $d 'opencode.jsonc')))) }
    'qwen' { return ((Get-Command qwen -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $env:USERPROFILE '.qwen/settings.json'))) }
    'kilo' { $d = Join-Path $configHome 'kilo'; return ((Get-Command kilo -ErrorAction SilentlyContinue) -or (Test-Path (Join-Path $d 'kilo.json')) -or (Test-Path (Join-Path $d 'kilo.jsonc'))) }
    'rovo' { return ((Get-Command rovo -ErrorAction SilentlyContinue) -and (Test-Path (Join-Path $env:USERPROFILE '.rovo/config.yml'))) }
    'twg' { return (Test-Path (Join-Path $configDir 'twg-bin')) }
    'vscode' { return (Test-Path (Join-Path $env:USERPROFILE '.vscode-server/data/User')) }
    default { return $false }
  }
}

function Link-FileManaged([string]$Source,[string]$Target) {
  if (-not (Test-Path $Source)) { throw "Missing source: $Source" }
  $src = (Resolve-Path $Source).Path
  if (Test-Path $Target) {
    $item = Get-Item $Target -Force
    $resolved = try { (Resolve-Path $Target).Path } catch { '' }
    if ($item.LinkType -and $resolved -eq $src) { return }
    if (-not $backupExistingMode) {
      throw "Refusing to replace $Target; review it and use --backup-existing if appropriate."
    }
    $stamp = [DateTime]::UtcNow.ToString('yyyyMMddHHmmss')
    $backup = "${Target}.backup.$stamp"
    $i = 0
    while (Test-Path "$backup.$i") { $i++ }
    Move-Item -Force $Target "$backup.$i"
  }
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
  try {
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
  } catch {
    # Fallback for environments without symlink privilege: hardlink for files, junction/copy not used for files
    New-Item -ItemType HardLink -Path $Target -Target $Source -Force | Out-Null
  }
}

function Link-InstructionManaged([string]$Source,[string]$Target) {
  Link-FileManaged -Source $Source -Target $Target
  & $pyCmd.Source (Join-Path $sourceRepo 'helpers/write-backup-loader.py') --source $Source --target $Target
  [Console]::Error.WriteLine("Calling agent: whenever reading $Target, read its adjacent .local-overrides.md loader and listed private instruction backups; apply the backup policy in memory/MEMORY.md. Client loading is not verified by setup.")
}

if ($requiredMissing) {
  foreach ($m in $missing) { [Console]::Error.WriteLine("  - $m") }
  [Console]::Error.WriteLine('Setup blocked by missing required executables; no setup changes made.')
  exit 1
}
if ($missing.Count -gt 0) {
  [Console]::Error.WriteLine('Missing external dependencies (install manually if needed):')
  foreach ($m in $missing) { [Console]::Error.WriteLine("  - $m") }
}

# WSL-shared-on-Windows: if running from a WSL UNC checkout and WSL is available,
# run Linux setup in the default/selected distro first, then continue with Windows-side links.
# AI_AGENT_CONFIG_NO_WSL_CALLBACK prevents infinite cross-calls when invoked from Linux setup.sh.
$wslDistroFromPath = Get-WslDistroFromPath $repo
$defaultWslDistro = Get-DefaultWslDistro
$wslDistro = if ($wslDistroFromPath) { $wslDistroFromPath } elseif ($defaultWslDistro) { $defaultWslDistro } else { $null }
$linuxRepoPath = Convert-WslUncToLinuxPath $repo
if ($env:AI_AGENT_CONFIG_NO_WSL_CALLBACK -ne '1') {
  if ($wslDistro -and $linuxRepoPath -and (Get-Command wsl -ErrorAction SilentlyContinue)) {
    try {
      Invoke-WslLinuxSetup -Distro $wslDistro -LinuxRepoPath $linuxRepoPath
    } catch {
      [Console]::Error.WriteLine("WSL-shared setup warning: $($_.Exception.Message)")
    }
  }
}
# Prefer canonical WSL UNC source paths for Windows-side links when known.
$wslUncRepo = $null
if ($wslDistro -and $linuxRepoPath) {
  $wslUncRepo = "\\wsl.localhost\$wslDistro" + ($linuxRepoPath -replace '/','\')
  if (-not (Test-Path $wslUncRepo)) { $wslUncRepo = $null }
}
$sourceRepo = if ($wslUncRepo) { $wslUncRepo } else { $repo }

$mail = Join-Path $repo 'MAIL-ROUTING.md'
$gitSafety = Join-Path $repo 'GIT-CONFIG-SAFETY.md'
if (-not (Test-Path $mail)) { [Console]::Error.WriteLine('Missing shared mail policy.'); exit 1 }
[Console]::Error.WriteLine('Calling agent: apply this policy during setup; client configuration remains pending until verified.')
[Console]::Error.WriteLine((Get-Content -Raw -Encoding UTF8 $mail))
[Console]::Error.WriteLine((Get-Content -Raw -Encoding UTF8 $gitSafety))

$active = @()
foreach ($agent in @('codex','copilot','opencode','qwen','kilo','rovo','twg','vscode','perplexity','pplx')) {
  if (Test-Selected $agent) { $active += $agent }
}
if ($active.Count -eq 0) {
  [Console]::Error.WriteLine('No configured agents detected; no managed links changed.')
  exit 0
}

if (-not $requestMode) {
  & $pyCmd.Source -m pip install --user --disable-pip-version-check --requirement (Join-Path $sourceRepo 'requirements.txt')
}

$toolsDir = Join-Path $env:USERPROFILE 'code/.codex-tools'
New-Item -ItemType Directory -Force -Path $toolsDir | Out-Null

foreach ($agent in $active) {
  switch ($agent) {
    'codex' {
      $homeDir = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $env:USERPROFILE '.codex' }
      Link-InstructionManaged (Join-Path $sourceRepo 'codex/AGENTS.md') (Join-Path $homeDir 'AGENTS.md')
      Link-FileManaged (Join-Path $sourceRepo 'helpers/codex-credit-status.sh') (Join-Path $toolsDir 'codex-credit-status.sh')
      if (Test-Path (Join-Path $sourceRepo 'helpers/codex-credit-status.ps1')) { Link-FileManaged (Join-Path $sourceRepo 'helpers/codex-credit-status.ps1') (Join-Path $toolsDir 'codex-credit-status.ps1') }
    }
    'copilot' {
      $homeDir = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $env:USERPROFILE '.copilot' }
      Link-InstructionManaged (Join-Path $sourceRepo 'copilot/copilot-instructions.md') (Join-Path $homeDir 'copilot-instructions.md')
      Link-FileManaged (Join-Path $sourceRepo 'helpers/copilot-credit-status.sh') (Join-Path $toolsDir 'copilot-credit-status.sh')
      Link-FileManaged (Join-Path $sourceRepo 'helpers/copilot-credit-status.mjs') (Join-Path $toolsDir 'copilot-credit-status.mjs')
      if (Test-Path (Join-Path $sourceRepo 'helpers/copilot-credit-status.ps1')) { Link-FileManaged (Join-Path $sourceRepo 'helpers/copilot-credit-status.ps1') (Join-Path $toolsDir 'copilot-credit-status.ps1') }
    }
    'opencode' {
      $mode = if ($requestMode) { 1 } else { 0 }
      & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $sourceRepo 'helpers/opencode-setup.ps1') -Repo $sourceRepo -Request $mode
    }
    'qwen' {
      Link-InstructionManaged (Join-Path $sourceRepo 'qwen/QWEN.md') (Join-Path $env:USERPROFILE '.qwen/QWEN.md')
    }
    'kilo' {
      Link-InstructionManaged (Join-Path $sourceRepo 'kilo/AGENTS.md') (Join-Path $configHome 'kilo/AGENTS.md')
    }
    'rovo' {
      [Console]::Error.WriteLine((Get-Content -Raw -Encoding UTF8 (Join-Path $sourceRepo 'ATLASSIAN.md')))
      Link-InstructionManaged (Join-Path $sourceRepo 'rovo/AGENTS.md') (Join-Path $env:USERPROFILE '.rovo/AGENTS.md')
      Link-FileManaged (Join-Path $sourceRepo 'helpers/rovo-request.sh') (Join-Path $toolsDir 'rovo-request.sh')
      if (Test-Path (Join-Path $sourceRepo 'helpers/rovo-request.ps1')) { Link-FileManaged (Join-Path $sourceRepo 'helpers/rovo-request.ps1') (Join-Path $toolsDir 'rovo-request.ps1') }
    }
    'twg' {
      [Console]::Error.WriteLine((Get-Content -Raw -Encoding UTF8 (Join-Path $sourceRepo 'ATLASSIAN.md')))
      $m = if ($requestMode) { 'request' } else { 'initial' }
      & powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $sourceRepo 'helpers/twg-setup.ps1') -Mode $m
    }
    'vscode' {
      $legacy = Join-Path $env:USERPROFILE '.vscode-server/data/User/instructions/global-codex-preferences.instructions.md'
      if (Test-Path $legacy) {
        # best-effort legacy repoint handled by link below
      }
      Link-InstructionManaged (Join-Path $sourceRepo 'instructions/global-preferences.instructions.md') $legacy
    }
    'perplexity' {
      Link-InstructionManaged (Join-Path $sourceRepo 'perplexity/AGENTS.md') (Join-Path $configDir 'perplexity/AGENTS.md')
    }
    'pplx' {
      Link-FileManaged (Join-Path $sourceRepo 'helpers/perplexity-search.sh') (Join-Path $toolsDir 'perplexity-search.sh')
      if (Test-Path (Join-Path $sourceRepo 'helpers/perplexity-search.ps1')) { Link-FileManaged (Join-Path $sourceRepo 'helpers/perplexity-search.ps1') (Join-Path $toolsDir 'perplexity-search.ps1') }
    }
  }
  if ($agent -ne 'pplx' -and $agent -ne 'twg') {
    foreach ($helper in @('track_agent_usage.py','send-completion-report.py','test_completion_report.py')) {
      $h = Join-Path $sourceRepo "helpers/$helper"
      if (Test-Path $h) { Link-FileManaged $h (Join-Path $toolsDir $helper) }
    }
  }
  if (-not $requestMode -and ($agent -eq 'codex' -or $agent -eq 'copilot' -or $agent -eq 'qwen')) {
    & $pyCmd.Source (Join-Path $sourceRepo 'helpers/install-request-hooks.py') --agent $agent --repo $sourceRepo
  }
}

[Console]::Error.WriteLine('Setup links complete; the calling agent must apply shared policies and verify client configuration separately.')
