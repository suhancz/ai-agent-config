#!/usr/bin/env bash
set -euo pipefail

command -v copilot >/dev/null 2>&1 || {
  printf 'GitHub Copilot CLI is required to read Copilot credits.\n' >&2
  exit 127
}
command -v node >/dev/null 2>&1 || {
  printf 'Node.js is required to read Copilot credits.\n' >&2
  exit 127
}

copilot_path="$(readlink -f "$(command -v copilot)")"
copilot_prefix="$(dirname "$(dirname "$copilot_path")")"
sdk_entry="$copilot_prefix/lib/node_modules/@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js"
if [[ ! -r "$sdk_entry" ]] && command -v npm >/dev/null 2>&1; then
  sdk_entry="$(npm root -g)/@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js"
fi
if [[ ! -r "$sdk_entry" ]]; then
  printf 'The Copilot CLI SDK quota API is unavailable at the installed CLI path.\n' >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
node "$script_dir/copilot-credit-status.mjs" "$sdk_entry"
