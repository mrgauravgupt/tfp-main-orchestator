# Architecture Boundaries

- Web code belongs in `tfpphotographers/apps/web`; API code in `apps/api`; native code in `apps/mobile`; shared contracts and infrastructure abstractions in `packages/*`. Source: `tfpphotographers/AGENTS.md`.
- Mobile consumes the existing `/api/v1` boundary through its adapter; do not create a second mobile backend. Source: `tfpphotographers/AGENTS.md`.
- Domain transitions that publish events write state and `event_outbox` in the same Prisma transaction. Source: `RULES.md`.
- PostgreSQL polling with `FOR UPDATE SKIP LOCKED` is intentional; a BullMQ/Redis migration requires measured operational need. Source: `AGENTS.md`.
- The isolated AI worker exclusively claims `process_moderation` and
  `process_translation`; the application worker exclusively applies both
  `apply_ai_*` result events. The image-processing worker independently leases
  `image_processing_jobs`. All three share canonical UAT PostgreSQL state but
  remain separate deployables. Source:
  `tfpphotographers/docs/architecture/EVENT_OUTBOX_AND_DEPLOYMENT_READINESS.md`.
- `tfp-moderation-service` is a retained historical checkout, not an active
  runtime or architectural source of truth. Source: `README.md` and
  `docs/agent/REPOSITORY_MAP.md`.

When evidence conflicts, current code and targeted tests outrank historical documentation.
