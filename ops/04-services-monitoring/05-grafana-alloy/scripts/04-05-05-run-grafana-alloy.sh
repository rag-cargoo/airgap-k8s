#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="grafana-alloy"
SERVICE_NAMESPACE="monitoring"
SERVICE_WORKLOAD="deployment/alloy"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=alloy"
SERVICE_PVC_NAMES=""
SERVICE_SERVICE_NAMES="alloy"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_apply_manifests
