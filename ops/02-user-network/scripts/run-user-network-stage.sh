#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STATE_SCRIPT="${PROJECT_ROOT}/ops/common/scripts/stage-state.sh"
STAGE_ID="02-01-user-network-apply"

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

CONFIGURE_SCRIPT="${PROJECT_ROOT}/ops/02-user-network/scripts/configure-node-user-network.sh"
VERIFY_SCRIPT="${PROJECT_ROOT}/ops/02-user-network/scripts/verify-node-user-network.sh"

step() {
  printf '%s[STEP]%s %s\n' "${COLOR_CYAN}" "${COLOR_RESET}" "$1"
}

upload_scripts() {
  local host_ip="$1"
  step "Upload scripts to ${host_ip}"
  scp -P "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${CONFIGURE_SCRIPT}" "${VERIFY_SCRIPT}" \
    "${AIRGAP_SSH_USER}@${host_ip}:/tmp/"
  printf '%s[OK]%s uploaded scripts to %s\n' "${COLOR_GREEN}" "${COLOR_RESET}" "${host_ip}"
}

remote_apply_and_verify() {
  local host_ip="$1"
  local expected_hostname="$2"
  local self_ip="$3"
  local self_name="$4"
  local peer_ip="$5"
  local peer_name="$6"

  step "Apply and verify on ${expected_hostname} (${host_ip})"
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" \
    "chmod +x /tmp/configure-node-user-network.sh /tmp/verify-node-user-network.sh && \
     sudo /tmp/configure-node-user-network.sh \
       --hostname '${expected_hostname}' \
       --self-ip '${self_ip}' \
       --self-name '${self_name}' \
       --peer-ip '${peer_ip}' \
       --peer-name '${peer_name}' && \
     sudo /tmp/verify-node-user-network.sh \
       --expected-hostname '${expected_hostname}' \
       --self-ip '${self_ip}' \
       --self-name '${self_name}' \
       --peer-ip '${peer_ip}' \
       --peer-name '${peer_name}'"
  printf '%s[OK]%s apply+verify finished on %s\n' "${COLOR_GREEN}" "${COLOR_RESET}" "${expected_hostname}"
}

cleanup_failure() {
  "${STATE_SCRIPT}" set-failed "${STAGE_ID}" || true
}

trap cleanup_failure ERR

upload_scripts "${AIRGAP_MASTER_PRIVATE_IP}"
upload_scripts "${AIRGAP_WORKER1_PRIVATE_IP}"
remote_apply_and_verify \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}" \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}" \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}"
remote_apply_and_verify \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}" \
  "${AIRGAP_WORKER1_PRIVATE_IP}" \
  "${AIRGAP_WORKER1_HOST}" \
  "${AIRGAP_MASTER_PRIVATE_IP}" \
  "${AIRGAP_MASTER_HOST}"

"${STATE_SCRIPT}" set-success "${STAGE_ID}"
trap - ERR
printf '%s[RESULT] SUCCESS%s\n' "${COLOR_GREEN}" "${COLOR_RESET}"
