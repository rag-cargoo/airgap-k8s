#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STATE_SCRIPT="${PROJECT_ROOT}/ops/common/scripts/stage-state.sh"
STAGE_ID="02-01-user-network-apply"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"

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

verify_remote() {
  local host_ip="$1"
  local expected_hostname="$2"
  local self_ip="$3"
  local self_name="$4"
  local peer_ip="$5"
  local peer_name="$6"

  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" \
    "sudo /tmp/verify-node-user-network.sh \
       --expected-hostname '${expected_hostname}' \
       --self-ip '${self_ip}' \
       --self-name '${self_name}' \
       --peer-ip '${peer_ip}' \
       --peer-name '${peer_name}'"
}

cleanup_failure() {
  "${STATE_SCRIPT}" set-failed "${STAGE_ID}" || true
}

trap cleanup_failure ERR

verify_remote \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}" \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}" \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}"
verify_remote \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}" \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}" \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}"

"${STATE_SCRIPT}" set-success "${STAGE_ID}"
trap - ERR
printf '[OK] 02-01 user/network actual verify passed\n'
