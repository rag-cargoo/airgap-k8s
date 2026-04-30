#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

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

remote_cmd() {
  local host_ip="$1"
  shift
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" "$@"
}

printf '[CHECK] containerd and kubelet services\n'
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo systemctl is-active --quiet containerd && sudo systemctl is-active --quiet kubelet"
remote_cmd "${AIRGAP_WORKER1_PRIVATE_IP}" "sudo systemctl is-active --quiet containerd && sudo systemctl is-active --quiet kubelet"

printf '[CHECK] node Ready state\n'
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc '
set -euo pipefail
for _ in \$(seq 1 60); do
  if KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes --no-headers 2>/dev/null | grep -q \"${AIRGAP_MASTER_HOST}.* Ready\" &&
     KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes --no-headers 2>/dev/null | grep -q \"${AIRGAP_WORKER1_HOST}.* Ready\"; then
    exit 0
  fi
  sleep 10
done
exit 1
'"

printf '[CHECK] Calico rollout and image pull failures\n'
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc '
set -euo pipefail
KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n tigera-operator rollout status deploy/tigera-operator --timeout=300s >/dev/null
KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n calico-system rollout status ds/calico-node --timeout=300s >/dev/null
KUBECONFIG=/etc/kubernetes/admin.conf kubectl -n calico-system rollout status deploy/calico-kube-controllers --timeout=300s >/dev/null
if KUBECONFIG=/etc/kubernetes/admin.conf kubectl get pods -A --no-headers | grep -E \"ErrImagePull|ImagePullBackOff\"; then
  exit 1
fi
KUBECONFIG=/etc/kubernetes/admin.conf kubectl get nodes -o wide
'"

printf '[RESULT] SUCCESS\n'
