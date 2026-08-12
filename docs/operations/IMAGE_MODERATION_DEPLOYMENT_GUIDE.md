# AI Inference Deployment Guide — OCI UAT

## Active service

- OCI: `tfp-a1-free-2ocpu-12gb` (`ubuntu@161.118.161.98`, ARM64)
- Repository: `tfp-ai-interface`
- Listener: `127.0.0.1:7011`
- Unit: `tfp-ai-interface.service`
- State: stateless; product jobs and results stay in the TFP PostgreSQL database

The service has no public route. The main API, app worker, and collage worker call it
over loopback with an internal key. Contabo is retired. The legacy
`tfp-moderation-service` repository is a rollback option and is not deployed by default.

## Capabilities

- OpenRouter/Qwen image moderation using a metadata-free 600px rendition and strict
  `{"explicit": 0|1}` schema;
- local rules plus ToxicBERT text moderation;
- local M2M100 translation;
- local Pillow edge-saliency visual focus for the collage contract.

## Validate locally

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-ai-interface
uv sync --extra local-ml
uv run ruff check .
uv run pytest -q
```

## Deploy

Use the service-only immutable release script when the database and app must remain:

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-ai-interface
bash scripts/deploy-uat.sh
```

Use `bash scripts/oci/deploy-all-uat.sh` from the orchestrator root only for an explicitly
authorized destructive UAT rebuild. It recreates the disposable UAT databases and runtime
directories before deploying inference, app, and collage.

## Required controls

- production settings validation and a 32+ character internal key;
- OpenRouter key, ZDR, data-collection denial, and no implicit model fallback;
- loopback binding, dedicated `tfpai` account, hardened systemd unit, and memory limit;
- bounded input size/pixels/concurrency/timeouts/retries;
- model downloads only during provisioning, then offline cache use;
- no folder-moderation images, workspaces, reports, or reviewer artifacts.

## Verify on OCI

```bash
ssh ubuntu@161.118.161.98
systemctl is-active tfp-ai-interface.service
sudo ss -lntp | grep -E '127\.0\.0\.1:7011'
test ! -e /srv/tfp-folder-moderation
```

Use the internal key without printing it to call authenticated `/health/ready` and focused
approved/rejected image, text, translation, and visual-focus probes. An external connection
to port `7011` must fail.

## Rollback

An explicit rollback may deploy V1, change `MODERATION_REMOTE_URL` and
`TRANSLATION_REMOTE_URL` to `http://127.0.0.1:7001`, then restart the app API and worker.
Do not enable V1's database worker while the app worker owns moderation jobs.
