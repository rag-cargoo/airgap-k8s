#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
STAGE_ROOT="${PROJECT_ROOT}/delivery/ops-runtime"
PACKAGE_ROOT="${STAGE_ROOT}/airgap-k8s-ops"
ARCHIVE_PATH="${PROJECT_ROOT}/delivery/ops-runtime.tar.gz"

print_step() {
  printf '[CHECK] %s\n' "$1"
}

print_step "prepare ops-runtime staging directories"
rm -rf "${STAGE_ROOT}"
mkdir -p "${PACKAGE_ROOT}/ops"

print_step "copy authored runtime sources for bastion execution"
cp -a "${PROJECT_ROOT}/ops/README.md" "${PACKAGE_ROOT}/ops/"
cp -a "${PROJECT_ROOT}/ops/common" "${PACKAGE_ROOT}/ops/"
cp -a "${PROJECT_ROOT}/ops/02-user-network" "${PACKAGE_ROOT}/ops/"
cp -a "${PROJECT_ROOT}/ops/03-kubernetes-cluster" "${PACKAGE_ROOT}/ops/"
cp -a "${PROJECT_ROOT}/ops/04-services-monitoring" "${PACKAGE_ROOT}/ops/"
cp -a "${PROJECT_ROOT}/ops/05-prometheus-grafana-external-access" "${PACKAGE_ROOT}/ops/"

print_step "remove generated or local-only files"
find "${PACKAGE_ROOT}" -type d -name '.terraform' -prune -exec rm -rf {} +
find "${PACKAGE_ROOT}" -type f \( \
  -name '*.tfstate' -o \
  -name '*.tfstate.*' -o \
  -name '*.tfplan' -o \
  -name 'terraform.tfvars' -o \
  -name '.env' -o \
  -name '.env.local' \
\) -delete

print_step "build ops-runtime archive"
tar -czf "${ARCHIVE_PATH}" -C "${STAGE_ROOT}" airgap-k8s-ops

DIR_COUNT="$(find "${PACKAGE_ROOT}/ops" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
FILE_COUNT="$(find "${PACKAGE_ROOT}" -type f | wc -l | tr -d ' ')"
ARCHIVE_SIZE="$(du -sh "${ARCHIVE_PATH}" | awk '{print $1}')"

printf '\n[SUMMARY] ops-runtime bundle prepared\n'
printf '  top-level ops directories: %s\n' "${DIR_COUNT}"
printf '  packaged files: %s\n' "${FILE_COUNT}"
printf '  archive path: %s\n' "${ARCHIVE_PATH}"
printf '  archive size: %s\n' "${ARCHIVE_SIZE}"
