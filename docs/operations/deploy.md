# TFP UAT Redeployment Runbook

## Current UAT Host

| Item | Value |
| --- | --- |
| Provider | Contabo VPS |
| Public IPv4 | `13.140.189.236` |
| SSH user | `root` |
| SSH key installed | local `~/.ssh/id_ed25519.pub` copied into `/root/.ssh/authorized_keys` |
| Moderation public port | `7001` |
| Moderation private app port | `7002` |
| Collage public port | `7003` |
| Collage private app port | `7004` |
| PostgreSQL | host-local `127.0.0.1:5432` on the VPS |

Public traffic reaches nginx first. Nginx forwards `:7001` to the moderation API on `127.0.0.1:7002` and `:7003` to the collage API on `127.0.0.1:7004`.

## SSH Access

The deployed root key is the existing local key:

```bash
ls -la ~/.ssh
cat ~/.ssh/id_ed25519.pub
ssh root@13.140.189.236
```

On the VPS, the key must be present with strict permissions:

```bash
mkdir -p /root/.ssh
chmod 700 /root/.ssh
nano /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
```

In nano, save with `Ctrl+O`, press `Enter`, then exit with `Ctrl+X`.

To set or rotate the root password from the VPS console or an existing SSH session:

```bash
passwd root
```

## Runtime Secrets And Env

Do not commit secrets. UAT runtime values live in ignored local env files, primarily:

```bash
tfpphotographers/.env.uat.local
```

The UAT env must point at the Contabo host:

```bash
VPS_DEPLOY_HOST=13.140.189.236
VPS_DEPLOY_USER=root
DEPLOY_HOST=13.140.189.236
DEPLOY_USER=root
MODERATION_REMOTE_URL=http://13.140.189.236:7001
TRANSLATION_REMOTE_URL=http://13.140.189.236:7001
COLLAGE_SERVICE_URL=http://13.140.189.236:7003
AIP_EXPOSE_PLAYGROUND_UI=true
```

Keep these secret values aligned across the main app, moderation service, and collage service:

- `AIP_INTERNAL_API_KEY`
- `MODERATION_REMOTE_AUTH_TOKEN`
- `COLLAGE_SERVICE_API_KEY`
- `DATABASE_URL`
- `DIRECT_URL`
- `SHADOW_DATABASE_URL`
- B2/S3 bucket credentials

## Service Deployment

Use the generic VPS wrapper from the orchestrator root:

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator
bash scripts/vps/deploy-both-services.sh
```

Target one service when needed:

```bash
DEPLOY_AI=false bash scripts/vps/deploy-both-services.sh
DEPLOY_COLLAGE=false bash scripts/vps/deploy-both-services.sh
```

The operator path is `scripts/vps`.

## Database

UAT PostgreSQL is installed on the Contabo VPS and listens locally on the host:

- database: `tfp_photographers_uat`
- shadow database: `tfp_photographers_uat_shadow`
- app role: `tfp_user`

For local migration work, use the checked-in app migration wrapper and the UAT env file. If laptop access needs a tunnel:

```bash
ssh -L 15433:127.0.0.1:5432 root@13.140.189.236
```

Then point the local command at `127.0.0.1:15433` for the duration of that session.

## Folder Moderation Overnight Job

The folder moderation host scripts now use generic VPS naming and default to the Contabo host. The image folder is synced from:

```bash
tfpphotographers/scripts/qa/test-folder-moderation/Images
```

to:

```bash
/srv/tfp-folder-moderation/images
```

Install or refresh the overnight cron:

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers
bash scripts/vps/install-folder-moderation-cron.sh
```

Run the same flow immediately:

```bash
bash scripts/vps/run-folder-moderation.sh
```

Download the latest JSON and rewrite paths for local report viewing:

```bash
bash scripts/vps/download-folder-moderation-json.sh
```

The remote cron currently runs at `23:00` in the VPS timezone and writes reports under:

```bash
/srv/tfp-folder-moderation/reports
```

## Health Checks

```bash
curl -fsS http://13.140.189.236:7001/health/live
curl -fsS http://13.140.189.236:7001/health/ready
curl -fsS http://13.140.189.236:7003/health/live
curl -fsS http://13.140.189.236:7001/tfp-collage-service/health/live
```

Host-side checks:

```bash
ssh root@13.140.189.236
systemctl status tfp-image-moderation-service --no-pager
systemctl status tfp-collage-service --no-pager
journalctl -u tfp-image-moderation-service -n 100 --no-pager
journalctl -u tfp-collage-service -n 100 --no-pager
nginx -t
```

## AI Interface

The AI service UI is enabled for UAT with:

```bash
AIP_EXPOSE_PLAYGROUND_UI=true
```

Open:

```text
http://13.140.189.236:7001/
```

## Deploying `tfpphotographers` With Limited Users

Yes, the main `tfpphotographers` app can be deployed for limited users.

Recommended UAT gate:

- Put Cloudflare Access, nginx basic auth, or an IP allowlist in front of the web app.
- Disable or restrict public registration at the app level.
- Seed or invite only the users who should test.

Do not rely on an unlisted URL as the only access control.
