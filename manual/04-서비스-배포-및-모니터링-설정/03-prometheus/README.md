# 04-03. Prometheus 배포

## 대상
- Namespace: `monitoring`
- Image: `docker.io/prom/prometheus:v2.55.1`
- Manifest: `ops/04-services-monitoring/03-prometheus/manifests/04-03-prometheus.yaml`
- Workload: `statefulset/prometheus`
- PVC: `data-prometheus-0`
- Service: `prometheus`

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
kubectl -n monitoring get statefulset,pod,pvc,svc -l app=prometheus
kubectl -n monitoring get pvc data-prometheus-0
```

## 완료 기준
- `prometheus-0` Pod가 `1/1 Running`이다.
- `data-prometheus-0` PVC가 `Bound`이다.
- `prometheus` Service가 존재한다.
