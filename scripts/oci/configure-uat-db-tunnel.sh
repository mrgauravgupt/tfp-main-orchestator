#!/usr/bin/env bash
set -euo pipefail

OCI_HOST="${OCI_DEPLOY_HOST:-161.118.161.98}"
OCI_USER="${OCI_DEPLOY_USER:-ubuntu}"

cat >&2 <<'NOTICE'
The Contabo-backed UAT database tunnel is retired.
OCI UAT uses fresh PostgreSQL on 127.0.0.1:5432 of the OCI host.
This compatibility command removes the obsolete tunnel unit and verifies the
OCI-local database; it never connects to Contabo.
NOTICE

ssh -o StrictHostKeyChecking=accept-new "$OCI_USER@$OCI_HOST" 'bash -s' <<'EOF'
set -euo pipefail
sudo systemctl disable --now tfp-uat-db-tunnel.service >/dev/null 2>&1 || true
sudo rm -f /etc/systemd/system/tfp-uat-db-tunnel.service
rm -f "$HOME/.ssh/tfp-uat-db-tunnel" "$HOME/.ssh/tfp-uat-db-tunnel.pub"
sudo systemctl daemon-reload
sudo systemctl is-active postgresql
sudo ss -ltn | grep -E '127\.0\.0\.1:5432'
EOF
