# 04 Services and Monitoring

`04`는 Kubernetes 클러스터 위에 DB와 모니터링 서비스를 배포하고 실제 지표 수집, dashboard, rule을 구성하는 단계다. 각 서비스는 독립 실행 가능해야 하므로 자산 목록, manifest, 실행 스크립트를 서비스 디렉터리 안에 둔다.

## Directories
- `01-mysql-or-mariadb/`
- `02-mongodb/`
- `03-prometheus/`
- `04-grafana/`
- `05-grafana-alloy/`
- `06-services-verify/`
- `scripts/04-service-lib.sh`

## Service Unit Layout
```text
<service>/
  assets/
    images.txt
    charts.txt
  manifests/
  dashboards/
  values/
  scripts/
    04-xx-01-download-assets.sh
    04-xx-02-verify-assets.sh
    04-xx-03-transfer-files.sh
    04-xx-04-import-images.sh
    04-xx-05-run-<service>.sh
    04-xx-06-verify-<service>.sh
```

## Execution Flow
```bash
make 04-01-mysql-or-mariadb-run
make 04-02-mongodb-run
make 04-03-prometheus-run
make 04-04-grafana-run
make 04-05-grafana-alloy-run
make 04-services-monitoring-verify
```

## Per-Service Flow
1. `download-assets`: pull image on the control host and save it as a tar under `assets/offline-assets/services/images/<service>/`.
2. `verify-assets`: verify local image tar and manifest existence.
3. `transfer-files`: send manifests to master and image tars to workload nodes.
4. `import-images`: import worker image tars into `containerd` and remove remote tar files unless `AIRGAP_KEEP_REMOTE_SERVICE_IMAGE_TARS=true`.
5. `run`: apply service manifests from master.
6. `verify`: verify worker image import, rollout, PVC, and Service objects.

## Runtime Notes
- Master is used for `kubectl apply` and manifest storage.
- Worker is the service workload target, so service images are imported and verified on worker.
- Prometheus imports images on master and worker because `node-exporter` runs as a DaemonSet on both nodes and `kube-state-metrics` is part of the Prometheus monitoring stack.
- Grafana dashboard JSON files are treated as offline manifest assets and are transferred with the service manifests.
- Remote image tar files are deleted after import to avoid `DiskPressure` on small root volumes.
- PVC-backed services require `local-path (default)` from `03-03-storageclass-run`.
- `04-service-lib.sh` waits for `node.kubernetes.io/disk-pressure:NoSchedule` to clear before applying service manifests.

## Targets
```bash
make 04-services-monitoring-run
make 04-services-monitoring-verify
make 04-services-monitoring-script-verify

make 04-01-mysql-or-mariadb-run
make 04-02-mongodb-run
make 04-03-prometheus-run
make 04-04-grafana-run
make 04-05-grafana-alloy-run
make 04-06-services-verify
```

## Verified Result
- MariaDB: `mariadb-0` Running, `data-mariadb-0` Bound
- MongoDB: `mongodb-0` Running, `data-mongodb-0` Bound
- Prometheus: `prometheus-0` Running, `node-exporter` Running on master/worker, `kube-state-metrics` Running, `kubernetes-cadvisor` healthy, `data-prometheus-0` Bound
- Grafana: `deployment/grafana` Ready, `grafana-data` Bound, `Prometheus` datasource and community dashboards `1860`, `25091`, `17483` provisioned from offline JSON assets
- Grafana Alloy: `deployment/alloy` Ready, `up{job="alloy"}` healthy in Prometheus
- `make 04-services-monitoring-verify`: success
