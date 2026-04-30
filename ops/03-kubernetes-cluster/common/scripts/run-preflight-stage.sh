#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
STATE_SCRIPT="${PROJECT_ROOT}/ops/common/scripts/stage-state.sh"
STAGE_ID="03-01-remote-preflight"

if [[ -t 1 ]]; then
  COLOR_GREEN=$'\033[32m'
  COLOR_CYAN=$'\033[36m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_GREEN=''
  COLOR_CYAN=''
  COLOR_RESET=''
fi

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

SCRIPT_PATH="${PROJECT_ROOT}/ops/03-kubernetes-cluster/common/scripts/kubeadm-preflight-check.sh"

step() {
  printf '%s[STEP]%s %s\n' "${COLOR_CYAN}" "${COLOR_RESET}" "$1"
}

upload_script() {
  local host_ip="$1"
  step "Upload preflight script to ${host_ip}"
  scp -P "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${SCRIPT_PATH}" "${AIRGAP_SSH_USER}@${host_ip}:/tmp/kubeadm-preflight-check.sh"
  printf '%s[OK]%s uploaded preflight script to %s\n' "${COLOR_GREEN}" "${COLOR_RESET}" "${host_ip}"
}

run_remote_preflight() {
  local host_ip="$1"
  local role="$2"
  local peer_ip="$3"
  step "Run preflight on ${host_ip} (${role})"
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" \
    "chmod +x /tmp/kubeadm-preflight-check.sh && \
     /tmp/kubeadm-preflight-check.sh --role '${role}' --peer '${peer_ip}'"
  printf '%s[OK]%s preflight finished on %s (%s)\n' "${COLOR_GREEN}" "${COLOR_RESET}" "${host_ip}" "${role}"
}

cleanup_failure() {
  "${STATE_SCRIPT}" set-failed "${STAGE_ID}" || true
}

trap cleanup_failure ERR

upload_script "${AIRGAP_MASTER_PRIVATE_IP}"
upload_script "${AIRGAP_WORKER1_PRIVATE_IP}"
run_remote_preflight "${AIRGAP_MASTER_PRIVATE_IP}" "control-plane" "${AIRGAP_WORKER1_PRIVATE_IP}"
run_remote_preflight "${AIRGAP_WORKER1_PRIVATE_IP}" "worker" "${AIRGAP_MASTER_PRIVATE_IP}"

"${STATE_SCRIPT}" set-success "${STAGE_ID}"
trap - ERR
printf '%s[RESULT] SUCCESS%s\n' "${COLOR_GREEN}" "${COLOR_RESET}"
