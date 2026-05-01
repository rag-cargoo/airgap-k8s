# 04-03 Prometheus

## Files
- `assets/images.txt`: `docker.io/prom/prometheus:v2.55.1`, `quay.io/prometheus/node-exporter:v1.8.2`, `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.14.0`
- `manifests/04-03-prometheus.yaml`: Namespace, RBAC, scrape ConfigMap, rule ConfigMap, kube-state-metrics Deployment, node-exporter DaemonSet, Service, StatefulSet, PVC template
- `scripts/04-03-01-download-assets.sh`
- `scripts/04-03-02-verify-assets.sh`
- `scripts/04-03-03-transfer-files.sh`
- `scripts/04-03-04-import-images.sh`
- `scripts/04-03-05-run-prometheus.sh`
- `scripts/04-03-06-verify-prometheus.sh`

## Monitoring Checks
- `promtool check config /etc/prometheus/prometheus.yml`
- `promtool check rules /etc/prometheus/rules/airgap-monitoring.yml`
- `promtool query instant http://127.0.0.1:9090 'up{job="node-exporter"}'`
- `promtool query instant http://127.0.0.1:9090 'up{job="kube-state-metrics"}'`
- `promtool query instant http://127.0.0.1:9090 'max by (namespace, endpoint) (kube_endpoint_address{namespace=~"database|monitoring", ready="true"})'`

## Targets
```bash
make 04-03-prometheus-run
make 04-03-prometheus-verify
```
