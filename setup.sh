#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: bash %s [--backup-existing | --request]\n' "$0"
}
backup_existing=0
request=0
if (($# > 1)); then usage >&2; exit 2; fi
case "${1:-}" in
  '') ;;
  --backup-existing) backup_existing=1 ;;
  --request) request=1 ;;
  --help|-h) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

# Check executable availability only; dependency installation is user-managed.
missing_dependencies=()
active=()
required_missing=0
check_dependency() {
  local executable="$1" purpose="$2" required="${3:-0}"
  if ! command -v "$executable" >/dev/null 2>&1; then
    missing_dependencies+=("$executable: $purpose")
    if ((required)); then required_missing=1; fi
  fi
}
report_dependencies() {
  local status=$? item
  if ((${#missing_dependencies[@]})); then
    printf '\nMissing external dependencies (install manually if needed):\n' >&2
    for item in "${missing_dependencies[@]}"; do printf '  - %s\n' "$item" >&2; done
    printf 'Optional tools are listed even for unselected integrations. No external binaries were installed.\n' >&2
  else
    printf '\nExternal dependency check: all listed executables are available.\n' >&2
  fi
  if [[ -n "${repo:-}" && "$required_missing" == 0 ]]; then
    python3.12 -c 'import sys; sys.path.insert(0, sys.argv.pop(1)); import setup_status; setup_status.report()' \
      "$repo/helpers" "$repo" "$request" "$status" "${active[@]}" >&2 ||
      printf 'Status collection failed; original setup exit status preserved.\n' >&2
  fi
  return "$status"
}
trap report_dependencies EXIT
for utility in dirname cat grep readlink date mv mkdir ln; do
  check_dependency "$utility" 'required by setup and instruction/backup management' 1
done
check_dependency python3.12 'required for Python helpers and instruction setup' 1
check_dependency bash 'shell-based setup, request hooks and wrappers' 1
check_dependency git 'backup-loader tracked-file safety checks and repository operations' 1
check_dependency timeout 'bounded jq-family compatibility probes'
check_dependency node 'Copilot quota SDK helper'
check_dependency npm 'optional fallback for locating the Copilot SDK'
for utility in find sort cut tail awk; do
  check_dependency "$utility" 'Codex quota history lookup or percentage formatting'
done
check_dependency /usr/sbin/sendmail 'local HTML completion-report submission; connector mail may be used instead'
for agent in codex copilot opencode qwen kilo rovo pplx; do
  check_dependency "$agent" "$agent CLI integration (only needed when selected)"
done
if ((required_missing)); then
  printf 'Setup blocked by missing required executables; no setup changes made.\n' >&2
  exit 1
fi

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=helpers/jq-family.sh
source "$repo/helpers/jq-family.sh"
if json_query_init; then
  printf 'JSON backend: %s (required behavior probes passed).\n' "$(json_query_backend)" >&2
else
  missing_dependencies+=('compatible jq/gojq/jaq: JSON parsing unavailable or probes failed')
fi
config="${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config"
if [[ -f "$config/twg-bin" ]]; then
  twg_dependency="$(cat -- "$config/twg-bin")"
  if [[ "$twg_dependency" != /* || "$twg_dependency" == *$'\n'* || ! -f "$twg_dependency" || ! -x "$twg_dependency" ]]; then
    missing_dependencies+=('configured standalone TWG executable: Teamwork Graph CLI integration; review the private twg-bin setting')
  fi
fi

# Keep the caller's working directory for task-repository identity resolution.
[[ -f "$repo/MAIL-ROUTING.md" ]] || { printf 'Missing shared mail policy.\n' >&2; exit 1; }
printf 'Calling agent: apply this policy during setup; client configuration remains pending until verified.\n' >&2
cat -- "$repo/MAIL-ROUTING.md" >&2
cat -- "$repo/GIT-CONFIG-SAFETY.md" >&2

selected() {
  local agent="$1"
  if [[ -f "$config/agents" ]]; then
    grep -Fxq -- "$agent" "$config/agents"
    return
  fi
  case "$agent" in
    codex) command -v codex >/dev/null 2>&1 && [[ -f "${CODEX_HOME:-$HOME/.codex}/config.toml" ]] ;;
    copilot) command -v copilot >/dev/null 2>&1 && [[ -f "${COPILOT_HOME:-$HOME/.copilot}/config.json" ]] ;;
    opencode) command -v opencode >/dev/null 2>&1 && [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.json" || -f "${XDG_CONFIG_HOME:-$HOME/.config}/opencode/opencode.jsonc" ]] ;;
    qwen) command -v qwen >/dev/null 2>&1 && [[ -f "$HOME/.qwen/settings.json" ]] ;;
    kilo) command -v kilo >/dev/null 2>&1 || [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/kilo/kilo.json" || -f "${XDG_CONFIG_HOME:-$HOME/.config}/kilo/kilo.jsonc" ]] ;;
    rovo) command -v rovo >/dev/null 2>&1 && [[ -f "$HOME/.rovo/config.yml" ]] ;;
    twg) [[ -f "$config/twg-bin" ]] ;;
    vscode) [[ -d "$HOME/.vscode-server/data/User" ]] ;;
    *) return 1 ;;
  esac
}

link_file() {
  local source="$1" target="$2" backup suffix
  [[ -f "$source" ]] || { printf 'Missing source: %s\n' "$source" >&2; return 1; }
  if [[ -L "$target" && "$(readlink -f -- "$target" || true)" == "$source" ]]; then return; fi
  if [[ -e "$target" || -L "$target" ]]; then
    if ((backup_existing == 0)); then
      printf 'Refusing to replace %s; review it and use --backup-existing if appropriate.\n' "$target" >&2
      return 1
    fi
    backup="${target}.backup.$(date '+%Y%m%d%H%M%S')"
    suffix=0
    while [[ -e "$backup.$suffix" || -L "$backup.$suffix" ]]; do ((suffix += 1)); done
    mv -- "$target" "$backup.$suffix"
  fi
  mkdir -p -- "$(dirname -- "$target")"
  ln -s -- "$source" "$target"
}

link_instruction() {
  link_file "$1" "$2"
  python3.12 "$repo/helpers/write-backup-loader.py" --source "$1" --target "$2"
  printf 'Calling agent: whenever reading %s, read its adjacent .local-overrides.md loader and listed private instruction backups; apply the backup policy in memory/MEMORY.md. Client loading is not verified by setup.\n' "$2" >&2
}

for agent in codex copilot opencode qwen kilo rovo twg vscode perplexity pplx; do
  if selected "$agent"; then active+=("$agent"); fi
done
if ((${#active[@]} == 0)); then
  printf 'No configured agents detected; no managed links changed; status summary follows.\n' >&2
  exit 0
fi

if ((request == 0)); then
  command -v python3.12 >/dev/null 2>&1 || { printf 'Python 3.12 required.\n' >&2; exit 1; }
  python3.12 -m pip install --user --disable-pip-version-check --requirement "$repo/requirements.txt"
fi

for agent in "${active[@]}"; do
  case "$agent" in
    codex|copilot|opencode|qwen|kilo|rovo|pplx)
      command -v "$agent" >/dev/null 2>&1 || {
        printf 'Selected agent %s has no executable; skipping.\n' "$agent" >&2
        continue
      }
      ;;
  esac
  case "$agent" in
    codex)
      link_instruction "$repo/codex/AGENTS.md" "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"
      link_file "$repo/helpers/codex-credit-status.sh" "$HOME/code/.codex-tools/codex-credit-status.sh"
      ;;
    copilot)
      link_instruction "$repo/copilot/copilot-instructions.md" "${COPILOT_HOME:-$HOME/.copilot}/copilot-instructions.md"
      link_file "$repo/helpers/copilot-credit-status.sh" "$HOME/code/.codex-tools/copilot-credit-status.sh"
      link_file "$repo/helpers/copilot-credit-status.mjs" "$HOME/code/.codex-tools/copilot-credit-status.mjs"
      ;;
    opencode)
      source "$repo/helpers/opencode-setup.sh"
      setup_opencode "$repo" "$request"
      ;;
    qwen)
      link_instruction "$repo/qwen/QWEN.md" "$HOME/.qwen/QWEN.md"
      ;;
    kilo)
      link_instruction "$repo/kilo/AGENTS.md" "${XDG_CONFIG_HOME:-$HOME/.config}/kilo/AGENTS.md"
      ;;
    rovo)
      cat -- "$repo/ATLASSIAN.md" >&2
      link_instruction "$repo/rovo/AGENTS.md" "$HOME/.rovo/AGENTS.md"
      link_file "$repo/helpers/rovo-request.sh" "$HOME/code/.codex-tools/rovo-request.sh"
      ;;
    twg)
      cat -- "$repo/ATLASSIAN.md" >&2
      mode=request
      if ((request == 0)); then mode=initial; fi
      bash "$repo/helpers/twg-setup.sh" "$mode"
      ;;
    vscode)
      legacy="$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md"
      if [[ -L "$legacy" && "$(readlink -f -- "$legacy" || true)" == "$repo/vscode/global-codex-preferences.instructions.md" ]]; then
        ln -sfn -- "$repo/instructions/global-preferences.instructions.md" "$legacy"
      fi
      link_instruction "$repo/instructions/global-preferences.instructions.md" "$legacy"
      ;;
    perplexity)
      link_instruction "$repo/perplexity/AGENTS.md" "$config/perplexity/AGENTS.md"
      ;;
    pplx)
      link_file "$repo/helpers/perplexity-search.sh" "$HOME/code/.codex-tools/perplexity-search.sh"
      ;;
  esac
  if [[ "$agent" != pplx && "$agent" != twg ]]; then
    for helper in track_agent_usage.py send-completion-report.py test_completion_report.py; do
      link_file "$repo/helpers/$helper" "$HOME/code/.codex-tools/$helper"
    done
  fi
  if ((request == 0)) && [[ "$agent" == codex || "$agent" == copilot || "$agent" == qwen ]]; then
    python3.12 "$repo/helpers/install-request-hooks.py" --agent "$agent" --repo "$repo"
  fi
done
printf 'Setup links complete; the calling agent must apply shared policies and verify client configuration separately.\n' >&2
