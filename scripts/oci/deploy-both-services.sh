#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export DEPLOY_ENV="${DEPLOY_ENV:-uat}"
export DEPLOY_HOST="${OCI_DEPLOY_HOST:-161.118.161.98}"
export DEPLOY_USER="${OCI_DEPLOY_USER:-ubuntu}"
export DEPLOY_PORT="${OCI_DEPLOY_PORT:-22}"
export VPS_DEPLOY_HOST="$DEPLOY_HOST"
export VPS_DEPLOY_USER="$DEPLOY_USER"
export AIP_DEPLOY_HOST="$DEPLOY_HOST"
export AIP_DEPLOY_USER="$DEPLOY_USER"
export COLLAGE_DEPLOY_HOST="$DEPLOY_HOST"
export COLLAGE_DEPLOY_USER="$DEPLOY_USER"
export APPLY_TFP_MIGRATIONS=false

bash "$ROOT_DIR/scripts/oci/configure-uat-db-tunnel.sh"
bash "$ROOT_DIR/scripts/vps/deploy-both-services.sh"
