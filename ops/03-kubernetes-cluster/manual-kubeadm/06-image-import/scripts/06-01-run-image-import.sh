#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"
SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"

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

import_images() {
  local host_ip="$1"
  local host_name="$2"
  printf '[STEP] import Kubernetes and Calico images on %s\n' "${host_name}"
  remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
for image_tar in ${SERVER_ASSETS_DIR}/kubernetes/images/kube-system/*.tar ${SERVER_ASSETS_DIR}/kubernetes/images/calico/*.tar; do
  ctr -n k8s.io images import \"\$image_tar\" >/dev/null
done
'"
}

import_images "${AIRGAP_MASTER_PRIVATE_IP}" "${AIRGAP_MASTER_HOST}"
import_images "${AIRGAP_WORKER1_PRIVATE_IP}" "${AIRGAP_WORKER1_HOST}"

printf '[RESULT] SUCCESS\n'
