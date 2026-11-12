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
repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
config="${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config"

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

active=()
for agent in codex copilot opencode qwen rovo twg vscode perplexity pplx; do
  if selected "$agent"; then active+=("$agent"); fi
done
if ((${#active[@]} == 0)); then
  printf 'No configured agents detected; nothing changed.\n' >&2
  exit 0
fi

if ((request == 0)); then
  command -v python3.12 >/dev/null 2>&1 || { printf 'Python 3.12 required.\n' >&2; exit 1; }
  python3.12 -m pip install --user --disable-pip-version-check --requirement "$repo/requirements.txt"
fi

for agent in "${active[@]}"; do
  case "$agent" in
    codex|copilot|opencode|qwen|rovo|pplx)
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
      setup_opencode
      ;;
    qwen)
      link_instruction "$repo/qwen/QWEN.md" "$HOME/.qwen/QWEN.md"
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
