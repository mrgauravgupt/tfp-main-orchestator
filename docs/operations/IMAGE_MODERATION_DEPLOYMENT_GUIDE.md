# Image Moderation Deployment Guide — OCI UAT

## Target

- OCI instance: `tfp-a1-free-2ocpu-12gb`
- SSH: `ubuntu@161.118.161.98`
- Shape: `VM.Standard.A1.Flex`, `2 OCPU / 12 GB RAM`, ARM64
- Repository: `tfp-moderation-service`
- Nginx/app listeners: `127.0.0.1:7001` / `127.0.0.1:7002`
- API service: `tfp-moderation-service.service`
- Worker: `tfp-moderation-service-moderation-worker@1.service`
- Shared database: OCI-local PostgreSQL at `127.0.0.1:5432`

The moderation endpoint has no public URL. The main application calls the
loopback proxy from the same OCI host. Contabo `13.140.189.236` is retired.

## Validate locally

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-moderation-service
uv run ruff check .
uv run pytest -q
```

## Deploy

For a service-only release that preserves the existing database and app:

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-moderation-service
AIP_DEPLOY_HOST=161.118.161.98 \
AIP_DEPLOY_USER=ubuntu \
  bash scripts/vps/deploy-prod-7001.sh uat
```

The `scripts/vps` name is historical and provider-neutral. For the `uat`
profile its current default host is OCI.

## Required security controls

- `AIP__SECURITY__REQUIRE_INTERNAL_API_KEY=true`
- a non-placeholder internal API key of at least 32 characters
- loopback-only Nginx and Uvicorn listeners
- one moderation worker on this 2-OCPU host unless load evidence supports more
- bucket-scoped private storage credentials only
- no folder-moderation workspace or reports

## Verify on OCI

```bash
ssh ubuntu@161.118.161.98
systemctl is-active tfp-moderation-service.service \
  tfp-moderation-service-moderation-worker@1.service
curl -fsS http://127.0.0.1:7001/health/live
sudo ss -lntp | grep -E '127\.0\.0\.1:700(1|2)'
test ! -e /srv/tfp-folder-moderation
```

Do not test the moderation service through the public OCI IP. A failure to
connect externally is the expected private-origin result.

## Cache and report boundary

Service response/model caches may persist when required by runtime performance.
Folder images, raw reports, reviewer pages, and policy-audit artifacts are not
part of the OCI UAT deployment and must not be synced.
