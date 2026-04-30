#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ASSETS_ROOT="${PROJECT_ROOT}/assets/offline-assets"
K8S_PACKAGES_DIR="${ASSETS_ROOT}/kubernetes/packages/kubernetes"
RUNTIME_PACKAGES_DIR="${ASSETS_ROOT}/kubernetes/packages/container-runtime"
K8S_IMAGES_DIR="${ASSETS_ROOT}/kubernetes/images/kube-system"
K8S_MANIFESTS_DIR="${ASSETS_ROOT}/kubernetes/manifests"
CHECKSUMS_DIR="${ASSETS_ROOT}/common/checksums"

K8S_MINOR_VERSION="v1.35"
K8S_PATCH_VERSION="1.35.3"
K8S_RPM_VERSION="1.35.3-150500.1.1"
CALICO_VERSION="v3.31.4"
AL2023_IMAGE="amazonlinux:2023"
DOWNLOAD_START_TS="$(date +%s)"
DOWNLOAD_TOTAL_STEPS=6
DOWNLOAD_CURRENT_STEP=0

format_duration() {
  local seconds="$1"
  printf '%02dm %02ds' $((seconds / 60)) $((seconds % 60))
}

step_start() {
  local title="$1"
  DOWNLOAD_CURRENT_STEP=$((DOWNLOAD_CURRENT_STEP + 1))
  STEP_START_TS="$(date +%s)"
  echo
  echo "[${DOWNLOAD_CURRENT_STEP}/${DOWNLOAD_TOTAL_STEPS}] [CHECK] ${title}"
}

step_ok() {
  local message="$1"
  local now_ts
  now_ts="$(date +%s)"
  local step_elapsed=$((now_ts - STEP_START_TS))
  local total_elapsed=$((now_ts - DOWNLOAD_START_TS))
  echo "[OK] ${message}"
  echo "[INFO] step elapsed: $(format_duration "${step_elapsed}")"
  echo "[INFO] total elapsed: $(format_duration "${total_elapsed}")"
}

require_cmd() {
  local cmd="$1"
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "[FAIL] required command not found: ${cmd}"
    exit 1
  fi
}

require_cmd docker
require_cmd curl
require_cmd sha256sum

mkdir -p \
  "${K8S_PACKAGES_DIR}" \
  "${RUNTIME_PACKAGES_DIR}" \
  "${K8S_IMAGES_DIR}" \
  "${K8S_MANIFESTS_DIR}" \
  "${CHECKSUMS_DIR}"

download_rpms() {
  local output_dir="$1"
  shift
  local packages=("$@")

  docker run --rm \
    -v "${output_dir}:/out" \
    "${AL2023_IMAGE}" \
    bash -lc "
      set -euo pipefail
      dnf install -y dnf-plugins-core curl >/dev/null 2>&1
      cat >/etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
      mkdir -p /tmp/out
      dnf download --resolve --alldeps --destdir /tmp/out ${packages[*]} --setopt=disable_excludes=kubernetes >/dev/null 2>&1
      cp -av /tmp/out/*.rpm /out/ >/dev/null
    "
}

list_kubeadm_images() {
  docker run --rm \
    "${AL2023_IMAGE}" \
    bash -lc "
      set -euo pipefail
      dnf install -y dnf-plugins-core curl >/dev/null 2>&1
      cat >/etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/${K8S_MINOR_VERSION}/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF
      dnf install -y kubeadm --setopt=disable_excludes=kubernetes >/dev/null 2>&1
      kubeadm config images list --kubernetes-version v${K8S_PATCH_VERSION}
    "
}

echo "[INFO] target Kubernetes version: ${K8S_PATCH_VERSION}"
echo "[INFO] target Calico version: ${CALICO_VERSION}"
echo "[INFO] target asset format: rpm/dnf for Amazon Linux 2023"

step_start "download Kubernetes rpm packages"
echo "[INFO] packages: kubelet kubeadm kubectl cri-tools kubernetes-cni"
download_rpms \
  "${K8S_PACKAGES_DIR}" \
  "kubelet" \
  "kubeadm" \
  "kubectl" \
  "cri-tools" \
  "kubernetes-cni"
step_ok "downloaded Kubernetes rpm packages"

step_start "download container runtime rpm packages"
echo "[INFO] packages: containerd, runc"
download_rpms \
  "${RUNTIME_PACKAGES_DIR}" \
  "containerd" \
  "runc"
step_ok "downloaded container runtime rpm packages"

step_start "save package version references"
cat > "${K8S_PACKAGES_DIR}/package-versions.txt" <<EOF
kubelet=${K8S_RPM_VERSION}
kubeadm=${K8S_RPM_VERSION}
kubectl=${K8S_RPM_VERSION}
cri-tools=pkgs.k8s.io-rpm-latest-for-${K8S_MINOR_VERSION}
kubernetes-cni=pkgs.k8s.io-rpm-latest-for-${K8S_MINOR_VERSION}
EOF

cat > "${RUNTIME_PACKAGES_DIR}/package-versions.txt" <<EOF
containerd=amazonlinux2023-dnf-latest
runc=amazonlinux2023-dnf-latest
EOF
step_ok "saved package version references"

step_start "download Calico manifests"
echo "[INFO] manifests: operator-crds.yaml, tigera-operator.yaml, custom-resources.yaml"
curl -fsSL -o "${K8S_MANIFESTS_DIR}/operator-crds.yaml" \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/operator-crds.yaml"
curl -fsSL -o "${K8S_MANIFESTS_DIR}/tigera-operator.yaml" \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/tigera-operator.yaml"
curl -fsSL -o "${K8S_MANIFESTS_DIR}/custom-resources.yaml" \
  "https://raw.githubusercontent.com/projectcalico/calico/${CALICO_VERSION}/manifests/custom-resources.yaml"
step_ok "downloaded Calico manifests"

step_start "generate kubeadm image list"
list_kubeadm_images | tee "${K8S_IMAGES_DIR}/images.txt" >/dev/null
echo "[INFO] image list:"
sed 's/^/[INFO]   /' "${K8S_IMAGES_DIR}/images.txt"
step_ok "generated kubeadm image list"

step_start "pull and save kube-system images"
while IFS= read -r image; do
  [[ -z "${image}" ]] && continue
  image_file="$(echo "${image}" | sed 's|/|_|g; s|:|_|g').tar"
  echo "[INFO] pulling image: ${image}"
  docker pull "${image}" >/dev/null
  docker save -o "${K8S_IMAGES_DIR}/${image_file}" "${image}"
  echo "[OK] saved image: ${image_file}"
done < "${K8S_IMAGES_DIR}/images.txt"
step_ok "pulled and saved kube-system images"

echo
echo "[CHECK] generate checksums"
(
  cd "${ASSETS_ROOT}"
  find kubernetes common -type f -print0 | sort -z | xargs -0 sha256sum > "${CHECKSUMS_DIR}/kubernetes-assets.sha256"
)

DOWNLOAD_END_TS="$(date +%s)"
DOWNLOAD_TOTAL_ELAPSED=$((DOWNLOAD_END_TS - DOWNLOAD_START_TS))
K8S_RPM_COUNT="$(find "${K8S_PACKAGES_DIR}" -maxdepth 1 -name '*.rpm' | wc -l | tr -d ' ')"
RUNTIME_RPM_COUNT="$(find "${RUNTIME_PACKAGES_DIR}" -maxdepth 1 -name '*.rpm' | wc -l | tr -d ' ')"
IMAGE_TAR_COUNT="$(find "${K8S_IMAGES_DIR}" -maxdepth 1 -name '*.tar' | wc -l | tr -d ' ')"
MANIFEST_COUNT="$(find "${K8S_MANIFESTS_DIR}" -maxdepth 1 -name '*.yaml' | wc -l | tr -d ' ')"
echo "[OK] generated checksums"
echo
echo "[RESULT] SUCCESS"
echo "[INFO] completed steps: ${DOWNLOAD_CURRENT_STEP}/${DOWNLOAD_TOTAL_STEPS}"
echo "[INFO] total elapsed: $(format_duration "${DOWNLOAD_TOTAL_ELAPSED}")"
echo "[INFO] summary:"
echo "[INFO]   Kubernetes rpm files: ${K8S_RPM_COUNT}"
echo "[INFO]   Runtime rpm files: ${RUNTIME_RPM_COUNT}"
echo "[INFO]   Kube-system image tar files: ${IMAGE_TAR_COUNT}"
echo "[INFO]   Manifest yaml files: ${MANIFEST_COUNT}"
