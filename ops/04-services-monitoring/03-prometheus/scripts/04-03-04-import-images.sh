#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="prometheus"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="statefulset/prometheus"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=prometheus"
SERVICE_PVC_NAMES="data-prometheus-0"
SERVICE_SERVICE_NAMES="prometheus"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_import_images
