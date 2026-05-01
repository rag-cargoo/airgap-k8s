#!/usr/bin/env bash

set -euo pipefail

SERVICE_ROOT="$(cd "$(dirname "${BASH_SOURCE[1]}")/.." && pwd)"
OPS04_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS04_ROOT}/../.." && pwd)"

source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"
SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"
REMOTE_STAGING_ROOT="${AIRGAP_SERVICE_STAGING_DIR:-/tmp/airgap-service-assets}"
KEEP_REMOTE_SERVICE_IMAGE_TARS="${AIRGAP_KEEP_REMOTE_SERVICE_IMAGE_TARS:-false}"

require_service_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing service var: %s\n' "${name}" >&2
    exit 1
  fi
}

require_env_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

service_init() {
  for var in SERVICE_ID SERVICE_NAMESPACE SERVICE_WORKLOAD SERVICE_POD_SELECTOR; do
    require_service_var "${var}"
  done
  for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP AIRGAP_WORKER1_PRIVATE_IP; do
    require_env_var "${var}"
  done
  if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
    require_env_var AIRGAP_BASTION_PUBLIC_IP
    PROXY_ARGS=(-o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}")
  else
    PROXY_ARGS=()
  fi
  SCP_ARGS=(-P "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}")

  IMAGE_LIST="${SERVICE_ROOT}/assets/images.txt"
  MANIFEST_SRC_DIR="${SERVICE_ROOT}/manifests"
  LOCAL_IMAGE_DIR="${PROJECT_ROOT}/assets/offline-assets/services/images/${SERVICE_ID}"
  LOCAL_MANIFEST_DIR="${PROJECT_ROOT}/assets/offline-assets/services/manifests/${SERVICE_ID}"
  REMOTE_IMAGE_DIR="${SERVER_ASSETS_DIR}/services/images/${SERVICE_ID}"
  REMOTE_MANIFEST_DIR="${SERVER_ASSETS_DIR}/services/manifests/${SERVICE_ID}"
  REMOTE_STAGING_DIR="${REMOTE_STAGING_ROOT}/${SERVICE_ID}"
}

service_write_rsync_ssh_config() {
  local host_key="$1"
  local host_ip="$2"
  local host_alias="airgap-${SERVICE_ID}-${host_key}"
  local config_dir="${PROJECT_ROOT}/.codex/tmp/rsync-ssh"
  local config_path="${config_dir}/${host_alias}.config"

  mkdir -p "${config_dir}"
  {
    printf 'Host %s\n' "${host_alias}"
    printf '  HostName %s\n' "${host_ip}"
    printf '  User %s\n' "${AIRGAP_SSH_USER}"
    printf '  Port %s\n' "${AIRGAP_SSH_PORT}"
    printf '  IdentityFile %s\n' "${AIRGAP_SSH_KEY_PATH}"
    printf '  IdentitiesOnly yes\n'
    printf '  StrictHostKeyChecking accept-new\n'
    if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
      printf '  ProxyCommand ssh -i %s -p %s -W %%h:%%p %s@%s\n' \
        "${AIRGAP_SSH_KEY_PATH}" \
        "${AIRGAP_SSH_PORT}" \
        "${AIRGAP_SSH_USER}" \
        "${AIRGAP_BASTION_PUBLIC_IP}"
    fi
  } >"${config_path}"
  chmod 600 "${config_path}"
  printf '%s %s\n' "${host_alias}" "${config_path}"
}

service_image_tar_name() {
  printf '%s' "$1" | sed 's#[/:@]#_#g'
}

service_images() {
  grep -Ev '^[[:space:]]*(#|$)' "${IMAGE_LIST}"
}

remote_cmd() {
  local host_ip="$1"
  shift
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${host_ip}" "$@"
}

remote_master_bash() {
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -s"
}

service_download_assets() {
  service_init
  mkdir -p "${LOCAL_IMAGE_DIR}" "${LOCAL_MANIFEST_DIR}"
  find "${LOCAL_IMAGE_DIR}" -maxdepth 1 -type f -name '*.tar' -delete
  cp "${IMAGE_LIST}" "${LOCAL_IMAGE_DIR}/images.txt"

  local image tar_name tar_path
  while IFS= read -r image; do
    tar_name="$(service_image_tar_name "${image}").tar"
    tar_path="${LOCAL_IMAGE_DIR}/${tar_name}"
    printf '[STEP] pull image: %s\n' "${image}"
    docker image inspect "${image}" >/dev/null 2>&1 || docker pull "${image}"
    printf '[STEP] save image tar: %s\n' "${tar_path}"
    docker save "${image}" -o "${tar_path}"
  done < <(service_images)

  find "${LOCAL_MANIFEST_DIR}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -delete
  find "${MANIFEST_SRC_DIR}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -print0 |
    while IFS= read -r -d '' manifest; do
      cp "${manifest}" "${LOCAL_MANIFEST_DIR}/"
    done
  printf '[RESULT] SUCCESS\n'
}

service_verify_assets() {
  service_init
  printf '[CHECK] local assets for %s\n' "${SERVICE_ID}"
  test -f "${LOCAL_IMAGE_DIR}/images.txt"
  test -d "${LOCAL_MANIFEST_DIR}"
  local expected actual manifests
  expected="$(service_images | wc -l | tr -d ' ')"
  actual="$(find "${LOCAL_IMAGE_DIR}" -maxdepth 1 -type f -name '*.tar' | wc -l | tr -d ' ')"
  manifests="$(find "${LOCAL_MANIFEST_DIR}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) | wc -l | tr -d ' ')"
  if [[ "${actual}" -lt "${expected}" || "${expected}" -eq 0 ]]; then
    printf '[FAIL] image tar count mismatch: expected=%s actual=%s\n' "${expected}" "${actual}" >&2
    exit 1
  fi
  if [[ "${manifests}" -eq 0 ]]; then
    printf '[FAIL] no service manifests found: %s\n' "${LOCAL_MANIFEST_DIR}" >&2
    exit 1
  fi
  printf '[OK] local assets verified for %s\n' "${SERVICE_ID}"
  printf '[RESULT] SUCCESS\n'
}

service_transfer_assets() {
  service_init
  local host_ip host_name rsync_target ssh_config_info host_alias ssh_config_path
  for host in master worker1; do
    if [[ "${host}" == "master" ]]; then
      host_ip="${AIRGAP_MASTER_PRIVATE_IP}"
      host_name="${AIRGAP_MASTER_HOST}"
    else
      host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
      host_name="${AIRGAP_WORKER1_HOST}"
    fi
    printf '[STEP] transfer %s assets to %s\n' "${SERVICE_ID}" "${host_name}"
    remote_cmd "${host_ip}" "mkdir -p ${REMOTE_STAGING_DIR}/images ${REMOTE_STAGING_DIR}/manifests"
    ssh_config_info="$(service_write_rsync_ssh_config "${host}" "${host_ip}")"
    host_alias="${ssh_config_info%% *}"
    ssh_config_path="${ssh_config_info#* }"
    rsync_target="${host_alias}:${REMOTE_STAGING_DIR}"
    if [[ "${host}" == "master" ]]; then
      rsync -az --partial --inplace --delete -e "ssh -F ${ssh_config_path}" \
        "${LOCAL_MANIFEST_DIR}/" "${rsync_target}/manifests/"
      remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
rm -rf ${REMOTE_MANIFEST_DIR} ${REMOTE_IMAGE_DIR}
mkdir -p ${REMOTE_MANIFEST_DIR}
cp -a ${REMOTE_STAGING_DIR}/manifests/. ${REMOTE_MANIFEST_DIR}/
rm -rf ${REMOTE_STAGING_DIR}
'"
    else
      rsync -az --partial --inplace --delete -e "ssh -F ${ssh_config_path}" \
        "${LOCAL_IMAGE_DIR}/" "${rsync_target}/images/"
      remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
rm -rf ${REMOTE_IMAGE_DIR}
mkdir -p ${REMOTE_IMAGE_DIR}
cp -a ${REMOTE_STAGING_DIR}/images/. ${REMOTE_IMAGE_DIR}/
rm -rf ${REMOTE_STAGING_DIR}
'"
    fi
  done
  printf '[RESULT] SUCCESS\n'
}

service_import_images() {
  service_init
  local host_ip host_name
  for host in worker1; do
    host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
    host_name="${AIRGAP_WORKER1_HOST}"
    printf '[STEP] import %s images on %s\n' "${SERVICE_ID}" "${host_name}"
    remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
image_dir=${REMOTE_IMAGE_DIR}
test -d \"\$image_dir\"
while IFS= read -r -d \"\" image_tar; do
  ctr -n k8s.io images import \"\$image_tar\" >/dev/null
done < <(find \"\$image_dir\" -maxdepth 1 -name \"*.tar\" -print0 | sort -z)
if [[ \"${KEEP_REMOTE_SERVICE_IMAGE_TARS}\" != \"true\" ]]; then
  find \"\$image_dir\" -maxdepth 1 -name \"*.tar\" -delete
fi
'"
  done
  printf '[RESULT] SUCCESS\n'
}

service_wait_nodes_schedulable() {
  service_init
  printf '[CHECK] nodes are schedulable for service workloads\n'
  remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
for attempt in $(seq 1 36); do
  taints="$(kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{" "}{range .spec.taints[*]}{.key}:{.effect}{" "}{end}{"\n"}{end}')"
  if ! grep -q 'node.kubernetes.io/disk-pressure:NoSchedule' <<<"${taints}"; then
    printf '[OK] no disk-pressure NoSchedule taint found\n'
    exit 0
  fi
  printf '[WAIT] disk-pressure taint still present, retry=%s/36\n' "${attempt}"
  sleep 10
done
printf '[FAIL] disk-pressure taint still blocks service scheduling\n' >&2
kubectl get nodes -o wide >&2
kubectl describe nodes | grep -E 'Name:|Taints:|DiskPressure|ImageGC|eviction' >&2 || true
exit 1
REMOTE
  printf '[RESULT] SUCCESS\n'
}

service_apply_manifests() {
  service_init
  service_wait_nodes_schedulable
  printf '[STEP] apply manifests for %s on %s\n' "${SERVICE_ID}" "${AIRGAP_MASTER_HOST}"
  remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc '
set -euo pipefail
manifest_dir=${REMOTE_MANIFEST_DIR}
test -d \"\$manifest_dir\"
export KUBECONFIG=/etc/kubernetes/admin.conf
find \"\$manifest_dir\" -maxdepth 1 -type f \( -name \"*.yaml\" -o -name \"*.yml\" \) -print0 |
  sort -z |
  xargs -0 -r kubectl apply -f
'"
  printf '[RESULT] SUCCESS\n'
}

service_verify_remote_images() {
  service_init
  local host_ip host_name image
  for host in worker1; do
    host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
    host_name="${AIRGAP_WORKER1_HOST}"
    printf '[CHECK] imported images for %s on %s\n' "${SERVICE_ID}" "${host_name}"
    while IFS= read -r image; do
      remote_cmd "${host_ip}" "sudo bash -lc 'ctr -n k8s.io images list | grep -Fq \"${image}\"'"
    done < <(service_images)
    printf '[OK] imported images verified for %s on %s\n' "${SERVICE_ID}" "${host_name}"
  done
  printf '[RESULT] SUCCESS\n'
}

service_verify_workload() {
  service_init
  printf '[CHECK] workload for %s\n' "${SERVICE_ID}"
  remote_master_bash <<REMOTE
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl -n "${SERVICE_NAMESPACE}" rollout status "${SERVICE_WORKLOAD}" --timeout="${SERVICE_ROLLOUT_TIMEOUT:-300s}" >/dev/null
kubectl -n "${SERVICE_NAMESPACE}" wait --for=condition=Ready pod -l "${SERVICE_POD_SELECTOR}" --timeout="${SERVICE_ROLLOUT_TIMEOUT:-300s}" >/dev/null
for pvc in ${SERVICE_PVC_NAMES:-}; do
  phase="\$(kubectl -n "${SERVICE_NAMESPACE}" get pvc "\${pvc}" -o jsonpath='{.status.phase}')"
  if [[ "\${phase}" != "Bound" ]]; then
    printf '[FAIL] PVC is not Bound: %s phase=%s\n' "\${pvc}" "\${phase}" >&2
    exit 1
  fi
done
for svc in ${SERVICE_SERVICE_NAMES:-}; do
  kubectl -n "${SERVICE_NAMESPACE}" get service "\${svc}" >/dev/null
done
REMOTE
  printf '[RESULT] SUCCESS\n'
}
