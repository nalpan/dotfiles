#!/usr/bin/env bash
# Claude Code の statusLine。model・effort・コンテキスト使用量を表示し、cmux のサイドバーにも同じ値を出す。
# 5 時間枠の使用率はサイドバーの進捗バーに出す。
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

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null; then
  key="claude_${CMUX_SURFACE_ID:-$session_id}"
  cache="${TMPDIR:-/tmp}/claude-cmux-status-${session_id}"
  # statusLine は頻繁に呼ばれるため、値が変わったときだけ cmux へ送る
  if [ "$(cat "$cache" 2>/dev/null || true)" != "$label" ]; then
    if cmux set-status "$key" "$label" --icon sparkle --priority 1 >/dev/null; then
      printf '%s' "$label" >"$cache"
    fi
  fi

  five_hour_used="$(jq -r '.rate_limits.five_hour.used_percentage // empty | floor' <<<"$input")"
  if [ -n "$five_hour_used" ]; then
    resets_at="$(jq -r '.rate_limits.five_hour.resets_at' <<<"$input")"
    seven_day_used="$(jq -r '.rate_limits.seven_day.used_percentage // empty | floor' <<<"$input")"
    usage_label="5h ${five_hour_used}%"
    if [ -n "$seven_day_used" ]; then
      usage_label="$usage_label · 7d ${seven_day_used}%"
    fi
    usage_label="$usage_label · $(date -r "$resets_at" +%H:%M) まで"
    usage_command=(set-progress "$(printf '%d.%02d' $((five_hour_used / 100)) $((five_hour_used % 100)))" --label "$usage_label")
  else
    usage_command=(clear-progress)
  fi
  usage_cache="${TMPDIR:-/tmp}/claude-cmux-usage-${session_id}"
  if [ "$(cat "$usage_cache" 2>/dev/null || true)" != "${usage_command[*]}" ]; then
    if cmux "${usage_command[@]}" >/dev/null; then
      printf '%s' "${usage_command[*]}" >"$usage_cache"
    fi
  fi
fi

printf '[%s]\n' "$label"
