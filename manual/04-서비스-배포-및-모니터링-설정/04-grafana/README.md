# 04-04. Grafana 배포

## 대상
- Namespace: `monitoring`
- Image: `docker.io/grafana/grafana:11.3.0`
- Manifest: `ops/04-services-monitoring/04-grafana/manifests/04-04-grafana.yaml`
- Workload: `deployment/grafana`
- PVC: `grafana-data`
- Service: `grafana`
- Datasource: `Prometheus`
- Dashboards:
  - `1860`: Node Exporter Full
  - `25091`: Kube-State-Metrics Overview
  - `17483`: Kubernetes Cluster Monitoring via Prometheus
- Dashboard Provisioning: Grafana.com JSON을 오프라인 자산으로 반입하고 ConfigMap으로 자동 로드

## 단계별 스크립트
```bash
make step-04-04-01-grafana-download-assets
make step-04-04-02-grafana-verify-assets
make step-04-04-03-grafana-transfer-files
make step-04-04-04-grafana-import-images
make step-04-04-05-grafana-run
make step-04-04-06-grafana-verify
```

## 묶음 실행
```bash
make 04-04-grafana-run
make 04-04-grafana-verify
```

## 확인 명령
```bash
kubectl -n monitoring get deployment,pod,pvc,svc -l app.kubernetes.io/name=grafana
kubectl -n monitoring get pvc grafana-data
kubectl -n monitoring get configmap grafana-datasources grafana-dashboard-providers
kubectl -n monitoring get configmap grafana-dashboard-node-exporter-full
kubectl -n monitoring get configmap grafana-dashboard-kube-state-metrics-overview
kubectl -n monitoring get configmap grafana-dashboard-kubernetes-cluster-monitoring
curl -fsS -u admin:airgap-grafana-pass http://127.0.0.1:13000/api/dashboards/uid/airgap-node-exporter-full
curl -fsS -u admin:airgap-grafana-pass http://127.0.0.1:13000/api/dashboards/uid/airgap-ksm-overview
curl -fsS -u admin:airgap-grafana-pass http://127.0.0.1:13000/api/dashboards/uid/airgap-k8s-cluster-community
```

## 커뮤니티 대시보드 반입 기준
온라인 Grafana에서는 dashboard import 화면에 `1860`, `25091`, `17483` 같은 번호를 입력해 가져올 수 있다.
폐쇄망 제출본에서는 같은 방식을 런타임에 수행하지 않고, 온라인 PC에서 JSON을 미리 다운로드한 뒤 `ops/04-services-monitoring/04-grafana/dashboards/`에 고정한다.
`04-04-01` 다운로드 단계는 해당 JSON 파일을 `assets/offline-assets/services/manifests/grafana/dashboards/`로 복사하고, `04-04-03` 전송 단계는 서버의 `/opt/offline-assets/services/manifests/grafana/dashboards/`로 반입한다.
`04-04-05` 배포 단계는 JSON 파일별 ConfigMap을 만들고 Grafana dashboard provider가 `/var/lib/grafana/dashboards`에서 자동 로드한다.
대용량 dashboard JSON ConfigMap은 `kubectl apply`의 `last-applied-configuration` annotation 제한에 걸릴 수 있으므로, `delete -> create` 방식으로 갱신한다.
기존 수작업 dashboard `airgap-k8s-monitoring`은 제거하고, 새 dashboard UID 3개만 유지한다.

## 중복 legend 처리 기준
기존 수작업 dashboard의 `Node Memory Usage`, `Root Filesystem Usage` 패널은 node 이름만 legend로 쓰면서 `instance`, `device`, `mountpoint`별 시계열을 그대로 반환해 같은 node 이름이 여러 줄로 중복 표시될 수 있었다.
새 구성은 node 상세는 `1860` Node Exporter Full에서 node 변수를 선택해 확인하고, Kubernetes 상태는 `25091`, `17483` dashboard로 분리한다.
직접 패널을 추가할 때는 node별 요약 패널에 `max by (node) (...)`, `sum by (node) (...)`처럼 집계를 명시한다.

## 완료 기준
- `deployment/grafana` rollout이 완료된다.
- `grafana-data` PVC가 `Bound`이다.
- `grafana` Service가 존재한다.
- Grafana API에서 `Prometheus` datasource가 확인된다.
- Grafana API에서 `airgap-node-exporter-full`, `airgap-ksm-overview`, `airgap-k8s-cluster-community` dashboard가 확인된다.
- `1860` dashboard는 `node-exporter` 지표로 node별 CPU/메모리/디스크 상태를 표시한다.
- `25091` dashboard는 `kube-state-metrics` 지표로 namespace, workload, pod, configmap, secret 상태를 표시한다.
- `17483` dashboard는 `kubernetes-cadvisor` scrape job의 `container_*`, `machine_*` 지표로 Kubernetes cluster resource 상태를 표시한다.
