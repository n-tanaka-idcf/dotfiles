#!/bin/bash

set -euo pipefail

# Claude Code の statusline。
# モデル名、コンテキストの使用率、セッションのコスト（API 料金換算の概算）を表示する。

IFS=$'\t' read -r model context cost < <(
  jq -r '[
    .model.display_name,
    (.context_window.used_percentage // 0 | floor),
    (.cost.total_cost_usd // 0)
  ] | @tsv'
)

printf '%s | ctx %d%% | $%.2f\n' "${model}" "${context}" "${cost}"
