#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# OCI deployment configuration
export DEPLOY_HOST="${DEPLOY_HOST:-80.225.208.169}"
export DEPLOY_USER="${DEPLOY_USER:-ubuntu}"
export DEPLOY_PORT="${DEPLOY_PORT:-22}"

# AI Inference Platform configuration
export AIP_DEPLOY_HOST="${AIP_DEPLOY_HOST:-$DEPLOY_HOST}"
export AIP_DEPLOY_USER="${AIP_DEPLOY_USER:-$DEPLOY_USER}"
export AIP_DEPLOY_PORT="${AIP_DEPLOY_PORT:-$DEPLOY_PORT}"
export AIP_DEPLOY_PATH="${AIP_DEPLOY_PATH:-/srv/ai-inference-platform/current}"
export AIP_SERVICE_NAME="${AIP_SERVICE_NAME:-ai-inference-platform}"
export AIP_NGINX_PORT="${AIP_NGINX_PORT:-7001}"
export AIP_APP_PORT="${AIP_APP_PORT:-7002}"
export AIP_EXPOSE_PLAYGROUND_UI="${AIP_EXPOSE_PLAYGROUND_UI:-true}"

# Collage Service configuration
export COLLAGE_DEPLOY_HOST="${COLLAGE_DEPLOY_HOST:-$DEPLOY_HOST}"
export COLLAGE_DEPLOY_USER="${COLLAGE_DEPLOY_USER:-$DEPLOY_USER}"
export COLLAGE_DEPLOY_PORT="${COLLAGE_DEPLOY_PORT:-$DEPLOY_PORT}"
export COLLAGE_DEPLOY_PATH="${COLLAGE_DEPLOY_PATH:-/srv/collage-service/current}"
export COLLAGE_SERVICE_NAME="${COLLAGE_SERVICE_NAME:-collage-service}"
export COLLAGE_NGINX_PORT="${COLLAGE_NGINX_PORT:-7003}"
export COLLAGE_APP_PORT="${COLLAGE_APP_PORT:-7004}"

# Control flags
DEPLOY_AI="${DEPLOY_AI:-true}"
DEPLOY_COLLAGE="${DEPLOY_COLLAGE:-true}"

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  OCI Deployment: AI Inference Platform + Collage Service"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Deployment Configuration:"
echo "  Host:              $DEPLOY_HOST"
echo "  User:              $DEPLOY_USER"
echo "  Port:              $DEPLOY_PORT"
echo ""
echo "AI Inference Platform:"
echo "  Deploy:            $DEPLOY_AI"
echo "  Path:              $AIP_DEPLOY_PATH"
echo "  Service:           $AIP_SERVICE_NAME"
echo "  Nginx Port:        $AIP_NGINX_PORT (public)"
echo "  App Port:          $AIP_APP_PORT (private)"
echo ""
echo "Collage Service:"
echo "  Deploy:            $DEPLOY_COLLAGE"
echo "  Path:              $COLLAGE_DEPLOY_PATH"
echo "  Service:           $COLLAGE_SERVICE_NAME"
echo "  Nginx Port:        $COLLAGE_NGINX_PORT (public)"
echo "  App Port:          $COLLAGE_APP_PORT (private)"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Deploy AI Inference Platform
if [[ "$DEPLOY_AI" == "true" ]]; then
  echo "📦 Deploying AI Inference Platform..."
  bash "$ROOT_DIR/ai-inference-platform/scripts/oci/deploy-prod-7001.sh"
  echo "✅ AI Inference Platform deployment complete"
  echo ""
fi

# Deploy Collage Service
if [[ "$DEPLOY_COLLAGE" == "true" ]]; then
  echo "📦 Deploying Collage Service..."
  bash "$ROOT_DIR/collage-service/scripts/oci/deploy-prod-7003.sh"
  echo "✅ Collage Service deployment complete"
  echo ""
fi

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  ✅ All deployments complete!"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Service URLs:"
echo "  AI Inference:  http://$DEPLOY_HOST:$AIP_NGINX_PORT/"
echo "  Collage:       http://$DEPLOY_HOST:$COLLAGE_NGINX_PORT/"
echo "  Health Check:  http://$DEPLOY_HOST:$AIP_NGINX_PORT/health/live"
echo ""
echo "To deploy only one service, use:"
echo "  DEPLOY_AI=false bash $0        # Deploy only collage service"
echo "  DEPLOY_COLLAGE=false bash $0   # Deploy only AI inference platform"
echo ""
