# 04-01 MySQL or MariaDB

MariaDB 기준으로 구현한다.

## Files
- `assets/images.txt`: `docker.io/library/mariadb:11.4`
- `manifests/04-01-mariadb.yaml`: Namespace, Secret, Service, StatefulSet, PVC template
- `scripts/04-01-01-download-assets.sh`
- `scripts/04-01-02-verify-assets.sh`
- `scripts/04-01-03-transfer-files.sh`
- `scripts/04-01-04-import-images.sh`
- `scripts/04-01-05-run-mysql-or-mariadb.sh`
- `scripts/04-01-06-verify-mysql-or-mariadb.sh`

## Targets
```bash
make 04-01-mysql-or-mariadb-run
make 04-01-mysql-or-mariadb-verify
```
