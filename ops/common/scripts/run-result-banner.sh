#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 3 ]]; then
  printf 'Usage: %s <target-label> <result-kind> <command...>\n' "$0" >&2
  exit 1
fi

TARGET_LABEL="$1"
RESULT_KIND="$2"
shift 2
CMD=("$@")

if [[ -t 1 ]]; then
  COLOR_GREEN=$'\033[32m'
  COLOR_RED=$'\033[31m'
  COLOR_CYAN=$'\033[36m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_GREEN=''
  COLOR_RED=''
  COLOR_CYAN=''
  COLOR_RESET=''
fi

print_banner() {
  local status="$1"
  local color="$2"
  local exit_code="${3:-0}"
  printf '\n%s==================================================%s\n' "${color}" "${COLOR_RESET}"
  printf '%s[RESULT] %s%s\n' "${color}" "${status}" "${COLOR_RESET}"
  printf '%s[TARGET] %s%s\n' "${COLOR_CYAN}" "${TARGET_LABEL}" "${COLOR_RESET}"
  printf '%s[KIND] %s%s\n' "${COLOR_CYAN}" "${RESULT_KIND}" "${COLOR_RESET}"
  if [[ "${status}" == "FAILED" ]]; then
    printf '%s[EXIT CODE] %s%s\n' "${COLOR_RED}" "${exit_code}" "${COLOR_RESET}"
  fi
  printf '%s==================================================%s\n' "${color}" "${COLOR_RESET}"
}

set +e
"${CMD[@]}"
EXIT_CODE=$?
set -e

if [[ "${EXIT_CODE}" -eq 0 ]]; then
  print_banner "SUCCESS" "${COLOR_GREEN}"
  exit 0
fi

print_banner "FAILED" "${COLOR_RED}" "${EXIT_CODE}"
exit "${EXIT_CODE}"
