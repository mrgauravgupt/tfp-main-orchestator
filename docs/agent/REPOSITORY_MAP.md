# Repository Map

## Confirmed structure

- Root orchestrator: repository-level governance and cross-service scripts; see `AGENTS.md` and `RULES.md`.
- `tfpphotographers`: production monorepo with Astro web (`apps/web`), Fastify API (`apps/api`), Expo mobile (`apps/mobile`), shared packages (`packages/*`), tests, and QA; see `tfpphotographers/AGENTS.md`.
- `tfp-collage-service`: standalone image-processing service with a retained
  repository/unit compatibility name; its runtime package owns renditions,
  manifests, lifecycle jobs, and non-blocking collages. See its `AGENTS.md` and
  `README.md`.
- `tfp-ai-interface`: active private FastAPI image/text/translation inference
  API plus isolated PostgreSQL request worker. It owns inference execution, not
  product domain state. See its `AGENTS.md`, `README.md`, and the canonical
  moderation/outbox guide in `tfpphotographers/docs/architecture/`.
- `tfp-moderation-service`: retained historical checkout; not part of active
  deployment or runtime orchestration.

Each directory is an independent Git repository. Cross-repository work must validate and commit the nested repository before updating the root gitlink.
