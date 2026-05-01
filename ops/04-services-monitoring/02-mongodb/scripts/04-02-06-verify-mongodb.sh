#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="mongodb"
SERVICE_NAMESPACE="database"
SERVICE_WORKLOAD="statefulset/mongodb"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=mongodb"
SERVICE_PVC_NAMES="data-mongodb-0"
SERVICE_SERVICE_NAMES="mongodb"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
