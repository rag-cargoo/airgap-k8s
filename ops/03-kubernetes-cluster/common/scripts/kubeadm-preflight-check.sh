#!/usr/bin/env bash

set -euo pipefail

ROLE="control-plane"
PEERS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --role)
      ROLE="${2:-}"
      shift 2
      ;;
    --peer)
      PEERS+=("${2:-}")
      shift 2
      ;;
    -h|--help)
      cat <<'EOF'
Usage:
  ./kubeadm-preflight-check.sh [--role control-plane|worker] [--peer <ip-or-host>]...

Examples:
  ./kubeadm-preflight-check.sh --role control-plane
  ./kubeadm-preflight-check.sh --role worker --peer 192.168.56.10 --peer 192.168.56.11
EOF
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n' "$1" >&2
      exit 1
      ;;
  esac
done

if [[ "$ROLE" != "control-plane" && "$ROLE" != "worker" ]]; then
  printf 'Invalid role: %s\n' "$ROLE" >&2
  exit 1
fi

FAILURES=0
WARNINGS=0
CURRENT_STEP=0
TOTAL_STEPS=13

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  printf '\n[%d/%d] [CHECK] %s\n' "$CURRENT_STEP" "$TOTAL_STEPS" "$1"
}

pass() {
  printf '[OK] %s\n' "$1"
}

warn() {
  WARNINGS=$((WARNINGS + 1))
  printf '[WARN] %s\n' "$1"
}

fail() {
  FAILURES=$((FAILURES + 1))
  printf '[FAIL] %s\n' "$1"
}

check_command() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    pass "Required command present: $cmd"
  else
    fail "Required command missing: $cmd"
  fi
}

check_required_commands() {
  check_command uname
  check_command awk
  check_command ip
  check_command ss
  check_command ping
}

check_memory() {
  local mem_kib mem_gib
  mem_kib="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
  mem_gib=$((mem_kib / 1024 / 1024))
  if (( mem_kib >= 2097152 )); then
    pass "RAM >= 2 GiB (${mem_gib} GiB detected)"
  else
    fail "RAM < 2 GiB (${mem_gib} GiB detected)"
  fi
}

check_cpu() {
  local cpu_count
  cpu_count="$(nproc)"
  if [[ "$ROLE" == "control-plane" ]]; then
    if (( cpu_count >= 2 )); then
      pass "Control-plane CPU >= 2 (${cpu_count} detected)"
    else
      fail "Control-plane CPU < 2 (${cpu_count} detected)"
    fi
  else
    if (( cpu_count >= 1 )); then
      pass "Worker CPU detected (${cpu_count})"
    else
      fail "CPU count check failed"
    fi
  fi
}

check_hostname() {
  local hostname_value
  hostname_value="$(hostname)"
  if [[ -n "$hostname_value" && "$hostname_value" != "localhost" ]]; then
    pass "Hostname set: $hostname_value"
  else
    fail "Hostname is empty or localhost"
  fi
}

check_kernel() {
  local kernel_version
  kernel_version="$(uname -r)"
  pass "Kernel version detected: $kernel_version"
  warn "Verify this kernel is supported/LTS according to Kubernetes docs"
}

check_glibc() {
  local glibc_version
  if command -v getconf >/dev/null 2>&1 && glibc_version="$(getconf GNU_LIBC_VERSION 2>/dev/null)"; then
    pass "glibc detected: $glibc_version"
  elif command -v ldd >/dev/null 2>&1; then
    glibc_version="$(ldd --version 2>/dev/null | head -n 1 || true)"
    if [[ -n "$glibc_version" ]]; then
      pass "glibc/ldd detected: $glibc_version"
    else
      warn "Could not determine glibc version"
    fi
  else
    warn "Could not determine glibc version"
  fi
}

check_os() {
  if [[ -r /etc/os-release ]]; then
    local pretty_name
    pretty_name="$(. /etc/os-release && printf '%s' "${PRETTY_NAME:-unknown}")"
    pass "OS detected: $pretty_name"
  else
    warn "/etc/os-release not found"
  fi
}

check_product_uuid() {
  local uuid_path="/sys/class/dmi/id/product_uuid"
  if [[ -r "$uuid_path" ]]; then
    pass "product_uuid detected: $(cat "$uuid_path")"
    warn "Compare product_uuid across all nodes to ensure uniqueness"
  else
    warn "product_uuid not readable at $uuid_path"
  fi
}

check_mac_addresses() {
  if command -v ip >/dev/null 2>&1; then
    pass "MAC addresses detected:"
    ip -br link | awk '{print "  - " $1 ": " $3 " (" $2 ")"}'
    warn "Compare MAC addresses across all nodes to ensure uniqueness"
  else
    warn "ip command not available for MAC address check"
  fi
}

check_default_route() {
  local route_count
  route_count="$(ip route show default 2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$route_count" == "0" ]]; then
    warn "No default route detected; verify static routes for cluster communication"
  elif [[ "$route_count" == "1" ]]; then
    pass "Single default route detected"
  else
    warn "Multiple default routes detected; verify correct adapter/routing for cluster traffic"
  fi
  ip route show default 2>/dev/null | sed 's/^/  - /' || true
}

check_swap() {
  if command -v swapon >/dev/null 2>&1; then
    if swapon --show | tail -n +2 | grep -q .; then
      fail "Swap is enabled; disable it or configure kubelet failSwapOn=false"
    else
      pass "Swap is disabled"
    fi
  else
    warn "swapon command not available"
  fi
}

port_in_use() {
  local port="$1"
  ss -lntH 2>/dev/null | awk '{print $4}' | grep -E "(^|:)$port$" >/dev/null 2>&1
}

check_ports() {
  local ports=()
  if [[ "$ROLE" == "control-plane" ]]; then
    ports=(6443 2379 2380 10250 10257 10259)
  else
    ports=(10250 10256)
  fi

  local port
  for port in "${ports[@]}"; do
    if port_in_use "$port"; then
      fail "Required port already in use locally: $port"
    else
      pass "Required port available locally: $port"
    fi
  done

  warn "If using NodePort services, also verify 30000-32767 policy in the environment"
}

check_peers() {
  local peer
  if [[ "${#PEERS[@]}" -eq 0 ]]; then
    warn "No peer nodes provided; skipped inter-node connectivity test"
    return
  fi

  for peer in "${PEERS[@]}"; do
    if ping -c 1 -W 1 "$peer" >/dev/null 2>&1; then
      pass "Peer reachable: $peer"
    else
      fail "Peer unreachable: $peer"
    fi
  done
}

main() {
  printf '== kubeadm preflight check ==\n'
  printf 'Role: %s\n' "$ROLE"
  printf '[0/%d] [CHECK] Preflight sequence initialized\n' "$TOTAL_STEPS"

  step "Required command availability"
  check_required_commands

  step "Operating system detection"
  check_os

  step "Kernel version check"
  check_kernel

  step "glibc availability check"
  check_glibc

  step "Memory requirement check"
  check_memory

  step "CPU requirement check"
  check_cpu

  step "Hostname check"
  check_hostname

  step "product_uuid check"
  check_product_uuid

  step "MAC address check"
  check_mac_addresses

  step "Default route check"
  check_default_route

  step "Required port availability check"
  check_ports

  step "Swap configuration check"
  check_swap

  step "Peer connectivity check"
  check_peers

  printf '\n== summary ==\n'
  printf 'completed steps: %d/%d\n' "$CURRENT_STEP" "$TOTAL_STEPS"
  printf 'warnings: %d\n' "$WARNINGS"
  printf 'failures: %d\n' "$FAILURES"

  if (( FAILURES > 0 )); then
    exit 1
  fi
}

main "$@"
