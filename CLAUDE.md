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
- `install.sh`: chezmoi をインストールし、dotfiles を適用する。devcontainer の `onCreateCommand` から実行される。
- `.chezmoiroot`: chezmoi のソースディレクトリを `home/` に指定する。
- `home/`: chezmoi で管理する dotfiles。ファイル名は chezmoi の命名規則に従う（例: `dot_bashrc` → `~/.bashrc`）。ここ以外のファイルはホームディレクトリに配置されない。
  - `.chezmoi.toml.tmpl`: `chezmoi init` 時に `~/.config/chezmoi/chezmoi.toml` を生成する。`sourceDir` にリポジトリのパスを記録し、`--source` なしで `chezmoi apply` できるようにする。
  - `dot_config/mise/config.toml`: mise のグローバル設定。mise でインストールするツール（task など）を `[tools]` に書く。
  - `run_onchange_initial_setup.sh`: apt で OS パッケージを入れ、mise を `~/.local/bin` にインストールする。
  - `run_onchange_after_install_mise_tools.sh.tmpl`: `mise install` を実行する。`config.toml` のハッシュを埋め込んでいるため、ツールを変更すると再実行される。`after_` なので、ファイル配置と `initial_setup.sh` のあとに実行される。
- `Taskfile.yml`: task コマンドのタスク定義。`environment:check` で必要なツールが利用可能か確認する（CI でも実行）。

## 規約

- ファイルは末尾に改行を 1 つ入れ、行末の空白は残さない。
- YAML はインデント 2 スペースで、先頭に `---` を付ける。
- シェルスクリプトは `#!/bin/bash` と `set -euo pipefail` で始める。
- GitHub Actions の `uses:` はコミット SHA で固定し、`# vX.Y.Z` のコメントでバージョンを併記する。
- devcontainer の Feature を追加・変更したら `devcontainer-lock.json` も更新する。
- devcontainer を追加したら、CI の matrix にもエントリを追加する。
- ツールを追加するときは `home/dot_config/mise/config.toml` に書く。CI で確認したいツールは `Taskfile.yml` の `environment:check` にも追加する。
- devcontainer の構成（Features、インストールするツールなど）やファイル構成を変更したら、README.md も更新する。
- 永続化したいツールの設定は `/misc/<tool>` に置く。`postCreateCommand.sh` の `target_sub_dirs` への追加と、`devcontainer.json` の `containerEnv` での設定ディレクトリの指定を行う（例: `CLAUDE_CONFIG_DIR`, `GH_CONFIG_DIR`）。

## 検証

- Dockerfile: `hadolint .devcontainer/ubuntu/Dockerfile`
- ツール: `mise exec -- task environment:check`
- devcontainer のビルドは CI（PR 作成時）で確認する。
