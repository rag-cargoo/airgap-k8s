#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"
SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"
LOCAL_STORAGECLASS_IMAGES_DIR="${PROJECT_ROOT}/assets/offline-assets/kubernetes/images/storageclass"
LOCAL_STORAGECLASS_MANIFEST="${PROJECT_ROOT}/assets/offline-assets/kubernetes/manifests/local-path-storage.yaml"

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

verify_storageclass_assets() {
  local host_ip="$1"
  local host_name="$2"
  printf '[CHECK] StorageClass asset files on %s\n' "${host_name}"
  remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
image_dir=${SERVER_ASSETS_DIR}/kubernetes/images/storageclass
manifest=${SERVER_ASSETS_DIR}/kubernetes/manifests/local-path-storage.yaml
test -d \"\$image_dir\"
test -f \"\$manifest\"
'"
  printf '[OK] StorageClass asset files verified on %s\n' "${host_name}"
}

printf '[CHECK] local StorageClass source assets\n'
test -d "${LOCAL_STORAGECLASS_IMAGES_DIR}"
test -f "${LOCAL_STORAGECLASS_MANIFEST}"
test "$(find "${LOCAL_STORAGECLASS_IMAGES_DIR}" -maxdepth 1 -name "*.tar" | wc -l)" -ge 1
printf '[OK] local StorageClass source assets verified\n'

verify_storageclass_assets "${AIRGAP_MASTER_PRIVATE_IP}" "${AIRGAP_MASTER_HOST}"
verify_storageclass_assets "${AIRGAP_WORKER1_PRIVATE_IP}" "${AIRGAP_WORKER1_HOST}"

printf '[RESULT] SUCCESS\n'
