#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
source "${PROJECT_ROOT}/ops/01-airgap-linux-environment/scripts/load-project-env.sh"

AIRGAP_SSH_PORT="${AIRGAP_SSH_PORT:-22}"
AIRGAP_USE_BASTION="${AIRGAP_USE_BASTION:-false}"

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    printf '[FAIL] missing env: %s\n' "${name}" >&2
    exit 1
  fi
}

for var in AIRGAP_SSH_USER AIRGAP_SSH_KEY_PATH AIRGAP_MASTER_PRIVATE_IP; do
  require_env "${var}"
done

if [[ "${AIRGAP_USE_BASTION}" == "true" ]]; then
  require_env AIRGAP_BASTION_PUBLIC_IP
  PROXY_ARGS=(-o "ProxyCommand=ssh -i ${AIRGAP_SSH_KEY_PATH} -p ${AIRGAP_SSH_PORT} -W %h:%p ${AIRGAP_SSH_USER}@${AIRGAP_BASTION_PUBLIC_IP}")
else
  PROXY_ARGS=()
fi

remote_master_bash() {
  ssh -p "${AIRGAP_SSH_PORT}" -i "${AIRGAP_SSH_KEY_PATH}" "${PROXY_ARGS[@]}" \
    "${AIRGAP_SSH_USER}@${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -s"
}

printf '[CHECK] local-path-provisioner rollout and dynamic PVC\n'
remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
SMOKE_NS=default
SMOKE_ID="local-path-smoke-$(date +%s)"
SMOKE_PVC="${SMOKE_ID}-pvc"
SMOKE_POD="${SMOKE_ID}-pod"
SMOKE_FILE="/tmp/${SMOKE_ID}.yaml"

cleanup() {
  kubectl delete pod -n "${SMOKE_NS}" "${SMOKE_POD}" --ignore-not-found=true --wait=false >/dev/null 2>&1 || true
  kubectl delete pvc -n "${SMOKE_NS}" "${SMOKE_PVC}" --ignore-not-found=true --wait=false >/dev/null 2>&1 || true
  rm -f "${SMOKE_FILE}"
}
trap cleanup EXIT

kubectl -n local-path-storage rollout status deploy/local-path-provisioner --timeout=300s >/dev/null

default_annotation="$(kubectl get storageclass local-path -o jsonpath='{.metadata.annotations.storageclass\.kubernetes\.io/is-default-class}')"
if [[ "${default_annotation}" != "true" ]]; then
  printf '[FAIL] local-path is not the default StorageClass\n' >&2
  exit 1
fi

cat > "${SMOKE_FILE}" <<YAML
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ${SMOKE_PVC}
  namespace: ${SMOKE_NS}
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 64Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: ${SMOKE_POD}
  namespace: ${SMOKE_NS}
spec:
  restartPolicy: Never
  containers:
    - name: busybox
      image: docker.io/library/busybox:1.37.0
      imagePullPolicy: IfNotPresent
      command:
        - /bin/sh
        - -c
      args:
        - echo storageclass-ok > /data/result && cat /data/result && sleep 3600
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: ${SMOKE_PVC}
YAML

kubectl apply -f "${SMOKE_FILE}" >/dev/null
kubectl wait -n "${SMOKE_NS}" --for=condition=Ready "pod/${SMOKE_POD}" --timeout=180s >/dev/null

pvc_phase="$(kubectl get pvc -n "${SMOKE_NS}" "${SMOKE_PVC}" -o jsonpath='{.status.phase}')"
if [[ "${pvc_phase}" != "Bound" ]]; then
  printf '[FAIL] smoke PVC is not Bound: %s\n' "${pvc_phase}" >&2
  exit 1
fi

pod_value="$(kubectl exec -n "${SMOKE_NS}" "${SMOKE_POD}" -- cat /data/result)"
if [[ "${pod_value}" != "storageclass-ok" ]]; then
  printf '[FAIL] smoke pod volume read mismatch: %s\n' "${pod_value}" >&2
  exit 1
fi

kubectl delete pod -n "${SMOKE_NS}" "${SMOKE_POD}" --ignore-not-found=true --wait=true >/dev/null
kubectl delete pvc -n "${SMOKE_NS}" "${SMOKE_PVC}" --ignore-not-found=true --wait=false >/dev/null
trap - EXIT
rm -f "${SMOKE_FILE}"
REMOTE

printf '[RESULT] SUCCESS\n'
