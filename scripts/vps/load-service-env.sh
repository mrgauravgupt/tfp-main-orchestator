#!/usr/bin/env bash

canonical_service_env() {
  case "${1:-}" in
    local|test|qa)
      printf 'local'
      ;;
    development|dev)
      printf 'development'
      ;;
    uat)
      printf 'uat'
      ;;
    prod|production)
      printf 'production'
      ;;
    *)
      return 1
      ;;
  esac
}

source_env_file_if_present() {
  local env_file="$1"
  [[ -f "$env_file" ]] || return 0

  local line key value
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
    [[ "$line" == export\ * ]] && line="${line#export }"
    [[ "$line" == *=* ]] || continue

    key="${line%%=*}"
    value="${line#*=}"
    key="${key%"${key##*[![:space:]]}"}"
    [[ "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]] || continue

    if [[ "${#value}" -ge 2 ]]; then
      if [[ "${value:0:1}" == '"' && "${value: -1}" == '"' ]]; then
        value="${value:1:${#value}-2}"
      elif [[ "${value:0:1}" == "'" && "${value: -1}" == "'" ]]; then
        value="${value:1:${#value}-2}"
      fi
    fi
    # Deploy files are parsed as literal dotenv files, not shell programs.
    # Ignore unresolved shell expressions so the checked-in script defaults
    # apply instead of forwarding strings such as ${NAME:-default}.
    [[ "$value" == *'${'* ]] && continue
    export "$key=$value"
  done < "$env_file"
}

load_service_deploy_env() {
  local root_dir="$1"
  local deploy_env="$2"
  local env_file_suffix="$deploy_env"
  if [[ "$deploy_env" == "production" ]]; then
    env_file_suffix="production"
  fi

  local tfp_env_file="${TFP_ENV_FILE:-$root_dir/tfpphotographers/.env.${env_file_suffix}.local}"
  if [[ "${LOAD_TFP_ENV_FILE:-true}" == "true" ]]; then
    source_env_file_if_present "$tfp_env_file"
  fi

  # Root-level deploy override files let service deploys run without manual
  # exports while keeping real secrets out of git.
  source_env_file_if_present "$root_dir/.env.deploy.local"
  source_env_file_if_present "$root_dir/.env.deploy.${env_file_suffix}.local"

  export DEPLOY_HOST="${DEPLOY_HOST:-${VPS_DEPLOY_HOST:-13.140.189.236}}"
  export DEPLOY_USER="${DEPLOY_USER:-${VPS_DEPLOY_USER:-root}}"
  export DEPLOY_PORT="${DEPLOY_PORT:-22}"

  export AIP_INTERNAL_API_KEY="${AIP_INTERNAL_API_KEY:-${MODERATION_REMOTE_AUTH_TOKEN:-${AIP__SECURITY__INTERNAL_API_KEY:-}}}"
  export MODERATION_REMOTE_AUTH_TOKEN="${MODERATION_REMOTE_AUTH_TOKEN:-${AIP_INTERNAL_API_KEY:-}}"
  export TRANSLATION_REMOTE_AUTH_TOKEN="${TRANSLATION_REMOTE_AUTH_TOKEN:-${AIP_INTERNAL_API_KEY:-}}"

  export TFP_DATABASE_URL="${TFP_DATABASE_URL:-${DATABASE_URL:-}}"
  export AIP_MODERATION_DATABASE_URL="${AIP_MODERATION_DATABASE_URL:-${TFP_DATABASE_URL:-${DATABASE_URL:-}}}"

  export B2_ENDPOINT="${B2_ENDPOINT:-${BACKBLAZE_ENDPOINT:-${STORAGE_S3_ENDPOINT:-}}}"
  export B2_ACCESS_KEY_ID="${B2_ACCESS_KEY_ID:-${BACKBLAZE_KEY_ID:-${STORAGE_S3_ACCESS_KEY_ID:-}}}"
  export B2_SECRET_ACCESS_KEY="${B2_SECRET_ACCESS_KEY:-${BACKBLAZE_APP_KEY:-${STORAGE_S3_SECRET_ACCESS_KEY:-}}}"
  export B2_BUCKET_NAME="${B2_BUCKET_NAME:-${BACKBLAZE_BUCKET_NAME:-${STORAGE_S3_BUCKET_NAME:-}}}"
  export B2_REGION="${B2_REGION:-${BACKBLAZE_REGION:-${STORAGE_S3_REGION:-us-east-005}}}"

  export AIP_MODERATION_S3_ENDPOINT="${AIP_MODERATION_S3_ENDPOINT:-${B2_ENDPOINT:-}}"
  export AIP_MODERATION_S3_ACCESS_KEY_ID="${AIP_MODERATION_S3_ACCESS_KEY_ID:-${B2_ACCESS_KEY_ID:-}}"
  export AIP_MODERATION_S3_SECRET_ACCESS_KEY="${AIP_MODERATION_S3_SECRET_ACCESS_KEY:-${B2_SECRET_ACCESS_KEY:-}}"
  export AIP_MODERATION_S3_BUCKET_NAME="${AIP_MODERATION_S3_BUCKET_NAME:-${B2_BUCKET_NAME:-}}"
  export AIP_MODERATION_S3_REGION="${AIP_MODERATION_S3_REGION:-${B2_REGION:-us-east-005}}"
}
