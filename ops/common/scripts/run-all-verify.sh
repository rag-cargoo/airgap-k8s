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

TOTAL_PREP_STEPS=8
CURRENT_STEP=0
FAILED=0
STEP_LABELS=()
STEP_RESULTS=()
LOG_DIR="${PROJECT_ROOT}/.codex/tmp/all-verify"
STATE_DIR="${PROJECT_ROOT}/.codex/runtime/airgap-k8s-state"
mkdir -p "${LOG_DIR}" "${STATE_DIR}"

run_step() {
  local label="$1"
  shift
  local log_file
  CURRENT_STEP=$((CURRENT_STEP + 1))
  log_file="${LOG_DIR}/step-${CURRENT_STEP}.log"
  STEP_LABELS+=("${label}")
  : > "${log_file}"

  if "$@" >"${log_file}" 2>&1; then
    STEP_RESULTS+=("성공")
    return 0
  fi

  FAILED=$((FAILED + 1))
  STEP_RESULTS+=("실패")
  return 1
}

# preparation checks
run_step "00-01 프로젝트 루트 확인" make 00-01-project-root-check || true
run_step "01-01 Terraform 출력 검증" make 01-01-terraform-verify || true
run_step "01-02 survey YAML -> .env 렌더링" ./ops/03-kubernetes-cluster/common/scripts/render-env-from-survey-yaml.sh || true
run_step "01-02 환경변수 로드 검증" bash -lc 'source ops/01-airgap-linux-environment/scripts/load-project-env.sh && make 01-02-env-vars-verify' || true
run_step "01-03 오프라인 자산 준비 검증" make 01-03-offline-assets-verify || true
run_step "공통 bastion 실행 원본 번들 검증" make ops-runtime-bundle-verify || true
run_step "02-01 사용자/네트워크 스크립트 준비 검증" make 02-01-user-network-scripts-verify || true
run_step "03-01 preflight 스크립트 준비 검증" make 03-01-preflight-script-verify || true

status_color() {
  case "$1" in
    성공) printf '%s' "${COLOR_GREEN}" ;;
    실패) printf '%s' "${COLOR_RED}" ;;
    *) printf '%s' "${COLOR_YELLOW}" ;;
  esac
}

marker_status() {
  local marker="$1"
  if [[ -f "${STATE_DIR}/${marker}.done" ]]; then
    printf '성공'
  elif [[ -f "${STATE_DIR}/${marker}.failed" ]]; then
    printf '실패'
  else
    printf '미실행'
  fi
}

set_stage_status() {
  OVERALL_LABELS+=("$1")
  OVERALL_RESULTS+=("$2")
}

OVERALL_LABELS=()
OVERALL_RESULTS=()

# Map prep checks to top-level stages using real results.
set_stage_status "00-01 프로젝트 루트 확인" "${STEP_RESULTS[0]}"
set_stage_status "01-01 Terraform 실습 환경 검증" "${STEP_RESULTS[1]}"
if [[ "${STEP_RESULTS[2]}" == "성공" && "${STEP_RESULTS[3]}" == "성공" ]]; then
  set_stage_status "01-02 환경변수 준비 및 로드 검증" "성공"
elif [[ "${STEP_RESULTS[2]}" == "실패" || "${STEP_RESULTS[3]}" == "실패" ]]; then
  set_stage_status "01-02 환경변수 준비 및 로드 검증" "실패"
else
  set_stage_status "01-02 환경변수 준비 및 로드 검증" "미실행"
fi
set_stage_status "01-03 오프라인 자산 준비 검증" "${STEP_RESULTS[4]}"
set_stage_status "공통 bastion 실행 원본 번들 검증" "${STEP_RESULTS[5]}"
set_stage_status "02-01 사용자 및 네트워크 설정 실제 적용" "$(marker_status 02-01-user-network-apply)"
set_stage_status "03-01 master/worker 원격 preflight" "$(marker_status 03-01-remote-preflight)"
set_stage_status "manual-kubeadm 01~06 실제 설치" "$(marker_status 03-manual-kubeadm-install)"
set_stage_status "ansible-kubeadm 01~06 실제 실행" "$(marker_status 03-ansible-kubeadm-run)"

OVERALL_TOTAL=${#OVERALL_LABELS[@]}
OVERALL_SUCCESS=0
OVERALL_FAILED=0
OVERALL_PENDING=0
for result in "${OVERALL_RESULTS[@]}"; do
  case "${result}" in
    성공) OVERALL_SUCCESS=$((OVERALL_SUCCESS + 1)) ;;
    실패) OVERALL_FAILED=$((OVERALL_FAILED + 1)) ;;
    *) OVERALL_PENDING=$((OVERALL_PENDING + 1)) ;;
  esac
done

CURRENT_STAGE="전체 단계 완료"
NEXT_ACTION="없음"
for i in "${!OVERALL_LABELS[@]}"; do
  if [[ "${OVERALL_RESULTS[$i]}" == "미실행" ]]; then
    CURRENT_STAGE="${OVERALL_LABELS[$i]} 대기"
    NEXT_ACTION="${OVERALL_LABELS[$i]} 시작 가능"
    break
  fi
  if [[ "${OVERALL_RESULTS[$i]}" == "실패" ]]; then
    CURRENT_STAGE="${OVERALL_LABELS[$i]} 실패"
    NEXT_ACTION="${OVERALL_LABELS[$i]} 수정 필요"
    break
  fi
done

printf '\n%s==================================================%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
printf '%s[전체 단계 상태]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
for i in "${!OVERALL_LABELS[@]}"; do
  color="$(status_color "${OVERALL_RESULTS[$i]}")"
  printf '%s- [%02d/%02d] %s : %s%s\n' \
    "${color}" "$((i + 1))" "${OVERALL_TOTAL}" "${OVERALL_LABELS[$i]}" "${OVERALL_RESULTS[$i]}" "${COLOR_RESET}"
done

printf '\n%s[요약]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
printf '전체 단계 성공: %d/%d\n' "${OVERALL_SUCCESS}" "${OVERALL_TOTAL}"
printf '전체 단계 미실행: %d/%d\n' "${OVERALL_PENDING}" "${OVERALL_TOTAL}"
printf '전체 단계 실패: %d/%d\n' "${OVERALL_FAILED}" "${OVERALL_TOTAL}"

if [[ "${OVERALL_FAILED}" -gt 0 ]]; then
  printf '%s현재 단계: 실패 단계 수정 필요%s\n' "${COLOR_RED}" "${COLOR_RESET}"
elif [[ "${OVERALL_PENDING}" -eq 0 ]]; then
  printf '%s현재 단계: 전체 단계 완료%s\n' "${COLOR_GREEN}" "${COLOR_RESET}"
else
  printf '%s현재 단계: %s%s\n' "${COLOR_YELLOW}" "${CURRENT_STAGE}" "${COLOR_RESET}"
fi

if [[ "${FAILED}" -gt 0 ]]; then
  printf '\n%s[준비 검증 실패 로그]%s\n' "${COLOR_RED}" "${COLOR_RESET}"
  for i in "${!STEP_LABELS[@]}"; do
    if [[ "${STEP_RESULTS[$i]}" == "실패" ]]; then
      printf '  - %s\n' "${STEP_LABELS[$i]}"
      printf '    로그: %s\n' "${LOG_DIR}/step-$((i + 1)).log"
      tail -n 10 "${LOG_DIR}/step-$((i + 1)).log" || true
    fi
  done
fi

if [[ "${OVERALL_FAILED}" -eq 0 && "${OVERALL_PENDING}" -gt 0 ]]; then
  printf '%s다음 작업: %s%s\n' "${COLOR_GREEN}" "${NEXT_ACTION}" "${COLOR_RESET}"
fi

if [[ "${ALL_VERIFY_VERBOSE:-false}" == "true" ]]; then
  printf '\n%s[준비 검증 상세]%s\n' "${COLOR_CYAN}" "${COLOR_RESET}"
  for i in "${!STEP_LABELS[@]}"; do
    color="$(status_color "${STEP_RESULTS[$i]}")"
    printf '%s- [%02d/%02d] %s : %s%s\n' \
      "${color}" "$((i + 1))" "${TOTAL_PREP_STEPS}" "${STEP_LABELS[$i]}" "${STEP_RESULTS[$i]}" "${COLOR_RESET}"
  done
fi
printf '%s==================================================%s\n' "${OVERALL_FAILED:+${COLOR_RED}}${COLOR_GREEN}" "${COLOR_RESET}"

if [[ "${OVERALL_FAILED}" -gt 0 || "${FAILED}" -gt 0 ]]; then
  exit 1
fi
