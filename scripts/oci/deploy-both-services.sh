#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_ENV="${DEPLOY_ENV:-uat}"

ENV_FILE_SUFFIX="$DEPLOY_ENV"
if [[ "$DEPLOY_ENV" == "prod" ]]; then
  ENV_FILE_SUFFIX="production"
fi

TFP_ENV_FILE="${TFP_ENV_FILE:-$ROOT_DIR/tfpphotographers/.env.${ENV_FILE_SUFFIX}.local}"
if [[ "${LOAD_TFP_ENV_FILE:-true}" == "true" && -f "$TFP_ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$TFP_ENV_FILE"
  set +a
fi

# OCI deployment configuration
export DEPLOY_HOST="${DEPLOY_HOST:-80.225.208.169}"
export DEPLOY_USER="${DEPLOY_USER:-ubuntu}"
export DEPLOY_PORT="${DEPLOY_PORT:-22}"

# TFP Image Moderation Service configuration
export AIP_DEPLOY_HOST="${AIP_DEPLOY_HOST:-$DEPLOY_HOST}"
export AIP_DEPLOY_USER="${AIP_DEPLOY_USER:-$DEPLOY_USER}"
export AIP_DEPLOY_PORT="${AIP_DEPLOY_PORT:-$DEPLOY_PORT}"
export AIP_DEPLOY_PATH="${AIP_DEPLOY_PATH:-/srv/tfp-image-moderation-service/current}"
export AIP_SERVICE_NAME="${AIP_SERVICE_NAME:-tfp-image-moderation-service}"
export AIP_NGINX_PORT="${AIP_NGINX_PORT:-7001}"
export AIP_APP_PORT="${AIP_APP_PORT:-7002}"
export AIP_EXPOSE_PLAYGROUND_UI="${AIP_EXPOSE_PLAYGROUND_UI:-true}"
export AIP_RUNTIME_ENV="${AIP_RUNTIME_ENV:-${AIP_ENV:-$DEPLOY_ENV}}"
export AIP_ENABLE_MODERATION_WORKER="${AIP_ENABLE_MODERATION_WORKER:-true}"

# TFP Collage Service configuration
export COLLAGE_DEPLOY_HOST="${COLLAGE_DEPLOY_HOST:-$DEPLOY_HOST}"
export COLLAGE_DEPLOY_USER="${COLLAGE_DEPLOY_USER:-$DEPLOY_USER}"
export COLLAGE_DEPLOY_PORT="${COLLAGE_DEPLOY_PORT:-$DEPLOY_PORT}"
export COLLAGE_DEPLOY_PATH="${COLLAGE_DEPLOY_PATH:-/srv/tfp-collage-service/current}"
export COLLAGE_SERVICE_NAME="${COLLAGE_SERVICE_NAME:-tfp-collage-service}"
export COLLAGE_NGINX_PORT="${COLLAGE_NGINX_PORT:-7003}"
export COLLAGE_APP_PORT="${COLLAGE_APP_PORT:-7004}"

# Control flags
DEPLOY_AI="${DEPLOY_AI:-true}"
DEPLOY_COLLAGE="${DEPLOY_COLLAGE:-true}"
APPLY_TFP_MIGRATIONS="${APPLY_TFP_MIGRATIONS:-true}"

apply_tfp_migrations() {
  local migration_name="20260611000100_external_image_moderation_jobs"
  local migration_file="$ROOT_DIR/tfpphotographers/packages/database/prisma/migrations/$migration_name/migration.sql"
  local remote_file="/tmp/$migration_name.sql"
  local database_name="${TFP_UAT_DATABASE_NAME:-tfp_photographers_uat}"
  local app_database_user="${TFP_UAT_DATABASE_USER:-tfp_user}"
  local checksum
  local migration_id

  if [[ ! -f "$migration_file" ]]; then
    echo "Missing migration file: $migration_file" >&2
    return 1
  fi

  checksum="$(shasum -a 256 "$migration_file" | awk '{print $1}')"
  migration_id="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  scp -P "$DEPLOY_PORT" -o StrictHostKeyChecking=accept-new "$migration_file" "$DEPLOY_USER@$DEPLOY_HOST:$remote_file" >/dev/null
  ssh -p "$DEPLOY_PORT" -o StrictHostKeyChecking=accept-new "$DEPLOY_USER@$DEPLOY_HOST" \
    MIGRATION_ID="$migration_id" MIGRATION_NAME="$migration_name" CHECKSUM="$checksum" REMOTE_FILE="$remote_file" DATABASE_NAME="$database_name" APP_DATABASE_USER="$app_database_user" 'bash -s' <<'EOF'
set -euo pipefail
if ! sudo -u postgres psql -d "$DATABASE_NAME" -Atc "SELECT 1 FROM _prisma_migrations WHERE migration_name = '$MIGRATION_NAME' LIMIT 1;" | grep -q 1; then
  sudo -u postgres psql -d "$DATABASE_NAME" -v ON_ERROR_STOP=1 -f "$REMOTE_FILE"
  sudo -u postgres psql -d "$DATABASE_NAME" -v ON_ERROR_STOP=1 -c "
    INSERT INTO _prisma_migrations (
      id,
      checksum,
      finished_at,
      migration_name,
      logs,
      rolled_back_at,
      started_at,
      applied_steps_count
    )
    VALUES (
      '$MIGRATION_ID',
      '$CHECKSUM',
      NOW(),
      '$MIGRATION_NAME',
      NULL,
      NULL,
      NOW(),
      1
    );
  "
fi
sudo -u postgres psql -d "$DATABASE_NAME" -v ON_ERROR_STOP=1 -c "
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE moderation_jobs TO $APP_DATABASE_USER;
  GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE moderation_results TO $APP_DATABASE_USER;
"
sudo rm -f "$REMOTE_FILE"
EOF
}

echo "═══════════════════════════════════════════════════════════════════════════════"
echo "  OCI Deployment: TFP Image Moderation Service + TFP Collage Service"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Deployment Configuration:"
echo "  Host:              $DEPLOY_HOST"
echo "  User:              $DEPLOY_USER"
echo "  Port:              $DEPLOY_PORT"
echo "  Apply migrations:  $APPLY_TFP_MIGRATIONS"
echo ""
echo "TFP Image Moderation Service:"
echo "  Deploy:            $DEPLOY_AI"
echo "  Path:              $AIP_DEPLOY_PATH"
echo "  Service:           $AIP_SERVICE_NAME"
echo "  Nginx Port:        $AIP_NGINX_PORT (public)"
echo "  App Port:          $AIP_APP_PORT (private)"
echo "  Moderation Worker: $AIP_ENABLE_MODERATION_WORKER"
echo ""
echo "TFP Collage Service:"
echo "  Deploy:            $DEPLOY_COLLAGE"
echo "  Path:              $COLLAGE_DEPLOY_PATH"
echo "  Service:           $COLLAGE_SERVICE_NAME"
echo "  Nginx Port:        $COLLAGE_NGINX_PORT (public)"
echo "  App Port:          $COLLAGE_APP_PORT (private)"
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

if [[ "$APPLY_TFP_MIGRATIONS" == "true" ]]; then
  echo "📦 Applying required TFP UAT database migrations..."
  apply_tfp_migrations
  echo "✅ TFP UAT database migrations ready"
  echo ""
fi

# Deploy TFP Collage Service first.
if [[ "$DEPLOY_COLLAGE" == "true" ]]; then
  echo "📦 Deploying TFP Collage Service..."
  bash "$ROOT_DIR/tfp-collage-service/scripts/oci/deploy-prod-7003.sh" "$DEPLOY_ENV"
  echo "✅ TFP Collage Service deployment complete"
  echo ""
fi

# Deploy TFP Image Moderation Service and DB-driven workers.
if [[ "$DEPLOY_AI" == "true" ]]; then
  echo "📦 Deploying TFP Image Moderation Service..."
  bash "$ROOT_DIR/tfp-image-moderation-service/scripts/oci/deploy-prod-7001.sh" "$DEPLOY_ENV"
  echo "✅ TFP Image Moderation Service deployment complete"
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
echo "  DEPLOY_AI=false bash $0        # Deploy only tfp-collage-service"
echo "  DEPLOY_COLLAGE=false bash $0   # Deploy only AI inference platform"
echo ""
