# プロダクト固有の注意事項

移行対象プロダクト: siberian, minuet, ocicat, willow, himalayan

## 一覧

| プロダクト | resolutions | .yarnrc | Chromatic VRT | scripts内yarn参照 | 特記事項 |
|---|---|---|---|---|---|
| siberian | `colors: 1.4.0` | なし | なし | `test-ci: yarn test` | React 17, Storybook 6.5.8 |
| minuet | `colors, @types/react, react-test-renderer` | なし | あり | `lint:fix` 内 | ML系ジョブはfront無関係 |
| ocicat | `graphql, react-test-renderer` | なし | あり | なし | msw使用 |
| willow | なし | あり | あり | `lint:fix` 内 | Dockerfile-devなし |
| himalayan | なし | あり | なし | `format` 内npm run | Node 20.16, npm run混在 |

## 各プロダクト詳細

### siberian

- **resolutions**: `"colors": "1.4.0"` → `pnpm.overrides` に変換が必要
- **scripts内yarn参照**: `"test-ci": "yarn test"` → `"test-ci": "pnpm run test"` に変更
- **特記事項**: React 17 + Storybook 6.5.8 の古いスタック。pnpm移行自体には影響しないが、依存解決で警告が出る可能性がある

### minuet

- **resolutions**: `colors`, `@types/react`, `react-test-renderer` の3つ → `pnpm.overrides` に変換
- **scripts内yarn参照**: `lint:fix` スクリプト内で yarn を参照 → `pnpm run` に変更
- **Chromatic VRT**: CI yaml 内に Chromatic ジョブがある。yarn → pnpm の変更漏れに注意
- **特記事項**: ML系のCIジョブがあるが、front とは無関係なので修正不要

### ocicat

- **resolutions**: `graphql`, `react-test-renderer` の2つ → `pnpm.overrides` に変換
- **Chromatic VRT**: CI yaml 内に Chromatic ジョブがある。yarn → pnpm の変更漏れに注意
- **特記事項**: msw を使用。pnpm では `pnpm.onlyBuiltDependencies` に `msw` を追加する必要がある場合がある（somali の例を参照）

### willow

- **.yarnrc**: 存在する → `git rm` で削除が必要
- **resolutions**: なし
- **scripts内yarn参照**: `lint:fix` スクリプト内で yarn を参照 → `pnpm run` に変更
- **Chromatic VRT**: CI yaml 内に Chromatic ジョブがある。yarn → pnpm の変更漏れに注意
- **特記事項**: Dockerfile-dev が存在しないため、Dockerfile のみ修正

### himalayan

- **.yarnrc**: 存在する → `git rm` で削除が必要
- **resolutions**: なし
- **scripts内yarn参照**: `format` スクリプト内で `npm run` を参照 → `pnpm run` に変更
- **特記事項**: Node 20.16 を使用。`npm run` と `yarn` が混在しているため、すべて `pnpm run` に統一すること
