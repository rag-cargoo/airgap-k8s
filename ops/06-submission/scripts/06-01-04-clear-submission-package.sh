#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
SUBMISSION_DIR="${PROJECT_ROOT}/delivery/submission"

rm -rf "${SUBMISSION_DIR}"
printf '[RESULT] SUCCESS\n'
printf '[OK] removed generated submission directory: %s\n' "${SUBMISSION_DIR}"
