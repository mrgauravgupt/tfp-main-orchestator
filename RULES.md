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

## Cross-layer dot-connecting and pre-flight guardrails

- **Multi-layer root cause triangulation**: Never accept symptoms or single-layer error messages at face value. Correlate across five architectural planes before proposing fixes: (1) DOM/view layout, (2) runtime AST and environment conditionals (`NODE_ENV`, `TFP_ENV_TARGET`), (3) transaction and lock boundaries (e.g., `pg_advisory_xact_lock`), (4) host resources and port listeners (`lsof`, disk space, process tables), and (5) edge/network headers.
- **Pre-flight syntax & conflict check**: Before running long builds or test suites, execute zero-cost syntax verifications: `bash -n` for shell scripts, `jq empty` for JSON files, and `git diff --check` for whitespace anomalies or unresolved merge conflict markers.
- **Timezone and form validation parity**: E2E test helpers must build timestamps in the same timezone context as the rendered component (e.g., `Asia/Kolkata` vs UTC) to prevent silent HTML5 `rangeUnderflow` or `rangeOverflow` validation failures that halt form submissions before network requests fire.
- **Schema reset role grant preservation**: Any script or operation that resets, pushes, or drops the PostgreSQL database schema must immediately re-grant required permissions to background worker roles (e.g., `tfp_ai_worker` on `event_outbox`). Never leave workers unpermissioned after a reset.
- **Interactive control click targets**: When custom styled inputs use decorative overlays (`<span>`), tests and interactive handlers must target the semantic `<label>` container while asserting the underlying checked state of the input.

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

## Generic Quality, Verification & Anti-False-Confidence Engineering Rules

1. **Single Source of Truth (SSOT) & Single Ownership Principle**:
   - In any architectural subsystem (use cases, route registries, feature inventories, design tokens, API route maps), exactly ONE canonical artifact owns the state.
   - Downstream consumers (compilers, linters, test harnesses, evidence collectors, report generators, release gates) must all consume that identical SSOT.
   - Introducing a ledger or registry that is read only by its own linter is an inert island ("shadow ledger") that creates false confidence. It is incomplete until all consumers, reports, and release verifiers are wired to it.
   - When secondary compatibility matrices exist, they must be derived or strictly non-overlapping. Never allow parallel registries to independently maintain statuses, actions, or capabilities.
   - In TFP E2E, `tests/e2e/human/use-case-coverage.json` is the sole canonical business use-case ledger; `coverage-matrix.json` is retained solely for feature inventory and compatibility projection.

2. **Bidirectional Semantic Traceability (The Anti-Cosmetic Rule)**:
   - Code comments, docstrings, annotations, or file presence are not proof of implementation.
   - Traceability must be strictly bidirectional: (1) every declared ledger item must map to an exact annotated test block, (2) every code annotation must resolve to a valid ledger entry, and (3) the test block must contain explicit, discriminating assertions verifying every visible action, postcondition, and negative boundary state claimed by the ledger.
   - Annotations must be placed directly inside or immediately adjacent to the executable test block (e.g. `// @use-case <id>`), not in loose file headers.

3. **Executable Reality Over Aspirational Declarations**:
   - Never declare compatibility, support, or capability for a platform, browser, operating system, or environment in any specification, contract, or ledger unless the current, active test harness can list, execute, and pass tests against that target.
   - Targets or features not yet executable must be classified as `planned`, `unsupported`, or `blocked`, never marked `implemented` to satisfy a checklist or pass a count check.
   - In TFP E2E, `browserProjects` must strictly reflect executable projects defined in `playwright.shared.ts` (`chromium`, `firefox`, `mobile-chromium`). WebKit must never be claimed until executable WebKit launcher support is implemented and verified.

4. **Granular Execution Isolation (Anti-Transitive Fallacy)**:
   - Status must always be evaluated at the leaf unit of execution (the specific test block, method, or scenario), never inferred transitively from an enclosing file, suite, class, or domain.
   - Partial, focused, or filtered executions (e.g. `test.only`, `--grep`) must leave unexecuted sibling items in the same file marked `not-run`. A passing subset run must never certify an aggregate suite or release gate.

5. **Adversarial Validation & Negative Contract Testing for Guards**:
   - Static guards, linters, and verification scripts must not merely check syntactic schema presence (`typeof x === 'string' && x.length > 0`). They must validate semantic truth against underlying ASTs, router declarations, file systems, and runtime configs.
   - Any validation guard must be accompanied by automated fixture-based mutation tests proving that invalid inputs, duplicate IDs, missing required arrays, nonexistent routes, and orphan annotations actively fail the guard for the exact intended failure reason.

6. **Cryptographic & Git-Anchored Evidence Integrity**:
   - Release certification gates must cryptographically bind runtime evidence to: (1) the exact Git commit hash of the tested application, and (2) the SHA-256 hashes of all input schemas, registries, and configuration.
   - If any input registry, code file, or configuration changes, previous evidence is immediately invalidated and cannot certify subsequent releases.

7. **Strict Multi-State Lifecycle Discipline**:
   - Every requirement, contract, and use case must follow an immutable lifecycle state machine:
     - `unclassified`: unreviewed (hard gate blocker; must fail CI)
     - `planned`: documented requirement, pending executable implementation
     - `implemented`: exact code/test exists, asserts full contract, passes static gates
     - `runtime-proven`: executed against live runtime with verified, hash-anchored evidence
     - `blocked`: valid requirement blocked by a specific external dependency (must identify concrete blocker)
     - `lower-level-only` / `not-applicable`: justified architectural decision backed by lower-level proof
   - Never inflate status to "implemented" or "complete" to make a metric or dashboard green.

8. **Zero Synthetic Shortcuts in End-to-End Verification**:
   - Strict E2E journeys must interact with the system strictly through real user surfaces (real DOM, real network requests, real storage, real timers).
   - Never bypass business logic, authentication, or validation using backdoor DB updates, route interception, forced clicks, DOM property mutations, or test-only product bypasses.
   - State persistence must be proven through visible reload or a subsequent real user journey, not assumed or mocked.
