# TFP Deployment and Agent Rules

This is the concise operational rulebook for humans and AI agents working across the orchestrator and its nested repositories.

## Source of truth

1. Current concrete code, actual runtime AST branches, and active configuration defaults.
2. Checked-in tests that verifiably exercise intended codepaths.
3. The relevant repository `AGENTS.md` and `MEMORY.md` for architectural invariants.
4. The app routing index at `tfpphotographers/docs/agent-index.json`.

**Documentation, `.md` files, docstrings, schema comments, and type definitions are pointers only.** Never assume runtime behavior or architectural enforcement from a comment, doc, or markdown file without verifying the actual executable code and active configuration. Historical audit documents explain context; they do not override current code.

## Mandatory safety rules

- Keep `main` releasable. Do not merge experimental work without targeted validation.
- Treat the orchestrator and each nested service repository as separate Git repositories. Commit and push each affected repository, then commit updated gitlinks in this root repository.
- Before finalizing any feature or committing code, all agents must complete the due diligence checklist outlined in `tfpphotographers/docs/operations/AGENT_DUE_DILIGENCE.md`.
- **Mandatory Live Visual Verification**: Always run the app (web FE/BE or mobile Metro/simulator) and validate impacted screens live via direct computer interaction or screenshots. Never conclude work or assume correctness from static checks alone.
- Never print or commit secrets, bearer tokens, presigned URLs, provider raw moderation payloads, or production connection strings.
- Never use destructive database reset, seed, delete, or production restore commands without an explicitly scoped request.
- Runtime proof is not implied by a passing static test. Record redacted evidence for production configuration, edge exposure, rate limiting, and restore drills.

## Anti-false-confidence and verification rigor

- **Tests must exercise the intended behavior**: Never write tests that pass trivially by bypassing the code under test (e.g., providing headers ignored by active configuration like `LOCATION_CLIENT_IP_HEADER_ORDER`). Verify that the tested path is genuinely reached and that altering expectations causes the test to fail.
- **Do not over-mock to simulate behavior**: When testing network, DNS, or HTTP boundaries, exercise real socket/streaming mechanics rather than shallow mocks that hide real-world failure modes.
- **Cross-service schema symmetry**: When adding fields (e.g. `correlationId`) to events or payloads produced by one service (e.g. `tfp-ai-interface`), ensure all downstream consumers (e.g. Fastify API workers and outbox processors) explicitly accept and validate those fields before deployment. Unsynchronized schema additions cause terminal job failures.
- **Privacy in validation and logging**:
  - Correlation and tracing IDs must be strictly bounded (e.g. alphanumeric regex `^[A-Za-z0-9._:-]{1,128}$`). Never log or persist arbitrary client strings.
  - Never log raw schema validation errors (e.g. Zod `error.message`) or write them into outbox `last_error` without redacting received values to prevent leaking PII or sensitive inputs.
- **Complete resource lifecycle**: Connection pool initializers must handle startup failures cleanly without leaving lingering half-open state. Shutdown and cleanup logic (`close()`, `aclose()`) must be protected by `try/finally` so that failure in one resource does not abort cleanup of others.
- **Precision in engineering claims**:
  - Distinguish structural patterns from empirical operational proofs. Having an index is not proof of query latency under millions of rows; rate-limiting cooldowns and exponential retries are not a 3-state circuit breaker; serial batch processing is not a complete guarantee against memory exhaustion from oversized inputs.
  - Do not claim a feature or fix is complete if caller call-sites remain unthreaded or end-to-end paths (e.g. browser-to-worker-to-translation) remain partial.
  - Run affected downstream consumer tests (such as notification event handlers) immediately when schemas or events change.

## UI/UX and visual audit discovery principles

- **Triangulate findings (visual observation + code/DOM verification)**: Use visual inspection to detect candidate anomalies, then inspect the DOM, component props, and active styles to understand the mechanism. This confirms whether an anomaly is a genuine layout defect, an edge-case collision, or an intended pattern behaving as designed.
- **Root-cause analysis with blast-radius mapping**: When an issue appears across multiple screens (e.g. blocked images across routes, or clipped list bottoms across tabs), trace the common parent or configuration. Report the root defect clearly as the primary finding while cataloging all affected routes/screens so developers see both the cause and its full surface impact.
- **Evaluate design patterns in context**: Assess whether responsive techniques (such as line-clamping, horizontal overflow chips, or dismissible consent banners) are functioning well: verify that clamped text preserves critical actions, that banners dismiss cleanly without blocking interactions, and that auth guards redirect as intended.
- **Lifecycle & settled state awareness**: When inspecting dynamic screens, observe both transient states (loading spinners, pull-to-refresh indicators) and settled states (network idle, data resolved) to accurately differentiate temporary loading animations from frozen or unresponsive UI.
- **Cross-reference text with catalogs & content fixtures**: When investigating suspected text truncation or missing copy, check the underlying translation catalog (`packages/i18n`) or database fixture, and check scroll position to distinguish content resting below the initial viewport fold from true text truncation.
- **Calibrate native navigation & safe-area insets**: For mobile scroll views and lists, verify that bottom padding dynamically accommodates safe-area insets and persistent navigation bars (~65–80px) to prevent action buttons and cards from being obscured.

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
