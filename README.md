# dotfiles

開発環境用の dotfiles と devcontainer 設定です。

## 構成

```text
.
├── .claude/                  # Claude Code のプロジェクト設定
├── .devcontainer/
│   ├── .env.example          # compose.yml に渡すユーザー情報のテンプレート
│   ├── compose.yml           # devcontainer 用の Docker Compose 定義
│   └── ubuntu/               # Ubuntu 24.04 ベースの devcontainer
│       ├── Dockerfile
│       ├── devcontainer.json
│       ├── devcontainer-lock.json
│       └── postCreateCommand.sh
├── .github/workflows/
│   └── run_devcontainer_ci.yaml  # devcontainer のビルド CI
├── home/                     # chezmoi で管理する dotfiles
│   ├── .chezmoi.toml.tmpl                             # chezmoi の設定（ソースディレクトリの記録）
│   ├── dot_bashrc                                     # bash の設定（Ubuntu の既定 + mise の有効化）
│   ├── dot_config/atuin/config.toml                   # atuin の設定
│   ├── dot_config/mise/config.toml                    # mise でインストールするツール
│   ├── dot_config/nushell/                            # nushell の設定（env.nu, config.nu, scripts/）
│   ├── dot_config/starship.toml                       # starship の設定（Pastel Powerline プリセット）
│   ├── run_onchange_initial_setup.sh                  # OS パッケージと mise のインストール
│   └── run_onchange_after_install_mise_tools.sh.tmpl  # mise install の実行
├── .chezmoiroot              # chezmoi のソースディレクトリ（home/）の指定
├── CLAUDE.md                 # Claude Code 向けのリポジトリガイド
├── install.sh                # chezmoi のインストールと dotfiles の適用
├── lefthook.yml              # Git フックの設定（pre-commit で shellcheck を実行）
└── Taskfile.yml              # task コマンドのタスク定義
```

## 使い方

1. `.env` を作成し、必要に応じてホスト側のユーザーに合わせて UID / GID を変更します。

   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```

2. VS Code でリポジトリを開き、「Dev Containers: Reopen in Container」から `ubuntu` を選択します。

### devcontainer の内容

- ベースイメージ: `ubuntu:24.04`（TZ は `Asia/Tokyo`）
- Features: docker-outside-of-docker, GitHub CLI, sshd, hadolint
- VS Code 拡張: Claude Code, Docker, GitHub Actions, シェルスクリプト、TOML、YAML 用の拡張
- ターミナルのフォント: `Monaspace Neon NF`。starship の Pastel Powerline プリセットは Nerd Font の記号を使うため、ホスト側に [Monaspace](https://github.com/githubnext/monaspace) の Nerd Font 版をインストールしておく必要があります。
- コンテナ作成時（`onCreateCommand`）に `install.sh` が chezmoi で `home/` の dotfiles を適用します。このとき OS パッケージ（curl, git）、mise、mise で管理するツール（atuin, carapace, fzf, lefthook, nushell, shellcheck, starship, task, zoxide）がインストールされます。リポジトリのパスは `~/.config/chezmoi/chezmoi.toml` に記録されるため、以降は `chezmoi apply` だけで再適用できます。
- Claude Code と GitHub CLI の設定、atuin のシェル履歴は名前付きボリューム `misc` の `/misc/claude`、`/misc/gh`、`/misc/atuin` に保存されるため、コンテナを再作成しても保持されます。

- コンテナ作成後（`postCreateCommand`）に `lefthook install` で Git フックをインストールします。コミット時に、ステージしたシェルスクリプト（`*.sh`, `*.sh.tmpl`）を shellcheck で検査します。

### ツールの追加

mise で入れるツールは [home/dot_config/mise/config.toml](home/dot_config/mise/config.toml) の `[tools]` に追記します。次に `chezmoi apply` を実行すると `mise install` が実行されます。

### タスク

```bash
task                    # タスクの一覧を表示
task chezmoi:diff       # chezmoi apply で適用される変更を表示
task chezmoi:apply      # dotfiles をホームディレクトリに適用
task environment:check  # 必要なツールが利用可能か確認
```

`task` を使うにはシェルで mise を有効化する必要があります（bash と nushell では対話シェルの起動時に自動で有効化されます）。有効化していない場合は `mise exec -- task` で実行します。nushell では `task` のタスク名やフラグを Tab で補完できます。そのほかのコマンドも [carapace](https://carapace.sh/) で補完できます。

nushell では [zoxide](https://github.com/ajeetdsouza/zoxide) が有効になっており、`z <キーワード>` で過去に移動したディレクトリへジャンプでき、`zi`（または Ctrl+J）で候補を fzf で対話的に選択できます。

nushell では [atuin](https://github.com/atuinsh/atuin) が有効になっており、Ctrl+R または上矢印キーでシェル履歴を検索できます。入力中のコマンドの続きが atuin の履歴からインラインヒント（灰色の文字）で表示され、→ キーまたは Ctrl+F で確定できます。

## CI

次のファイルを変更した PR で、[run_devcontainer_ci.yaml](.github/workflows/run_devcontainer_ci.yaml) が devcontainer をビルドし、`task environment:check` で必要なツールが揃っているか確認します。

- `.devcontainer/**`
- `.github/workflows/run_devcontainer_ci.yaml`
- `.chezmoiroot`、`home/**`、`install.sh`
- `Taskfile.yml`
