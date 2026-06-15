# TFP Security Deployment Runbook

This workspace deploys three cooperating services:

- `tfpphotographers`: Astro/Fastify main application.
- `tfp-image-moderation-service`: internal AI moderation API and optional moderation worker.
- `tfp-collage-service`: collage API and optional collage worker.

## Required Production Secrets

Set these before UAT or production deploys:

```bash
export AIP_INTERNAL_API_KEY="<shared-secret-used-by-main-app>"
export COLLAGE_SERVICE_API_KEY="<shared-secret-used-by-main-app>"
```

The main app sends the image moderation key with `MODERATION_REMOTE_AUTH_TOKEN`. The deploy wrappers map that value to `AIP_INTERNAL_API_KEY` if `AIP_INTERNAL_API_KEY` is not set, so these should normally match:

```bash
export MODERATION_REMOTE_AUTH_TOKEN="$AIP_INTERNAL_API_KEY"
```

The combined deploy script now fails before remote sync if either required key is missing for UAT or production.

## Safe Deployment Defaults

- Image moderation requires the internal API key in UAT/prod.
- Image moderation OpenAPI is disabled in UAT/prod.
- Image moderation playground/folder-ops UI is disabled by default in UAT/prod.
- Collage service requires `COLLAGE_SERVICE_API_KEY` in UAT/prod.
- Collage service blocks `file:` URLs, `data:` URLs, redirects, localhost, private IPs, and oversized image responses in UAT/prod.
- Collage CORS is allow-list based when `COLLAGE_ALLOWED_ORIGINS` is configured.

Local development remains flexible through explicit local settings:

```bash
export COLLAGE_ENVIRONMENT=local
export COLLAGE_ALLOW_FILE_URLS=true
export COLLAGE_ALLOW_DATA_URLS=true
export AIP_EXPOSE_PLAYGROUND_UI=true
```

Do not use those local overrides in UAT or production.

## Deploy

From the workspace root:

```bash
bash scripts/oci/deploy-both-services.sh
```

For service-local deployment:

```bash
bash tfp-image-moderation-service/scripts/oci/deploy-interactive.sh
bash tfp-collage-service/scripts/oci/deploy-interactive.sh
```

The deploy wrappers load the matching `tfpphotographers/.env.<env>.local` file when present. Keep `AIP_INTERNAL_API_KEY`, `COLLAGE_SERVICE_API_KEY`, app URLs, B2 settings, and DB settings aligned there or export them in the shell before deploy.

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
-H "x-internal-api-key: $AIP_INTERNAL_API_KEY"
-H "x-api-key: $COLLAGE_SERVICE_API_KEY"
```

Never print or commit actual secret values in logs, docs, test fixtures, or screenshots.
