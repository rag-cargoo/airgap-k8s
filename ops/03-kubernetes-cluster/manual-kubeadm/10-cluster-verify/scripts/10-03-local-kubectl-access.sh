#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

ACTION="start"
LOCAL_PORT="${AIRGAP_LOCAL_KUBECTL_PORT:-16443}"
KUBECONFIG_PATH="${AIRGAP_LOCAL_KUBECONFIG:-${PROJECT_ROOT}/.kube/airgap-k8s-admin.conf}"
CONTROL_SOCKET="${AIRGAP_LOCAL_KUBECTL_SSH_SOCKET:-${TMPDIR:-/tmp}/airgap-k8s-kubectl-tunnel-${USER:-user}.sock}"
FOREGROUND="false"
SKIP_TEST="false"

usage() {
  cat <<'EOF'
Usage:
  10-03-local-kubectl-access.sh [start|stop|status|prepare|install|setup|default] [options]

Actions:
  start      Fetch local kubeconfig, start SSH tunnel in background, run kubectl test
  stop       Stop the background SSH tunnel
  status     Check the background SSH tunnel
  prepare    Fetch local kubeconfig only
  install    Install kubectl to ~/.local/bin without sudo
  setup      Merge kubeconfig into ~/.kube/config, start tunnel, run plain kubectl test
  default    Alias of setup

Options:
  --foreground             Start tunnel in foreground. Stop with Ctrl-C.
  --skip-test              Do not run local kubectl test after start.
  --port <port>            Local API port. Default: 16443
  --kubeconfig <path>      Local kubeconfig path. Default: .kube/airgap-k8s-admin.conf
  --socket <path>          SSH control socket path. Default: /tmp/airgap-k8s-kubectl-tunnel-<user>.sock

After start:
  kubectl --kubeconfig .kube/airgap-k8s-admin.conf get nodes

After setup:
  kubectl get nodes
EOF
}

if [[ $# -gt 0 && "$1" != --* ]]; then
  ACTION="$1"
  shift
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    --foreground)
      FOREGROUND="true"
      shift
      ;;
    --skip-test)
      SKIP_TEST="true"
      shift
      ;;
    --port)
      LOCAL_PORT="${2:-}"
      shift 2
      ;;
    --kubeconfig)
      KUBECONFIG_PATH="${2:-}"
      shift 2
      ;;
    --socket)
      CONTROL_SOCKET="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf '[FAIL] unknown argument: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

case "${ACTION}" in
  start|stop|status|prepare|install|setup|default) ;;
  *)
    printf '[FAIL] unknown action: %s\n' "${ACTION}" >&2
    usage >&2
    exit 1
    ;;
esac

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_SSH_PORT AIRGAP_USE_BASTION AIRGAP_MASTER_PRIVATE_IP; do
  require_env "${var}"
done

SSH_BASE=(-p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" -o "ExitOnForwardFailure=yes" -o "ServerAliveInterval=30")
TUNNEL_SSH_OPTIONS=("${SSH_BASE[@]}")

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  require_env AIRGAP_BASTION_PUBLIC_IP
  TUNNEL_TARGET="${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}"
  TUNNEL_SPEC="127.0.0.1:${LOCAL_PORT}:127.0.0.1:6443"
  TUNNEL_SSH_OPTIONS=(
    "${SSH_BASE[@]}"
    -o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}"
  )
  MASTER_SSH=(
    "${TUNNEL_SSH_OPTIONS[@]}"
    "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}"
  )
else
  TUNNEL_TARGET="${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}"
  TUNNEL_SPEC="127.0.0.1:${LOCAL_PORT}:127.0.0.1:6443"
  MASTER_SSH=("${SSH_BASE[@]}" "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}")
fi

SSH_CONTROL=("${TUNNEL_SSH_OPTIONS[@]}" -S "${CONTROL_SOCKET}" "${TUNNEL_TARGET}")

prepare_kubeconfig() {
  local tmp_config
  tmp_config="$(mktemp)"
  mkdir -p "$(dirname "${KUBECONFIG_PATH}")"

  printf '[STEP] fetch admin kubeconfig from master\n'
  ssh "${MASTER_SSH[@]}" "sudo cat /etc/kubernetes/admin.conf" > "${tmp_config}"

  printf '[STEP] write local kubeconfig: %s\n' "${KUBECONFIG_PATH}"
  awk -v port="${LOCAL_PORT}" -v tls_name="${AIRGAP_MASTER_PRIVATE_IP}" '
    /^[[:space:]]*tls-server-name:[[:space:]]*/ {
      next
    }
    /^[[:space:]]*server:[[:space:]]*/ {
      match($0, /^[[:space:]]*/)
      indent = substr($0, RSTART, RLENGTH)
      print indent "server: https://127.0.0.1:" port
      print indent "tls-server-name: " tls_name
      next
    }
    {
      print
    }
  ' "${tmp_config}" | sed \
    -e 's/^\([[:space:]]*- name:\) kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*name:\) kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*cluster:\) kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*- name:\) kubernetes-admin@kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*name:\) kubernetes-admin@kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*current-context:\) kubernetes-admin@kubernetes$/\1 airgap-k8s/' \
    -e 's/^\([[:space:]]*user:\) kubernetes-admin$/\1 airgap-k8s-admin/' \
    -e 's/^\([[:space:]]*- name:\) kubernetes-admin$/\1 airgap-k8s-admin/' \
    -e 's/^\([[:space:]]*name:\) kubernetes-admin$/\1 airgap-k8s-admin/' \
    > "${KUBECONFIG_PATH}"
  rm -f "${tmp_config}"
  chmod 600 "${KUBECONFIG_PATH}"

  printf '[OK] kubeconfig ready\n'
  printf '[INFO] kubectl command: kubectl --kubeconfig %s get nodes\n' "${KUBECONFIG_PATH}"
}

print_kubectl_install_help() {
  cat <<'EOF'
[FAIL] local kubectl not found.
[INFO] Install kubectl first, then rerun setup:
  make 03-02-local-kubectl-install
  make 03-02-local-kubectl-setup

[INFO] Or install with snap:
  sudo snap install kubectl --classic
EOF
}

require_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    return
  fi
  print_kubectl_install_help >&2
  exit 1
}

install_kubectl() {
  local os arch kubectl_arch version install_dir install_path
  if command -v kubectl >/dev/null 2>&1; then
    printf '[OK] kubectl already installed: %s\n' "$(command -v kubectl)"
    kubectl version --client=true || true
    return
  fi

  os="$(uname -s)"
  arch="$(uname -m)"
  version="${AIRGAP_K8S_VERSION:-v1.35.4}"
  install_dir="${AIRGAP_LOCAL_KUBECTL_BIN_DIR:-${HOME}/.local/bin}"
  install_path="${install_dir}/kubectl"

  case "${os}" in
    Linux) ;;
    *)
      printf '[FAIL] unsupported OS for auto install: %s\n' "${os}" >&2
      printf '[INFO] Install kubectl manually for this OS, then rerun setup.\n' >&2
      exit 1
      ;;
  esac

  case "${arch}" in
    x86_64|amd64) kubectl_arch="amd64" ;;
    aarch64|arm64) kubectl_arch="arm64" ;;
    *)
      printf '[FAIL] unsupported CPU architecture for auto install: %s\n' "${arch}" >&2
      exit 1
      ;;
  esac

  if ! command -v curl >/dev/null 2>&1; then
    printf '[FAIL] curl is required to install kubectl without sudo.\n' >&2
    printf '[INFO] Alternative: sudo snap install kubectl --classic\n' >&2
    exit 1
  fi

  mkdir -p "${install_dir}"
  printf '[STEP] download kubectl %s for linux/%s\n' "${version}" "${kubectl_arch}"
  curl -fL --retry 3 --retry-delay 2 \
    "https://dl.k8s.io/release/${version}/bin/linux/${kubectl_arch}/kubectl" \
    -o "${install_path}"
  chmod +x "${install_path}"

  printf '[OK] kubectl installed: %s\n' "${install_path}"
  case ":${PATH}:" in
    *":${install_dir}:"*) ;;
    *)
      printf '[WARN] %s is not in PATH for this shell.\n' "${install_dir}"
      printf '[INFO] Add this to your shell profile: export PATH="%s:$PATH"\n' "${install_dir}"
      ;;
  esac
  "${install_path}" version --client=true || true
}

cleanup_stale_default_kubeconfig() {
  local default_config="$1"
  if ! kubectl --kubeconfig "${default_config}" config view \
    -o 'jsonpath={range .users[*]}{.name}{"\n"}{end}' | grep -Fxq "kubernetes-admin"; then
    return
  fi
  if kubectl --kubeconfig "${default_config}" config view \
    -o 'jsonpath={range .contexts[*]}{.context.user}{"\n"}{end}' | grep -Fxq "kubernetes-admin"; then
    return
  fi

  kubectl --kubeconfig "${default_config}" config unset users.kubernetes-admin >/dev/null || true
  printf '[OK] removed stale unreferenced kubeconfig user: kubernetes-admin\n'
}

merge_default_kubeconfig() {
  local default_dir default_config backup_path tmp_merged
  default_dir="${HOME}/.kube"
  default_config="${default_dir}/config"
  mkdir -p "${default_dir}"

  if [[ -f "${default_config}" ]]; then
    backup_path="${default_config}.backup-before-airgap-k8s"
    if [[ ! -f "${backup_path}" ]]; then
      cp "${default_config}" "${backup_path}"
      printf '[OK] existing default kubeconfig backed up once: %s\n' "${backup_path}"
    fi
  fi

  tmp_merged="$(mktemp)"
  if [[ -f "${default_config}" ]]; then
    KUBECONFIG="${KUBECONFIG_PATH}:${default_config}" kubectl config view --flatten > "${tmp_merged}"
  else
    KUBECONFIG="${KUBECONFIG_PATH}" kubectl config view --flatten > "${tmp_merged}"
  fi

  if [[ -f "${default_config}" ]] && cmp -s "${tmp_merged}" "${default_config}"; then
    rm -f "${tmp_merged}"
    printf '[OK] default kubeconfig already up to date: %s\n' "${default_config}"
  else
    cp "${tmp_merged}" "${default_config}"
    rm -f "${tmp_merged}"
    printf '[OK] default kubeconfig merged: %s\n' "${default_config}"
  fi

  kubectl --kubeconfig "${default_config}" config use-context airgap-k8s >/dev/null
  cleanup_stale_default_kubeconfig "${default_config}"
  chmod 600 "${default_config}"
  printf '[INFO] plain kubectl command: kubectl get nodes\n'
}

is_tunnel_running() {
  [[ -S "${CONTROL_SOCKET}" ]] || return 1
  ssh "${SSH_CONTROL[@]}" -O check >/dev/null 2>&1
}

tunnel_status() {
  if [[ ! -S "${CONTROL_SOCKET}" ]]; then
    printf '[INFO] tunnel socket not found: %s\n' "${CONTROL_SOCKET}"
    return 1
  fi
  is_tunnel_running
}

start_tunnel() {
  local i
  mkdir -p "$(dirname "${CONTROL_SOCKET}")"
  if is_tunnel_running; then
    printf '[OK] tunnel already running: 127.0.0.1:%s -> %s:6443\n' "${LOCAL_PORT}" "${AIRGAP_MASTER_PRIVATE_IP}"
    return
  fi
  rm -f "${CONTROL_SOCKET}"

  if [[ "${FOREGROUND}" == "true" ]]; then
    printf '[STEP] start foreground tunnel: 127.0.0.1:%s -> %s:6443\n' "${LOCAL_PORT}" "${AIRGAP_MASTER_PRIVATE_IP}"
    printf '[INFO] keep this terminal open. Stop with Ctrl-C.\n'
    exec ssh "${TUNNEL_SSH_OPTIONS[@]}" -N -L "${TUNNEL_SPEC}" "${TUNNEL_TARGET}"
  fi

  printf '[STEP] start background tunnel: 127.0.0.1:%s -> %s:6443\n' "${LOCAL_PORT}" "${AIRGAP_MASTER_PRIVATE_IP}"
  if command -v setsid >/dev/null 2>&1; then
    setsid ssh "${TUNNEL_SSH_OPTIONS[@]}" -M -S "${CONTROL_SOCKET}" -N -L "${TUNNEL_SPEC}" "${TUNNEL_TARGET}" >/dev/null 2>&1 &
  else
    nohup ssh "${TUNNEL_SSH_OPTIONS[@]}" -M -S "${CONTROL_SOCKET}" -N -L "${TUNNEL_SPEC}" "${TUNNEL_TARGET}" >/dev/null 2>&1 &
  fi
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if is_tunnel_running; then
      printf '[OK] tunnel started\n'
      return
    fi
    sleep 0.5
  done

  printf '[FAIL] tunnel start failed\n' >&2
  rm -f "${CONTROL_SOCKET}"
  exit 1
}

stop_tunnel() {
  if tunnel_status; then
    ssh "${SSH_CONTROL[@]}" -O exit >/dev/null
    printf '[OK] tunnel stopped\n'
    return
  fi
  rm -f "${CONTROL_SOCKET}"
  printf '[INFO] tunnel is not running\n'
}

test_kubectl() {
  if [[ "${SKIP_TEST}" == "true" ]]; then
    return
  fi
  if ! command -v kubectl >/dev/null 2>&1; then
    printf '[WARN] local kubectl not found. Install kubectl or run from a machine with kubectl.\n'
    printf '[INFO] kubeconfig: %s\n' "${KUBECONFIG_PATH}"
    return
  fi
  printf '[STEP] test local kubectl\n'
  kubectl --kubeconfig "${KUBECONFIG_PATH}" get nodes
}

test_default_kubectl() {
  if [[ "${SKIP_TEST}" == "true" ]]; then
    return
  fi
  if ! command -v kubectl >/dev/null 2>&1; then
    printf '[WARN] local kubectl not found. Install kubectl or run from a machine with kubectl.\n'
    printf '[INFO] default kubeconfig: %s/.kube/config\n' "${HOME}"
    return
  fi
  printf '[STEP] test plain kubectl\n'
  kubectl get nodes
}

case "${ACTION}" in
  prepare)
    prepare_kubeconfig
    ;;
  install)
    install_kubectl
    ;;
  start)
    prepare_kubeconfig
    start_tunnel
    test_kubectl
    printf '[RESULT] SUCCESS\n'
    ;;
  setup|default)
    require_kubectl
    prepare_kubeconfig
    merge_default_kubeconfig
    start_tunnel
    test_default_kubectl
    printf '[RESULT] SUCCESS\n'
    ;;
  stop)
    stop_tunnel
    ;;
  status)
    if tunnel_status; then
      printf '[OK] tunnel running: 127.0.0.1:%s -> %s:6443\n' "${LOCAL_PORT}" "${AIRGAP_MASTER_PRIVATE_IP}"
    else
      printf '[INFO] tunnel is not running\n'
      exit 1
    fi
    ;;
esac
