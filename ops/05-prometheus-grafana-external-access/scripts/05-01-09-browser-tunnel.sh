#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/05-external-access-lib.sh"

ACTION="${1:-start}"
TUNNEL_BIND_HOST="${AIRGAP_EXTERNAL_ACCESS_TUNNEL_BIND_HOST:-127.0.0.1}"
INGRESS_TUNNEL_PORT="${AIRGAP_EXTERNAL_ACCESS_TUNNEL_INGRESS_PORT:-18080}"
GRAFANA_TUNNEL_PORT="${AIRGAP_GRAFANA_TUNNEL_PORT:-13000}"
PROMETHEUS_TUNNEL_PORT="${AIRGAP_PROMETHEUS_TUNNEL_PORT:-19090}"
TUNNEL_DIR="/tmp"
CONTROL_SOCKET="${TUNNEL_DIR}/airgap-k8s-05-browser-${USER:-user}.sock"
LOG_DIR="${PROJECT_ROOT}/.codex/runtime/tunnels"
TUNNEL_LOG="${LOG_DIR}/airgap-05-browser-tunnel.log"

tunnel_running() {
  [[ -S "${CONTROL_SOCKET}" ]] || return 1
  ssh -S "${CONTROL_SOCKET}" -O check \
    -p "${AIRGAP_SSH_PORT}" \
    -i "${AIRGAP_SSH_KEY_PATH}" \
    "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" >/dev/null 2>&1
}

print_access_info() {
  printf '[INFO] Grafana direct URL: http://%s:%s\n' "${TUNNEL_BIND_HOST}" "${GRAFANA_TUNNEL_PORT}"
  printf '[INFO] Prometheus direct URL: http://%s:%s\n' "${TUNNEL_BIND_HOST}" "${PROMETHEUS_TUNNEL_PORT}"
  printf '[INFO] Ingress tunnel URL after hosts mapping: http://%s:%s\n' "${GRAFANA_HOST}" "${INGRESS_TUNNEL_PORT}"
  printf '[INFO] hosts mapping for ingress tunnel: %s %s %s\n' "${TUNNEL_BIND_HOST}" "${GRAFANA_HOST}" "${PROMETHEUS_HOST}"
  printf '[INFO] Grafana login: admin / airgap-grafana-pass\n'
}

start_tunnel() {
  local attempt
  external_access_init
  mkdir -p "${TUNNEL_DIR}" "${LOG_DIR}"

  if tunnel_running; then
    printf '[OK] browser tunnel already running\n'
    print_access_info
    return 0
  fi

  local endpoints lb_ip grafana_ip prometheus_ip
  endpoints="$(remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
lb_ip="$(kubectl -n ingress-nginx get svc ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
grafana_ip="$(kubectl -n monitoring get svc grafana -o jsonpath='{.spec.clusterIP}')"
prometheus_ip="$(kubectl -n monitoring get svc prometheus -o jsonpath='{.spec.clusterIP}')"
if [[ -z "${lb_ip}" || -z "${grafana_ip}" || -z "${prometheus_ip}" ]]; then
  printf '[FAIL] missing service IP. lb=%s grafana=%s prometheus=%s\n' "${lb_ip}" "${grafana_ip}" "${prometheus_ip}" >&2
  exit 1
fi
printf '%s %s %s\n' "${lb_ip}" "${grafana_ip}" "${prometheus_ip}"
REMOTE
)"
  read -r lb_ip grafana_ip prometheus_ip <<<"${endpoints}"

  printf '[STEP] open browser tunnel through %s\n' "${AIRGAP_MASTER_HOST}"
  printf '[INFO] ingress target: %s:80\n' "${lb_ip}"
  printf '[INFO] grafana target: %s:3000\n' "${grafana_ip}"
  printf '[INFO] prometheus target: %s:9090\n' "${prometheus_ip}"

  rm -f "${CONTROL_SOCKET}" "${TUNNEL_LOG}"
  if command -v setsid >/dev/null 2>&1; then
    setsid ssh -M -S "${CONTROL_SOCKET}" -N \
      -o ExitOnForwardFailure=yes \
      -o ServerAliveInterval=30 \
      -p "${AIRGAP_SSH_PORT}" \
      -i "${AIRGAP_SSH_KEY_PATH}" \
      "${PROXY_ARGS[@]}" \
      -L "${TUNNEL_BIND_HOST}:${INGRESS_TUNNEL_PORT}:${lb_ip}:80" \
      -L "${TUNNEL_BIND_HOST}:${GRAFANA_TUNNEL_PORT}:${grafana_ip}:3000" \
      -L "${TUNNEL_BIND_HOST}:${PROMETHEUS_TUNNEL_PORT}:${prometheus_ip}:9090" \
      "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" >"${TUNNEL_LOG}" 2>&1 &
  else
    nohup ssh -M -S "${CONTROL_SOCKET}" -N \
      -o ExitOnForwardFailure=yes \
      -o ServerAliveInterval=30 \
      -p "${AIRGAP_SSH_PORT}" \
      -i "${AIRGAP_SSH_KEY_PATH}" \
      "${PROXY_ARGS[@]}" \
      -L "${TUNNEL_BIND_HOST}:${INGRESS_TUNNEL_PORT}:${lb_ip}:80" \
      -L "${TUNNEL_BIND_HOST}:${GRAFANA_TUNNEL_PORT}:${grafana_ip}:3000" \
      -L "${TUNNEL_BIND_HOST}:${PROMETHEUS_TUNNEL_PORT}:${prometheus_ip}:9090" \
      "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" >"${TUNNEL_LOG}" 2>&1 &
  fi

  for attempt in 1 2 3 4 5 6 7 8 9 10; do
    if tunnel_running; then
      printf '[RESULT] SUCCESS\n'
      print_access_info
      return 0
    fi
    sleep 0.5
  done

  printf '[FAIL] browser tunnel start failed\n' >&2
  if [[ -s "${TUNNEL_LOG}" ]]; then
    cat "${TUNNEL_LOG}" >&2
  fi
  rm -f "${CONTROL_SOCKET}"
  exit 1
}

stop_tunnel() {
  external_access_init
  if tunnel_running; then
    ssh -S "${CONTROL_SOCKET}" -O exit \
      -p "${AIRGAP_SSH_PORT}" \
      -i "${AIRGAP_SSH_KEY_PATH}" \
      "${PROXY_ARGS[@]}" \
      "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" >/dev/null 2>&1 || true
    printf '[OK] browser tunnel stopped\n'
  else
    printf '[OK] browser tunnel is not running\n'
  fi
  rm -f "${CONTROL_SOCKET}"
}

status_tunnel() {
  external_access_init
  if tunnel_running; then
    printf '[OK] browser tunnel running\n'
    print_access_info
  else
    printf '[INFO] browser tunnel stopped\n'
    exit 1
  fi
}

case "${ACTION}" in
  start)
    start_tunnel
    ;;
  stop)
    stop_tunnel
    ;;
  status)
    status_tunnel
    ;;
  *)
    printf 'Usage: %s [start|stop|status]\n' "$0" >&2
    exit 1
    ;;
esac
