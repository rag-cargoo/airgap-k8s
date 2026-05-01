#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SUBMISSION_DIR="${PROJECT_ROOT}/delivery/submission"
ZIP_DIR="${SUBMISSION_DIR}/02-server-config-zip-attach-this"
FINAL_DIR="${SUBMISSION_DIR}/03-final-email-attachments"
STAGING_DIR="${SUBMISSION_DIR}/.staging"
PACKAGE_NAME="airgap-k8s-server-configs"
PACKAGE_ROOT="${STAGING_DIR}/${PACKAGE_NAME}"
ZIP_PATH="${ZIP_DIR}/${PACKAGE_NAME}.zip"

print_step() {
  printf '[CHECK] %s\n' "$1"
}

copy_path() {
  local source="$1"
  local target="$2"
  if [[ -e "${source}" ]]; then
    mkdir -p "$(dirname "${target}")"
    cp -a "${source}" "${target}"
  fi
}

print_step "prepare submission config package staging directory"
rm -rf "${PACKAGE_ROOT}"
mkdir -p "${PACKAGE_ROOT}/ops/01-airgap-linux-environment" "${ZIP_DIR}" "${FINAL_DIR}"

print_step "copy root reproducibility files"
copy_path "${PROJECT_ROOT}/README.md" "${PACKAGE_ROOT}/README.md"
copy_path "${PROJECT_ROOT}/ASSIGNMENT.md" "${PACKAGE_ROOT}/ASSIGNMENT.md"
copy_path "${PROJECT_ROOT}/Makefile" "${PACKAGE_ROOT}/Makefile"
copy_path "${PROJECT_ROOT}/.env.example" "${PACKAGE_ROOT}/.env.example"

print_step "copy offline download scripts without Terraform code"
copy_path "${PROJECT_ROOT}/ops/01-airgap-linux-environment/README.md" "${PACKAGE_ROOT}/ops/01-airgap-linux-environment/README.md"
copy_path "${PROJECT_ROOT}/ops/01-airgap-linux-environment/Makefile" "${PACKAGE_ROOT}/ops/01-airgap-linux-environment/Makefile"
copy_path "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts" "${PACKAGE_ROOT}/ops/01-airgap-linux-environment/scripts"
copy_path "${PROJECT_ROOT}/ops/01-airgap-linux-environment/vm-airgap-setup" "${PACKAGE_ROOT}/ops/01-airgap-linux-environment/vm-airgap-setup"

print_step "copy server configuration, manifests, dashboards, and verification scripts"
copy_path "${PROJECT_ROOT}/ops/README.md" "${PACKAGE_ROOT}/ops/README.md"
copy_path "${PROJECT_ROOT}/ops/common" "${PACKAGE_ROOT}/ops/common"
copy_path "${PROJECT_ROOT}/ops/02-user-network" "${PACKAGE_ROOT}/ops/02-user-network"
copy_path "${PROJECT_ROOT}/ops/03-kubernetes-cluster" "${PACKAGE_ROOT}/ops/03-kubernetes-cluster"
copy_path "${PROJECT_ROOT}/ops/04-services-monitoring" "${PACKAGE_ROOT}/ops/04-services-monitoring"
copy_path "${PROJECT_ROOT}/ops/05-prometheus-grafana-external-access" "${PACKAGE_ROOT}/ops/05-prometheus-grafana-external-access"
copy_path "${PROJECT_ROOT}/ops/06-submission/README.md" "${PACKAGE_ROOT}/ops/06-submission/README.md"

print_step "remove generated, secret, Terraform, and offline binary outputs"
find "${PACKAGE_ROOT}" -type d \( \
  -name '.terraform' -o \
  -name '.git' -o \
  -name '.kube' -o \
  -name 'offline-assets' -o \
  -name 'ops-runtime' -o \
  -name 'delivery' \
\) -prune -exec rm -rf {} +

find "${PACKAGE_ROOT}" -type f \( \
  -name '.env' -o \
  -name '.env.local' -o \
  -name '*.pem' -o \
  -name '*.key' -o \
  -name '*.tfstate' -o \
  -name '*.tfstate.*' -o \
  -name '*.tfplan' -o \
  -name 'terraform.tfvars' -o \
  -name 'tfplan' -o \
  -name '*.tar' -o \
  -name '*.tar.gz' \
\) -delete

rm -rf "${PACKAGE_ROOT}/ops/01-airgap-linux-environment/aws-terraform-simulation"

cat > "${PACKAGE_ROOT}/PACKAGE_CONTENTS.md" <<'EOF'
# airgap-k8s-server-configs.zip

## Included
- Kubernetes manual kubeadm scripts and verification scripts
- Calico and StorageClass related scripts/manifests
- MariaDB, MongoDB, Prometheus, Grafana, Grafana Alloy manifests
- Prometheus scrape configuration and alert rules
- Grafana datasource/provider manifests and offline dashboard JSON files
- MetalLB, ingress-nginx, and monitoring Ingress templates
- Offline asset download scripts and image/chart list files
- Root Makefile and README files needed to understand execution order

## Excluded
- Terraform code and Terraform runtime files
- Downloaded offline binary assets
- offline-assets.tar.gz
- .env, kubeconfig, private keys, tfstate, tfplan, and local runtime files

The complete repository, including Terraform environment simulation code, is available through the GitHub link written in the submission manual.
EOF

print_step "build server config ZIP"
rm -f "${ZIP_PATH}"
mkdir -p "${SUBMISSION_DIR}"
(
  cd "${STAGING_DIR}"
  zip -qr "${ZIP_PATH}" "${PACKAGE_NAME}"
)
cp -f "${ZIP_PATH}" "${FINAL_DIR}/${PACKAGE_NAME}.zip"

ENTRY_COUNT="$(zipinfo -1 "${ZIP_PATH}" | wc -l | tr -d ' ')"
ZIP_SIZE="$(du -sh "${ZIP_PATH}" | awk '{print $1}')"

printf '[SUMMARY] server config ZIP generated\n'
printf '  zip path: %s\n' "${ZIP_PATH}"
printf '  final attachment copy: %s\n' "${FINAL_DIR}/${PACKAGE_NAME}.zip"
printf '  zip size: %s\n' "${ZIP_SIZE}"
printf '  entries: %s\n' "${ENTRY_COUNT}"
