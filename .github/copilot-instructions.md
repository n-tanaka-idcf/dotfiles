# Copilot 指示書 (dotfiles)

## 全体像
- このリポジトリは **chezmoi** で管理する個人用 dotfiles です（[README.md](../README.md) 参照）。
- ファイルは chezmoi の命名規則に従います:
  - `dot_*` → `~/.*`（例: `dot_zshrc` → `~/.zshrc`）
  - `private_dot_config/**` → `~/.config/**`
  - `private_dot_local/**` → `~/.local/**`
  - `*.tmpl` は chezmoi がレンダリングする Go テンプレートです

## 重要な規約（修正する場所）
- Git 設定はテンプレート化されています: `dot_gitconfig.tmpl` は `.chezmoi.toml.tmpl` から `name/email` を読み込みます。
- Zsh がメインのエントリポイントです: `dot_zshrc` で PATH/XDG 変数の設定や各種ツールの補完を配線しています。
- Zsh プラグインは **sheldon** 管理: `private_dot_config/sheldon/plugins.toml`（`dot_zshrc` から読み込まれます）。
- CLI ツールは **aqua** 管理: `private_dot_config/aquaproj-aqua/aqua.yaml`。

## フック / 副作用
- `run_onchange_initial_setup.sh` は chezmoi の “run_onchange” スクリプトです。トリガーされると次を行う可能性があります:
  - OS パッケージのインストール（apt/dnf）
  - aqua と全ツールのインストール
  - tmux TPM プラグインのインストール
  - ログインシェルを zsh に変更（`chsh`）
  ここは変更を最小限にし、新規マシンや CI 上でも実行される前提で扱ってください。

## シークレット（SOPS + age）
- シークレットは **SOPS** + **age** 受信者で運用する想定です（`.sops.yaml`）。
- ローカルの age キーは `.sopsrc` で設定します（`ageKeyFile: key.txt`）。`key.txt` は gitignore 済みです。
- 暗号化ファイルを追加・変更する場合は、SOPS の設定整合性を崩さないでください。

## 開発ワークフロー（このコマンドを使う）
- ローカルへの適用: `./install.sh`（必要なら chezmoi をインストールし、その後 `chezmoi init --apply --source=.` を実行）。
- よく使う Task:
  - `task diff` → `chezmoi apply --dry-run`
  - `task apply` → `chezmoi apply`
  - `task test` → `test/` の **goss** チェックを実行（`goss validate`）

## CI の前提
- GitHub Actions は `./install.sh` でデプロイし、次に `~/.zshrc` を source してから `goss validate` を実行します（`.github/workflows/test_dotfiles_deployment.yaml` 参照）。
- Workflow ファイルは `actionlint` で lint します（`.github/workflows/run_workflow_ci.yaml` 参照）。

## スコープ境界
- `.chezmoiignore` により、リポジトリ専用アセット（例: `.devcontainer/`, `docs/`, `test/`, `Taskfile.yaml`）は `$HOME` へは適用されません。
  ここへの変更は開発/CI に影響しますが、実際にデプロイされる dotfiles には反映されません。
