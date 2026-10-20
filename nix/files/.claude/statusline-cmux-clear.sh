#!/usr/bin/env bash
# SessionEnd hook。statusline-cmux.sh が出した cmux サイドバーの表示を消す。
set -euo pipefail

input="$(cat)"
session_id="$(jq -r '.session_id // "unknown"' <<<"$input")"
rm -f "${TMPDIR:-/tmp}/claude-cmux-status-${session_id}"

if [ -n "${CMUX_WORKSPACE_ID:-}" ] && command -v cmux >/dev/null; then
  cmux clear-status "claude_${CMUX_SURFACE_ID:-$session_id}" >/dev/null
fi
