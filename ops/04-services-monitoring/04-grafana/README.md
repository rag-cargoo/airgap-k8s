# 04-04 Grafana

## Files
- `assets/images.txt`: `docker.io/grafana/grafana:11.3.0`
- `manifests/04-04-grafana.yaml`: Namespace, Secret, datasource ConfigMap, PVC, Service, Deployment
- `scripts/04-04-01-download-assets.sh`
- `scripts/04-04-02-verify-assets.sh`
- `scripts/04-04-03-transfer-files.sh`
- `scripts/04-04-04-import-images.sh`
- `scripts/04-04-05-run-grafana.sh`
- `scripts/04-04-06-verify-grafana.sh`

## Targets
```bash
make 04-04-grafana-run
make 04-04-grafana-verify
```
