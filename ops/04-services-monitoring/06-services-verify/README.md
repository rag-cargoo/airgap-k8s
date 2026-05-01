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
- `monitoring` namespace: Prometheus, Grafana, Alloy Pod/PVC/Service
