# 04-02. MongoDB 배포

## 대상
- Namespace: `database`
- Image: `docker.io/library/mongo:7.0`
- Manifest: `ops/04-services-monitoring/02-mongodb/manifests/04-02-mongodb.yaml`
- Workload: `statefulset/mongodb`
- PVC: `data-mongodb-0`
- Service: `mongodb`

## 단계별 스크립트
```bash
make step-04-02-01-mongodb-download-assets
make step-04-02-02-mongodb-verify-assets
make step-04-02-03-mongodb-transfer-files
make step-04-02-04-mongodb-import-images
make step-04-02-05-mongodb-run
make step-04-02-06-mongodb-verify
```

## 묶음 실행
```bash
make 04-02-mongodb-run
make 04-02-mongodb-verify
```

## 확인 명령
```bash
kubectl -n database get statefulset,pod,pvc,svc -l app=mongodb
kubectl -n database get pvc data-mongodb-0
```

## 완료 기준
- `mongodb-0` Pod가 `1/1 Running`이다.
- `data-mongodb-0` PVC가 `Bound`이다.
- `mongodb` Service가 존재한다.
