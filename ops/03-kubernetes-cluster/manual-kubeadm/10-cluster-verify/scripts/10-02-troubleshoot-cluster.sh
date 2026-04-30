#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

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

remote_cmd() {
  local host_ip="$1"
  shift
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" "$@"
}

printf '[INFO] master services\n'
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo systemctl --no-pager --full status containerd kubelet | sed -n '1,80p'" || true
printf '[INFO] worker services\n'
remote_cmd "${AIRGAP_WORKER1_PRIVATE_IP}" "sudo systemctl --no-pager --full status containerd kubelet | sed -n '1,80p'" || true
printf '[INFO] cluster nodes and pods\n'
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc 'KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide; KUBECONFIG=/etc/kubernetes/admin.conf kubectl get pods -A -o wide'" || true
