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

verify_images() {
  local host_ip="$1"
  local host_name="$2"
  local role="$3"
  printf '[CHECK] imported images on %s\n' "${host_name}"
  remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
images=\$(ctr -n k8s.io images list)
require_image() {
  local pattern=\"\$1\"
  if ! grep -q \"\${pattern}\" <<<\"\${images}\"; then
    printf \"[FAIL] missing imported image: %s\n\" \"\${pattern}\" >&2
    exit 1
  fi
}
if [[ \"${role}\" == \"control-plane\" ]]; then
  require_image \"registry.k8s.io/kube-apiserver\"
  require_image \"registry.k8s.io/kube-controller-manager\"
  require_image \"registry.k8s.io/kube-scheduler\"
  require_image \"registry.k8s.io/etcd\"
else
  require_image \"registry.k8s.io/coredns/coredns\"
fi
require_image \"registry.k8s.io/kube-proxy\"
require_image \"registry.k8s.io/pause\"
require_image \"quay.io/calico/node\"
'"
  printf '[OK] imported images verified on %s\n' "${host_name}"
}

verify_images "${AIRGAP_MASTER_PRIVATE_IP}" "${AIRGAP_MASTER_HOST}" "control-plane"
verify_images "${AIRGAP_WORKER1_PRIVATE_IP}" "${AIRGAP_WORKER1_HOST}" "worker"

printf '[RESULT] SUCCESS\n'
