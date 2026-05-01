# 04-05. Grafana Alloy 배포

## 대상
- Namespace: `monitoring`
- Image: `docker.io/grafana/alloy:v1.5.1`
- Manifest: `ops/04-services-monitoring/05-grafana-alloy/manifests/04-05-grafana-alloy.yaml`
- Workload: `deployment/alloy`
- Service: `alloy`

## 단계별 스크립트
```bash
make step-04-05-01-grafana-alloy-download-assets
make step-04-05-02-grafana-alloy-verify-assets
make step-04-05-03-grafana-alloy-transfer-files
make step-04-05-04-grafana-alloy-import-images
make step-04-05-05-grafana-alloy-run
make step-04-05-06-grafana-alloy-verify
```

## 묶음 실행
```bash
make 04-05-grafana-alloy-run
make 04-05-grafana-alloy-verify
```

## 확인 명령
```bash
kubectl -n monitoring get deployment,pod,svc -l app=alloy
kubectl -n monitoring logs deployment/alloy --tail=50
```

## 완료 기준
- `deployment/alloy` rollout이 완료된다.
- `alloy` Pod가 `1/1 Running`이다.
- `alloy` Service가 존재한다.
