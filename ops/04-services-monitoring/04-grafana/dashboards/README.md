# Grafana Dashboard Assets

## Source Dashboards
- `1860-node-exporter-full.json`: Grafana.com dashboard `1860`, Node Exporter Full.
- `25091-kube-state-metrics-overview.json`: Grafana.com dashboard `25091`, Kube-State-Metrics Overview.
- `17483-kubernetes-cluster-monitoring.json`: Grafana.com dashboard `17483`, Kubernetes Cluster Monitoring via Prometheus.

## Airgap Customization
- Datasource placeholders are pinned to the local Grafana datasource UID `Prometheus`.
- Dashboard UIDs are changed to `airgap-*` values to avoid collisions with imported user dashboards.
- The `17483` dashboard is kept because Prometheus now scrapes kubelet cAdvisor metrics through the Kubernetes API server proxy.
