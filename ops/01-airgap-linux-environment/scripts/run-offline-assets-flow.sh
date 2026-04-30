#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${PROJECT_ROOT}"

START_TS="$(date +%s)"
TOTAL_STEPS=5
CURRENT_STEP=0
FAILED_STEPS=()
FAILED_LOGS=()

format_duration() {
  local seconds="$1"
  printf '%02dm %02ds' $((seconds / 60)) $((seconds % 60))
}

run_step() {
  local label="$1"
  shift
  local cmd=("$@")
  local log_file

  CURRENT_STEP=$((CURRENT_STEP + 1))
  local step_start_ts
  step_start_ts="$(date +%s)"
  log_file="$(mktemp)"

  echo
  echo "[${CURRENT_STEP}/${TOTAL_STEPS}] [CHECK] ${label}"
  echo "[INFO] command: ${cmd[*]}"

  set +e
  "${cmd[@]}" > >(tee "${log_file}") 2> >(tee -a "${log_file}" >&2)
  local exit_code=$?
  set -e

  local step_end_ts
  step_end_ts="$(date +%s)"
  local step_elapsed=$((step_end_ts - step_start_ts))
  local total_elapsed=$((step_end_ts - START_TS))

  if [[ "${exit_code}" -eq 0 ]]; then
    echo "[OK] ${label}"
    echo "[INFO] step elapsed: $(format_duration "${step_elapsed}")"
    echo "[INFO] total elapsed: $(format_duration "${total_elapsed}")"
    rm -f "${log_file}"
    return 0
  fi

  echo "[FAIL] ${label}"
  echo "[INFO] step elapsed: $(format_duration "${step_elapsed}")"
  echo "[INFO] total elapsed: $(format_duration "${total_elapsed}")"
  FAILED_STEPS+=("${label} :: ${cmd[*]}")
  FAILED_LOGS+=("${log_file}")
  return "${exit_code}"
}

print_failure_summary() {
  local end_ts total_elapsed
  end_ts="$(date +%s)"
  total_elapsed=$((end_ts - START_TS))

  echo
  echo "[RESULT] FAILED"
  echo "[INFO] completed steps: $((CURRENT_STEP - 1))/${TOTAL_STEPS}"
  echo "[INFO] total elapsed: $(format_duration "${total_elapsed}")"
  echo
  echo "[FAILED STEPS]"

  local i
  for i in "${!FAILED_STEPS[@]}"; do
    echo "$((i + 1)). ${FAILED_STEPS[$i]}"
    echo "[LOG TAIL]"
    tail -n 20 "${FAILED_LOGS[$i]}" || true
  done
}

run_step "작업 원본 자산 경로 확인" make step-01-03-01-assets-tree-check || { print_failure_summary; exit 1; }
run_step "쿠버네티스 설치용 자산 다운로드" make step-01-03-02-k8s-assets-download || { print_failure_summary; exit 1; }
run_step "쿠버네티스 설치용 자산 검증" make step-01-03-03-k8s-assets-verify || { print_failure_summary; exit 1; }
run_step "서버 반입용 번들 생성" make step-01-03-04-bundle-create || { print_failure_summary; exit 1; }
run_step "서버 반입용 번들 검증" make step-01-03-05-bundle-verify || { print_failure_summary; exit 1; }

END_TS="$(date +%s)"
TOTAL_ELAPSED=$((END_TS - START_TS))
K8S_DEB_COUNT="$(find assets/offline-assets/kubernetes/packages/kubernetes -maxdepth 1 -name '*.deb' | wc -l | tr -d ' ')"
RUNTIME_DEB_COUNT="$(find assets/offline-assets/kubernetes/packages/container-runtime -maxdepth 1 -name '*.deb' | wc -l | tr -d ' ')"
IMAGE_TAR_COUNT="$(find assets/offline-assets/kubernetes/images/kube-system -maxdepth 1 -name '*.tar' | wc -l | tr -d ' ')"
MANIFEST_COUNT="$(find assets/offline-assets/kubernetes/manifests -maxdepth 1 -name '*.yaml' | wc -l | tr -d ' ')"
BUNDLE_SIZE="$(du -sh delivery/offline-assets.tar.gz | awk '{print $1}')"

echo
echo "[RESULT] SUCCESS"
echo "[INFO] completed steps: ${CURRENT_STEP}/${TOTAL_STEPS}"
echo "[INFO] total elapsed: $(format_duration "${TOTAL_ELAPSED}")"
echo "[INFO] summary:"
echo "[INFO]   Kubernetes deb files: ${K8S_DEB_COUNT}"
echo "[INFO]   Runtime deb files: ${RUNTIME_DEB_COUNT}"
echo "[INFO]   Kube-system image tar files: ${IMAGE_TAR_COUNT}"
echo "[INFO]   Manifest yaml files: ${MANIFEST_COUNT}"
echo "[INFO]   Bundle archive size: ${BUNDLE_SIZE}"
