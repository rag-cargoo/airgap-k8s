# 04-06 Services Verify

04 서비스 전체 상태를 종합 검증한다.

## Files
- `scripts/04-06-01-verify-services.sh`

## Targets
```bash
make 04-services-monitoring-verify
make 04-06-services-verify
```

## Checks
- `database` namespace: MariaDB, MongoDB Pod/PVC/Service
- `monitoring` namespace: Prometheus, node-exporter, kube-state-metrics, Grafana, Alloy Pod/PVC/Service
- Prometheus scrape targets: `node-exporter`, `kube-state-metrics`, `alloy`
- Grafana dashboard: node resource panels and namespace service/workload/pod status panels
