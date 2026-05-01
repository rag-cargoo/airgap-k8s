#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/grafana"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=grafana"
SERVICE_PVC_NAMES="grafana-data"
SERVICE_SERVICE_NAMES="grafana"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
