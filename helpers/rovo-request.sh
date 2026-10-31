#!/usr/bin/env bash
set -euo pipefail
source_path="$(readlink -f -- "${BASH_SOURCE[0]}")"
repo="$(cd -- "$(dirname -- "$source_path")/.." && pwd -P)"
bash "$repo/setup.sh" --request >&2
for instruction in AGENTS.md memory/MEMORY.md MAIL-ROUTING.md GIT-CONFIG-SAFETY.md ATLASSIAN.md rovo/AGENTS.md; do
  printf '\n--- %s ---\n' "$instruction"
  cat -- "$repo/$instruction"
done
