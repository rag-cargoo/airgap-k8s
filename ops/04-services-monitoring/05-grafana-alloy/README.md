# 04-05 Grafana Alloy

## Files
- `assets/images.txt`: `docker.io/grafana/alloy:v1.5.1`
- `manifests/04-05-grafana-alloy.yaml`: Namespace, ConfigMap with self scrape and Prometheus remote_write, Service, Deployment
- `scripts/04-05-01-download-assets.sh`
- `scripts/04-05-02-verify-assets.sh`
- `scripts/04-05-03-transfer-files.sh`
- `scripts/04-05-04-import-images.sh`
- `scripts/04-05-05-run-grafana-alloy.sh`
- `scripts/04-05-06-verify-grafana-alloy.sh`

## Monitoring Checks
- Alloy config contains `prometheus.scrape "alloy_self"`.
- Alloy config contains `prometheus.remote_write "prometheus"`.
- Prometheus query `up{job="alloy"}` returns a healthy target.

## Targets
```bash
make 04-05-grafana-alloy-run
make 04-05-grafana-alloy-verify
```
