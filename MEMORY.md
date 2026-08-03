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

## 2026-08 Contabo UAT incident boundary

- Contabo VPS `13.140.189.236` hosts private UAT only; the TFP product is not
  live or publicly launched from this VPS. UAT status does not reduce the host
  hardening requirement.
- A provider complaint alleged outbound `SSH_BRUTE_FORCE` traffic from the VPS.
  The complaint identifies the source IP but does not prove the responsible
  process, account, or person; root cause requires preserved VPS and provider
  network evidence.
- Before any reactivation or migration, deny new outbound connections to public
  TCP port `22` by default at the provider or host firewall. Use HTTPS over
  `443`, or a narrow destination allowlist, for any legitimate outbound
  deployment dependency.
- Outbound TCP/22 containment is distinct from inbound administration. Inbound
  SSH must be key-only, limited to trusted operator sources or private access,
  use an unprivileged deployment account, and disable direct root login after
  break-glass recovery.
- Preserve the disk and logs before remediation; inspect `sshd`/auth journals,
  processes, containers, cron and systemd persistence, accounts, authorized
  keys, and outbound network evidence. Rotate credentials and secrets and
  rebuild from a trusted image whenever compromise cannot be excluded.

## Design System & Architecture Auditing Rules

- **Context-Aware Boundaries**: Do not blindly enforce a Single Source of Truth (SSOT) from the database (`schema.prisma`) to the frontend if a shared contract is intentionally used instead. For instance, moderation reasons and shared boundary validations (e.g., normalizers) correctly live in shared TypeScript contracts, not Prisma schemas or Zod.
- **Validating Layout Hardcodes**: Before flagging hardcoded CSS in base files (`base.scss`), verify if they are legitimate local component rules or base normalization rules, rather than true design token bypasses.
- **UI vs. Backend Constraints**: UI previews and data upload limits can intentionally differ (e.g., mood board slicing in UI versus max upload limit in backend). Do not automatically mark them as SSOT violations.
- **Transactional Emails**: The `packages/email` transactional templates are a major visual surface. When auditing design tokens, check if backend email literals (colors, typography) are bypassing `design-tokens.json`.
- **Token Generation Sync**: The token sync script (`scripts/design-tokens/sync.mjs`) is intentionally lossy or currently incomplete (e.g., misses `cardGeometry` and some colors). Consider this before flagging components for "bypassing" tokens they don't actually have access to.
- **Mobile vs. Web QA Gates**: Remember that `qa:design-tokens` for web tests different patterns than `mobile-design-token-audit.mjs`. The mobile audit currently misses layout drift (padding, margins, radii, letter-spacing), meaning mobile code could have hardcoded layouts without failing the build.
