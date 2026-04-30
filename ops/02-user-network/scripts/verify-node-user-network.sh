#!/usr/bin/env bash

set -euo pipefail

EXPECTED_HOSTNAME=""
SELF_IP=""
SELF_NAME=""
PEER_IP=""
PEER_NAME=""
FAILURES=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --expected-hostname)
      EXPECTED_HOSTNAME="${2:-}"
      shift 2
      ;;
    --self-ip)
      SELF_IP="${2:-}"
      shift 2
      ;;
    --self-name)
      SELF_NAME="${2:-}"
      shift 2
      ;;
    --peer-ip)
      PEER_IP="${2:-}"
      shift 2
      ;;
    --peer-name)
      PEER_NAME="${2:-}"
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  sudo ./verify-node-user-network.sh \
    --expected-hostname k8s-master \
    --self-ip 10.10.20.151 \
    --self-name k8s-master \
    --peer-ip 10.10.20.154 \
    --peer-name k8s-worker1
EOF
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

pass() {
  printf '[OK] %s\n' "$1"
}

fail() {
  printf '[FAIL] %s\n' "$1"
  FAILURES=$((FAILURES + 1))
}

check_devops_user() {
  if id devops >/dev/null 2>&1; then
    pass "user exists: devops"
  else
    fail "user missing: devops"
  fi
}

check_devops_sudo_group() {
  if id -nG devops 2>/dev/null | tr ' ' '\n' | grep -qx 'sudo'; then
    pass "devops in sudo group"
  elif id -nG devops 2>/dev/null | tr ' ' '\n' | grep -qx 'wheel'; then
    pass "devops in wheel group"
  else
    fail "devops not in sudo/wheel group"
  fi
}

check_hostname_value() {
  local current_hostname
  current_hostname="$(hostname)"
  if [[ "${current_hostname}" == "${EXPECTED_HOSTNAME}" ]]; then
    pass "hostname matched: ${current_hostname}"
  else
    fail "hostname mismatch: expected ${EXPECTED_HOSTNAME}, found ${current_hostname}"
  fi
}

check_hosts_entry() {
  local ip="$1"
  local name="$2"
  if getent hosts "${name}" | awk '{print $1}' | grep -qx "${ip}"; then
    pass "hosts entry matched: ${ip} ${name}"
  else
    fail "hosts entry mismatch: ${ip} ${name}"
  fi
}

check_devops_user
check_devops_sudo_group
check_hostname_value
check_hosts_entry "${SELF_IP}" "${SELF_NAME}"
check_hosts_entry "${PEER_IP}" "${PEER_NAME}"

printf '\n[RESULT] '
if (( FAILURES > 0 )); then
  printf 'FAILED\n'
  printf '[INFO] failures: %d\n' "${FAILURES}"
  exit 1
fi

printf 'SUCCESS\n'
