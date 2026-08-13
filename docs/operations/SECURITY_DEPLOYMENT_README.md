# TFP Security Deployment Runbook

This workspace deploys three cooperating services:

- `tfpphotographers`: Astro/Fastify main application.
- `tfp-ai-interface`: private inference API and isolated AI request worker.
- `tfp-collage-service`: collage API and optional collage worker.

## Required Production Secrets

Set these before UAT or production deploys:

```bash
export TFP_AI_INTERNAL_API_KEY="<shared-secret-used-by-main-app>"
export COLLAGE_SERVICE_API_KEY="<shared-secret-used-by-main-app>"
```

The main app sends the image moderation key with `MODERATION_REMOTE_AUTH_TOKEN`.
The AI interface reads the same secret from `TFP_AI_INTERNAL_API_KEY`, so these
values must match:

```bash
export MODERATION_REMOTE_AUTH_TOKEN="$TFP_AI_INTERNAL_API_KEY"
```

Each service deploy preflights its own secret-managed environment file before
remote synchronization. The full-stack deploy stops as soon as one service
fails that validation.

## Safe Deployment Defaults

- Image moderation requires the internal API key in UAT/prod.
- Image moderation OpenAPI is disabled in UAT/prod.
- Image moderation playground/folder-ops UI is disabled by default in UAT/prod.
- Collage service requires `COLLAGE_SERVICE_API_KEY` in UAT/prod.
- Collage service blocks `file:` URLs, `data:` URLs, redirects, localhost, private IPs, and oversized image responses in UAT/prod.
- Collage CORS is allow-list based when `COLLAGE_ALLOWED_ORIGINS` is configured.

Local development remains flexible through explicit local settings:

```bash
export IMAGE_PROCESSING_ENVIRONMENT=local
export COLLAGE_ALLOW_FILE_URLS=true
export COLLAGE_ALLOW_DATA_URLS=true
```

Do not use those local overrides in UAT or production.

## Deploy

From the workspace root:

```bash
bash scripts/oci/deploy-all-uat.sh
```

Current UAT target: OCI `tfp-a1-free-2ocpu-12gb` at `161.118.161.98`.
Contabo is retired. Use only the explicit OCI and service-owned deploy
entrypoints below.

For service-local deployment:

```bash
bash tfp-ai-interface/scripts/deploy-uat.sh
bash tfp-collage-service/scripts/deploy/deploy.sh uat
```

The main app and collage deploy wrappers load their service-owned environment
files. The AI interface deploy reads `tfp-ai-interface/.env.uat.local`. Keep
`TFP_AI_INTERNAL_API_KEY`, `MODERATION_REMOTE_AUTH_TOKEN`,
`COLLAGE_SERVICE_API_KEY`, database, and storage settings aligned in those
secret-managed files.

## Operator Checks

Use the checked-in menu:

```bash
cd tfpphotographers
bash ./scripts/manage-tfp.sh
```

The environment summary shows non-secret status for:

- active moderation provider
- moderation remote URL
- image moderation API key configured/missing
- collage service URL
- collage service API key configured/missing

Run the environment doctor after env changes:

```bash
bash ./scripts/pnpm-node20.sh qa:env:doctor
```

## Runtime Health Checks

```bash
curl -fsS "$MODERATION_REMOTE_URL/health/live"
curl -fsS "$COLLAGE_SERVICE_URL/health/live"
```

Authenticated service calls must include:

```bash
-H "x-internal-api-key: $TFP_AI_INTERNAL_API_KEY"
-H "x-api-key: $COLLAGE_SERVICE_API_KEY"
```

Never print or commit actual secret values in logs, docs, test fixtures, or screenshots.
