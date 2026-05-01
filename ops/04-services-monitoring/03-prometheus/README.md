# 04-03 Prometheus

## Files
- `assets/images.txt`: `docker.io/prom/prometheus:v2.55.1`
- `manifests/04-03-prometheus.yaml`: Namespace, ConfigMap, Service, StatefulSet, PVC template
- `scripts/04-03-01-download-assets.sh`
- `scripts/04-03-02-verify-assets.sh`
- `scripts/04-03-03-transfer-files.sh`
- `scripts/04-03-04-import-images.sh`
- `scripts/04-03-05-run-prometheus.sh`
- `scripts/04-03-06-verify-prometheus.sh`

## Targets
```bash
make 04-03-prometheus-run
make 04-03-prometheus-verify
```
