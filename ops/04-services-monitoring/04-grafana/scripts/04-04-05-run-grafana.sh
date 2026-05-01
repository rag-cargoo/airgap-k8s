#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/grafana"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=grafana"
SERVICE_PVC_NAMES="grafana-data"
SERVICE_SERVICE_NAMES="grafana"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"

create_grafana_dashboard_configmaps() {
  service_init
  printf '[STEP] create Grafana dashboard ConfigMaps from offline JSON files\n'
  remote_cmd "${AIRGAP_MASTER_PRIVATE_IP}" "sudo bash -lc '
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf
dashboard_dir=${REMOTE_DASHBOARD_DIR}
test -f \"\${dashboard_dir}/1860-node-exporter-full.json\"
test -f \"\${dashboard_dir}/25091-kube-state-metrics-overview.json\"
test -f \"\${dashboard_dir}/17483-kubernetes-cluster-monitoring.json\"

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f - >/dev/null
kubectl -n monitoring delete configmap \
  grafana-dashboard-node-exporter-full \
  grafana-dashboard-kube-state-metrics-overview \
  grafana-dashboard-kubernetes-cluster-monitoring \
  --ignore-not-found >/dev/null
kubectl -n monitoring create configmap grafana-dashboard-node-exporter-full \
  --from-file=1860-node-exporter-full.json=\"\${dashboard_dir}/1860-node-exporter-full.json\" >/dev/null
kubectl -n monitoring create configmap grafana-dashboard-kube-state-metrics-overview \
  --from-file=25091-kube-state-metrics-overview.json=\"\${dashboard_dir}/25091-kube-state-metrics-overview.json\" >/dev/null
kubectl -n monitoring create configmap grafana-dashboard-kubernetes-cluster-monitoring \
  --from-file=17483-kubernetes-cluster-monitoring.json=\"\${dashboard_dir}/17483-kubernetes-cluster-monitoring.json\" >/dev/null
kubectl -n monitoring delete configmap grafana-dashboards --ignore-not-found >/dev/null
'"
  printf '[RESULT] SUCCESS\n'
}

create_grafana_dashboard_configmaps
service_apply_manifests
