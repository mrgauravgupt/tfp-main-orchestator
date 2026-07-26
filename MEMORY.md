# Workspace Memory for Future Agents

## Repository map

- `tfpphotographers/`: main Astro, Fastify, Prisma, PostgreSQL product monorepo.
- `tfp-moderation-service/`: FastAPI inference and folder-operations service.
- `tfp-collage-service/`: Node collage worker service.
- This root repository coordinates deployment scripts and records nested Git revisions.

## 2026 deployment-readiness baseline

- The validated architecture audit is in `VALIDATED_AUDIT_AND_IMPLEMENTATION_PLAN.md`; use it as a prioritized backlog, not as proof of live runtime state.
- The PostgreSQL-backed `event_outbox` is intentional. It uses `FOR UPDATE SKIP LOCKED`, retry state, terminal `FAILED`, and stale-processing recovery. Do not propose Redis/BullMQ merely because an outbox exists.
- Domain transitions must use the transaction-scoped enqueue helper. Do not reintroduce post-commit event emission for moderation transitions.
- TypeScript worker shutdown drains active jobs with a bounded timeout; Python moderation worker handles SIGTERM/SIGINT by stopping new polling and finishing the active batch.
- Moderation folder operations require the internal service key and a separate step-up password for every mutation. The API port remains private behind the VPS proxy.
- Deployment defaults to `tfpdeploy`; `root` is a deliberate break-glass override only.

## Remaining runtime evidence

These cannot be proven by static code alone and must be recorded per deployment:

- effective production database host and Redis configuration;
- reverse-proxy/edge reachability and allowed origins;
- shared rate-limit behavior across more than one API process;
- backup checksum plus successful restore to a disposable database;
- worker-drain behavior against an isolated UAT job.
