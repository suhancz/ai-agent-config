#!/usr/bin/env bash
set -euo pipefail
mode="${1:-request}"
case "$mode" in initial|request) ;; *) exit 2 ;; esac
config="${XDG_CONFIG_HOME:-$HOME/.config}/ai-agent-config"
if [[ ! -f "$config/twg-bin" ]]; then
  printf 'TWG pending: configure an approved standalone binary in the private twg-bin file.\n' >&2
  exit 0
fi
twg_bin="$(cat -- "$config/twg-bin")"
if [[ "$twg_bin" != /* || "$twg_bin" == *$'\n'* || ! -f "$twg_bin" || ! -x "$twg_bin" ]]; then
  printf 'TWG skipped: private twg-bin must name one executable absolute path.\n' >&2
  exit 1
fi
resolved="$(readlink -f -- "$twg_bin")"
case "$resolved" in
  */.rovo/*|*/.rovodev/*)
    printf 'TWG skipped: do not independently manage a Rovo-bundled binary.\n' >&2
    exit 1
    ;;
esac
if [[ "$mode" == initial ]]; then
  "$twg_bin" skills install --global
  "$twg_bin" doctor
else
  printf 'Standalone TWG selected; request mode does not install skills or start login.\n' >&2
fi
