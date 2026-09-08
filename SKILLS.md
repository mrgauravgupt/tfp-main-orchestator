# Tooling and validation entrypoints

Use the capabilities actually available in your current agent session. A checked-in tool list cannot prove an MCP server, browser, model or cloud account is connected.

## Repository-owned workflows

- Task rules: [AGENTS.md](AGENTS.md), [RULES.md](RULES.md), and the nested repository instructions.
- Reusable task workflows: [.agents/skills](.agents/skills/) and [.agents/workflows](.agents/workflows/).
- Domain navigation: [product agent index](tfpphotographers/docs/agent-index.json).
- Application explanation: [How TFP works](tfpphotographers/docs/architecture/SYSTEM_GUIDE.md).
- Required validation: [due diligence](tfpphotographers/docs/operations/AGENT_DUE_DILIGENCE.md).

## Commands and runtime ownership

Run product commands from `tfpphotographers`. `.nvmrc` owns Node selection; use `scripts/pnpm-node20.sh` and `scripts/run-node20.sh` despite their historical names. Inspect `package.json` and the invoked scripts before execution.

| Task | Executable entrypoint |
| --- | --- |
| Product lifecycle/menu | `scripts/manage-tfp.sh`, `scripts/start-app.sh` |
| Native lifecycle/menu | `scripts/manage-tfp-mobile.sh` |
| Architecture gate | `scripts/architecture/enforce-boundaries.mjs` |
| Token consistency | `scripts/design-tokens/sync.mjs --check` |
| Environment resolution/validation | `scripts/env/resolve-env.mjs`, `scripts/env/doctor.mjs` |
| Browser coverage guard | `scripts/qa/human-e2e-guard.mjs` |
| Native coverage guard | `apps/mobile/tests/e2e/scripts/guard.mjs` |
| Root cross-service contract | `contracts/ai-outbox.schema.json`, `scripts/contracts/*` |
| Root UAT orchestration | `scripts/oci/deploy-all-uat.sh`, `scripts/oci/verify-uat-stack.sh` |

The last two rows are relative to the orchestrator. Others are product-relative. Coverage guards inspect registrations; they do not run user journeys. Architecture enforcement currently has scope gaps documented in the current audit.

## Authentication and safety

TFP uses passwordless email verification. Lower-environment automation has a protected seed-login bridge; do not publish its secret or invent password credentials. Follow the [runtime and seed guide](tfpphotographers/docs/operations/AGENT_RUNTIME_AND_SEED_GUIDE.md).

A read-only review does not authorize a restart, seed/reset, deployment or external mutation. Documentation edits can be reviewed and validated without restarting application services. Actual UI changes require the repository's fresh-start and live-inspection procedure.

Folder moderation and the historical moderation checkout are excluded from active UAT. The active AI source is `tfp-ai-interface`; confirm service routes in executable registrations rather than assuming `/health/live` or a legacy port.
