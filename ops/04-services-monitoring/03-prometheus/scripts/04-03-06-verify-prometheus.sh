#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="prometheus"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="statefulset/prometheus"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=prometheus"
SERVICE_PVC_NAMES="data-prometheus-0"
SERVICE_SERVICE_NAMES="prometheus node-exporter kube-state-metrics"
SERVICE_IMAGE_HOSTS="master worker1"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
remote_master_bash <<'REMOTE'
set -euo pipefail
export KUBECONFIG=/etc/kubernetes/admin.conf

kubectl -n monitoring rollout status daemonset/node-exporter --timeout=300s >/dev/null
kubectl -n monitoring rollout status deployment/kube-state-metrics --timeout=300s >/dev/null
kubectl -n monitoring wait --for=condition=Ready pod -l app.kubernetes.io/name=node-exporter --timeout=300s >/dev/null
kubectl -n monitoring wait --for=condition=Ready pod -l app.kubernetes.io/name=kube-state-metrics --timeout=300s >/dev/null
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool check config /etc/prometheus/prometheus.yml >/dev/null
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool check rules /etc/prometheus/rules/airgap-monitoring.yml >/dev/null

for query in 'up{job="node-exporter"}' 'up{job="kube-state-metrics"}' 'up{job="kubernetes-cadvisor"}' 'kube_pod_status_ready{namespace=~"database|monitoring",condition="true"}'; do
  for attempt in $(seq 1 30); do
    if kubectl -n monitoring exec prometheus-0 -c prometheus -- \
      promtool query instant http://127.0.0.1:9090 "${query}" | grep -q '=> 1'; then
      printf '[OK] Prometheus query returned data: %s\n' "${query}"
      break
    fi
    if [[ "${attempt}" -eq 30 ]]; then
      printf '[FAIL] Prometheus query did not return expected data: %s\n' "${query}" >&2
      kubectl -n monitoring exec prometheus-0 -c prometheus -- \
        promtool query instant http://127.0.0.1:9090 'up' >&2 || true
      exit 1
    fi
    printf '[WAIT] Prometheus query not ready: %s retry=%s/30\n' "${query}" "${attempt}"
    sleep 10
  done
done

for query in 'machine_cpu_cores{kubernetes_io_hostname!=""}' 'container_cpu_usage_seconds_total{kubernetes_io_hostname!=""}'; do
  for attempt in $(seq 1 30); do
    if kubectl -n monitoring exec prometheus-0 -c prometheus -- \
      promtool query instant http://127.0.0.1:9090 "${query}" | grep -q '=>'; then
      printf '[OK] Prometheus cAdvisor query returned data: %s\n' "${query}"
      break
    fi
    if [[ "${attempt}" -eq 30 ]]; then
      printf '[FAIL] Prometheus cAdvisor query did not return data: %s\n' "${query}" >&2
      kubectl -n monitoring exec prometheus-0 -c prometheus -- \
        promtool query instant http://127.0.0.1:9090 'up{job="kubernetes-cadvisor"}' >&2 || true
      exit 1
    fi
    printf '[WAIT] Prometheus cAdvisor query not ready: %s retry=%s/30\n' "${query}" "${attempt}"
    sleep 10
  done
done
REMOTE
