#!/usr/bin/env bash

set -euo pipefail

OPS05_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_ROOT="$(cd "${OPS05_ROOT}/../.." && pwd)"

source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"
AIRGAP_MASTER_HOST="${AIRGAP_MASTER_HOST:-k8s-master}"
AIRGAP_WORKER1_HOST="${AIRGAP_WORKER1_HOST:-k8s-worker1}"
SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"
REMOTE_STAGING_ROOT="${AIRGAP_EXTERNAL_ACCESS_STAGING_DIR:-/tmp/airgap-external-access-assets}"
KEEP_REMOTE_IMAGE_TARS="${AIRGAP_KEEP_REMOTE_EXTERNAL_ACCESS_IMAGE_TARS:-false}"

METALLB_VERSION="${AIRGAP_METALLB_VERSION:-v0.15.2}"
INGRESS_NGINX_VERSION="${AIRGAP_INGRESS_NGINX_VERSION:-v1.13.2}"
METALLB_NATIVE_URL="${AIRGAP_METALLB_NATIVE_URL:-https://raw.githubusercontent.com/metallb/metallb/${METALLB_VERSION}/config/manifests/metallb-native.yaml}"
INGRESS_NGINX_DEPLOY_URL="${AIRGAP_INGRESS_NGINX_DEPLOY_URL:-https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-${INGRESS_NGINX_VERSION}/deploy/static/provider/cloud/deploy.yaml}"

METALLB_ADDRESS_POOL="${AIRGAP_METALLB_ADDRESS_POOL:-10.10.20.240-10.10.20.250}"
INGRESS_HTTP_NODE_PORT="${AIRGAP_INGRESS_HTTP_NODE_PORT:-30080}"
INGRESS_HTTPS_NODE_PORT="${AIRGAP_INGRESS_HTTPS_NODE_PORT:-30443}"
GRAFANA_HOST="${AIRGAP_GRAFANA_HOST:-grafana.airgap.local}"
PROMETHEUS_HOST="${AIRGAP_PROMETHEUS_HOST:-prometheus.airgap.local}"

IMAGE_LIST="${OPS05_ROOT}/assets/images.txt"
LOCAL_IMAGE_DIR="${PROJECT_ROOT}/assets/offline-assets/external-access/images"
LOCAL_MANIFEST_DIR="${PROJECT_ROOT}/assets/offline-assets/external-access/manifests"
REMOTE_IMAGE_DIR="${SERVER_ASSETS_DIR}/external-access/images"
REMOTE_MANIFEST_DIR="${SERVER_ASSETS_DIR}/external-access/manifests"
REMOTE_STAGING_DIR="${REMOTE_STAGING_ROOT}/external-access"

require_env_var() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

external_access_init() {
  for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP AIRGAP_WORKER1_PRIVATE_IP; do
    require_env_var "${var}"
  done
  if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
    require_env_var AIRGAP_BASTION_PUBLIC_IP
    PROXY_ARGS=(-o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}")
  else
    PROXY_ARGS=()
  fi
}

image_tar_name() {
  printf '%s' "$1" | sed 's#[/:@]#_#g'
}

external_access_images() {
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

write_rsync_ssh_config() {
  local host_key="$1"
  local host_ip="$2"
  local host_alias="airgap-05-${host_key}"
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

render_template() {
  local src="$1"
  local dst="$2"
  sed \
    -e "s#__METALLB_ADDRESS_POOL__#${METALLB_ADDRESS_POOL}#g" \
    -e "s#__INGRESS_HTTP_NODE_PORT__#${INGRESS_HTTP_NODE_PORT}#g" \
    -e "s#__INGRESS_HTTPS_NODE_PORT__#${INGRESS_HTTPS_NODE_PORT}#g" \
    -e "s#__GRAFANA_HOST__#${GRAFANA_HOST}#g" \
    -e "s#__PROMETHEUS_HOST__#${PROMETHEUS_HOST}#g" \
    "${src}" >"${dst}"
}

download_external_access_assets() {
  external_access_init
  mkdir -p "${LOCAL_IMAGE_DIR}" "${LOCAL_MANIFEST_DIR}"
  find "${LOCAL_IMAGE_DIR}" -maxdepth 1 -type f -name '*.tar' -delete
  find "${LOCAL_MANIFEST_DIR}" -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -delete
  cp "${IMAGE_LIST}" "${LOCAL_IMAGE_DIR}/images.txt"

  printf '[STEP] download MetalLB native manifest: %s\n' "${METALLB_NATIVE_URL}"
  curl -fsSL "${METALLB_NATIVE_URL}" -o "${LOCAL_MANIFEST_DIR}/05-01-metallb-native.yaml"

  printf '[STEP] download ingress-nginx manifest: %s\n' "${INGRESS_NGINX_DEPLOY_URL}"
  curl -fsSL "${INGRESS_NGINX_DEPLOY_URL}" |
    sed -E 's/@sha256:[a-f0-9]+//g' >"${LOCAL_MANIFEST_DIR}/05-02-ingress-nginx-controller.yaml"

  render_template "${OPS05_ROOT}/manifests/05-03-metallb-address-pool.yaml.template" \
    "${LOCAL_MANIFEST_DIR}/05-03-metallb-address-pool.yaml"
  render_template "${OPS05_ROOT}/manifests/05-04-ingress-nginx-service.yaml.template" \
    "${LOCAL_MANIFEST_DIR}/05-04-ingress-nginx-service.yaml"
  render_template "${OPS05_ROOT}/manifests/05-05-monitoring-ingress.yaml.template" \
    "${LOCAL_MANIFEST_DIR}/05-05-monitoring-ingress.yaml"

  local image tar_name tar_path
  while IFS= read -r image; do
    tar_name="$(image_tar_name "${image}").tar"
    tar_path="${LOCAL_IMAGE_DIR}/${tar_name}"
    printf '[STEP] pull image: %s\n' "${image}"
    docker image inspect "${image}" >/dev/null 2>&1 || docker pull "${image}"
    printf '[STEP] save image tar: %s\n' "${tar_path}"
    docker save "${image}" -o "${tar_path}"
  done < <(external_access_images)

  printf '[RESULT] SUCCESS\n'
}

verify_external_access_assets() {
  external_access_init
  printf '[CHECK] local 05 external access assets\n'
  test -f "${LOCAL_IMAGE_DIR}/images.txt"
  test -f "${LOCAL_MANIFEST_DIR}/05-01-metallb-native.yaml"
  test -f "${LOCAL_MANIFEST_DIR}/05-02-ingress-nginx-controller.yaml"
  test -f "${LOCAL_MANIFEST_DIR}/05-03-metallb-address-pool.yaml"
  test -f "${LOCAL_MANIFEST_DIR}/05-04-ingress-nginx-service.yaml"
  test -f "${LOCAL_MANIFEST_DIR}/05-05-monitoring-ingress.yaml"

  local expected actual
  expected="$(external_access_images | wc -l | tr -d ' ')"
  actual="$(find "${LOCAL_IMAGE_DIR}" -maxdepth 1 -type f -name '*.tar' | wc -l | tr -d ' ')"
  if [[ "${actual}" -lt "${expected}" || "${expected}" -eq 0 ]]; then
    printf '[FAIL] image tar count mismatch: expected=%s actual=%s\n' "${expected}" "${actual}" >&2
    exit 1
  fi
  grep -Fq "name: airgap-lb-pool" "${LOCAL_MANIFEST_DIR}/05-03-metallb-address-pool.yaml"
  grep -Fq "${GRAFANA_HOST}" "${LOCAL_MANIFEST_DIR}/05-05-monitoring-ingress.yaml"
  grep -Fq "${PROMETHEUS_HOST}" "${LOCAL_MANIFEST_DIR}/05-05-monitoring-ingress.yaml"
  printf '[OK] local 05 assets verified\n'
  printf '[RESULT] SUCCESS\n'
}

transfer_external_access_assets() {
  external_access_init
  local host_ip host_name rsync_target ssh_config_info host_alias ssh_config_path
  for host in master worker1; do
    if [[ "${host}" == "master" ]]; then
      host_ip="${AIRGAP_MASTER_PRIVATE_IP}"
      host_name="${AIRGAP_MASTER_HOST}"
    else
      host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
      host_name="${AIRGAP_WORKER1_HOST}"
    fi
    printf '[STEP] transfer 05 assets to %s\n' "${host_name}"
    remote_cmd "${host_ip}" "mkdir -p ${REMOTE_STAGING_DIR}/images ${REMOTE_STAGING_DIR}/manifests"
    ssh_config_info="$(write_rsync_ssh_config "${host}" "${host_ip}")"
    host_alias="${ssh_config_info%% *}"
    ssh_config_path="${ssh_config_info#* }"
    rsync_target="${host_alias}:${REMOTE_STAGING_DIR}"
    rsync -az --partial --inplace --delete -e "ssh -F ${ssh_config_path}" \
      "${LOCAL_IMAGE_DIR}/" "${rsync_target}/images/"
    if [[ "${host}" == "master" ]]; then
      rsync -az --partial --inplace --delete -e "ssh -F ${ssh_config_path}" \
        "${LOCAL_MANIFEST_DIR}/" "${rsync_target}/manifests/"
    fi
    remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
rm -rf ${REMOTE_IMAGE_DIR}
mkdir -p ${REMOTE_IMAGE_DIR}
cp -a ${REMOTE_STAGING_DIR}/images/. ${REMOTE_IMAGE_DIR}/
if [[ \"${host}\" == \"master\" ]]; then
  rm -rf ${REMOTE_MANIFEST_DIR}
  mkdir -p ${REMOTE_MANIFEST_DIR}
  cp -a ${REMOTE_STAGING_DIR}/manifests/. ${REMOTE_MANIFEST_DIR}/
fi
rm -rf ${REMOTE_STAGING_DIR}
'"
  done
  printf '[RESULT] SUCCESS\n'
}

import_external_access_images() {
  external_access_init
  local host_ip host_name
  for host in master worker1; do
    if [[ "${host}" == "master" ]]; then
      host_ip="${AIRGAP_MASTER_PRIVATE_IP}"
      host_name="${AIRGAP_MASTER_HOST}"
    else
      host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
      host_name="${AIRGAP_WORKER1_HOST}"
    fi
    printf '[STEP] import 05 images on %s\n' "${host_name}"
    remote_cmd "${host_ip}" "sudo bash -lc '
set -euo pipefail
image_dir=${REMOTE_IMAGE_DIR}
test -d \"\$image_dir\"
while IFS= read -r -d \"\" image_tar; do
  ctr -n k8s.io images import \"\$image_tar\" >/dev/null
done < <(find \"\$image_dir\" -maxdepth 1 -name \"*.tar\" -print0 | sort -z)
if [[ \"${KEEP_REMOTE_IMAGE_TARS}\" != \"true\" ]]; then
  find \"\$image_dir\" -maxdepth 1 -name \"*.tar\" -delete
fi
'"
  done
  printf '[RESULT] SUCCESS\n'
}

verify_external_access_images() {
  external_access_init
  local host_ip host_name image
  for host in master worker1; do
    if [[ "${host}" == "master" ]]; then
      host_ip="${AIRGAP_MASTER_PRIVATE_IP}"
      host_name="${AIRGAP_MASTER_HOST}"
    else
      host_ip="${AIRGAP_WORKER1_PRIVATE_IP}"
      host_name="${AIRGAP_WORKER1_HOST}"
    fi
    printf '[CHECK] imported 05 images on %s\n' "${host_name}"
    while IFS= read -r image; do
      remote_cmd "${host_ip}" "sudo bash -lc 'ctr -n k8s.io images list | grep -Fq \"${image}\"'"
    done < <(external_access_images)
    printf '[OK] imported 05 images verified on %s\n' "${host_name}"
  done
  printf '[RESULT] SUCCESS\n'
}

apply_metallb() {
  external_access_init
  printf '[STEP] apply MetalLB native manifest and IP pool\n'
  remote_master_bash <<REMOTE
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "${REMOTE_MANIFEST_DIR}/05-01-metallb-native.yaml"
kubectl -n metallb-system rollout status deployment/controller --timeout=300s
kubectl -n metallb-system rollout status daemonset/speaker --timeout=300s
for attempt in \$(seq 1 30); do
  if kubectl apply -f "${REMOTE_MANIFEST_DIR}/05-03-metallb-address-pool.yaml"; then
    break
  fi
  if [[ "\${attempt}" -eq 30 ]]; then
    printf '[FAIL] MetalLB webhook did not accept IP pool resources after retries\n' >&2
    exit 1
  fi
  printf '[WAIT] MetalLB webhook not ready for IP pool resources, retry=%s/30\n' "\${attempt}"
  sleep 5
done
kubectl -n metallb-system get ipaddresspool airgap-lb-pool
kubectl -n metallb-system get l2advertisement airgap-l2
REMOTE
  printf '[RESULT] SUCCESS\n'
}

apply_ingress_nginx() {
  external_access_init
  printf '[STEP] apply ingress-nginx controller and LoadBalancer service\n'
  remote_master_bash <<REMOTE
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f "${REMOTE_MANIFEST_DIR}/05-02-ingress-nginx-controller.yaml"
kubectl apply -f "${REMOTE_MANIFEST_DIR}/05-04-ingress-nginx-service.yaml"
kubectl -n ingress-nginx wait --for=condition=complete job/ingress-nginx-admission-create --timeout=300s
kubectl -n ingress-nginx wait --for=condition=complete job/ingress-nginx-admission-patch --timeout=300s
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=300s
for attempt in \$(seq 1 60); do
  ip="\$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)"
  if [[ -n "\${ip}" ]]; then
    printf '[OK] ingress-nginx LoadBalancer IP: %s\n' "\${ip}"
    exit 0
  fi
  printf '[WAIT] ingress-nginx LoadBalancer IP pending, retry=%s/60\n' "\${attempt}"
  sleep 5
done
kubectl -n ingress-nginx get svc ingress-nginx-controller -o wide >&2
exit 1
REMOTE
  printf '[RESULT] SUCCESS\n'
}

apply_monitoring_ingress() {
  external_access_init
  printf '[STEP] apply monitoring Ingress rules\n'
  remote_master_bash <<REMOTE
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl -n monitoring rollout status deployment/grafana --timeout=300s
kubectl -n monitoring rollout status statefulset/prometheus --timeout=300s
kubectl apply -f "${REMOTE_MANIFEST_DIR}/05-05-monitoring-ingress.yaml"
kubectl -n monitoring get ingress grafana prometheus
REMOTE
  printf '[RESULT] SUCCESS\n'
}

verify_external_access() {
  external_access_init
  printf '[CHECK] MetalLB + ingress-nginx + monitoring Ingress access\n'
  remote_master_bash <<REMOTE
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl -n metallb-system rollout status deployment/controller --timeout=300s >/dev/null
kubectl -n metallb-system rollout status daemonset/speaker --timeout=300s >/dev/null
kubectl -n ingress-nginx rollout status deployment/ingress-nginx-controller --timeout=300s >/dev/null
kubectl -n monitoring get ingress grafana prometheus >/dev/null
lb_ip="\$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
if [[ -z "\${lb_ip}" ]]; then
  printf '[FAIL] ingress-nginx LoadBalancer IP is empty\n' >&2
  exit 1
fi
printf '[INFO] ingress-nginx LoadBalancer IP: %s\n' "\${lb_ip}"
kubectl -n ingress-nginx get svc ingress-nginx-controller -o wide
kubectl -n monitoring get ingress -o wide
grafana_ready=false
for attempt in \$(seq 1 30); do
  if curl -fsS -H "Host: ${GRAFANA_HOST}" "http://\${lb_ip}/api/health" >/tmp/grafana-health.json &&
    grep -Eq '"database"[[:space:]]*:[[:space:]]*"ok"' /tmp/grafana-health.json; then
    grafana_ready=true
    break
  fi
  printf '[WAIT] Grafana ingress route not ready, retry=%s/30\n' "\${attempt}"
  sleep 3
done
if [[ "\${grafana_ready}" != "true" ]]; then
  printf '[FAIL] Grafana ingress route did not become ready\n' >&2
  exit 1
fi

prometheus_ready=false
for attempt in \$(seq 1 30); do
  if curl -fsS -H "Host: ${PROMETHEUS_HOST}" "http://\${lb_ip}/-/ready" >/tmp/prometheus-ready.txt &&
    grep -Fq "Prometheus Server is Ready" /tmp/prometheus-ready.txt; then
    prometheus_ready=true
    break
  fi
  printf '[WAIT] Prometheus ingress route not ready, retry=%s/30\n' "\${attempt}"
  sleep 3
done
if [[ "\${prometheus_ready}" != "true" ]]; then
  printf '[FAIL] Prometheus ingress route did not become ready\n' >&2
  exit 1
fi
printf '[OK] Grafana host route: http://%s -> %s\n' "${GRAFANA_HOST}" "\${lb_ip}"
printf '[OK] Prometheus host route: http://%s -> %s\n' "${PROMETHEUS_HOST}" "\${lb_ip}"
REMOTE
  printf '[RESULT] SUCCESS\n'
}
