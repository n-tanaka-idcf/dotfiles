# dotfiles

開発環境用の dotfiles と devcontainer 設定です。

## 構成

```text
.
├── .claude/
│   ├── hooks/check_edited_file.sh  # 編集したファイルを規約に照らして確認する hook
│   ├── statusline.sh         # CLI の statusline（モデル名、コンテキストの使用率と残り、利用制限、コスト）
│   └── settings.json         # Claude Code のプロジェクト設定（permissions, hooks, statusline）
├── .devcontainer/
│   ├── .env.example          # compose.yml に渡すユーザー情報のテンプレート
│   ├── compose.yml           # devcontainer 用の Docker Compose 定義
│   └── ubuntu/               # Ubuntu 24.04 ベースの devcontainer
│       ├── Dockerfile
│       ├── devcontainer.json
│       ├── devcontainer-lock.json
│       └── postCreateCommand.sh
├── .github/workflows/
│   ├── run_devcontainer_ci.yaml  # devcontainer のビルド CI
│   └── run_dotfiles_ci.yaml      # Ubuntu / Rocky Linux のコンテナで dotfiles を適用する CI
├── home/                     # chezmoi で管理する dotfiles
│   ├── .chezmoi.toml.tmpl                             # chezmoi の設定（ソースディレクトリの記録）
│   ├── dot_config/atuin/config.toml                   # atuin の設定
│   ├── dot_config/helix/config.toml                   # helix の設定
│   ├── dot_config/herdr/config.toml                   # herdr の設定
│   ├── dot_config/mise/config.toml                    # mise でインストールするツール
│   ├── dot_config/nushell/                            # nushell の設定（env.nu, config.nu, scripts/）
│   ├── dot_config/starship.toml                       # starship の設定（蛍光色の Powerline）
│   ├── dot_config/tuios/config.d/dotfiles.toml        # tuios の設定（~/.config/tuios/config.toml が優先）
│   ├── modify_dot_bashrc                              # ~/.bashrc の末尾に mise の有効化を追記
│   ├── run_onchange_initial_setup.sh                  # OS パッケージと mise のインストール
│   ├── run_onchange_after_install_mise_tools.sh.tmpl  # mise install の実行
│   └── run_onchange_after_reset_nushell_autoload.sh.tmpl  # nushell の初期化スクリプトのキャッシュ削除
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

### devcontainer を使わない環境

VM などに直接適用する場合は、次のコマンドで chezmoi をインストールし、このリポジトリの dotfiles を適用します。Debian 系（apt）と RHEL 系（dnf）に対応しており、OS パッケージのインストールに `sudo` を使います。事前に `git` と `curl` が必要です。

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply n-tanaka-idcf
```

リポジトリは `~/.local/share/chezmoi` に clone されます。以降は `chezmoi update` で取り込みと再適用を行えます。

### devcontainer の内容

- ベースイメージ: `ubuntu:24.04`（TZ は `Asia/Tokyo`）
- Features: docker-outside-of-docker, hadolint
- VS Code 拡張: Claude Code, Docker, GitHub Actions, シェルスクリプト、TOML、YAML 用の拡張
- ターミナルのフォント: `Monaspace Neon NF`。starship の設定（Pastel Powerline プリセットがベース）は Nerd Font の記号を使うため、ホスト側に [Monaspace](https://github.com/githubnext/monaspace) の Nerd Font 版をインストールしておく必要があります。
- コンテナ作成時（`onCreateCommand`）に `install.sh` が chezmoi で `home/` の dotfiles を適用します。このとき OS パッケージ（curl, git, libatomic, openssh-client）、mise、mise で管理するツール（atuin, carapace, claude, devcontainer-cli, fd, fish, fzf, gh, ghq, helix, herdr, jq, k9s, kind, kubectl, lefthook, neovim, node, nushell, ripgrep, shellcheck, starship, task, tuios, zoxide）がインストールされます。リポジトリのパスは `~/.config/chezmoi/chezmoi.toml` に記録されるため、以降は `chezmoi apply` だけで再適用できます。
- Claude Code と GitHub CLI の設定、atuin のシェル履歴は名前付きボリューム `misc` の `/misc/claude`、`/misc/gh`、`/misc/atuin` に保存されるため、コンテナを再作成しても保持されます。

- コンテナ作成後（`postCreateCommand`）に `lefthook install` で Git フックをインストールします。コミット時に、ステージしたシェルスクリプト（`*.sh`, `*.sh.tmpl`）を shellcheck で検査します。
- Claude Code がファイルを編集すると、PostToolUse の hook（[.claude/hooks/check_edited_file.sh](.claude/hooks/check_edited_file.sh)）がシェルスクリプトの shellcheck、行末の空白、末尾の改行を確認し、問題があれば Claude に修正させます。

### ツールの追加

mise で入れるツールは [home/dot_config/mise/config.toml](home/dot_config/mise/config.toml) の `[tools]` に追記します。次に `chezmoi apply` を実行すると `mise install` が実行されます。

Claude Code の CLI（`claude`）も mise で入れています。Claude Code 自身による自動更新は `[env]` の `DISABLE_AUTOUPDATER` で無効にしているため、更新は `mise upgrade claude` で行います。VS Code 拡張は CLI とは別に自身のバイナリを持っており、CLI と同じ `CLAUDE_CONFIG_DIR`（`/misc/claude`）の設定を使います。

### タスク

```bash
task                    # タスクの一覧を表示
task chezmoi:diff       # chezmoi apply で適用される変更を表示
task chezmoi:apply      # dotfiles をホームディレクトリに適用
task environment:check  # 必要なツールが利用可能か確認
```

`task` を使うにはシェルで mise を有効化する必要があります（bash と nushell では対話シェルの起動時に自動で有効化されます）。有効化していない場合は `mise exec -- task` で実行します。nushell では `task` のタスク名やフラグを Tab で補完できます。そのほかのコマンドも [carapace](https://carapace.sh/) で補完できます。

nushell では [zoxide](https://github.com/ajeetdsouza/zoxide) が有効になっており、`z <キーワード>` で過去に移動したディレクトリへジャンプでき、`zi`（または Ctrl+J）で候補を fzf で対話的に選択できます。

nushell では [atuin](https://github.com/atuinsh/atuin) が有効になっており、Ctrl+R または上矢印キーでシェル履歴を検索できます。入力中のコマンドの続きが atuin の履歴からインラインヒント（灰色の文字）で表示され、→ キーまたは Ctrl+F で確定できます。ヒントは 2 文字以上入力したときに表示され、入力が前回の候補と一致しているあいだは atuin を呼ばずに前回の結果を使い回します。履歴の記録と検索は、必要になったときに自動で起動する atuin の daemon が担当します（`atuin daemon status` で状態を確認できます）。

nushell の起動を速くするため、atuin、carapace、starship、task、zoxide の初期化スクリプトは `~/.local/share/nushell/vendor/autoload/` にキャッシュされ、起動のたびには生成し直しません（mise の有効化スクリプトは起動時の PATH を埋め込むため、毎回生成します）。キャッシュは mise の設定か `dot_config/nushell/scripts/` が変わったときに `chezmoi apply` で削除され、次の起動で作り直されます。`mise upgrade` でツールだけを更新したときは、該当するファイルを削除して nushell を起動し直してください。

## CI

次のファイルを変更した PR で、[run_devcontainer_ci.yaml](.github/workflows/run_devcontainer_ci.yaml) が devcontainer をビルドし、`task environment:check` で必要なツールが揃っているか確認します。

- `.devcontainer/**`
- `.github/workflows/run_devcontainer_ci.yaml`
- `.chezmoiroot`、`home/**`、`install.sh`
- `Taskfile.yml`

また、次のファイルを変更した PR で、[run_dotfiles_ci.yaml](.github/workflows/run_dotfiles_ci.yaml) が matrix で `ubuntu:24.04` と `rockylinux/rockylinux:9` のコンテナを起動し、その中で `install.sh` を実行して chezmoi のインストールと dotfiles の適用を行い、nushell 上で `task environment:check` を実行して必要なツールが揃っているか確認します。devcontainer を使わない Debian 系・RHEL 系の環境でも dotfiles を適用できることを確認するためのものです。コンテナには事前に sudo と git（Ubuntu では curl も）だけを入れ、新しくインストールした OS に近い状態で確認します。

- `.github/workflows/run_dotfiles_ci.yaml`
- `.chezmoiroot`、`home/**`、`install.sh`
- `Taskfile.yml`

どちらの CI も、同じファイルの変更が main にマージされたときにも実行され、PR の CI で使うキャッシュを保存します。

- run_devcontainer_ci: Docker のビルドキャッシュを GitHub Actions のキャッシュ（`type=gha`）に保存し、Features などの変わっていないレイヤーを再利用します。devcontainers/ci は Docker Compose 構成のビルドに `cacheTo` を渡さないため、CI の中で `.devcontainer/compose.yml` に `cache_from` / `cache_to` を追加しています。
- run_dotfiles_ci: mise でインストールしたツール（`~/.local/share/mise/installs`）を OS ごとにキャッシュし、最新版が変わったツールだけをダウンロードします。キャッシュは main でのみ保存し（古いバージョンは `mise prune` で削除）、PR では復元だけを行います。
