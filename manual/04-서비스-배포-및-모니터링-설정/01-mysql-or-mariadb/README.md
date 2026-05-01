# 04-01. MariaDB 배포

## 대상
- Namespace: `database`
- Image: `docker.io/library/mariadb:11.4`
- Manifest: `ops/04-services-monitoring/01-mysql-or-mariadb/manifests/04-01-mariadb.yaml`
- Workload: `statefulset/mariadb`
- PVC: `data-mariadb-0`
- Service: `mariadb`

## 단계별 스크립트
```bash
make step-04-01-01-mysql-or-mariadb-download-assets
make step-04-01-02-mysql-or-mariadb-verify-assets
make step-04-01-03-mysql-or-mariadb-transfer-files
make step-04-01-04-mysql-or-mariadb-import-images
make step-04-01-05-mysql-or-mariadb-run
make step-04-01-06-mysql-or-mariadb-verify
```

## 묶음 실행
```bash
make 04-01-mysql-or-mariadb-run
make 04-01-mysql-or-mariadb-verify
```

## 확인 명령
```bash
kubectl -n database get statefulset,pod,pvc,svc -l app=mariadb
kubectl -n database get pvc data-mariadb-0
```

## 완료 기준
- `mariadb-0` Pod가 `1/1 Running`이다.
- `data-mariadb-0` PVC가 `Bound`이다.
- `mariadb` Service가 존재한다.
