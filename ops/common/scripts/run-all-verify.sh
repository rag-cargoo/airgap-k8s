#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${PROJECT_ROOT}"

if [[ -t 1 ]]; then
  COLOR_GREEN=$'\033[32m'
  COLOR_RED=$'\033[31m'
  COLOR_YELLOW=$'\033[33m'
  COLOR_CYAN=$'\033[36m'
  COLOR_RESET=$'\033[0m'
else
  COLOR_GREEN=''
  COLOR_RED=''
  COLOR_YELLOW=''
  COLOR_CYAN=''
  COLOR_RESET=''
fi

LOG_DIR="${PROJECT_ROOT}/.codex/tmp/all-verify"
mkdir -p "${LOG_DIR}"

STAGE_LABELS=()
STAGE_RESULTS=()
STAGE_LOGS=()
FAILED=0
PENDING=0

status_color() {
  case "$1" in
    성공) printf '%s' "${COLOR_GREEN}" ;;
    실패) printf '%s' "${COLOR_RED}" ;;
    *) printf '%s' "${COLOR_YELLOW}" ;;
  esac
}

record_stage() {
  local label="$1"
  local result="$2"
  local log_file="$3"
  STAGE_LABELS+=("${label}")
  STAGE_RESULTS+=("${result}")
  STAGE_LOGS+=("${log_file}")
}

run_verify() {
  local label="$1"
  shift
  local stage_no log_file
  stage_no=$((${#STAGE_LABELS[@]} + 1))
  log_file="${LOG_DIR}/step-${stage_no}.log"
  : > "${log_file}"
  {
    printf '[COMMAND]'
    printf ' %q' "$@"
    printf '\n\n'
  } >> "${log_file}"

  if "$@" >>"${log_file}" 2>&1; then
    record_stage "${label}" "성공" "${log_file}"
    return 0
  fi

  FAILED=$((FAILED + 1))
  record_stage "${label}" "실패" "${log_file}"
  return 1
}

run_pending() {
  local label="$1"
  local reason="$2"
  local stage_no log_file
  stage_no=$((${#STAGE_LABELS[@]} + 1))
  log_file="${LOG_DIR}/step-${stage_no}.log"
  printf '%s\n' "${reason}" > "${log_file}"
  PENDING=$((PENDING + 1))
  record_stage "${label}" "미실행" "${log_file}"
}

make_target_exists() {
  local target="$1"
  make -qp 2>/dev/null | awk -F: -v target="${target}" '
    $1 == target {
      found = 1
    }
    END {
      exit found ? 0 : 1
    }
  '
}

run_verify "00-01 프로젝트 루트 확인" make 00-01-project-root-check || true
run_verify "01-01 Terraform 실습 환경 검증" make 01-01-terraform-verify || true
run_verify "01-02 환경변수 준비 및 로드 검증" bash -lc '
  make 01-02-env-file-verify &&
  source ops/01-airgap-linux-environment/scripts/load-project-env.sh &&
  make 01-02-env-vars-verify
' || true
run_verify "01-03 오프라인 자산 준비 검증" make 01-03-offline-assets-verify || true
run_verify "공통 bastion 실행 원본 번들 검증" make ops-runtime-bundle-verify || true
run_verify "02-01 사용자 및 네트워크 설정 실제 적용 검증" make 02-01-user-network-verify || true
run_verify "03-01 master/worker 원격 preflight 검증" make 03-01-preflight-verify || true
run_verify "manual-kubeadm 01~10 실제 설치 검증" make 03-02-manual-kubeadm-verify || true

if make_target_exists "03-03-ansible-kubeadm-verify"; then
  run_verify "ansible-kubeadm 01~06 실제 실행 검증" make 03-03-ansible-kubeadm-verify || true
else
  run_pending "ansible-kubeadm 01~06 실제 실행 검증" "03-03-ansible-kubeadm-verify target is not implemented yet."
fi

OVERALL_TOTAL=${#STAGE_LABELS[@]}
OVERALL_SUCCESS=0
OVERALL_FAILED=0
OVERALL_PENDING=0
for result in "${STAGE_RESULTS[@]}"; do
  case "${result}" in
    성공) OVERALL_SUCCESS=$((OVERALL_SUCCESS + 1)) ;;
    실패) OVERALL_FAILED=$((OVERALL_FAILED + 1)) ;;
    *) OVERALL_PENDING=$((OVERALL_PENDING + 1)) ;;
  esac
done

CURRENT_STAGE="전체 단계 완료"
NEXT_ACTION="없음"
for i in "${!STAGE_LABELS[@]}"; do
  if [[ "${STAGE_RESULTS[$i]}" == "미실행" ]]; then
    CURRENT_STAGE="${STAGE_LABELS[$i]} 대기"
    NEXT_ACTION="${STAGE_LABELS[$i]} target 작성 또는 실행"
    break
  fi
  if [[ "${STAGE_RESULTS[$i]}" == "실패" ]]; then
    CURRENT_STAGE="${STAGE_LABELS[$i]} 실패"
    NEXT_ACTION="${STAGE_LABELS[$i]} 수정 필요"
    break
  fi
done

printf '\n%s==================================================%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
printf '%s[전체 단계 Verify 실행 결과]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
for i in "${!STAGE_LABELS[@]}"; do
  color="$(status_color "${STAGE_RESULTS[$i]}")"
  printf '%s- [%02d/%02d] %s : %s%s\n' \
    "${color}" "$((i + 1))" "${OVERALL_TOTAL}" "${STAGE_LABELS[$i]}" "${STAGE_RESULTS[$i]}" "${COLOR_RESET}"
done

printf '\n%s[요약]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
printf '전체 verify 성공: %d/%d\n' "${OVERALL_SUCCESS}" "${OVERALL_TOTAL}"
printf '전체 verify 미실행: %d/%d\n' "${OVERALL_PENDING}" "${OVERALL_TOTAL}"
printf '전체 verify 실패: %d/%d\n' "${OVERALL_FAILED}" "${OVERALL_TOTAL}"

if [[ "${OVERALL_FAILED}" -gt 0 ]]; then
  printf '%s현재 단계: 실패 단계 수정 필요%s\n' "${COLOR_RED}" "${COLOR_RESET}"
elif [[ "${OVERALL_PENDING}" -eq 0 ]]; then
  printf '%s현재 단계: 전체 verify 완료%s\n' "${COLOR_GREEN}" "${COLOR_RESET}"
else
  printf '%s현재 단계: %s%s\n' "${COLOR_YELLOW}" "${CURRENT_STAGE}" "${COLOR_RESET}"
fi

if [[ "${OVERALL_FAILED}" -gt 0 ]]; then
  printf '\n%s[Verify 실패 로그]%s\n' "${COLOR_RED}" "${COLOR_RESET}"
  for i in "${!STAGE_LABELS[@]}"; do
    if [[ "${STAGE_RESULTS[$i]}" == "실패" ]]; then
      printf '  - %s\n' "${STAGE_LABELS[$i]}"
      printf '    로그: %s\n' "${STAGE_LOGS[$i]}"
      tail -n 10 "${STAGE_LOGS[$i]}" || true
    fi
  done
fi

if [[ "${OVERALL_FAILED}" -eq 0 && "${OVERALL_PENDING}" -gt 0 ]]; then
  printf '%s다음 작업: %s%s\n' "${COLOR_GREEN}" "${NEXT_ACTION}" "${COLOR_RESET}"
fi

if [[ "${ALL_VERIFY_VERBOSE:-false}" == "true" ]]; then
  printf '\n%s[Verify 상세 로그 경로]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
  for i in "${!STAGE_LABELS[@]}"; do
    color="$(status_color "${STAGE_RESULTS[$i]}")"
    printf '%s- [%02d/%02d] %s : %s%s\n' \
      "${color}" "$((i + 1))" "${OVERALL_TOTAL}" "${STAGE_LABELS[$i]}" "${STAGE_RESULTS[$i]}" "${COLOR_RESET}"
    printf '  로그: %s\n' "${STAGE_LOGS[$i]}"
  done
fi

printf '%s==================================================%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"

if [[ "${OVERALL_FAILED}" -gt 0 ]]; then
  exit 1
fi
