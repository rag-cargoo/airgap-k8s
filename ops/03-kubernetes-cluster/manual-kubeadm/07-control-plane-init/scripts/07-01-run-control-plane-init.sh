#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
K8S_VERSION="${AIRGAP_K8S_VERSION:-v1.35.4}"
POD_CIDR="${AIRGAP_POD_CIDR:-192.168.0.0/16}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP; do
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

printf '[STEP] kubeadm init on %s\n' "${AIRGAP_MASTER_HOST}"
remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc '
set -euo pipefail
if [[ ! -f /etc/kubernetes/admin.conf ]]; then
  kubeadm init \
    --kubernetes-version ${K8S_VERSION} \
    --apiserver-advertise-address ${AIRGAP_MASTER_PRIVATE_IP} \
    --pod-network-cidr ${POD_CIDR}
else
  echo \"control plane already initialized; skipping kubeadm init\"
fi
mkdir -p /home/${AIRGAP_SSH_USER}/.kube
cp /etc/kubernetes/admin.conf /home/${AIRGAP_SSH_USER}/.kube/config
chown -R ${AIRGAP_SSH_USER}:${AIRGAP_SSH_USER} /home/${AIRGAP_SSH_USER}/.kube
mkdir -p /home/devops/.kube
cp /etc/kubernetes/admin.conf /home/devops/.kube/config
chown -R devops:devops /home/devops/.kube
'"

printf '[RESULT] SUCCESS\n'
