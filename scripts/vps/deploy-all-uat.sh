#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "scripts/vps/deploy-all-uat.sh is a compatibility entrypoint."
echo "Current UAT deploys target OCI through scripts/oci/deploy-all-uat.sh."
exec bash "$ROOT_DIR/scripts/oci/deploy-all-uat.sh"
