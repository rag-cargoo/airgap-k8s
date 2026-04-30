#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  printf 'Usage: %s <set-success|set-failed|clear|status> <stage-id>\n' "$0" >&2
  exit 1
fi

ACTION="$1"
STAGE_ID="$2"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STATE_DIR="${PROJECT_ROOT}/.codex/runtime/airgap-k8s-state"
DONE_FILE="${STATE_DIR}/${STAGE_ID}.done"
FAILED_FILE="${STATE_DIR}/${STAGE_ID}.failed"

mkdir -p "${STATE_DIR}"

case "${ACTION}" in
  set-success)
    rm -f "${FAILED_FILE}"
    touch "${DONE_FILE}"
    ;;
  set-failed)
    rm -f "${DONE_FILE}"
    touch "${FAILED_FILE}"
    ;;
  clear)
    rm -f "${DONE_FILE}" "${FAILED_FILE}"
    ;;
  status)
    if [[ -f "${DONE_FILE}" ]]; then
      printf 'success\n'
    elif [[ -f "${FAILED_FILE}" ]]; then
      printf 'failed\n'
    else
      printf 'pending\n'
    fi
    ;;
  *)
    printf 'Unknown action: %s\n' "${ACTION}" >&2
    exit 1
    ;;
esac
