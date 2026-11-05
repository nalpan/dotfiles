#!/usr/bin/env bash
# SessionEnd hook。statusline-cmux.sh が出した cmux サイドバーの表示を消す。
set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // "unknown"' <<<"$input")"
rm -f "${TMPDIR:-/tmp}/claude-cmux-status-${session_id}" "${TMPDIR:-/tmp}"/claude-cmux-usage-*-"${session_id}"

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null; then
  surface="${CMUX_SURFACE_ID:-$session_id}"
  for status_key in "claude_${surface}" "claude_usage_5h_${surface}" "claude_usage_7d_${surface}"; do
    cmux clear-status "$status_key" >/dev/null
  done
fi
