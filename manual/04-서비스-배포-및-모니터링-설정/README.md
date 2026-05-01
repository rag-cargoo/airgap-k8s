# 04. 서비스 배포 및 모니터링 설정

04 단계는 `03`에서 구성한 Kubernetes 클러스터와 기본 StorageClass 위에 DB와 모니터링 서비스를 배포하고, Prometheus 지표 수집, Grafana dashboard, Grafana Alloy 수집 설정을 구성한다.

## 04-00. 사전 조건
```bash
cd <프로젝트-루트>
make 03-03-storageclass-verify
kubectl get storageclass
kubectl get nodes -o wide
```

설명: `local-path (default)`가 보여야 하며, worker 노드에 `DiskPressure` taint가 없어야 한다. PVC를 사용하는 MariaDB, MongoDB, Prometheus, Grafana는 기본 StorageClass가 없으면 `Pending` 상태로 멈춘다.

## 04-01. MariaDB
```bash
make 04-01-mysql-or-mariadb-run
make 04-01-mysql-or-mariadb-verify
```

설명: `docker.io/library/mariadb:11.4` 이미지를 폐쇄망 자산으로 저장하고 worker에 import한 뒤 `database` namespace에 StatefulSet, Service, Secret, PVC를 적용한다.

세부 절차: [01-mysql-or-mariadb](./01-mysql-or-mariadb/README.md)

## 04-02. MongoDB
```bash
make 04-02-mongodb-run
make 04-02-mongodb-verify
```

설명: `docker.io/library/mongo:7.0` 이미지를 worker에 import하고 `database` namespace에 StatefulSet, Service, Secret, PVC를 적용한다.

세부 절차: [02-mongodb](./02-mongodb/README.md)

## 04-03. Prometheus
```bash
make 04-03-prometheus-run
make 04-03-prometheus-verify
```

설명: `docker.io/prom/prometheus:v2.55.1`, `quay.io/prometheus/node-exporter:v1.8.2`, `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.14.0` 이미지를 master/worker에 import하고 `monitoring` namespace에 Prometheus StatefulSet, node-exporter DaemonSet, kube-state-metrics Deployment, scrape ConfigMap, alert rule ConfigMap, Service, PVC를 적용한다. `kubernetes-cadvisor` scrape job은 Kubernetes API server proxy를 통해 kubelet cAdvisor 지표를 수집한다.

세부 절차: [03-prometheus](./03-prometheus/README.md)

## 04-04. Grafana
```bash
make 04-04-grafana-run
make 04-04-grafana-verify
```

설명: `docker.io/grafana/grafana:11.3.0` 이미지를 worker에 import하고 `monitoring` namespace에 Deployment, Service, Secret, datasource ConfigMap, dashboard provider ConfigMap, dashboard ConfigMap, PVC를 적용한다. Dashboard는 Grafana.com community dashboard `1860`, `25091`, `17483` JSON을 오프라인 자산으로 반입해 자동 로드한다.

세부 절차: [04-grafana](./04-grafana/README.md)

## 04-05. Grafana Alloy
```bash
make 04-05-grafana-alloy-run
make 04-05-grafana-alloy-verify
```

설명: `docker.io/grafana/alloy:v1.5.1` 이미지를 worker에 import하고 `monitoring` namespace에 self scrape와 Prometheus remote_write가 포함된 ConfigMap, Deployment, Service를 적용한다.

세부 절차: [05-grafana-alloy](./05-grafana-alloy/README.md)

## 04-06. 전체 서비스 검증
```bash
make 04-services-monitoring-verify
make 04-06-services-verify
```

설명: 서비스별 로컬 자산, containerd 이미지, workload Ready, PVC Bound, Service 객체, Prometheus config/rule, scrape target, Grafana datasource/dashboard provisioning을 검증한다.

세부 절차: [06-services-verify](./06-services-verify/README.md)

## 04-07. 실행 순서 요약
```bash
make 04-01-mysql-or-mariadb-run
make 04-02-mongodb-run
make 04-03-prometheus-run
make 04-04-grafana-run
make 04-05-grafana-alloy-run
make 04-services-monitoring-verify
```

## 04-08. 검증 결과
- `make 04-01-mysql-or-mariadb-run`: 성공
- `make 04-02-mongodb-run`: 성공
- `make 04-03-prometheus-run`: 성공
- `make 04-04-grafana-run`: 성공
- `make 04-05-grafana-alloy-run`: 성공
- `make 04-services-monitoring-verify`: 성공
- `database`: `mariadb-0`, `mongodb-0` 모두 `1/1 Running`
- `monitoring`: `prometheus-0`, `grafana`, `alloy` 모두 `1/1 Running`
- `monitoring`: `node-exporter`가 master와 worker에서 모두 `1/1 Running`
- `monitoring`: `kube-state-metrics`가 `1/1 Running`
- PVC: `data-mariadb-0`, `data-mongodb-0`, `data-prometheus-0`, `grafana-data` 모두 `Bound`
- Prometheus: `up{job="node-exporter"}`, `up{job="kube-state-metrics"}`, `up{job="kubernetes-cadvisor"}`, `up{job="alloy"}` query가 healthy target을 반환
- Prometheus: `machine_cpu_cores{kubernetes_io_hostname!=""}` query가 cAdvisor node 지표를 반환
- Prometheus: `sum by (node) (up{job="node-exporter"})` query가 master/worker node별 상태를 반환
- Prometheus: `max by (namespace, endpoint) (kube_endpoint_address{namespace=~"database|monitoring", ready="true"})` query가 namespace별 service endpoint up/down 상태를 반환
- Grafana: `Prometheus` datasource와 `airgap-node-exporter-full`, `airgap-ksm-overview`, `airgap-k8s-cluster-community` dashboard provisioning 확인
- Grafana: dashboard에서 node exporter, kube-state-metrics, cAdvisor 기반 Kubernetes 상태 패널 확인

## 04-09. 장애 참고
8GB 루트 볼륨에서 서비스 이미지를 올리면 worker에 `DiskPressure`가 발생할 수 있다. 증상과 처리 절차는 [DiskPressure 트러블슈팅](../troubleshooting/04-services-diskpressure-root-volume.md)에 기록한다.
