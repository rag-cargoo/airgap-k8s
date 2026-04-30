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

verify_ssh() {
  local host_ip="$1"
  local host_name="$2"
  printf '[CHECK] ssh access to %s (%s)\n' "${host_name}" "${host_ip}"
  remote_cmd "${host_ip}" "hostname >/dev/null"
  printf '[OK] ssh access to %s\n' "${host_name}"
}

verify_assets() {
  local host_ip="$1"
  local host_name="$2"
  printf '[CHECK] offline assets on %s\n' "${host_name}"
  remote_cmd "${host_ip}" "sudo test -d ${SERVER_ASSETS_DIR}/kubernetes/packages && sudo test -d ${SERVER_ASSETS_DIR}/kubernetes/images && sudo test -d ${SERVER_ASSETS_DIR}/kubernetes/manifests"
  printf '[OK] offline assets present on %s\n' "${host_name}"
}

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  printf '[CHECK] ssh access to bastion (%s)\n' "${AIRGAP_BASTION_PUBLIC_IP}"
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" "hostname >/dev/null"
  printf '[OK] ssh access to bastion\n'
fi

verify_ssh "${AIRGAP_MASTER_PRIVATE_IP}" "${AIRGAP_MASTER_HOST}"
verify_ssh "${AIRGAP_WORKER1_PRIVATE_IP}" "${AIRGAP_WORKER1_HOST}"
verify_assets "${AIRGAP_MASTER_PRIVATE_IP}" "${AIRGAP_MASTER_HOST}"
verify_assets "${AIRGAP_WORKER1_PRIVATE_IP}" "${AIRGAP_WORKER1_HOST}"

printf '[RESULT] SUCCESS\n'
