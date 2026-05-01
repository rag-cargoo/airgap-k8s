#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
TF_DIR="${PROJECT_ROOT}/ops/01-airgap-linux-environment/aws-terraform-simulation"
ENV_FILE="${PROJECT_ROOT}/.env"
ENV_EXAMPLE_FILE="${PROJECT_ROOT}/.env.example"

if ! command -v terraform >/dev/null 2>&1; then
  echo "[FAIL] terraform 명령을 찾을 수 없습니다."
  exit 1
fi

if [[ ! -d "${TF_DIR}" ]]; then
  echo "[FAIL] Terraform 디렉터리가 없습니다: ${TF_DIR}"
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  if [[ ! -f "${ENV_EXAMPLE_FILE}" ]]; then
    echo "[FAIL] .env.example 파일이 없습니다: ${ENV_EXAMPLE_FILE}"
    exit 1
  fi
  cp "${ENV_EXAMPLE_FILE}" "${ENV_FILE}"
  echo "[INFO] .env 파일이 없어 .env.example 기준으로 생성했습니다."
fi

set -a
source "${ENV_FILE}"
set +a

tf_output_raw() {
  local name="$1"
  terraform -chdir="${TF_DIR}" output -raw "${name}"
}

AIRGAP_BASTION_PUBLIC_IP="$(tf_output_raw bastion_public_ip)"
AIRGAP_MASTER_PRIVATE_IP="$(tf_output_raw master_private_ip)"
AIRGAP_WORKER1_PRIVATE_IP="$(tf_output_raw worker1_private_ip)"

AIRGAP_SSH_USER="${AIRGAP_SSH_USER:-ec2-user}"
AIRGAP_SSH_KEY_PATH="${AIRGAP_SSH_KEY_PATH:-}"
AIRGAP_OFFLINE_ASSETS_ARCHIVE="${AIRGAP_OFFLINE_ASSETS_ARCHIVE:-offline-assets.tar.gz}"
AIRGAP_SERVER_ASSETS_DIR="${AIRGAP_SERVER_ASSETS_DIR:-/opt/offline-assets}"

if [[ -z "${AIRGAP_SSH_KEY_PATH}" ]]; then
  echo "[WARN] AIRGAP_SSH_KEY_PATH is empty. Set your local private key path in .env before SSH-based steps."
fi

cat > "${ENV_FILE}" <<EOF
AIRGAP_SSH_USER=${AIRGAP_SSH_USER}
AIRGAP_SSH_KEY_PATH=${AIRGAP_SSH_KEY_PATH}
AIRGAP_BASTION_PUBLIC_IP=${AIRGAP_BASTION_PUBLIC_IP}
AIRGAP_MASTER_PRIVATE_IP=${AIRGAP_MASTER_PRIVATE_IP}
AIRGAP_WORKER1_PRIVATE_IP=${AIRGAP_WORKER1_PRIVATE_IP}
AIRGAP_OFFLINE_ASSETS_ARCHIVE=${AIRGAP_OFFLINE_ASSETS_ARCHIVE}
AIRGAP_SERVER_ASSETS_DIR=${AIRGAP_SERVER_ASSETS_DIR}
EOF

echo "[OK] .env updated from Terraform outputs"
echo "[INFO] env file path: ${ENV_FILE}"
echo "AIRGAP_BASTION_PUBLIC_IP=${AIRGAP_BASTION_PUBLIC_IP}"
echo "AIRGAP_MASTER_PRIVATE_IP=${AIRGAP_MASTER_PRIVATE_IP}"
echo "AIRGAP_WORKER1_PRIVATE_IP=${AIRGAP_WORKER1_PRIVATE_IP}"
echo
echo "[INFO] current .env"
cat "${ENV_FILE}"
