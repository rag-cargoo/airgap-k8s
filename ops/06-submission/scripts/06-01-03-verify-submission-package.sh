#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SUBMISSION_DIR="${PROJECT_ROOT}/delivery/submission"
MANUAL_DIR="${SUBMISSION_DIR}/01-manual-source-convert-to-hwpx-pdf"
ZIP_DIR="${SUBMISSION_DIR}/02-server-config-zip-attach-this"
FINAL_DIR="${SUBMISSION_DIR}/03-final-email-attachments"
VERIFY_DIR="${SUBMISSION_DIR}/04-verification-evidence"
MANUAL_MD="${MANUAL_DIR}/airgap-k8s-manual.md"
MANUAL_HTML="${MANUAL_DIR}/airgap-k8s-manual.html"
ZIP_PATH="${ZIP_DIR}/airgap-k8s-server-configs.zip"
FINAL_ZIP_PATH="${FINAL_DIR}/airgap-k8s-server-configs.zip"
ZIP_LIST="${VERIFY_DIR}/airgap-k8s-server-configs.entries.txt"

failures=0

fail() {
  printf '[FAIL] %s\n' "$1" >&2
  failures=$((failures + 1))
}

ok() {
  printf '[OK] %s\n' "$1"
}

check_file() {
  local path="$1"
  if [[ -f "${path}" ]]; then
    ok "file exists: ${path}"
  else
    fail "missing file: ${path}"
  fi
}

check_contains() {
  local path="$1"
  local pattern="$2"
  if grep -qF "${pattern}" "${path}"; then
    ok "manual contains: ${pattern}"
  else
    fail "manual missing: ${pattern}"
  fi
}

check_zip_entry() {
  local entry="$1"
  if grep -qxF "${entry}" "${ZIP_LIST}"; then
    ok "zip entry: ${entry}"
  else
    fail "zip missing entry: ${entry}"
  fi
}

check_zip_not_matching() {
  local pattern="$1"
  if grep -E "${pattern}" "${ZIP_LIST}" >/dev/null; then
    fail "zip contains forbidden pattern: ${pattern}"
    grep -E "${pattern}" "${ZIP_LIST}" | sed 's/^/[FORBIDDEN] /' >&2
  else
    ok "zip excludes pattern: ${pattern}"
  fi
}

printf '[1/5] [CHECK] generated submission files\n'
check_file "${MANUAL_MD}"
check_file "${MANUAL_HTML}"
check_file "${ZIP_PATH}"
check_file "${FINAL_ZIP_PATH}"

printf '[2/5] [CHECK] manual required technical sections\n'
check_contains "${MANUAL_MD}" "실습 환경 구성 안내"
check_contains "${MANUAL_MD}" "폐쇄망 반입 방식"
check_contains "${MANUAL_MD}" "StorageClass 사용 이유"
check_contains "${MANUAL_MD}" "local-path-provisioner"
check_contains "${MANUAL_MD}" "MetalLB와 ingress-nginx 사용 이유"
check_contains "${MANUAL_MD}" "Grafana.com community dashboard JSON"
check_contains "${MANUAL_MD}" "/opt/offline-assets"
check_contains "${MANUAL_MD}" "/opt/airgap-k8s-ops"
check_contains "${MANUAL_MD}" "홍구"
check_contains "${MANUAL_MD}" "akinux1004@gmail.com"

printf '[3/5] [CHECK] archive entries\n'
if [[ -f "${ZIP_PATH}" ]]; then
  mkdir -p "${VERIFY_DIR}"
  zipinfo -1 "${ZIP_PATH}" > "${ZIP_LIST}"
fi

check_zip_entry "airgap-k8s-server-configs/ops/03-kubernetes-cluster/storageclass/scripts/03-03-03-run-storageclass-apply.sh"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/03-prometheus/manifests/04-03-prometheus.yaml"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/04-grafana/manifests/04-04-grafana.yaml"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/04-grafana/dashboards/1860-node-exporter-full.json"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/04-grafana/dashboards/25091-kube-state-metrics-overview.json"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/04-grafana/dashboards/17483-kubernetes-cluster-monitoring.json"
check_zip_entry "airgap-k8s-server-configs/ops/04-services-monitoring/05-grafana-alloy/manifests/04-05-grafana-alloy.yaml"
check_zip_entry "airgap-k8s-server-configs/ops/05-prometheus-grafana-external-access/manifests/05-03-metallb-address-pool.yaml.template"
check_zip_entry "airgap-k8s-server-configs/ops/05-prometheus-grafana-external-access/manifests/05-04-ingress-nginx-service.yaml.template"
check_zip_entry "airgap-k8s-server-configs/ops/05-prometheus-grafana-external-access/manifests/05-05-monitoring-ingress.yaml.template"
check_zip_entry "airgap-k8s-server-configs/ops/01-airgap-linux-environment/scripts/download-k8s-offline-assets.sh"

printf '[4/5] [CHECK] archive exclusions\n'
check_zip_not_matching '(^|/)\.env$'
check_zip_not_matching '(^|/)\.kube(/|$)'
check_zip_not_matching '(^|/)\.terraform(/|$)'
check_zip_not_matching 'terraform\.tfvars$'
check_zip_not_matching 'terraform\.tfstate'
check_zip_not_matching '(^|/)tfplan$'
check_zip_not_matching '\.pem$'
check_zip_not_matching '\.key$'
check_zip_not_matching '(^|/)offline-assets(/|$)|offline-assets\.tar\.gz$'
check_zip_not_matching '(^|/)ops-runtime(/|$)|ops-runtime\.tar\.gz$'
check_zip_not_matching 'aws-terraform-simulation'

printf '[5/5] [CHECK] mail attachment size hint\n'
if [[ -f "${ZIP_PATH}" ]]; then
  size_bytes="$(stat -c '%s' "${ZIP_PATH}")"
  if [[ "${size_bytes}" -le 25000000 ]]; then
    ok "zip size is under 25MB mail attachment threshold: ${size_bytes} bytes"
  else
    fail "zip size exceeds 25MB mail attachment threshold: ${size_bytes} bytes"
  fi
fi

if [[ "${failures}" -ne 0 ]]; then
  printf '\n[RESULT] FAILED\n'
  printf '[INFO] failures: %s\n' "${failures}"
  exit 1
fi

printf '\n[RESULT] SUCCESS\n'
printf '[OK] submission package verified\n'
