#!/usr/bin/env bash
set -euo pipefail
config="${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config"
if [[ ! -f "$config/agents" ]] || ! grep -Fxq pplx "$config/agents"; then
  printf 'Enable configured pplx explicitly in the private agents file first.\n' >&2
  exit 1
fi
repo="$(cd -- "$(dirname -- "$(readlink -f -- "${BASH_SOURCE[0]}")")/.." && pwd -P)"
bash "$repo/setup.sh" --request >&2
command -v pplx >/dev/null 2>&1 || { printf 'Configured pplx CLI required.\n' >&2; exit 1; }
exec pplx "$@"
