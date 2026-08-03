# TFP Deployment and Agent Rules

This is the concise operational rulebook for humans and AI agents working across the orchestrator and its nested repositories.

## Source of truth

1. Current code and checked-in tests.
2. The relevant repository `AGENTS.md` and `MEMORY.md`.
3. The app routing index at `tfpphotographers/docs/agent-index.json`.
4. Active operations runbooks under `tfpphotographers/docs/operations/`.

Historical audit documents explain context; they do not override current code.

## Mandatory safety rules

- Keep `main` releasable. Do not merge experimental work without targeted validation.
- Treat the orchestrator and each nested service repository as separate Git repositories. Commit and push each affected repository, then commit updated gitlinks in this root repository.
- Before finalizing any feature or committing code, all agents must complete the due diligence checklist outlined in `tfpphotographers/docs/operations/AGENT_DUE_DILIGENCE.md`.
- Never print or commit secrets, bearer tokens, presigned URLs, provider raw moderation payloads, or production connection strings.
- Never use destructive database reset, seed, delete, or production restore commands without an explicitly scoped request.
- Runtime proof is not implied by a passing static test. Record redacted evidence for production configuration, edge exposure, rate limiting, and restore drills.

## Event outbox rules

- A state transition that promises a domain event must write the state and its `event_outbox` row with the same Prisma transaction client.
- Never call `eventBus.emit()` after a committed transition when that transition can instead enqueue inside its transaction.
- Do not dual-enqueue during a migration. One transition produces one outbox row.
- Consumers must remain idempotent. The outbox guarantees durable handoff, not exactly-once external delivery.
- `FAILED` is the terminal dead-letter state. Add query/replay tooling before adding a second queue table.

## Deployment rules

- Production services bind privately and are exposed only through the intended reverse proxy.
- Deploy with the unprivileged `tfpdeploy` account. Root is explicit break-glass/bootstrap only.
- Internet-facing UAT and production hosts must deny unauthorized **outbound**
  SSH traffic to public TCP port `22` by default. If a workload genuinely needs
  outbound SSH, prefer HTTPS over port `443` or add a narrow, reviewed
  destination allowlist. Do not confuse this egress control with administrative
  **inbound** SSH, which must be key-only, restricted to trusted operator
  sources or a private access path, and use an unprivileged account with direct
  root login disabled.
- UAT is non-production, not a lower-security exception. Before reconnecting a
  suspended or potentially compromised host, preserve evidence, apply the
  outbound SSH deny at the provider or host firewall, rotate credentials, and
  rebuild from a trusted image when compromise cannot be excluded.
- Every folder-operations mutation needs the internal API key plus the destructive-action password; keep the surface private at the edge.
- Worker shutdown must stop polling, drain active work within the configured grace period, then rely on database leases for crash recovery.
- A production release requires a redacted strict configuration check and a disposable restore drill; neither may be inferred from repository state.
