# 04-04. Grafana 배포

## 대상
- Namespace: `monitoring`
- Image: `docker.io/grafana/grafana:11.3.0`
- Manifest: `ops/04-services-monitoring/04-grafana/manifests/04-04-grafana.yaml`
- Workload: `deployment/grafana`
- PVC: `grafana-data`
- Service: `grafana`

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
kubectl -n monitoring get deployment,pod,pvc,svc -l app=grafana
kubectl -n monitoring get pvc grafana-data
```

## 완료 기준
- `deployment/grafana` rollout이 완료된다.
- `grafana-data` PVC가 `Bound`이다.
- `grafana` Service가 존재한다.
