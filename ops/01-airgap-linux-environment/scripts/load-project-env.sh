#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ENV_FILE="${PROJECT_ROOT}/.env"

if [[ ! -f "${ENV_FILE}" ]]; then
  echo "[FAIL] ${ENV_FILE} 파일이 없습니다."
  echo "[INFO] cp .env.example .env"
  return 1 2>/dev/null || exit 1
fi

set -a
source "${ENV_FILE}"
set +a

required_vars=(
  AIRGAP_SSH_USER
  AIRGAP_SSH_KEY_PATH
  AIRGAP_BASTION_PUBLIC_IP
  AIRGAP_MASTER_PRIVATE_IP
  AIRGAP_WORKER1_PRIVATE_IP
  AIRGAP_OFFLINE_ASSETS_ARCHIVE
  AIRGAP_SERVER_ASSETS_DIR
)

missing=0
for var_name in "${required_vars[@]}"; do
  if [[ -z "${!var_name:-}" ]]; then
    echo "[FAIL] ${var_name} 값이 비어 있습니다."
    missing=1
  fi
done

if [[ "${missing}" -ne 0 ]]; then
  return 1 2>/dev/null || exit 1
fi

echo "[OK] project env loaded: ${ENV_FILE}"
