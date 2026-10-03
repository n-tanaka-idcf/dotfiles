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
└── CLAUDE.md                 # Claude Code 向けのリポジトリガイド
```

## 使い方

1. `.env` を作成し、必要に応じてホスト側のユーザーに合わせて UID / GID を変更します。

   ```bash
   cp .devcontainer/.env.example .devcontainer/.env
   ```

2. VS Code でリポジトリを開き、「Dev Containers: Reopen in Container」から `ubuntu` を選択します。

### devcontainer の内容

- ベースイメージ: `ubuntu:24.04`（TZ は `Asia/Tokyo`）
- Features: docker-outside-of-docker, GitHub CLI, hadolint
- VS Code 拡張: Claude Code, Docker, GitHub Actions, シェルスクリプト、TOML、YAML 用の拡張
- Claude Code と GitHub CLI の設定は名前付きボリューム `misc` の `/misc/claude`、`/misc/gh` に保存されるため、コンテナを再作成しても保持されます。

## CI

`.devcontainer/**` またはワークフロー自体を変更した PR で、[run_devcontainer_ci.yaml](.github/workflows/run_devcontainer_ci.yaml) が devcontainer をビルドします。
