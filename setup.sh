#!/usr/bin/env bash
set -euo pipefail

usage() {
  printf 'Usage: %s [--backup-existing]\n' "$0"
}

backup_existing=0
if (($# > 1)); then
  usage >&2
  exit 2
fi
if (($# == 1)); then
  if [[ "$1" == '--backup-existing' ]]; then
    backup_existing=1
  elif [[ "$1" == '--help' || "$1" == '-h' ]]; then
    usage
    exit 0
  else
    usage >&2
    exit 2
  fi
fi

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

if ! command -v python3.12 >/dev/null 2>&1; then
  printf 'Python 3.12 is required to install the repository requirements.\n' >&2
  exit 1
fi
if ! python3.12 -m pip --version >/dev/null 2>&1; then
  printf 'Python 3.12 pip is required to install requirements.txt.\n' >&2
  exit 1
fi

python3.12 -m pip install --user --disable-pip-version-check \
  --requirement "$repo/requirements.txt"

link_file() {
  local source="$1"
  local target="$2"
  local existing backup stamp suffix

  if [[ ! -f "$source" ]]; then
    printf 'Missing source file: %s\n' "$source" >&2
    return 1
  fi

  mkdir -p -- "$(dirname -- "$target")"

  if [[ -L "$target" ]]; then
    existing="$(readlink -f -- "$target" || true)"
    if [[ "$existing" == "$source" ]]; then
      printf 'Already linked: %s\n' "$target"
      return 0
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    if ((backup_existing == 0)); then
      printf 'Refusing to replace existing path: %s (use --backup-existing)\n' "$target" >&2
      return 1
    fi

    stamp="$(date '+%Y%m%d%H%M%S')"
    backup="${target}.backup.${stamp}"
    suffix=1
    while [[ -e "$backup" || -L "$backup" ]]; do
      backup="${target}.backup.${stamp}.${suffix}"
      ((suffix += 1))
    done
    mv -- "$target" "$backup"
    printf 'Backed up: %s\n' "$backup"
  fi

  ln -s -- "$source" "$target"
  printf 'Linked: %s\n' "$target"
}

missing=()
for command_name in jq awk date find sort cut tail readlink codex copilot node npm; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    missing+=("$command_name")
  fi
done
if [[ ! -x /usr/sbin/sendmail ]]; then
  missing+=("/usr/sbin/sendmail")
fi
if ((${#missing[@]})); then
  printf 'Missing optional runtime dependencies (install with the appropriate OS/CLI package manager): %s\n' \
    "$(IFS=', '; printf '%s' "${missing[*]}")" >&2
fi

link_file "$repo/codex/AGENTS.md" "$HOME/.codex/AGENTS.md"
link_file "$repo/copilot/copilot-instructions.md" "$HOME/.copilot/copilot-instructions.md"
link_file "$repo/vscode/global-codex-preferences.instructions.md" \
  "$HOME/.vscode-server/data/User/instructions/global-codex-preferences.instructions.md"
link_file "$repo/helpers/codex-credit-status.sh" "$HOME/code/.codex-tools/codex-credit-status.sh"
link_file "$repo/helpers/copilot-credit-status.sh" "$HOME/code/.codex-tools/copilot-credit-status.sh"
link_file "$repo/helpers/send-completion-report.py" "$HOME/code/.codex-tools/send-completion-report.py"
link_file "$repo/helpers/test_completion_report.py" "$HOME/code/.codex-tools/test_completion_report.py"
