# 04-02 MongoDB

## Files
- `assets/images.txt`: `docker.io/library/mongo:7.0`
- `manifests/04-02-mongodb.yaml`: Namespace, Secret, Service, StatefulSet, PVC template
- `scripts/04-02-01-download-assets.sh`
- `scripts/04-02-02-verify-assets.sh`
- `scripts/04-02-03-transfer-files.sh`
- `scripts/04-02-04-import-images.sh`
- `scripts/04-02-05-run-mongodb.sh`
- `scripts/04-02-06-verify-mongodb.sh`

## Targets
```bash
make 04-02-mongodb-run
make 04-02-mongodb-verify
```
