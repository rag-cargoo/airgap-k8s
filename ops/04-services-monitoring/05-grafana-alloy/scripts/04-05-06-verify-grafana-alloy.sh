#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana-alloy"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/alloy"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=alloy"
SERVICE_PVC_NAMES=""
SERVICE_SERVICE_NAMES="alloy"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl -n monitoring get configmap alloy-config -o jsonpath='{.data.config\.alloy}' | grep -Fq 'prometheus.scrape "alloy_self"'
kubectl -n monitoring get configmap alloy-config -o jsonpath='{.data.config\.alloy}' | grep -Fq 'prometheus.remote_write "prometheus"'

for attempt in $(seq 1 30); do
  if kubectl -n monitoring exec prometheus-0 -c prometheus -- \
    promtool query instant http://127.0.0.1:9090 'up{job="alloy"}' | grep -q '=> 1'; then
    printf '[OK] Prometheus is scraping Grafana Alloy metrics\n'
    exit 0
  fi
  printf '[WAIT] Alloy scrape target not ready, retry=%s/30\n' "${attempt}"
  sleep 10
done

printf '[FAIL] Prometheus did not expose healthy Alloy scrape target\n' >&2
kubectl -n monitoring exec prometheus-0 -c prometheus -- \
  promtool query instant http://127.0.0.1:9090 'up' >&2 || true
exit 1
REMOTE
