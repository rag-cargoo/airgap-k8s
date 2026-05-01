# 04-03. Prometheus 배포

## 대상
- Namespace: `monitoring`
- Image: `docker.io/prom/prometheus:v2.55.1`
- Exporter Image: `quay.io/prometheus/node-exporter:v1.8.2`
- State Metrics Image: `registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.14.0`
- Manifest: `ops/04-services-monitoring/03-prometheus/manifests/04-03-prometheus.yaml`
- Workload: `statefulset/prometheus`
- Exporter Workload: `daemonset/node-exporter`
- State Metrics Workload: `deployment/kube-state-metrics`
- PVC: `data-prometheus-0`
- Service: `prometheus`, `node-exporter`, `kube-state-metrics`
- Scrape Jobs: `prometheus`, `node-exporter`, `kube-state-metrics`, `kubernetes-cadvisor`

## 단계별 스크립트
```bash
make step-04-03-01-prometheus-download-assets
make step-04-03-02-prometheus-verify-assets
make step-04-03-03-prometheus-transfer-files
make step-04-03-04-prometheus-import-images
make step-04-03-05-prometheus-run
make step-04-03-06-prometheus-verify
```

## 묶음 실행
```bash
make 04-03-prometheus-run
make 04-03-prometheus-verify
```

## 확인 명령
```bash
kubectl -n monitoring get statefulset,pod,pvc,svc -l app.kubernetes.io/name=prometheus
kubectl -n monitoring get daemonset,pod,svc -l app.kubernetes.io/name=node-exporter
kubectl -n monitoring get deployment,pod,svc -l app.kubernetes.io/name=kube-state-metrics
kubectl -n monitoring get pvc data-prometheus-0
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool check config /etc/prometheus/prometheus.yml
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool check rules /etc/prometheus/rules/airgap-monitoring.yml
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool query instant http://127.0.0.1:9090 'up{job="node-exporter"}'
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool query instant http://127.0.0.1:9090 'up{job="kube-state-metrics"}'
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool query instant http://127.0.0.1:9090 'up{job="kubernetes-cadvisor"}'
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool query instant http://127.0.0.1:9090 'machine_cpu_cores{kubernetes_io_hostname!=""}'
kubectl -n monitoring exec prometheus-0 -c prometheus -- promtool query instant http://127.0.0.1:9090 'max by (namespace, endpoint) (kube_endpoint_address{namespace=~"database|monitoring", ready="true"})'
```

## 완료 기준
- `prometheus-0` Pod가 `1/1 Running`이다.
- `node-exporter` DaemonSet이 master와 worker에서 모두 `1/1 Running`이다.
- `kube-state-metrics` Deployment가 `1/1 Running`이다.
- `data-prometheus-0` PVC가 `Bound`이다.
- `prometheus`, `node-exporter`, `kube-state-metrics` Service가 존재한다.
- Prometheus config와 rule 검증이 성공한다.
- Prometheus query `up{job="node-exporter"}`가 healthy target을 반환한다.
- Prometheus query `up{job="kube-state-metrics"}`가 healthy target을 반환한다.
- Prometheus query `up{job="kubernetes-cadvisor"}`가 healthy target을 반환한다.
- Prometheus query `machine_cpu_cores{kubernetes_io_hostname!=""}`가 node별 cAdvisor 지표를 반환한다.
- Prometheus query가 node별 상태와 namespace별 service endpoint up/down 상태를 반환한다.
