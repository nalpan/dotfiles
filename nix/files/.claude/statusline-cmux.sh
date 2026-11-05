#!/usr/bin/env bash
# Claude Code の statusLine。model・effort・コンテキスト使用量を表示し、cmux のサイドバーにも同じ値を出す。
# 使用量の枠（5 時間・7 日）は、枠ごとの pill に文字のバーで出す。
set -euo pipefail

input="$(cat)"
model="$(jq -r '.model.display_name // .model.id // "?"' <<<"$input")"
effort="$(jq -r '.effort.level // empty' <<<"$input")"
context_used="$(jq -r '.context_window.used_percentage // empty | floor' <<<"$input")"
session_id="$(jq -r '.session_id // "unknown"' <<<"$input")"

label="$model"
if [ -n "$effort" ]; then
  label="$label / $effort"
fi
if [ -n "$context_used" ]; then
  label="$label / ctx ${context_used}%"
fi

usage_bar() {
  local filled=$((($1 + 5) / 10)) bar="" i
  for ((i = 0; i < 10; i++)); do
    if ((i < filled)); then bar+="▰"; else bar+="▱"; fi
  done
  printf '%s' "$bar"
}

show_usage() {
  local name="$1" window="$2" reset_format="$3" used resets_at command
  used="$(jq -r ".rate_limits.${window}.used_percentage // empty | floor" <<<"$input")"
  if [ -n "$used" ]; then
    resets_at="$(jq -r ".rate_limits.${window}.resets_at" <<<"$input")"
    command=(set-status "claude_usage_${name}_${surface}" "$name $(usage_bar "$used") ${used}% $(date -r "$resets_at" +"$reset_format")" --icon gauge --priority 0)
  else
    command=(clear-status "claude_usage_${name}_${surface}")
  fi
  local cache="${TMPDIR:-/tmp}/claude-cmux-usage-${name}-${session_id}"
  if [ "$(cat "$cache" 2>/dev/null || true)" != "${command[*]}" ]; then
    if cmux "${command[@]}" >/dev/null; then
      printf '%s' "${command[*]}" >"$cache"
    fi
  fi
}

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null; then
  surface="${CMUX_SURFACE_ID:-$session_id}"
  key="claude_${surface}"
  cache="${TMPDIR:-/tmp}/claude-cmux-status-${session_id}"
  # statusLine は頻繁に呼ばれるため、値が変わったときだけ cmux へ送る
  if [ "$(cat "$cache" 2>/dev/null || true)" != "$label" ]; then
    if cmux set-status "$key" "$label" --icon sparkle --priority 1 >/dev/null; then
      printf '%s' "$label" >"$cache"
    fi
  fi

  show_usage "5h" "five_hour" "%H:%M"
  show_usage "7d" "seven_day" "%-m/%-d %H:%M"
fi

printf '[%s]\n' "$label"
