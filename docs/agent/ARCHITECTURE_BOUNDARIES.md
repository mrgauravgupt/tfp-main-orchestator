# Architecture Boundaries

- Web code belongs in `tfpphotographers/apps/web`; API code in `apps/api`; native code in `apps/mobile`; shared contracts and infrastructure abstractions in `packages/*`. Source: `tfpphotographers/AGENTS.md`.
- Mobile consumes the existing `/api/v1` boundary through its adapter; do not create a second mobile backend. Source: `tfpphotographers/AGENTS.md`.
- Domain transitions that publish events write state and `event_outbox` in the same Prisma transaction. Source: `RULES.md`.
- PostgreSQL polling with `FOR UPDATE SKIP LOCKED` is intentional; a BullMQ/Redis migration requires measured operational need. Source: `AGENTS.md`.
- Collage and moderation services share UAT PostgreSQL state with the TFP app and must remain separate repositories/services. Source: service `AGENTS.md` files.

When evidence conflicts, current code and targeted tests outrank historical documentation.
