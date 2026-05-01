#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP; do
  require_env "${var}"
done

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  require_env AIRGAP_BASTION_PUBLIC_IP
  PROXY_ARGS=(-o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}")
else
  PROXY_ARGS=()
fi

ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
  "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -s" <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get namespace database monitoring >/dev/null
kubectl -n database rollout status statefulset/mariadb --timeout=300s >/dev/null
kubectl -n database rollout status statefulset/mongodb --timeout=300s >/dev/null
kubectl -n monitoring rollout status statefulset/prometheus --timeout=300s >/dev/null
kubectl -n monitoring rollout status deployment/grafana --timeout=300s >/dev/null
kubectl -n monitoring rollout status deployment/alloy --timeout=300s >/dev/null
for item in \
  database/data-mariadb-0 \
  database/data-mongodb-0 \
  monitoring/data-prometheus-0 \
  monitoring/grafana-data; do
  ns="${item%%/*}"
  pvc="${item#*/}"
  phase="$(kubectl -n "${ns}" get pvc "${pvc}" -o jsonpath='{.status.phase}')"
  if [[ "${phase}" != "Bound" ]]; then
    printf '[FAIL] PVC is not Bound: %s/%s phase=%s\n' "${ns}" "${pvc}" "${phase}" >&2
    exit 1
  fi
done
kubectl get pods -n database -o wide
kubectl get pods -n monitoring -o wide
kubectl get pvc -n database
kubectl get pvc -n monitoring
REMOTE

printf '[RESULT] SUCCESS\n'
