#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"
SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"
SERVER_ASSETS_PARENT="$(dirname "${SERVER_ASSETS_DIR}")"
OFFLINE_ARCHIVE_VALUE="${AIRGAP_OFFLINE_ASSETS_ARCHIVE:-offline-assets.tar.gz}"
OFFLINE_ARCHIVE_NAME="$(basename "${OFFLINE_ARCHIVE_VALUE}")"
case "${OFFLINE_ARCHIVE_VALUE}" in
  /*) OFFLINE_ARCHIVE="${OFFLINE_ARCHIVE_VALUE}" ;;
  */*) OFFLINE_ARCHIVE="${PROJECT_ROOT}/${OFFLINE_ARCHIVE_VALUE}" ;;
  *) OFFLINE_ARCHIVE="${PROJECT_ROOT}/delivery/${OFFLINE_ARCHIVE_VALUE}" ;;
esac
BASTION_STAGING_DIR="${AIRGAP_BASTION_STAGING_DIR:-/home/${AIRGAP_SSH_USER:-ec2-user}/airgap-transfer}"
BASTION_STAGED_ARCHIVE="${BASTION_STAGING_DIR}/${OFFLINE_ARCHIVE_NAME}"
BASTION_STAGED_KEY="${BASTION_STAGING_DIR}/airgap-offline-transfer-key.pem"
NODE_STAGING_DIR="${AIRGAP_NODE_STAGING_DIR:-/tmp}"
NODE_STAGED_ARCHIVE="${NODE_STAGING_DIR}/${OFFLINE_ARCHIVE_NAME}"

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

stage_on_bastion() {
  printf '[STEP] stage offline archive on bastion\n'
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
    "mkdir -p ${BASTION_STAGING_DIR}"
  rsync -a --partial --inplace --info=progress2 \
    -e "ssh -p ${AIRGAP_SSH_PORT} -i ${AIRGAP_SSH_KEY_PATH}" \
    "${OFFLINE_ARCHIVE}" "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:${BASTION_STAGED_ARCHIVE}"
  scp -P "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
    "${AIRGAP_SSH_KEY_PATH}" "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}:${BASTION_STAGED_KEY}"
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
    "chmod 600 ${BASTION_STAGED_KEY}"
}

cleanup_bastion_key() {
  if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
    ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
      "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
      "rm -f ${BASTION_STAGED_KEY}" >/dev/null 2>&1 || true
  fi
}

upload_archive() {
  local host_ip="$1"
  printf '[STEP] upload offline archive to %s\n' "${host_ip}"
  if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
    ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" \
      "${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}" \
      "mkdir -p ${NODE_STAGING_DIR} && rsync -a --partial --inplace --info=progress2 -e 'ssh -o StrictHostKeyChecking=no -i ${BASTION_STAGED_KEY}' ${BASTION_STAGED_ARCHIVE} ${AIRGAP_SSH_USER}@${host_ip}:${NODE_STAGED_ARCHIVE}"
  else
    rsync -a --partial --inplace --info=progress2 \
      -e "ssh -p ${AIRGAP_SSH_PORT} -i ${AIRGAP_SSH_KEY_PATH}" \
      "${OFFLINE_ARCHIVE}" "${AIRGAP_SSH_USER}@${host_ip}:${NODE_STAGED_ARCHIVE}"
  fi
}

extract_archive() {
  local host_ip="$1"
  printf '[STEP] extract offline archive on %s\n' "${host_ip}"
  remote_cmd "${host_ip}" \
    "sudo mkdir -p ${SERVER_ASSETS_PARENT} && sudo tar -xzf ${NODE_STAGED_ARCHIVE} -C ${SERVER_ASSETS_PARENT}"
}

trap cleanup_bastion_key EXIT

[[ -f "${OFFLINE_ARCHIVE}" ]] || {
  printf '[FAIL] missing offline archive: %s\n' "${OFFLINE_ARCHIVE}" >&2
  exit 1
}

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  stage_on_bastion
fi

upload_archive "${AIRGAP_MASTER_PRIVATE_IP}"
upload_archive "${AIRGAP_WORKER1_PRIVATE_IP}"
extract_archive "${AIRGAP_MASTER_PRIVATE_IP}"
extract_archive "${AIRGAP_WORKER1_PRIVATE_IP}"

printf '[RESULT] SUCCESS\n'
