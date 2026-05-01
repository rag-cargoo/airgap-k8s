# 04-06. 서비스 통합 검증

## 실행
```bash
make 04-services-monitoring-verify
make 04-06-services-verify
```

## 검증 범위
- 서비스별 로컬 이미지 tar와 manifest 존재 여부
- worker 노드 containerd에 서비스 이미지 import 여부
- MariaDB, MongoDB, Prometheus StatefulSet Ready
- node-exporter DaemonSet Ready
- kube-state-metrics, Grafana, Alloy Deployment rollout 완료
- MariaDB, MongoDB, Prometheus, Grafana PVC `Bound`
- 각 Service 객체 존재 여부
- Prometheus config/rule 검증
- Prometheus query `up{job="node-exporter"}`, `up{job="kube-state-metrics"}`, `up{job="kubernetes-cadvisor"}`, `up{job="alloy"}` 검증
- Prometheus query `machine_cpu_cores{kubernetes_io_hostname!=""}` 검증
- Prometheus query로 node별 상태와 namespace별 service endpoint up/down 상태 검증
- Grafana datasource/dashboard provisioning 검증

## 확인 명령
```bash
kubectl -n database get pods,pvc,svc -o wide
kubectl -n monitoring get pods,pvc,svc -o wide
kubectl get pv
```

## 완료 기준
- `database` namespace의 `mariadb-0`, `mongodb-0`이 `1/1 Running`이다.
- `monitoring` namespace의 `prometheus-0`, `grafana`, `alloy`, `kube-state-metrics`, `node-exporter`가 `1/1 Running`이다.
- `data-mariadb-0`, `data-mongodb-0`, `data-prometheus-0`, `grafana-data` PVC가 모두 `Bound`이다.
- Prometheus가 `node-exporter`, `kube-state-metrics`, `kubernetes-cadvisor`, `alloy` target을 healthy 상태로 scrape한다.
- Grafana에 `Prometheus` datasource와 `airgap-node-exporter-full`, `airgap-ksm-overview`, `airgap-k8s-cluster-community` dashboard가 provision된다.
- Grafana dashboard에서 node exporter, kube-state-metrics, cAdvisor 기반 Kubernetes 상태가 확인된다.
