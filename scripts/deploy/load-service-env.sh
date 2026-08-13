#!/usr/bin/env bash

canonical_service_env() {
  case "${1:-}" in
    local|development|uat|production)
      printf '%s' "$1"
      ;;
    *)
      return 1
      ;;
  esac
}

rewrite_service_postgres_host() {
  local raw_url="${1:-}"
  local host_override="${2:-}"
  local port_override="${3:-5432}"
  [[ -n "$raw_url" && -n "$host_override" ]] || {
    printf '%s' "$raw_url"
    return 0
  }

  python3 - "$raw_url" "$host_override" "$port_override" <<'PY'
import sys
from urllib.parse import quote, unquote, urlsplit, urlunsplit

raw, host, port = sys.argv[1:4]
parsed = urlsplit(raw)
if not parsed.scheme or not parsed.path:
    raise SystemExit("Invalid PostgreSQL URL supplied to deploy host override")

username = unquote(parsed.username or "")
password = unquote(parsed.password or "")
auth = ""
if username:
    auth = quote(username, safe="")
    if password:
        auth += ":" + quote(password, safe="")
    auth += "@"

print(urlunsplit((parsed.scheme, f"{auth}{host}:{port}", parsed.path, parsed.query, parsed.fragment)))
PY
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
    [[ "$value" == *'${'* ]] && continue
    export "$key=$value"
  done < "$env_file"
}

load_service_deploy_env() {
  local root_dir="$1"
  local deploy_env="$2"
  local tfp_env_file="${TFP_ENV_FILE:-$root_dir/tfpphotographers/.env.${deploy_env}.local}"

  source_env_file_if_present "$tfp_env_file"
  source_env_file_if_present "$root_dir/.env.deploy.local"
  source_env_file_if_present "$root_dir/.env.deploy.${deploy_env}.local"

  if [[ -n "${DEPLOY_DATABASE_HOST_OVERRIDE:-}" ]]; then
    local database_port_override="${DEPLOY_DATABASE_PORT_OVERRIDE:-5432}"
    DATABASE_URL="$(rewrite_service_postgres_host "${DATABASE_URL:-}" "$DEPLOY_DATABASE_HOST_OVERRIDE" "$database_port_override")"
    DATABASE_DIRECT_URL="$(rewrite_service_postgres_host "${DATABASE_DIRECT_URL:-${DATABASE_URL:-}}" "$DEPLOY_DATABASE_HOST_OVERRIDE" "$database_port_override")"
    export DATABASE_URL DATABASE_DIRECT_URL
  fi

  if [[ "$deploy_env" == "uat" ]]; then
    export DEPLOY_HOST="${DEPLOY_HOST:-${OCI_UAT_HOST:-161.118.161.98}}"
    export DEPLOY_USER="${DEPLOY_USER:-${OCI_UAT_USER:-ubuntu}}"
  else
    export DEPLOY_HOST="${DEPLOY_HOST:-}"
    export DEPLOY_USER="${DEPLOY_USER:-tfpdeploy}"
  fi
  export DEPLOY_PORT="${DEPLOY_PORT:-22}"

  export TFP_DATABASE_URL="${TFP_DATABASE_URL:-${DATABASE_URL:-}}"
  export B2_REGION="${B2_REGION:-us-east-005}"
  export B2_PRIVATE_ACCESS_KEY_ID="${B2_PRIVATE_ACCESS_KEY_ID:-}"
  export B2_PRIVATE_SECRET_ACCESS_KEY="${B2_PRIVATE_SECRET_ACCESS_KEY:-}"
  export B2_PRIVATE_BUCKET_NAME="${B2_PRIVATE_BUCKET_NAME:-}"
  export B2_PUBLIC_ACCESS_KEY_ID="${B2_PUBLIC_ACCESS_KEY_ID:-}"
  export B2_PUBLIC_SECRET_ACCESS_KEY="${B2_PUBLIC_SECRET_ACCESS_KEY:-}"
  export B2_PUBLIC_BUCKET_NAME="${B2_PUBLIC_BUCKET_NAME:-}"
  export MEDIA_PUBLIC_BASE_URL="${MEDIA_PUBLIC_BASE_URL:-}"
  export IMAGE_PROCESSING_SERVICE_API_KEY="${IMAGE_PROCESSING_SERVICE_API_KEY:-}"
}
