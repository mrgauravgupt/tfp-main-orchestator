#!/usr/bin/env bash
set -euo pipefail

DEPLOY_HOST="${OCI_UAT_HOST:-161.118.161.98}"
DEPLOY_USER="${OCI_UAT_USER:-ubuntu}"
DEPLOY_PORT="${OCI_UAT_PORT:-22}"
PUBLIC_URL="${OCI_UAT_PUBLIC_URL:-https://uat.tfpphotographers.com}"
SSH_OPTS=(-p "$DEPLOY_PORT" -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=accept-new)

echo "Verifying OCI UAT service graph on $DEPLOY_USER@$DEPLOY_HOST"

ssh "${SSH_OPTS[@]}" "$DEPLOY_USER@$DEPLOY_HOST" 'bash -s' <<'EOF'
set -euo pipefail

units=(
  postgresql.service
  tfp-main-uat-api.service
  tfp-main-uat-worker.service
  tfp-main-uat-web.service
  tfp-ai-interface.service
  tfp-ai-interface-worker.service
  tfp-collage-service.service
  cloudflared.service
)

for unit in "${units[@]}"; do
  if ! systemctl is-active --quiet "$unit"; then
    echo "Required UAT unit is not active: $unit" >&2
    systemctl --no-pager --full status "$unit" >&2 || true
    exit 1
  fi
done

for endpoint in \
  http://127.0.0.1:4000/health \
  http://127.0.0.1:4000/ready \
  http://127.0.0.1:8080/health \
  http://127.0.0.1:7011/health/live \
  http://127.0.0.1:7004/health/live \
  http://127.0.0.1:7003/health/live; do
  curl --fail --silent --show-error --max-time 15 "$endpoint" >/dev/null
done

sudo -u postgres pg_isready --host 127.0.0.1 --port 5432 --quiet

required_listeners=(4000 5432 7003 7004 7011 8080)
listeners="$(ss -ltnH)"
for port in "${required_listeners[@]}"; do
  if ! grep -Eq "127\\.0\\.0\\.1:${port}[[:space:]]" <<<"$listeners"; then
    echo "Required loopback listener is missing: 127.0.0.1:$port" >&2
    exit 1
  fi
  if grep -Eq "(^|[[:space:]])(0\\.0\\.0\\.0|\\[::\\]):${port}[[:space:]]" <<<"$listeners"; then
    echo "Private UAT port is exposed beyond loopback: $port" >&2
    exit 1
  fi
done

if [[ -e /srv/tfp-folder-moderation ]]; then
  echo "Retired folder-moderation path must remain absent from OCI UAT" >&2
  exit 1
fi

printf 'active_units=%s\n' "${#units[@]}"
printf 'reachable_loopback_endpoints=6\n'
printf 'database=ready\n'
printf 'private_listeners=loopback-only\n'
EOF

public_status="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --max-time 20 "$PUBLIC_URL")"
case "$public_status" in
  200|302|303|307|308) ;;
  *)
    echo "Public UAT route is not reachable through Cloudflare: HTTP $public_status" >&2
    exit 1
    ;;
esac

echo "public_route=$PUBLIC_URL status=$public_status"
echo "OCI UAT dependency verification passed."
