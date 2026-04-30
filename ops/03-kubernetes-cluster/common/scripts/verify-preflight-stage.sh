#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
STATE_SCRIPT="${PROJECT_ROOT}/ops/common/scripts/stage-state.sh"
STAGE_ID="03-01-remote-preflight"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP AIRGAP_WORKER1_PRIVATE_IP; do
  require_env "${var}"
done

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  require_env AIRGAP_BASTION_PUBLIC_IP
  PROXY_ARGS=(-o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}")
else
  PROXY_ARGS=()
fi

run_remote_verify() {
  local host_ip="$1"
  local role="$2"
  local peer_ip="$3"
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" \
    "test -x /tmp/kubeadm-preflight-check.sh && \
     /tmp/kubeadm-preflight-check.sh --role '${role}' --peer '${peer_ip}'"
}

cleanup_failure() {
  "${STATE_SCRIPT}" set-failed "${STAGE_ID}" || true
}

trap cleanup_failure ERR

run_remote_verify "${AIRGAP_MASTER_PRIVATE_IP}" "control-plane" "${AIRGAP_WORKER1_PRIVATE_IP}"
run_remote_verify "${AIRGAP_WORKER1_PRIVATE_IP}" "worker" "${AIRGAP_MASTER_PRIVATE_IP}"

"${STATE_SCRIPT}" set-success "${STAGE_ID}"
trap - ERR
printf '[OK] 03-01 remote preflight verify passed\n'
