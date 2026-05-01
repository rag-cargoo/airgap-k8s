#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ASSETS_ROOT="${PROJECT_ROOT}/assets/offline-assets"
K8S_PACKAGES_DIR="${ASSETS_ROOT}/kubernetes/packages/kubernetes"
RUNTIME_PACKAGES_DIR="${ASSETS_ROOT}/kubernetes/packages/container-runtime"
K8S_IMAGES_DIR="${ASSETS_ROOT}/kubernetes/images/kube-system"
CALICO_IMAGES_DIR="${ASSETS_ROOT}/kubernetes/images/calico"
STORAGECLASS_IMAGES_DIR="${ASSETS_ROOT}/kubernetes/images/storageclass"
K8S_MANIFESTS_DIR="${ASSETS_ROOT}/kubernetes/manifests"
CHECKSUM_FILE="${ASSETS_ROOT}/common/checksums/kubernetes-assets.sha256"

TOTAL_STEPS=14
CURRENT_STEP=0
FAILURES=0
FAILURE_MESSAGES=()

step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  printf "[%d/%d] [CHECK] %s\n" "${CURRENT_STEP}" "${TOTAL_STEPS}" "$1"
}

ok() {
  printf "[OK] %s\n" "$1"
}

fail() {
  printf "[FAIL] %s\n" "$1"
  FAILURE_MESSAGES+=("$1")
  FAILURES=$((FAILURES + 1))
}

check_file() {
  local file_path="$1"
  local label="$2"
  if [ -f "${file_path}" ]; then
    ok "${label}: ${file_path}"
  else
    fail "${label} missing: ${file_path}"
  fi
}

check_count() {
  local dir_path="$1"
  local pattern="$2"
  local minimum="$3"
  local label="$4"
  local count

  count=$(find "${dir_path}" -maxdepth 1 -name "${pattern}" | wc -l | tr -d ' ')
  if [ "${count}" -ge "${minimum}" ]; then
    ok "${label}: ${count} files"
  else
    fail "${label} insufficient: expected >= ${minimum}, found ${count}"
  fi
}

print_failure_summary_and_exit() {
  if [ "${FAILURES}" -gt 0 ]; then
    printf "\n[RESULT] FAILED\n"
    printf "[INFO] failures: %d\n" "${FAILURES}"
    printf "[INFO] rerun: make 01-03-offline-assets-run\n"
    printf "[FAILED CHECKS]\n"
    for message in "${FAILURE_MESSAGES[@]}"; do
      printf -- "- %s\n" "${message}"
    done
    exit 1
  fi
}

step "Required metadata files"
check_file "${K8S_PACKAGES_DIR}/package-versions.txt" "Kubernetes package version file"
check_file "${RUNTIME_PACKAGES_DIR}/package-versions.txt" "Container runtime package version file"
check_file "${K8S_IMAGES_DIR}/images.txt" "Kube-system image list file"
check_file "${CALICO_IMAGES_DIR}/images.txt" "Calico image list file"
check_file "${STORAGECLASS_IMAGES_DIR}/images.txt" "StorageClass image list file"
check_file "${CHECKSUM_FILE}" "Checksum file"

step "Calico manifest files"
check_file "${K8S_MANIFESTS_DIR}/operator-crds.yaml" "Calico operator CRDs manifest"
check_file "${K8S_MANIFESTS_DIR}/tigera-operator.yaml" "Calico tigera-operator manifest"
check_file "${K8S_MANIFESTS_DIR}/custom-resources.yaml" "Calico custom-resources manifest"

step "StorageClass manifest files"
check_file "${K8S_MANIFESTS_DIR}/local-path-storage.yaml" "local-path StorageClass manifest"

step "Kubernetes rpm package count"
check_count "${K8S_PACKAGES_DIR}" '*.rpm' 1 "Kubernetes rpm packages"

step "Container runtime rpm package count"
check_count "${RUNTIME_PACKAGES_DIR}" '*.rpm' 1 "Container runtime rpm packages"

step "Kube-system image tar count"
check_count "${K8S_IMAGES_DIR}" '*.tar' 1 "Kube-system image tar files"

step "Calico image tar count"
check_count "${CALICO_IMAGES_DIR}" '*.tar' 1 "Calico image tar files"

step "StorageClass image tar count"
check_count "${STORAGECLASS_IMAGES_DIR}" '*.tar' 2 "StorageClass image tar files"

print_failure_summary_and_exit

step "Kubernetes rpm package list"
find "${K8S_PACKAGES_DIR}" -maxdepth 1 -name '*.rpm' | sort
ok "Printed Kubernetes rpm package list"

step "Container runtime rpm package list"
find "${RUNTIME_PACKAGES_DIR}" -maxdepth 1 -name '*.rpm' | sort
ok "Printed container runtime rpm package list"

step "Kube-system image tar list"
find "${K8S_IMAGES_DIR}" -maxdepth 1 -name '*.tar' | sort
ok "Printed kube-system image tar list"

step "Calico image tar list"
find "${CALICO_IMAGES_DIR}" -maxdepth 1 -name '*.tar' | sort
ok "Printed Calico image tar list"

step "StorageClass image tar list"
find "${STORAGECLASS_IMAGES_DIR}" -maxdepth 1 -name '*.tar' | sort
ok "Printed StorageClass image tar list"

step "Image and checksum preview"
sed -n '1,20p' "${K8S_IMAGES_DIR}/images.txt"
sed -n '1,20p' "${CALICO_IMAGES_DIR}/images.txt"
sed -n '1,20p' "${STORAGECLASS_IMAGES_DIR}/images.txt"
sed -n '1,10p' "${CHECKSUM_FILE}"
ok "Printed image list and checksum preview"

printf "\n[RESULT] SUCCESS\n"
printf "[OK] Kubernetes offline assets verified\n"
