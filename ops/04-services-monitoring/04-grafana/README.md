# 04-04 Grafana

## Files
- `assets/images.txt`: `docker.io/grafana/grafana:11.3.0`
- `dashboards/1860-node-exporter-full.json`: Grafana.com community dashboard 1860, Node Exporter Full
- `dashboards/25091-kube-state-metrics-overview.json`: Grafana.com community dashboard 25091, Kube-State-Metrics Overview
- `dashboards/17483-kubernetes-cluster-monitoring.json`: Grafana.com community dashboard 17483, Kubernetes Cluster Monitoring via Prometheus
- `manifests/04-04-grafana.yaml`: Namespace, Secret, datasource ConfigMap, dashboard provider ConfigMap, PVC, Service, Deployment
- `scripts/04-04-01-download-assets.sh`
- `scripts/04-04-02-verify-assets.sh`
- `scripts/04-04-03-transfer-files.sh`
- `scripts/04-04-04-import-images.sh`
- `scripts/04-04-05-run-grafana.sh`
- `scripts/04-04-06-verify-grafana.sh`

## Monitoring Checks
- Grafana API datasource lookup: `Prometheus`
- Grafana API dashboard UID lookup: `airgap-node-exporter-full`
- Grafana API dashboard UID lookup: `airgap-ksm-overview`
- Grafana API dashboard UID lookup: `airgap-k8s-cluster-community`
- Dashboards include node resource charts, kube-state-metrics inventory/status panels, and cAdvisor-backed Kubernetes cluster resource panels.

## Targets
```bash
make 04-04-grafana-run
make 04-04-grafana-verify
```
