# OCI UAT Deployment Runbook

## Current target

| Item | Current UAT value |
| --- | --- |
| Provider | Oracle Cloud Infrastructure Always Free |
| Instance | `tfp-a1-free-2ocpu-12gb` |
| Shape | `VM.Standard.A1.Flex` — `2 OCPU / 12 GB RAM`, ARM64 |
| Region / AD | `ap-mumbai-1` / `lqoG:AP-MUMBAI-1-AD-1` |
| Public / private IPv4 | `161.118.161.98` / `10.0.1.114` |
| OS / SSH | Ubuntu ARM64 / `ubuntu@161.118.161.98` |
| Tester URL | `https://uat.tfpphotographers.com` |
| Cloudflare tunnel | `tfp-oci-uat` -> `http://localhost:8080` |
| PostgreSQL | OCI-host-local `127.0.0.1:5432` |

Contabo `13.140.189.236` is retired. Do not use it for application deployment,
database tunnels, moderation, collage, seed operations, or folder processing.
The older OCI E2 micro `140.245.30.133` is also not the UAT target.

## Private topology

The OCI security list and host firewall expose no application port. Services
listen only on loopback:

| Component | Listener |
| --- | --- |
| PostgreSQL | `127.0.0.1:5432` |
| Main API | `127.0.0.1:4000` |
| Main web gateway | `127.0.0.1:8080` |
| Moderation proxy / app | `127.0.0.1:7001` / `127.0.0.1:7002` |
| Collage proxy / app | `127.0.0.1:7003` / `127.0.0.1:7004` |

Only key-based administrative SSH is retained. Testers reach the app through
Cloudflare Access and the outbound-only tunnel.

## Deployment entrypoints

From the orchestrator root, a deliberately fresh full-stack UAT deployment is:

```bash
bash scripts/oci/deploy-all-uat.sh
```

This bootstrap resets the disposable UAT database and runtime directories. It
must be used only when a fresh UAT is intended. It transfers minimal committed
runtime sources and explicitly excludes folder-moderation images and reports.

For an ordinary application-only release that preserves the active database and
services:

```bash
cd tfpphotographers
UAT_DEPLOY_HOST=161.118.161.98 \
UAT_DEPLOY_USER=ubuntu \
UAT_REQUIRE_CLOUDFLARED=true \
UAT_DELETE_JSON_REPORTS=false \
  bash scripts/vps/deploy-main-uat.sh
```

The `scripts/vps` directory name is historical and provider-neutral. Current
UAT defaults resolve to OCI; the compatibility `scripts/vps/deploy-all-uat.sh`
delegates to `scripts/oci/deploy-all-uat.sh`.

Deploy only moderation and collage without reconnecting any remote database:

```bash
OCI_DEPLOY_HOST=161.118.161.98 \
OCI_DEPLOY_USER=ubuntu \
  bash scripts/oci/deploy-both-services.sh
```

## Secrets and storage

Runtime values belong in ignored `.env.uat.local` files or a secret manager.
Never commit or print them. The OCI runtime uses:

- independent bucket-scoped Backblaze keys for private and public buckets;
- fresh host-local PostgreSQL;
- distinct moderation and collage internal API keys;
- no storage master/admin key inside an application process.

## Folder-moderation exclusion

Folder moderation is not part of OCI UAT. Normal deployment must keep
`/srv/tfp-folder-moderation` absent and must not transfer source image folders,
raw moderation reports, reviewer chunks, screenshots, or generated audit
artifacts. Legacy remote folder-moderation scripts are disabled by default.

## Cloudflare configuration

- Tunnel: `tfp-oci-uat`
- Route: `uat.tfpphotographers.com` -> `http://localhost:8080`
- Catch-all: `http_status:404`
- Access application: `TFP UAT`
- Policy: `Approved UAT testers`
- Session duration: 6 hours

Approved email addresses are maintained in Cloudflare Access, not in the
application deployment scripts.

## Verification

Host-side:

```bash
ssh ubuntu@161.118.161.98
systemctl is-active cloudflared postgresql@16-main \
  tfp-main-uat-api tfp-main-uat-web tfp-main-uat-worker \
  tfp-moderation-service tfp-moderation-service-moderation-worker@1 \
  tfp-collage-service
sudo ss -lntp | grep -E '127\.0\.0\.1:(4000|5432|7001|7002|7003|7004|8080)'
test ! -e /srv/tfp-folder-moderation
curl -fsS http://127.0.0.1:4000/health
```

External:

```bash
curl -I https://uat.tfpphotographers.com
```

An unauthenticated request must redirect to Cloudflare Access. Direct public
connections to `4000`, `5432`, `7001-7004`, and `8080` must fail.

For temporary laptop database administration, use an SSH local forward to the
OCI loopback listener and scope the database URL override to that command:

```bash
ssh -N -L 15432:127.0.0.1:5432 ubuntu@161.118.161.98
```

## Rollback

UAT releases are disposable. Redeploy a pushed application commit as a fresh
release, repeat listener and health checks, and leave Cloudflare Access/Tunnel
unchanged. Never point rollback tooling at the retired Contabo host.
