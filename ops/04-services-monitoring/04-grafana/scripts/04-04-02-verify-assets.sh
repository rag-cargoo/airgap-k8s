#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/grafana"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=grafana"
SERVICE_PVC_NAMES="grafana-data"
SERVICE_SERVICE_NAMES="grafana"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_assets
service_init
for dashboard in \
  1860-node-exporter-full.json \
  25091-kube-state-metrics-overview.json \
  17483-kubernetes-cluster-monitoring.json; do
  test -f "${LOCAL_DASHBOARD_DIR}/${dashboard}"
  jq -e '.uid and .title and (.panels | length > 0)' "${LOCAL_DASHBOARD_DIR}/${dashboard}" >/dev/null
done
printf '[OK] Grafana community dashboard JSON files verified\n'
