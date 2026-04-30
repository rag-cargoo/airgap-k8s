#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../../.." && pwd)"
SURVEY_YAML="${PROJECT_ROOT}/manual/00-제출-매뉴얼-개요/03-사전-조사-정보-수집-템플릿.yaml"
ENV_FILE="${PROJECT_ROOT}/.env"
ENV_EXAMPLE_FILE="${PROJECT_ROOT}/.env.example"

if [[ ! -f "${SURVEY_YAML}" ]]; then
  echo "[FAIL] survey yaml not found: ${SURVEY_YAML}"
  echo "[INFO] cp manual/00-제출-매뉴얼-개요/03-사전-조사-정보-수집-템플릿.example.yaml \\"
  echo "         manual/00-제출-매뉴얼-개요/03-사전-조사-정보-수집-템플릿.yaml"
  exit 1
fi

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${ENV_EXAMPLE_FILE}" "${ENV_FILE}"
  echo "[INFO] created .env from .env.example: ${ENV_FILE}"
fi

get_yaml_value() {
  local key="$1"
  awk -F':' -v key="${key}" '
    {
      current_key=$1
      value=substr($0, index($0, ":") + 1)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", current_key)
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
      gsub(/^"/, "", value)
      gsub(/"$/, "", value)
    }
    current_key == key {
      print value
      exit
    }
  ' "${SURVEY_YAML}"
}

set_env_value() {
  local key="$1"
  local value="$2"
  local escaped
  escaped="$(printf '%s' "${value}" | sed 's/[&|\\]/\\&/g')"
  if grep -q "^${key}=" "${ENV_FILE}"; then
    sed -i "s|^${key}=.*|${key}=${escaped}|" "${ENV_FILE}"
  else
    printf '%s=%s\n' "${key}" "${value}" >> "${ENV_FILE}"
  fi
}

set_env_value AIRGAP_SSH_USER "$(get_yaml_value 'ssh_user')"
set_env_value AIRGAP_SSH_KEY_PATH "$(get_yaml_value 'ssh_key_path')"
set_env_value AIRGAP_SSH_PORT "$(get_yaml_value 'ssh_port')"
set_env_value AIRGAP_USE_BASTION "$(get_yaml_value 'use_bastion')"
set_env_value AIRGAP_BASTION_PUBLIC_IP "$(get_yaml_value 'bastion_public_ip')"
set_env_value AIRGAP_BASTION_HOST "$(get_yaml_value 'bastion_host')"
set_env_value AIRGAP_CONTROL_NODE_IP "$(get_yaml_value 'control_node_ip')"
set_env_value AIRGAP_CONTROL_NODE_HOST "$(get_yaml_value 'control_node_host')"
set_env_value AIRGAP_MASTER_PRIVATE_IP "$(get_yaml_value 'master_private_ip')"
set_env_value AIRGAP_MASTER_HOST "$(get_yaml_value 'master_host')"
set_env_value AIRGAP_WORKER1_PRIVATE_IP "$(get_yaml_value 'worker1_private_ip')"
set_env_value AIRGAP_WORKER1_HOST "$(get_yaml_value 'worker1_host')"
set_env_value AIRGAP_OFFLINE_ASSETS_ARCHIVE "$(get_yaml_value 'offline_assets_archive')"
set_env_value AIRGAP_SERVER_ASSETS_DIR "$(get_yaml_value 'server_assets_dir')"
set_env_value AIRGAP_OPS_RUNTIME_ARCHIVE "$(get_yaml_value 'ops_runtime_archive')"
set_env_value AIRGAP_SERVER_OPS_RUNTIME_DIR "$(get_yaml_value 'server_ops_runtime_dir')"

echo "[OK] rendered .env from survey yaml: ${SURVEY_YAML}"
echo "[INFO] env file path: ${ENV_FILE}"
grep '^AIRGAP_' "${ENV_FILE}"
