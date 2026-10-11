#!/bin/bash

set -euo pipefail

# Claude Code の PostToolUse (Edit|Write) フック。
# 編集したファイルを規約（shellcheck、行末の空白、末尾の改行）に照らして確認し、
# 問題があれば exit 2 で Claude に伝えて修正させる。

file_path="$(jq -r '.tool_input.file_path // empty')"

# リポジトリ外のファイル、存在しないファイル、バイナリファイルは対象外
if [[ "${file_path}" != "${CLAUDE_PROJECT_DIR}/"* || ! -s "${file_path}" ]] || ! grep -Iq . "${file_path}"; then
  exit 0
fi

errors=()

case "${file_path}" in
  *.sh | *.sh.tmpl)
    if ! output="$(shellcheck "${file_path}" 2>&1)"; then
      errors+=("shellcheck で問題が見つかりました:"$'\n'"${output}")
    fi
    ;;
esac

if output="$(grep -n '[[:space:]]$' "${file_path}")"; then
  errors+=("行末に空白があります:"$'\n'"${output}")
fi

if [[ -n "$(tail -c 1 "${file_path}")" ]]; then
  errors+=("ファイルの末尾に改行がありません。")
elif [[ "$(tail -c 2 "${file_path}" | wc -l)" -eq 2 ]]; then
  errors+=("ファイルの末尾に改行が 2 つ以上あります。")
fi

if [[ ${#errors[@]} -gt 0 ]]; then
  {
    echo "${file_path} が規約に沿っていません。"
    printf '%s\n' "${errors[@]}"
  } >&2
  exit 2
fi
