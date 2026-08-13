#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_HOST="${OCI_UAT_HOST:-161.118.161.98}"
DEPLOY_USER="${OCI_UAT_USER:-ubuntu}"
DEPLOY_PORT="${OCI_UAT_PORT:-22}"
SSH_OPTS=(-p "$DEPLOY_PORT" -o StrictHostKeyChecking=accept-new)
APP_ENV="$ROOT_DIR/tfpphotographers/.env.uat"
APP_ENV_LOCAL="$ROOT_DIR/tfpphotographers/.env.uat.local"

for required_file in "$APP_ENV" "$APP_ENV_LOCAL"; do
  if [[ ! -f "$required_file" ]]; then
    echo "Required UAT environment file is missing: $required_file" >&2
    exit 1
  fi
done

remote_temp="$(ssh "${SSH_OPTS[@]}" "$DEPLOY_USER@$DEPLOY_HOST" 'mktemp -d /tmp/tfp-oci-bootstrap.XXXXXX')"
cleanup() {
  ssh "${SSH_OPTS[@]}" "$DEPLOY_USER@$DEPLOY_HOST" "sudo rm -rf -- '$remote_temp'" >/dev/null 2>&1 || true
}
trap cleanup EXIT

scp -P "$DEPLOY_PORT" -o StrictHostKeyChecking=accept-new \
  "$APP_ENV" "$APP_ENV_LOCAL" "$DEPLOY_USER@$DEPLOY_HOST:$remote_temp/" >/dev/null

ssh "${SSH_OPTS[@]}" "$DEPLOY_USER@$DEPLOY_HOST" REMOTE_TEMP="$remote_temp" 'bash -s' <<'EOF'
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive

sudo apt-get update -y
sudo apt-get install -y --no-install-recommends \
  postgresql postgresql-contrib curl git rsync build-essential pkg-config \
  nginx iptables-persistent netfilter-persistent python3

for unit in \
  tfp-uat-db-tunnel.service \
  tfp-main-uat-api.service \
  tfp-main-uat-worker.service \
  tfp-main-uat-web.service \
  tfp-image-moderation-service.service \
  tfp-image-moderation-service-moderation-worker@1.service \
  tfp-moderation-service.service \
  tfp-moderation-service-moderation-worker@1.service \
  tfp-ai-inference-service.service \
  tfp-ai-inference-worker.service \
  tfp-ai-interface.service \
  tfp-ai-interface-worker.service \
  tfp-collage-service.service; do
  sudo systemctl disable --now "$unit" >/dev/null 2>&1 || true
done

sudo rm -f \
  /etc/systemd/system/tfp-uat-db-tunnel.service \
  /etc/systemd/system/tfp-main-uat-api.service \
  /etc/systemd/system/tfp-main-uat-worker.service \
  /etc/systemd/system/tfp-main-uat-web.service \
  /etc/systemd/system/tfp-image-moderation-service.service \
  /etc/systemd/system/tfp-image-moderation-service-moderation-worker@.service \
  /etc/systemd/system/tfp-moderation-service.service \
  /etc/systemd/system/tfp-moderation-service-moderation-worker@.service \
  /etc/systemd/system/tfp-ai-inference-service.service \
  /etc/systemd/system/tfp-ai-inference-worker.service \
  /etc/systemd/system/tfp-ai-interface.service \
  /etc/systemd/system/tfp-ai-interface-worker.service \
  /etc/systemd/system/tfp-collage-service.service
sudo systemctl daemon-reload
for retired_unit in \
  tfp-image-moderation-service.service \
  tfp-image-moderation-service-moderation-worker@1.service \
  tfp-moderation-service.service \
  tfp-moderation-service-moderation-worker@1.service \
  tfp-ai-inference-service.service \
  tfp-ai-inference-worker.service \
  tfp-moderation-service-v2.service; do
  sudo systemctl reset-failed "$retired_unit" >/dev/null 2>&1 || true
done

sudo rm -rf -- \
  /srv/tfp-main-uat \
  /srv/tfp-image-moderation-service \
  /srv/tfp-moderation-service \
  /srv/tfp-ai-inference-service \
  /srv/tfp-ai-interface \
  /srv/tfp-collage-service \
  /srv/tfp-folder-moderation
rm -f "$HOME/.ssh/tfp-uat-db-tunnel" "$HOME/.ssh/tfp-uat-db-tunnel.pub"

if ! getent group tfpapp >/dev/null; then
  sudo groupadd --system tfpapp
fi
if ! id tfpapp >/dev/null 2>&1; then
  sudo useradd --system --gid tfpapp --home-dir /srv/tfp-main-uat --shell /usr/sbin/nologin tfpapp
fi
if id tfpai >/dev/null 2>&1; then
  sudo usermod --home /srv/tfp-ai-interface tfpai
fi

sudo systemctl enable --now postgresql
sudo python3 - "$REMOTE_TEMP/.env.uat" "$REMOTE_TEMP/.env.uat.local" <<'PY'
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit

values = {}
for env_path in sys.argv[1:]:
    with open(env_path, encoding="utf-8") as handle:
        for raw_line in handle:
            line = raw_line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, value = line.split("=", 1)
            value = value.strip()
            if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
                value = value[1:-1]
            values[key.strip()] = value

database_url = values.get("DATABASE_URL", "")
shadow_url = values.get("SHADOW_DATABASE_URL", "")
if not database_url or not shadow_url:
    raise SystemExit("DATABASE_URL and SHADOW_DATABASE_URL must both be configured")

main = urlsplit(database_url)
shadow = urlsplit(shadow_url)
role = unquote(main.username or "")
password = unquote(main.password or "")
main_db = unquote(main.path.lstrip("/"))
shadow_db = unquote(shadow.path.lstrip("/"))

identifier = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
for label, value in (("database role", role), ("database", main_db), ("shadow database", shadow_db)):
    if not identifier.fullmatch(value):
        raise SystemExit(f"Unsafe {label} identifier in UAT configuration")
if main_db in {"postgres", "template0", "template1"} or shadow_db in {"postgres", "template0", "template1"}:
    raise SystemExit("Refusing to replace a PostgreSQL system database")
if not password:
    raise SystemExit("The UAT database role requires a password")

def ident(value: str) -> str:
    return '"' + value.replace('"', '""') + '"'

def literal(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"

role_ident = ident(role)
sql = f"""
DO $bootstrap$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = {literal(role)}) THEN
    CREATE ROLE {role_ident} LOGIN PASSWORD {literal(password)};
  ELSE
    ALTER ROLE {role_ident} LOGIN PASSWORD {literal(password)};
  END IF;
END
$bootstrap$;
DROP DATABASE IF EXISTS {ident(main_db)} WITH (FORCE);
DROP DATABASE IF EXISTS {ident(shadow_db)} WITH (FORCE);
CREATE DATABASE {ident(main_db)} OWNER {role_ident};
CREATE DATABASE {ident(shadow_db)} OWNER {role_ident};
"""
subprocess.run(
    ["runuser", "-u", "postgres", "--", "psql", "-v", "ON_ERROR_STOP=1"],
    input=sql,
    text=True,
    check=True,
)
PY

sudo -u postgres psql -v ON_ERROR_STOP=1 -c "ALTER SYSTEM SET listen_addresses = '127.0.0.1';" >/dev/null
sudo systemctl restart postgresql

sudo rm -f \
  /etc/nginx/sites-enabled/default \
  /etc/nginx/sites-enabled/tfp-image-moderation-service \
  /etc/nginx/sites-enabled/tfp-moderation-service \
  /etc/nginx/sites-enabled/tfp-collage-service \
  /etc/nginx/sites-available/tfp-image-moderation-service \
  /etc/nginx/sites-available/tfp-moderation-service \
  /etc/nginx/sites-available/tfp-collage-service

if ! sudo iptables -C OUTPUT -p tcp --dport 22 -m conntrack --ctstate NEW -j REJECT 2>/dev/null; then
  sudo iptables -I OUTPUT 1 -p tcp --dport 22 -m conntrack --ctstate NEW -j REJECT
fi
if ! sudo iptables -C INPUT ! -i lo -p tcp -m multiport --dports 80,4000,5432,7003,7004,7011,8080 -j DROP 2>/dev/null; then
  sudo iptables -I INPUT 1 ! -i lo -p tcp -m multiport --dports 80,4000,5432,7003,7004,7011,8080 -j DROP
fi
sudo netfilter-persistent save >/dev/null

sudo systemctl is-active postgresql
ss -ltn | grep -E '127\.0\.0\.1:5432'
if [[ -e /srv/tfp-folder-moderation ]]; then
  echo "Folder moderation hierarchy unexpectedly exists after bootstrap" >&2
  exit 1
fi
EOF

echo "Fresh OCI UAT host bootstrap complete: $DEPLOY_USER@$DEPLOY_HOST"
