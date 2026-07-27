#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_MAIN="${DEPLOY_MAIN:-true}"
DEPLOY_AI="${DEPLOY_AI:-true}"
DEPLOY_COLLAGE="${DEPLOY_COLLAGE:-true}"

echo "TFP UAT deployment"
echo "  Main application:   $DEPLOY_MAIN"
echo "  Moderation service: $DEPLOY_AI"
echo "  Collage service:    $DEPLOY_COLLAGE"

if [[ "$DEPLOY_MAIN" == "true" ]]; then
  bash "$ROOT_DIR/tfpphotographers/scripts/vps/deploy-main-uat.sh"
fi

DEPLOY_ENV=uat \
DEPLOY_AI="$DEPLOY_AI" \
DEPLOY_COLLAGE="$DEPLOY_COLLAGE" \
bash "$ROOT_DIR/scripts/vps/deploy-both-services.sh"

echo "All requested UAT services deployed."
