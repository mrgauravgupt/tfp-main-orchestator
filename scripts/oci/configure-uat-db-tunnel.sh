#!/usr/bin/env bash
set -euo pipefail

OCI_HOST="${OCI_DEPLOY_HOST:-161.118.161.98}"
OCI_USER="${OCI_DEPLOY_USER:-ubuntu}"
DB_HOST="${CONTABO_DB_HOST:-13.140.189.236}"
DB_USER="${CONTABO_DB_USER:-root}"
KEY_PATH="/home/$OCI_USER/.ssh/tfp-uat-db-tunnel"

ssh -o StrictHostKeyChecking=accept-new "$OCI_USER@$OCI_HOST" \
  "test -f '$KEY_PATH' || ssh-keygen -q -t ed25519 -N '' -f '$KEY_PATH'; cat '$KEY_PATH.pub'" |
  ssh -o StrictHostKeyChecking=accept-new "$DB_USER@$DB_HOST" \
    'umask 077; mkdir -p ~/.ssh; key=$(cat); blob=$(printf "%s" "$key" | awk "{print \$2}"); grep -qF "$blob" ~/.ssh/authorized_keys || printf "restrict,port-forwarding,permitopen=\"127.0.0.1:5432\" %s\n" "$key" >> ~/.ssh/authorized_keys'

ssh -o StrictHostKeyChecking=accept-new "$OCI_USER@$OCI_HOST" \
  DB_HOST="$DB_HOST" DB_USER="$DB_USER" KEY_PATH="$KEY_PATH" 'bash -s' <<'EOF'
set -euo pipefail
sudo apt-get update -y
sudo apt-get install -y autossh
sudo tee /etc/systemd/system/tfp-uat-db-tunnel.service >/dev/null <<UNIT
[Unit]
Description=TFP UAT PostgreSQL tunnel to Contabo
After=network-online.target
Wants=network-online.target

[Service]
User=$USER
Environment=AUTOSSH_GATETIME=0
ExecStart=/usr/bin/autossh -M 0 -N -o BatchMode=yes -o ServerAliveInterval=30 -o ServerAliveCountMax=3 -o ExitOnForwardFailure=yes -o StrictHostKeyChecking=accept-new -i $KEY_PATH -L 127.0.0.1:5432:127.0.0.1:5432 $DB_USER@$DB_HOST
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
UNIT
sudo systemctl daemon-reload
sudo systemctl enable --now tfp-uat-db-tunnel
for _ in $(seq 1 30); do
  if timeout 2 bash -c '</dev/tcp/127.0.0.1/5432' 2>/dev/null; then
    exit 0
  fi
  sleep 1
done
sudo systemctl --no-pager --full status tfp-uat-db-tunnel
exit 1
EOF
