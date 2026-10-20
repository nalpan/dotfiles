#!/usr/bin/env bash
# Claude Code の statusLine。model と effort を表示し、cmux のサイドバーにも同じ値を出す。
set -euo pipefail

input="$(cat)"
model="$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")"
effort="$(jq -r '.effort.level // empty' <<<"$input")"
session_id="$(jq -r '.session_id // "unknown"' <<<"$input")"

label="$model"
if [ -n "$effort" ]; then
  label="$model · $effort"
fi

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null; then
  key="claude_${CMUX_SURFACE_ID:-$session_id}"
  cache="${TMPDIR:-/tmp}/claude-cmux-status-${session_id}"
  # statusLine は頻繁に呼ばれるため、値が変わったときだけ cmux へ送る
  if [ "$(cat "$cache" 2>/dev/null || true)" != "$label" ]; then
    if cmux set-status "$key" "$label" --icon sparkle --priority 1 >/dev/null; then
      printf '%s' "$label" >"$cache"
    fi
  fi
fi

printf '[%s]\n' "$label"
