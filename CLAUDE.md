# CLAUDE.md

このリポジトリで作業する Claude Code 向けのガイドです。

## 概要

個人用の dotfiles と devcontainer 設定を管理するリポジトリです。アプリケーションコードはなく、主に Dockerfile、devcontainer / Compose の設定、シェルスクリプト、GitHub Actions ワークフローで構成されます。

## 構成

- `.devcontainer/compose.yml`: devcontainer のサービス定義。UID / GID / ユーザー名は `.devcontainer/.env` から受け取る（`.env` は git 管理外、テンプレートは `.env.example`）。
- `.devcontainer/<name>/`: devcontainer ごとのディレクトリ。現在は `ubuntu` のみ。
  - `devcontainer.json`: Features、VS Code 設定・拡張、環境変数、マウント
  - `devcontainer-lock.json`: Features のバージョン固定
  - `postCreateCommand.sh`: コンテナ作成後の初期化処理（`/misc` 配下のディレクトリ作成など）
- `.github/workflows/run_devcontainer_ci.yaml`: matrix で各 devcontainer をビルドする CI。

## 規約

- ファイルは末尾に改行を 1 つ入れ、行末の空白は残さない。
- YAML はインデント 2 スペースで、先頭に `---` を付ける。
- シェルスクリプトは `#!/bin/bash` と `set -euo pipefail` で始める。
- GitHub Actions の `uses:` はコミット SHA で固定し、`# vX.Y.Z` のコメントでバージョンを併記する。
- devcontainer の Feature を追加・変更したら `devcontainer-lock.json` も更新する。
- devcontainer を追加したら、CI の matrix にもエントリを追加する。
- 永続化したいツールの設定は `/misc/<tool>` に置く。`postCreateCommand.sh` の `target_sub_dirs` への追加と、`devcontainer.json` の `containerEnv` での設定ディレクトリの指定を行う（例: `CLAUDE_CONFIG_DIR`, `GH_CONFIG_DIR`）。

## 検証

- Dockerfile: `hadolint .devcontainer/ubuntu/Dockerfile`
- devcontainer のビルドは CI（PR 作成時）で確認する。
