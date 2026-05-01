# 04-05 Grafana Alloy

## Files
- `assets/images.txt`: `docker.io/grafana/alloy:v1.5.1`
- `manifests/04-05-grafana-alloy.yaml`: Namespace, ConfigMap, Service, Deployment
- `scripts/04-05-01-download-assets.sh`
- `scripts/04-05-02-verify-assets.sh`
- `scripts/04-05-03-transfer-files.sh`
- `scripts/04-05-04-import-images.sh`
- `scripts/04-05-05-run-grafana-alloy.sh`
- `scripts/04-05-06-verify-grafana-alloy.sh`

## Targets
```bash
make 04-05-grafana-alloy-run
make 04-05-grafana-alloy-verify
```
