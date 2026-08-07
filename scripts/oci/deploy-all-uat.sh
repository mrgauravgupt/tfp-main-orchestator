#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_HOST="${OCI_UAT_HOST:-161.118.161.98}"
DEPLOY_USER="${OCI_UAT_USER:-ubuntu}"
DEPLOY_PORT="${OCI_UAT_PORT:-22}"

bash "$ROOT_DIR/scripts/oci/bootstrap-uat-host.sh"

UAT_DEPLOY_HOST="$DEPLOY_HOST" \
UAT_DEPLOY_USER="$DEPLOY_USER" \
UAT_DEPLOY_PORT="$DEPLOY_PORT" \
UAT_DELETE_JSON_REPORTS=false \
UAT_REQUIRE_CLOUDFLARED=false \
  bash "$ROOT_DIR/tfpphotographers/scripts/vps/deploy-main-uat.sh"

DEPLOY_HOST="$DEPLOY_HOST" \
DEPLOY_USER="$DEPLOY_USER" \
DEPLOY_PORT="$DEPLOY_PORT" \
DEPLOY_ENV=uat \
APPLY_TFP_MIGRATIONS=false \
  bash "$ROOT_DIR/scripts/vps/deploy-both-services.sh"

echo "OCI UAT application and services are deployed on loopback-only origins."
