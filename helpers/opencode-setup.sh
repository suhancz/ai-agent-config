#!/usr/bin/env bash
# Sourced by setup.sh; use its conflict handling and private backup loader.
setup_opencode() {
  if (($# != 2)); then
    printf 'Usage: setup_opencode <repository> <request-mode:0-or-1>\n' >&2
    return 2
  fi
  local repo="$1" request="$2"
  if [[ "$request" != 0 && "$request" != 1 ]]; then
    printf 'OpenCode request mode must be 0 or 1.\n' >&2
    return 2
  fi
  local family config_dir plugin_dir v1_target v2_target wanted stale source
  family="$(python3.12 "$repo/helpers/opencode-version.py")" || return 1
  config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
  if [[ -n "${OPENCODE_CONFIG_DIR:-}" ]]; then
    printf 'Custom OPENCODE_CONFIG_DIR requires verified discovery support; refusing automatic setup.\n' >&2
    return 1
  fi
  plugin_dir="$config_dir/plugins"
  v1_target="$plugin_dir/ai-agent-config.js"
  v2_target="$plugin_dir/ai-agent-config/index.js"
  if [[ "$family" == 1 ]]; then
    wanted="$v1_target"
    stale="$v2_target"
    source="$repo/opencode/v1.js"
  else
    wanted="$v2_target"
    stale="$v1_target"
    source="$repo/opencode/v2.js"
  fi
  if ((request != 0)); then
    if [[ ! -L "$wanted" || "$(readlink -f -- "$wanted" || true)" != "$source" ]]; then
      printf 'OpenCode hook missing or API family changed; rerun initial setup and restart OpenCode.\n' >&2
      return 1
    fi
  else
    if [[ -e "$stale" || -L "$stale" ]]; then
      if [[ -L "$stale" && ( "$(readlink -f -- "$stale" || true)" == "$repo/opencode/v1.js" || "$(readlink -f -- "$stale" || true)" == "$repo/opencode/v2.js" ) ]]; then
        link_file "$source" "$wanted"
        rm -- "$stale"
      else
        printf 'Conflicting inactive OpenCode hook; review it manually before migration.\n' >&2
        return 1
      fi
    else
      link_file "$source" "$wanted"
    fi
  fi
  link_instruction "$repo/opencode/AGENTS.md" "$config_dir/AGENTS.md"
  printf 'OpenCode API family %s selected; restart and verify prompt-hook loading.\n' "$family" >&2
}
