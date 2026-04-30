#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STAGE_ROOT="${PROJECT_ROOT}/delivery/ops-runtime/airgap-k8s-ops"
ARCHIVE_PATH="${PROJECT_ROOT}/delivery/ops-runtime.tar.gz"

failures=0

check_path() {
  local label="$1"
  local path="$2"
  if [[ -e "${path}" ]]; then
    printf '[OK] %s: %s\n' "${label}" "${path}"
    return
  fi
  printf '[FAIL] %s missing: %s\n' "${label}" "${path}"
  failures=$((failures + 1))
}

printf '[1/4] [CHECK] staged runtime directories\n'
check_path "ops runtime root" "${STAGE_ROOT}"
check_path "ops common" "${STAGE_ROOT}/ops/common"
check_path "ops 02 user network" "${STAGE_ROOT}/ops/02-user-network"
check_path "ops 03 kubernetes cluster" "${STAGE_ROOT}/ops/03-kubernetes-cluster"
check_path "ops 04 services monitoring" "${STAGE_ROOT}/ops/04-services-monitoring"
check_path "ops 05 external access" "${STAGE_ROOT}/ops/05-prometheus-grafana-external-access"

printf '[2/4] [CHECK] generated archive file\n'
check_path "ops-runtime archive" "${ARCHIVE_PATH}"

printf '[3/4] [CHECK] archive content preview\n'
if [[ -f "${ARCHIVE_PATH}" ]]; then
  set +o pipefail
  tar -tzf "${ARCHIVE_PATH}" | head -n 20
  set -o pipefail
  printf '[OK] Printed ops-runtime archive preview\n'
fi

printf '[4/4] [CHECK] required authored file preview\n'
check_path "ops root readme" "${STAGE_ROOT}/ops/README.md"
check_path "kube cluster readme" "${STAGE_ROOT}/ops/03-kubernetes-cluster/README.md"
check_path "preflight script" "${STAGE_ROOT}/ops/03-kubernetes-cluster/common/scripts/kubeadm-preflight-check.sh"

if [[ "${failures}" -ne 0 ]]; then
  printf '\n[RESULT] FAILED\n'
  printf '[INFO] failures: %s\n' "${failures}"
  exit 1
fi

printf '\n[RESULT] SUCCESS\n'
printf '[OK] ops-runtime bundle verified\n'
