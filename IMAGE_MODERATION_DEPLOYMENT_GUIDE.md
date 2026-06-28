# Image Moderation Deployment Guide

This guide documents the current Contabo UAT deployment flow for `tfp-image-moderation-service`.

## Target

- Service repo: `tfp-image-moderation-service`
- UAT host: `13.140.189.236`
- SSH user: `root`
- Public service URL: `http://13.140.189.236:7001`
- Private app port: `7002`
- Systemd service: `tfp-image-moderation-service`
- Deploy wrapper: `tfp-image-moderation-service/scripts/vps/deploy-prod-7001.sh`

## 1. Review Local State

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator
git status --short --branch
git -C tfp-image-moderation-service status --short --branch
```

If both the nested service and root gitlink changed, commit the nested service first, then commit the root gitlink.

## 2. Validate Policy And Tests

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-image-moderation-service
uv run python - <<'PY'
from pathlib import Path
from tfp_image_moderation_service.moderation_policy import RawEnvelopePolicyEvaluator

path = Path("src/tfp_image_moderation_service/policies/policy_ai_inference_raw_envelope.yml")
policy = RawEnvelopePolicyEvaluator.from_file(path)
print(f"loaded policy: {policy.policy_id} v{policy.version}")
PY

uv run pytest -q tests/unit tests/integration/test_api.py
```

For a quick policy-only deploy, at minimum run the policy load check.

## 3. Commit And Push The Service

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-image-moderation-service
git fetch origin
git status --short --branch
git add config/base.yaml src/tfp_image_moderation_service/policies/policy_ai_inference_raw_envelope.yml tests/unit/test_updated_policy.py
git commit -m "fix(moderation): tune CLIP sexual act policy"
git push origin main
```

Adjust the staged files and commit message to match the actual change.

## 4. Commit And Push The Root Gitlink

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator
git fetch origin
git status --short --branch
git add tfp-image-moderation-service IMAGE_MODERATION_DEPLOYMENT_GUIDE.md
git commit -m "docs(moderation): document deployment flow"
git push origin main
```

## 5. Deploy To Contabo UAT

Use the service-local deploy wrapper. It loads root deploy env when available and targets the current Contabo UAT service host by default.

```bash
cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-image-moderation-service
bash scripts/vps/deploy-prod-7001.sh uat
```

If the deploy needs an explicit internal API key, either export it before running the deploy or place it in the root ignored deploy env files loaded by `scripts/vps/load-service-env.sh`.

```bash
export AIP_INTERNAL_API_KEY="<internal-api-key>"
bash scripts/vps/deploy-prod-7001.sh uat
```

## 6. Verify Health

```bash
curl -fsS http://13.140.189.236:7001/health/live

cd /Users/hexa/Desktop/tfp-main-orchestator/tfp-image-moderation-service
bash scripts/vps/diagnose-prod.sh --since "30 minutes ago" --lines 300
```

## 7. Clear Image Response Cache

Preferred API path:

```bash
curl -fsS -X DELETE \
  -H "Authorization: Bearer ${AIP_INTERNAL_API_KEY}" \
  http://13.140.189.236:7001/api/v1/cache/image-responses
```

Host-level fallback:

```bash
ssh root@13.140.189.236 \
  'rm -rf /srv/tfp-image-moderation-service/current/.runtime/*/cache/image-responses/* && systemctl restart tfp-image-moderation-service'
```

Use the API path when the internal API key is available. Use the host-level fallback when the local shell does not have the token.

## 8. Retest Images

After cache clear, rerun the same images through `/api/v1/analyze-image` or the folder moderation launcher so the new CLIP prompts and policy rules are evaluated from fresh inference output.

Expected new CLIP fields live under:

```text
clip.explicit_semantics.pack_scores.human_sexual_act_context
clip.explicit_semantics.pack_scores.human_oral_sex_context
clip.explicit_semantics.pack_scores.human_manual_stimulation_context
clip.explicit_semantics.pack_scores.human_obscured_sexual_act_context
clip.explicit_semantics.pack_scores.human_group_sex_context
clip.explicit_semantics.pack_scores.human_nude_kissing_context
clip.explicit_semantics.pack_scores.human_genital_context
clip.explicit_semantics.pack_scores.human_erotic_context
```
