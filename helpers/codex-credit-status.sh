#!/usr/bin/env bash

set -euo pipefail

codex_state_dir="${CODEX_CREDITS_STATE_DIR:-${CODEX_HOME:-${HOME}/.codex}}"
sessions_dir="${codex_state_dir}/sessions"
display_timezone="${CODEX_CREDITS_TIMEZONE:-Europe/Budapest}"

unavailable() {
  printf '%s\n' 'Codex credits: percentage and renewal unavailable (not exposed by this account).'
}

if [[ ! -d "${sessions_dir}" ]] || ! command -v jq >/dev/null 2>&1; then
  unavailable
  exit 0
fi

rate_limits=''

# Prefer the authenticated app-server snapshot. It uses Codex's existing cached
# ChatGPT login and never reads or prints the credential file itself.
if command -v codex >/dev/null 2>&1; then
  coproc credit_app_server { codex app-server --stdio 2>/dev/null; }
  app_server_pid="$!"

  printf '%s\n' \
    '{"id":1,"method":"initialize","params":{"clientInfo":{"name":"codex-credit-status","version":"1.0.0"},"capabilities":null}}' \
    '{"id":2,"method":"account/rateLimits/read","params":null}' \
    >&"${credit_app_server[1]}"

  while IFS= read -r -t 20 app_server_line <&"${credit_app_server[0]}"; do
    rate_limits="$(
      jq -c 'select(.id == 2 and .result.rateLimits? != null) | .result.rateLimits' \
        <<<"${app_server_line}" 2>/dev/null || true
    )"

    if [[ -n "${rate_limits}" ]]; then
      break
    fi
  done

  kill "${app_server_pid}" 2>/dev/null || true
  wait "${app_server_pid}" 2>/dev/null || true
fi

# Fall back to the newest locally recorded snapshot when app-server access is
# unavailable (for example, inside a restricted sandbox).
while IFS= read -r session_file; do
  if [[ -n "${rate_limits}" ]]; then
    break
  fi

  rate_limits="$({
    jq -c 'select(.payload.rate_limits? != null) | .payload.rate_limits' "${session_file}" 2>/dev/null || true
  } | tail -n 1)"

  if [[ -n "${rate_limits}" ]]; then
    break
  fi
done < <(
  find "${sessions_dir}" -type f -name '*.jsonl' -printf '%T@ %p\n' 2>/dev/null \
    | sort -nr \
    | cut -d' ' -f2-
)

if [[ -z "${rate_limits}" ]]; then
  unavailable
  exit 0
fi

if [[ "$(jq -r '.credits.unlimited // false' <<<"${rate_limits}")" == 'true' ]]; then
  printf '%s\n' 'Codex credits: unlimited; no renewal date applies.'
  exit 0
fi

format_number() {
  awk -v value="$1" 'BEGIN {
    if (value == int(value)) printf "%d", value;
    else printf "%.1f", value;
  }'
}

format_reset() {
  local reset_epoch="$1"

  if [[ -z "${reset_epoch}" || "${reset_epoch}" == 'null' ]]; then
    printf '%s' 'renewal unknown'
    return
  fi

  TZ="${display_timezone}" date -d "@${reset_epoch}" '+renews %Y-%m-%d %H:%M %Z' 2>/dev/null \
    || printf '%s' 'renewal unknown'
}

window_label() {
  case "$1" in
    300) printf '%s' '5-hour' ;;
    10080) printf '%s' 'weekly' ;;
    null|'') printf '%s' 'usage window' ;;
    *) printf '%s-minute' "$1" ;;
  esac
}

parts=()

individual_remaining="$(jq -r '.individualLimit.remainingPercent // .individual_limit.remaining_percent // empty' <<<"${rate_limits}")"
if [[ -n "${individual_remaining}" ]]; then
  individual_reset="$(jq -r '.individualLimit.resetsAt // .individual_limit.resets_at // empty' <<<"${rate_limits}")"
  parts+=("Business individual limit $(format_number "${individual_remaining}")% remaining ($(format_reset "${individual_reset}"))")
fi

for window in primary secondary; do
  used_percent="$(jq -r --arg window "${window}" '.[$window].usedPercent // .[$window].used_percent // empty' <<<"${rate_limits}")"
  if [[ -z "${used_percent}" ]]; then
    continue
  fi

  remaining_percent="$(awk -v used="${used_percent}" 'BEGIN {
    remaining = 100 - used;
    if (remaining < 0) remaining = 0;
    if (remaining > 100) remaining = 100;
    print remaining;
  }')"
  window_minutes="$(jq -r --arg window "${window}" '.[$window].windowMinutes // .[$window].window_minutes // empty' <<<"${rate_limits}")"
  reset_epoch="$(jq -r --arg window "${window}" '.[$window].resetsAt // .[$window].resets_at // .[$window].reset_at // empty' <<<"${rate_limits}")"

  parts+=("$(window_label "${window_minutes}") $(format_number "${remaining_percent}")% remaining ($(format_reset "${reset_epoch}"))")
done

if (( ${#parts[@]} == 0 )); then
  unavailable
  exit 0
fi

joined="${parts[0]}"
for ((index = 1; index < ${#parts[@]}; index++)); do
  joined+="; ${parts[index]}"
done

printf 'Codex credits: %s.\n' "${joined}"
