#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_HOST="${OCI_UAT_HOST:-161.118.161.98}"
DEPLOY_USER="${OCI_UAT_USER:-ubuntu}"
DEPLOY_PORT="${OCI_UAT_PORT:-22}"

bash "$ROOT_DIR/scripts/oci/bootstrap-uat-host.sh"
python3 "$ROOT_DIR/scripts/oci/prepare-ai-worker-env.py"

UAT_DEPLOY_HOST="$DEPLOY_HOST" \
UAT_DEPLOY_USER="$DEPLOY_USER" \
UAT_DEPLOY_PORT="$DEPLOY_PORT" \
UAT_DELETE_JSON_REPORTS=false \
UAT_REQUIRE_CLOUDFLARED="${OCI_UAT_REQUIRE_CLOUDFLARED:-true}" \
  bash "$ROOT_DIR/tfpphotographers/scripts/vps/deploy-main-uat.sh"

OCI_UAT_HOST="$DEPLOY_HOST" \
OCI_UAT_USER="$DEPLOY_USER" \
OCI_UAT_PORT="$DEPLOY_PORT" \
  bash "$ROOT_DIR/tfp-ai-inference-service/scripts/deploy-uat.sh"

DEPLOY_HOST="$DEPLOY_HOST" \
DEPLOY_USER="$DEPLOY_USER" \
DEPLOY_PORT="$DEPLOY_PORT" \
DEPLOY_ENV=uat \
DEPLOY_AI=false \
APPLY_TFP_MIGRATIONS=false \
  bash "$ROOT_DIR/scripts/vps/deploy-both-services.sh"

echo "OCI UAT app, AI inference, and collage services are deployed on loopback-only origins."
