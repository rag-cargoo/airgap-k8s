#!/usr/bin/env bash

set -euo pipefail

HOSTNAME_VALUE=""
SELF_IP=""
SELF_NAME=""
PEER_IP=""
PEER_NAME=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --hostname)
      HOSTNAME_VALUE="${2:-}"
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
  sudo ./configure-node-user-network.sh \
    --hostname k8s-master \
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

if [[ $EUID -ne 0 ]]; then
  printf '[FAIL] run as root or sudo\n' >&2
  exit 1
fi

for required in HOSTNAME_VALUE SELF_IP SELF_NAME PEER_IP PEER_NAME; do
  if [[ -z "${!required}" ]]; then
    printf '[FAIL] missing required argument: %s\n' "${required}" >&2
    exit 1
  fi
done

ensure_devops_user() {
  if id devops >/dev/null 2>&1; then
    printf '[OK] user exists: devops\n'
  else
    useradd -m -s /bin/bash devops
    printf '[OK] user created: devops\n'
  fi
}

ensure_sudo_group() {
  if getent group sudo >/dev/null 2>&1; then
    usermod -aG sudo devops
    printf '[OK] added devops to sudo group\n'
  elif getent group wheel >/dev/null 2>&1; then
    usermod -aG wheel devops
    printf '[OK] added devops to wheel group\n'
  else
    printf '[WARN] sudo/wheel group not found; grant sudo policy manually\n'
  fi
}

set_node_hostname() {
  hostnamectl set-hostname "${HOSTNAME_VALUE}"
  printf '[OK] hostname set: %s\n' "${HOSTNAME_VALUE}"
}

upsert_hosts_entry() {
  local ip="$1"
  local name="$2"
  local hosts_file="/etc/hosts"

  if grep -Eq "^[[:space:]]*${ip}[[:space:]]+${name}([[:space:]]|\$)" "${hosts_file}"; then
    printf '[OK] hosts entry already present: %s %s\n' "${ip}" "${name}"
    return
  fi

  if grep -Eq "[[:space:]]${name}([[:space:]]|\$)" "${hosts_file}"; then
    sed -i -E "/[[:space:]]${name}([[:space:]]|\$)/d" "${hosts_file}"
  fi

  printf '%s %s\n' "${ip}" "${name}" >> "${hosts_file}"
  printf '[OK] hosts entry added: %s %s\n' "${ip}" "${name}"
}

ensure_devops_user
ensure_sudo_group
set_node_hostname
upsert_hosts_entry "${SELF_IP}" "${SELF_NAME}"
upsert_hosts_entry "${PEER_IP}" "${PEER_NAME}"

printf '[RESULT] SUCCESS\n'
