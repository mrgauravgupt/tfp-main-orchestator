# Repository Map

## Confirmed structure

- Root orchestrator: repository-level governance and cross-service scripts; see `AGENTS.md` and `RULES.md`.
- `tfpphotographers`: production monorepo with Astro web (`apps/web`), Fastify API (`apps/api`), Expo mobile (`apps/mobile`), shared packages (`packages/*`), tests, and QA; see `tfpphotographers/AGENTS.md`.
- `tfp-collage-service`: standalone collage generation service; see `tfp-collage-service/AGENTS.md` and `README.md`.
- `tfp-ai-inference-service`: active stateless FastAPI image/text/translation inference service; see its `AGENTS.md` and `README.md`.
- `tfp-moderation-service`: unchanged legacy V1 rollback service; do not deploy by default.

Each directory is an independent Git repository. Cross-repository work must validate and commit the nested repository before updating the root gitlink.
