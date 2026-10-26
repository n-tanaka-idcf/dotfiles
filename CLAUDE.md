# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概要

[chezmoi](https://www.chezmoi.io/) で管理する dotfiles リポジトリ。開発は devcontainer（Ubuntu）内で行う。`.chezmoiroot` が `home/` を指しているため、chezmoi が管理するのは `home/` 配下のみ。それ以外（`install.sh`、`Taskfile.yml`、`.devcontainer/`、`.github/`）はリポジトリ用のツール類。

## コマンド

[Task](https://taskfile.dev/) 経由で実行する（引数なしの `task` でタスク一覧を表示）。

- `task chezmoi:diff` — 未適用の dotfile の差分を表示（追加引数も渡せる。例: `task chezmoi:diff -- ~/.bashrc`）
- `task chezmoi:apply` — dotfiles を適用
- `task environment:check` — 必要なツール（chezmoi, claude, curl, gh, git, mise, ssh, task）が PATH にあるか確認。CI で実行されるのもこれ

`./install.sh` は chezmoi が未インストールなら導入し、`chezmoi init --apply --source=<リポジトリ>` を実行する。devcontainer では `onCreateCommand` として実行される。

## アーキテクチャ

- **chezmoi 設定**: `home/.chezmoi.toml.tmpl` が `sourceDir` をリポジトリの作業ツリーに設定するため、リポジトリ自体が chezmoi のソースディレクトリになる。
- **ツールのインストール**: `home/dot_config/mise/config.toml` に mise で管理するツール（claude, task, gh）を宣言する。`run_onchange_after_install_mise_tools.sh.tmpl` がこのファイルのハッシュを埋め込んでいるため、変更されるたびに `mise install` が再実行される。
- **OS の初期設定**: `home/run_onchange_initial_setup.sh` が apt パッケージと mise をインストールする（Debian/Ubuntu のみ対応）。
- **`~/.bashrc`**: `home/modify_dot_bashrc` は chezmoi の *modify テンプレート*。ファイル全体は管理せず、マーカーで囲んだ mise 有効化ブロックを取り除いてから末尾に追記し直す（冪等）。`~/.bashrc` がなければ `/etc/skel/.bashrc` をベースにする。
- **Devcontainer**（`.devcontainer/`）: compose ベース。`.devcontainer/.env` が必要（`.env.example` をコピーし、ユーザー名・UID・GID をホストに合わせる）。`misc` ボリュームを `/misc` にマウントし、`CLAUDE_CONFIG_DIR=/misc/claude` と `GH_CONFIG_DIR=/misc/gh` をそこに向けることで、再ビルドしても Claude と gh の設定が残る。これらのディレクトリは `postCreateCommand.sh` が作成する。
- **CI**（`.github/workflows/run_devcontainer_ci.yaml`）: devcontainer をビルドして `task environment:check` を実行する。トリガーは `.devcontainer/`、`home/`、`.chezmoiroot`、`install.sh`、`Taskfile.yml`、ワークフロー自身の変更時のみ。Action は commit SHA で固定している。

## 規約

- コミットは `git commit` を直接実行せず、プロジェクトスキル `git-commit`（`.claude/skills/git-commit`）を使う。Conventional Commits 形式のメッセージが作られる。
- `home/` 配下のテンプレートのコメントは日本語で書かれているため、周囲のファイルの言語に合わせる。
