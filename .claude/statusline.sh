#!/bin/bash

set -euo pipefail

# Claude Code の statusline。
# モデル名、コンテキストの使用率と残り、利用制限（5 時間 / 週）の使用率、
# セッションのコスト（API 料金換算の概算）を表示する。
# 利用制限は Pro / Max の契約時だけ渡されるため、値がなければ表示しない。

IFS=$'\t' read -r model context remaining cost five_hour seven_day < <(
  jq -r '[
    .model.display_name,
    (.context_window.used_percentage // 0 | floor),
    (.context_window.remaining_percentage // 100 | floor),
    (.cost.total_cost_usd // 0),
    (.rate_limits.five_hour.used_percentage // "-" | if type == "number" then floor else . end),
    (.rate_limits.seven_day.used_percentage // "-" | if type == "number" then floor else . end)
  ] | @tsv'
)

line=$(printf '%s | ctx %d%% (残り %d%%)' "${model}" "${context}" "${remaining}")

if [[ "${five_hour}" != "-" ]]; then
  line+=$(printf ' | 5h %d%%' "${five_hour}")
fi
if [[ "${seven_day}" != "-" ]]; then
  line+=$(printf ' | 7d %d%%' "${seven_day}")
fi
line+=$(printf ' | $%.2f' "${cost}")

printf '%s\n' "${line}"
