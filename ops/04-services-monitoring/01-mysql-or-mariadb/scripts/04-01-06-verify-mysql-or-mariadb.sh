#!/usr/bin/env bash
set -euo pipefail
SERVICE_ID="mysql-or-mariadb"
SERVICE_NAMESPACE="database"
SERVICE_WORKLOAD="statefulset/mariadb"
SERVICE_POD_SELECTOR="app.kubernetes.io/name=mariadb"
SERVICE_PVC_NAMES="data-mariadb-0"
SERVICE_SERVICE_NAMES="mariadb"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/04-service-lib.sh"
service_verify_remote_images
service_verify_workload
