---
name: migrate-to-pnpm
description: "yarn v1からpnpmへの移行を実行する。トリガー: 'migrate to pnpm', 'yarn to pnpm', 'pnpm移行', 'pnpmに移行'"
---

# yarn v1 → pnpm 移行スキル

対象プロダクトのfrontディレクトリをyarn v1からpnpmに移行する。
移行済みプロダクト（cheetoh, somali, leo）のパターンに準拠すること。

プロダクト固有の注意事項は `references/product-specific-notes.md` を参照すること。

## 移行手順

以下のステップを順番に実行すること。

### Step 1: package.json の修正

対象: `apps/{product}/front/package.json`

1. `"packageManager": "pnpm@10.26.1"` をトップレベルに追加する
2. `scripts` に `"preinstall": "npx only-allow pnpm"` を追加する
3. `resolutions` フィールドがあれば `pnpm.overrides` に変換する:
   ```json
   // before
   "resolutions": {
     "colors": "1.4.0"
   }

   // after（resolutionsは削除）
   "pnpm": {
     "overrides": {
       "colors": "1.4.0"
     }
   }
   ```
4. `scripts` 内の `yarn` コマンド参照を `pnpm run` に変更する:
   - `yarn test` → `pnpm run test`
   - `yarn <script>` → `pnpm run <script>`
   - `npm run <script>` → `pnpm run <script>`

### Step 2: lockfile の切り替え（バージョン保持）

対象ディレクトリ: `apps/{product}/front/`

```bash
# node_modules を削除
rm -rf node_modules

# yarn.lock を読み取り、同じバージョンで pnpm-lock.yaml を生成
pnpm import

# lockfile に基づいて node_modules を再構築
pnpm install

# 確認後 yarn.lock を削除
git rm yarn.lock
```

`pnpm import` は yarn.lock から依存関係のバージョンをそのまま引き継ぐため、バージョンの差異は発生しない。

### Step 3: Dockerfile の修正

対象: `apps/{product}/front/Dockerfile` （存在する場合）

参考パターン: `apps/cheetoh/front/Dockerfile`

以下の変更を行う:

1. **pnpm のインストールを追加**（corepackではなく `npm install -g pnpm` を使用。Node.js 25+でのcorepackバンドル削除を考慮）:
   ```dockerfile
   RUN apk --update add git make g++ python3 \
       && npm install -g pnpm
   ```

2. **COPY対象を変更**:
   ```dockerfile
   # before
   COPY apps/{product}/front/yarn.lock yarn.lock

   # after
   COPY apps/{product}/front/pnpm-lock.yaml pnpm-lock.yaml
   ```

3. **コマンドを変更**:
   ```dockerfile
   # before
   RUN yarn install
   RUN yarn build

   # after
   RUN pnpm install
   RUN pnpm run build
   ```

`Dockerfile-dev` も存在する場合は同様に修正すること。

### Step 4: CI ワークフローの修正

対象: `.github/workflows/{product}_ci.yaml` 内の front_test ジョブ等

参考パターン: `.github/workflows/cheetoh_ci.yaml` L157-191

以下の変更を行う:

1. **`cache: yarn` と `cache-dependency-path` を actions/setup-node から削除**

2. **pnpm/action-setup ステップを追加**（actions/setup-node の直後）:
   ```yaml
   - uses: pnpm/action-setup@v3
     with:
       version: latest
   ```

3. **pnpm store cache ステップを追加**:
   ```yaml
   - name: Get pnpm store directory
     shell: bash
     run: |
       echo "STORE_PATH=$(pnpm store path --silent)" >> "$GITHUB_ENV"
   - uses: actions/cache@v4
     name: Setup pnpm cache
     with:
       path: ${{ env.STORE_PATH }}
       key: >-
         ${{ runner.os }}-pnpm-store-
         ${{ hashFiles('**/pnpm-lock.yaml') }}
       restore-keys: |
         ${{ runner.os }}-pnpm-store-
   ```

4. **yarn コマンドを pnpm に置換**:
   - `yarn install --frozen-lockfile` → `pnpm install --frozen-lockfile`
   - `yarn <script>` → `pnpm run <script>`
   - `yarn --cwd` → `pnpm --dir`

5. **Chromatic VRT ジョブがある場合**、同様に yarn → pnpm に変更すること。`cache-dependency-path` が `yarn.lock` を参照している箇所も修正する。

### Step 5: ファイルのクリーンアップ

```bash
# yarn.lock を削除（Step 2で未実施の場合）
git rm apps/{product}/front/yarn.lock

# .yarnrc があれば削除
git rm apps/{product}/front/.yarnrc 2>/dev/null || true
```

### Step 6: 検証

以下をすべて確認する:

1. `pnpm install` が成功すること
2. `pnpm run build` が成功すること
3. `pnpm run test` が成功すること（テストスクリプトがある場合）
4. Dockerfile に `yarn` 文字列が残っていないこと
5. CI yaml に不要な `yarn` 文字列が残っていないこと
6. `.yarnrc` が削除されていること（存在した場合）

検証スクリプト `scripts/verify-migration.sh` を使用して自動検証も行うこと:

```bash
bash .claude/skills/migrate-to-pnpm/scripts/verify-migration.sh {product}
```
