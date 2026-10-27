# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリ。開発は devcontainer（Ubuntu）内で行う。`.chezmoiroot` が `home/` を指しているため、chezmoi が管理するのは `home/` 配下のみ。それ以外（`install.sh`、`Taskfile.yml`、`.devcontainer/`、`.github/`）はリポジトリ用のツール類。

## コマンド

[Task](https://taskfile.dev/) 経由で実行する（引数なしの `task` でタスク一覧を表示）。

- `task chezmoi:diff` — 未適用の dotfile の差分を表示（追加引数も渡せる。例: `task chezmoi:diff -- ~/.bashrc`）
- `task chezmoi:apply` — dotfiles を適用
- `task environment:check` — 必要なツール（atuin, chezmoi, claude, curl, fd, fzf, gh, git, herdr, jq, mise, nu, ssh, task）が PATH にあるか確認。CI で実行されるのもこれ

`./install.sh` は chezmoi が未インストールなら導入し、`chezmoi init --apply --source=<リポジトリ>` を実行する。devcontainer では `onCreateCommand` として実行される。

## アーキテクチャ

- **chezmoi 設定**: `home/.chezmoi.toml.tmpl` が `sourceDir` をリポジトリの作業ツリーに設定するため、リポジトリ自体が chezmoi のソースディレクトリになる。
- **ツールのインストール**: `home/dot_config/mise/config.toml` に mise で管理するツール（claude, task, gh, jq, herdr, nu, fzf, fd, atuin）を宣言する。`run_onchange_after_install_mise_tools.sh.tmpl` がこのファイルのハッシュを埋め込んでいるため、変更されるたびに `mise install` が再実行される。
- **OS の初期設定**: `home/run_onchange_initial_setup.sh` が apt パッケージと mise をインストールする（Debian/Ubuntu のみ対応）。
- **`~/.bashrc`**: `home/modify_dot_bashrc` は chezmoi の *modify テンプレート*。ファイル全体は管理せず、マーカーで囲んだ mise 有効化ブロックを取り除いてから末尾に追記し直す（冪等）。`~/.bashrc` がなければ `/etc/skel/.bashrc` をベースにする。
- **Devcontainer**（`.devcontainer/`）: compose ベース。`.devcontainer/.env` が必要（`.env.example` をコピーし、ユーザー名・UID・GID をホストに合わせる）。`misc` ボリュームを `/misc` にマウントし、`CLAUDE_CONFIG_DIR=/misc/claude`、`GH_CONFIG_DIR=/misc/gh`、`ATUIN_DB_PATH=/misc/atuin/history.db` をそこに向けることで、再ビルドしても Claude と gh の設定、atuin の履歴が残る。これらのディレクトリは `postCreateCommand.sh` が作成する。
- **CI**（`.github/workflows/run_devcontainer_ci.yaml`）: devcontainer をビルドして `task environment:check` を実行する。トリガーは `.devcontainer/`、`home/`、`.chezmoiroot`、`install.sh`、`Taskfile.yml`、ワークフロー自身の変更時のみ。Action は commit SHA で固定している。

## AI 向けドキュメント

`docs/ai/` 配下のファイルは Claude Code の振る舞いを定める指示。以下でインポートしており、常に読み込んで従う。

- @docs/ai/confirm-first-pair-programmer.md — 確認を多めに取りながら進めるペアプロの進め方（質問で合意形成してから実装する）

ただし、ユーザーが対象と操作を明示した依頼（例:「CLAUDE.md をコミットして」「この箇所をこう直して」）は、その時点で「GO」の合図とみなす。Phase 0〜2 の質問や計画の提示は省略して実行してよい。質問や承認を求めるのは、依頼に曖昧さや分岐がある場合と、不可逆・高リスクな操作（push、履歴の書き換え、環境の変更など）が必要な場合に限る。

## 規約

- コミットは `git commit` を直接実行せず、プロジェクトスキル `git-commit`（`.claude/skills/git-commit`）を使う。Conventional Commits 形式のメッセージが作られる。
- `home/` 配下のコメントの言語はファイルごとに異なる（`modify_dot_bashrc` は日本語、`run_onchange_*` は英語）。編集するファイルの言語に合わせる。
