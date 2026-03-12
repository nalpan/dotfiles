#!/usr/bin/env bash
# pnpm移行の検証スクリプト
# Usage: bash .claude/skills/migrate-to-pnpm/scripts/verify-migration.sh <product>

set -euo pipefail

PRODUCT="${1:?Usage: $0 <product>}"
FRONT_DIR="apps/${PRODUCT}/front"
REPO_ROOT="$(git rev-parse --show-toplevel)"

cd "$REPO_ROOT"

ERRORS=0
WARNINGS=0

pass() { echo "  [PASS] $1"; }
fail() { echo "  [FAIL] $1"; ERRORS=$((ERRORS + 1)); }
warn() { echo "  [WARN] $1"; WARNINGS=$((WARNINGS + 1)); }

echo "=== pnpm移行検証: ${PRODUCT} ==="
echo ""

# --- ファイル存在チェック ---
echo "--- ファイルチェック ---"

if [ -f "${FRONT_DIR}/yarn.lock" ]; then
  fail "yarn.lock が残っている"
else
  pass "yarn.lock は削除済み"
fi

if [ -f "${FRONT_DIR}/.yarnrc" ]; then
  fail ".yarnrc が残っている"
else
  pass ".yarnrc は存在しない"
fi

if [ -f "${FRONT_DIR}/pnpm-lock.yaml" ]; then
  pass "pnpm-lock.yaml が存在する"
else
  fail "pnpm-lock.yaml が存在しない"
fi

# --- package.json チェック ---
echo ""
echo "--- package.json チェック ---"

PACKAGE_JSON="${FRONT_DIR}/package.json"

if grep -q '"packageManager"' "$PACKAGE_JSON"; then
  pass "packageManager フィールドが存在する"
else
  fail "packageManager フィールドが存在しない"
fi

if grep -q '"preinstall"' "$PACKAGE_JSON"; then
  pass "preinstall スクリプトが存在する"
else
  fail "preinstall スクリプトが存在しない"
fi

if grep -q '"resolutions"' "$PACKAGE_JSON"; then
  fail "resolutions フィールドが残っている（pnpm.overrides に変換が必要）"
else
  pass "resolutions フィールドは存在しない"
fi

# scripts内のyarn/npm run参照チェック
YARN_IN_SCRIPTS=$(grep -o '"[^"]*": "[^"]*yarn[^"]*"' "$PACKAGE_JSON" | grep -v '"preinstall"' || true)
if [ -n "$YARN_IN_SCRIPTS" ]; then
  fail "scripts内にyarn参照が残っている: ${YARN_IN_SCRIPTS}"
else
  pass "scripts内にyarn参照はない"
fi

NPM_RUN_IN_SCRIPTS=$(grep -o '"[^"]*": "[^"]*npm run[^"]*"' "$PACKAGE_JSON" || true)
if [ -n "$NPM_RUN_IN_SCRIPTS" ]; then
  fail "scripts内にnpm run参照が残っている: ${NPM_RUN_IN_SCRIPTS}"
else
  pass "scripts内にnpm run参照はない"
fi

# --- Dockerfile チェック ---
echo ""
echo "--- Dockerfile チェック ---"

for DOCKERFILE in "${FRONT_DIR}/Dockerfile" "${FRONT_DIR}/Dockerfile-dev"; do
  if [ -f "$DOCKERFILE" ]; then
    YARN_IN_DOCKER=$(grep -n 'yarn' "$DOCKERFILE" || true)
    if [ -n "$YARN_IN_DOCKER" ]; then
      fail "${DOCKERFILE} にyarn文字列が残っている:"
      echo "       ${YARN_IN_DOCKER}"
    else
      pass "${DOCKERFILE} にyarn文字列はない"
    fi
  fi
done

# --- CI ワークフローチェック ---
echo ""
echo "--- CI ワークフローチェック ---"

CI_YAML=".github/workflows/${PRODUCT}_ci.yaml"
if [ -f "$CI_YAML" ]; then
  # front関連ジョブ内のyarn参照をチェック
  YARN_IN_CI=$(grep -n 'yarn' "$CI_YAML" || true)
  if [ -n "$YARN_IN_CI" ]; then
    # yarnがfront関連の行にあるかどうかを警告
    warn "${CI_YAML} にyarn文字列がある（front以外のジョブなら問題なし）:"
    echo "       ${YARN_IN_CI}"
  else
    pass "${CI_YAML} にyarn文字列はない"
  fi

  if grep -q 'pnpm/action-setup' "$CI_YAML"; then
    pass "pnpm/action-setup ステップが存在する"
  else
    warn "pnpm/action-setup ステップが見つからない（front以外のジョブのみなら問題なし）"
  fi
else
  warn "CI yaml が見つからない: ${CI_YAML}"
fi

# --- ビルド検証 ---
echo ""
echo "--- ビルド検証 ---"

cd "${REPO_ROOT}/${FRONT_DIR}"

echo "  pnpm install を実行中..."
if pnpm install 2>&1; then
  pass "pnpm install 成功"
else
  fail "pnpm install 失敗"
fi

echo "  pnpm run build を実行中..."
if pnpm run build 2>&1; then
  pass "pnpm run build 成功"
else
  fail "pnpm run build 失敗"
fi

# --- 結果サマリ ---
echo ""
echo "=== 検証結果 ==="
echo "  エラー: ${ERRORS}"
echo "  警告: ${WARNINGS}"

if [ "$ERRORS" -gt 0 ]; then
  echo ""
  echo "移行に問題があります。上記のFAIL項目を修正してください。"
  exit 1
else
  echo ""
  echo "移行検証に成功しました。"
  exit 0
fi
