#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/grafana"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=grafana"
SERVICE_PVC_NAMES="grafana-data"
SERVICE_SERVICE_NAMES="grafana"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl -n monitoring get configmap \
  grafana-datasources \
  grafana-dashboard-providers \
  grafana-dashboard-node-exporter-full \
  grafana-dashboard-kube-state-metrics-overview \
  grafana-dashboard-kubernetes-cluster-monitoring >/dev/null

if ! command -v curl >/dev/null 2>&1; then
  printf '[WARN] curl not found on master; skipped Grafana HTTP provisioning checks\n'
  exit 0
fi

admin_user="$(kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-user}' | base64 -d)"
admin_password="$(kubectl -n monitoring get secret grafana-admin -o jsonpath='{.data.admin-password}' | base64 -d)"
kubectl -n monitoring port-forward svc/grafana 13030:3000 >/tmp/airgap-grafana-port-forward.log 2>&1 &
pf_pid="$!"
cleanup() {
  kill "${pf_pid}" >/dev/null 2>&1 || true
  wait "${pf_pid}" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for attempt in $(seq 1 30); do
  if curl -fsS "http://127.0.0.1:13030/api/health" | grep -Eq '"database"[[:space:]]*:[[:space:]]*"ok"'; then
    break
  fi
  if [[ "${attempt}" -eq 30 ]]; then
    printf '[FAIL] Grafana API did not become ready through port-forward\n' >&2
    cat /tmp/airgap-grafana-port-forward.log >&2 || true
    exit 1
  fi
  printf '[WAIT] Grafana API not ready, retry=%s/30\n' "${attempt}"
  sleep 5
done

curl -fsS -u "${admin_user}:${admin_password}" \
  "http://127.0.0.1:13030/api/datasources/name/Prometheus" | grep -Eq '"type"[[:space:]]*:[[:space:]]*"prometheus"'
for dashboard_uid in \
  airgap-node-exporter-full \
  airgap-ksm-overview \
  airgap-k8s-cluster-community; do
  curl -fsS -u "${admin_user}:${admin_password}" \
    "http://127.0.0.1:13030/api/dashboards/uid/${dashboard_uid}" | grep -q '"dashboard"'
done
printf '[OK] Grafana datasource and dashboard provisioning verified\n'
REMOTE
