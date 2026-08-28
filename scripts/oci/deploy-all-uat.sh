#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_HOST="${OCI_UAT_HOST:-161.118.161.98}"
DEPLOY_USER="${OCI_UAT_USER:-ubuntu}"
DEPLOY_PORT="${OCI_UAT_PORT:-22}"
BOOTSTRAP_HOST="${OCI_UAT_BOOTSTRAP_HOST:-false}"

if [[ "$BOOTSTRAP_HOST" == "true" ]]; then
  echo "OCI_UAT_BOOTSTRAP_HOST=true: rebuilding the UAT host and databases before deployment."
  bash "$ROOT_DIR/scripts/oci/bootstrap-uat-host.sh"
else
  echo "Routine OCI UAT deployment: preserving the existing host and database."
fi
python3 "$ROOT_DIR/scripts/oci/prepare-ai-worker-env.py"

UAT_DEPLOY_HOST="$DEPLOY_HOST" \
UAT_DEPLOY_USER="$DEPLOY_USER" \
UAT_DEPLOY_PORT="$DEPLOY_PORT" \
UAT_DELETE_JSON_REPORTS=false \
UAT_REQUIRE_CLOUDFLARED="${OCI_UAT_REQUIRE_CLOUDFLARED:-true}" \
  bash "$ROOT_DIR/tfpphotographers/scripts/deploy/deploy-main-uat.sh"

OCI_UAT_HOST="$DEPLOY_HOST" \
OCI_UAT_USER="$DEPLOY_USER" \
OCI_UAT_PORT="$DEPLOY_PORT" \
  bash "$ROOT_DIR/tfp-ai-interface/scripts/deploy-uat.sh"

COLLAGE_DEPLOY_HOST="$DEPLOY_HOST" \
COLLAGE_DEPLOY_USER="$DEPLOY_USER" \
COLLAGE_DEPLOY_PORT="$DEPLOY_PORT" \
  bash "$ROOT_DIR/tfp-collage-service/scripts/deploy/deploy.sh" uat

OCI_UAT_HOST="$DEPLOY_HOST" \
OCI_UAT_USER="$DEPLOY_USER" \
OCI_UAT_PORT="$DEPLOY_PORT" \
  bash "$ROOT_DIR/scripts/oci/verify-uat-stack.sh"

echo "OCI UAT app, AI inference, and collage services are deployed and dependency-verified on loopback-only origins."
