# shellcheck shell=bash
# Sourced-only adapter: all repository jq consumers must use json_query.
JSON_QUERY_BIN=''
JSON_QUERY_IMPLEMENTATION=''
json_query_init() {
  local candidate result version
  [[ -z "$JSON_QUERY_BIN" ]] || return 0
  command -v timeout >/dev/null 2>&1 || return 1
  for candidate in jq gojq jaq; do
    candidate="$(type -P "$candidate" || true)"
    [[ -n "$candidate" ]] || continue
    result="$(printf '%s\n' '{}' '{"id":2,"result":{"rateLimits":{"x":0}}}' |
      timeout 3 "$candidate" -c 'select(.id == 2 and .result.rateLimits? != null) | .result.rateLimits' 2>/dev/null)" || continue
    [[ "$result" == '{"x":0}' ]] || continue
    result="$(printf '%s\n' '{"primary":{"used_percent":0},"credits":{"unlimited":false}}' |
      timeout 3 "$candidate" -r --arg window primary '(.[$window].usedPercent // .[$window].used_percent // empty), (.credits.unlimited // false)' 2>/dev/null)" || continue
    [[ "$result" == $'0\nfalse' ]] || continue
    result="$(printf '%s\n' '{}' '{"payload":{"rate_limits":{"x":0}}}' |
      timeout 3 "$candidate" -c 'select(.payload.rate_limits? != null) | .payload.rate_limits' 2>/dev/null)" || continue
    [[ "$result" == '{"x":0}' ]] || continue
    version="$(timeout 3 "$candidate" --version 2>/dev/null || true)"
    case "$version" in
      jq-*) JSON_QUERY_IMPLEMENTATION=jq ;;
      gojq\ *) JSON_QUERY_IMPLEMENTATION=gojq ;;
      jaq\ *) JSON_QUERY_IMPLEMENTATION=jaq ;;
      *) JSON_QUERY_IMPLEMENTATION=unidentified-compatible ;;
    esac
    JSON_QUERY_BIN="$candidate"
    return 0
  done
  return 1
}
json_query() {
  json_query_init || return 127
  "$JSON_QUERY_BIN" "$@"
}
json_query_backend() {
  printf '%s' "$JSON_QUERY_IMPLEMENTATION"
}
