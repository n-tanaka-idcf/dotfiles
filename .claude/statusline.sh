#!/usr/bin/env bash
# Claude Code status line: model | context usage | cost | elapsed time
# Reads the session JSON from stdin. Prints nothing if jq is missing.

command -v jq >/dev/null 2>&1 || exit 0

input=$(cat)

# One jq call; missing values fall back to defaults.
IFS=$'\t' read -r model pct cost ms < <(
  jq -r '[
    (.model.display_name // "?"),
    ((.context_window.used_percentage // 0) | floor),
    (.cost.total_cost_usd // 0),
    (.cost.total_duration_ms // 0)
  ] | @tsv' <<<"$input" 2>/dev/null
)
[ -n "$model" ] || exit 0

RESET=$'\033[0m'
DIM=$'\033[2m'
CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
MAGENTA=$'\033[35m'

# Context usage: yellow from 70%, red from 90%.
if [ "$pct" -ge 90 ]; then
  pct_color=$RED
elif [ "$pct" -ge 70 ]; then
  pct_color=$YELLOW
else
  pct_color=$GREEN
fi

secs=$((ms / 1000))
if [ "$secs" -ge 3600 ]; then
  elapsed=$(printf '%dh%02dm' $((secs / 3600)) $((secs % 3600 / 60)))
else
  elapsed=$(printf '%dm%02ds' $((secs / 60)) $((secs % 60)))
fi

sep="${DIM} | ${RESET}"
printf '%s%s%s%s%s%s%%%s%s%s$%.2f%s%s%s%s%s\n' \
  "$CYAN" "$model" "$RESET" \
  "$sep" "$pct_color" "$pct" "$RESET" \
  "$sep" "$YELLOW" "$cost" "$RESET" \
  "$sep" "$MAGENTA" "$elapsed" "$RESET"
