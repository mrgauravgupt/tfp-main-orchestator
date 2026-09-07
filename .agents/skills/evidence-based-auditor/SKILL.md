---
name: evidence-based-auditor
description: >-
  Automatically performs evidence-based read-only audits and reviews when the
  user says check, review, inspect, audit, find issues, identify gaps, make sure,
  check every file, check the whole repository, or prepare a findings report.
  Applies to i18n, hardcoded content, design tokens, typography, accessibility,
  architecture, code quality, security, consistency, duplication, conventions,
  tests, configuration, and repository-wide compliance.
---

# Evidence-Based Auditor

Use `read-only-audit` workflow principles. Automated output is candidate discovery, never proof.

Define issue, exception, severity, confidence, and evidence criteria; inventory scope and exclusions; then validate every reported candidate in code context. A confirmed finding must identify repository, file or symbol, observation, relevant convention, evidence, impact, related surfaces, false-positive analysis, remediation, and post-fix validation.

Do not edit source, inflate findings, dump raw regex matches, or claim exhaustive coverage without reconciliation.

---

## Known Failure Modes (learned from production audit correction)

These specific errors caused 8 of 22 findings to be invalid. Check for each before publishing.

### 1. Pattern match ≠ violation
A grep for `prisma.` in a module is not evidence of a boundary violation. Read the **surrounding context**: is it in a read/query path (allowed), a command/service (tracked debt), or a persistence adapter (allowed)? Check if an enforcement script already tracks and gates this debt.

### 2. Existing infrastructure overlooked
Before reporting "no DLQ", "no operator tooling", "no rate limiting" — search for it. Admin route files, operator scripts, and utility packages often already implement what the audit claims is missing. Read the admin route files, not just the core domain files.

### 3. Pattern described as anti-pattern without reading the intent
`Pick<PrismaClient, '$executeRaw'>` is a structural seam enabling transaction injection, not "zero abstraction". Read the type and its consumers before calling it a pseudo-pattern. Check if tests inject doubles before claiming "untestable".

### 4. Incorrect severity escalation
A missing locale catalog in email templates is **high** — it affects user experience and is real work. Calling it "safety-critical" inflates priority and erodes trust in the report. Apply: Critical = data loss/security. High = user-facing correctness. Medium = code quality. Low = style.

### 5. Claiming "complete" before the full artifact exists
If a feature requires both code AND a migration/config/test to be meaningful, do not mark it ✅ until all parts are committed and verifiable. An index declaration without a migration is not an index. A utility with zero consumers and zero tests is not "implemented".

### 6. Confusing fixed-N concurrent queries with N+1
N+1 is: one query per row of a parent result set, growing with data. A fixed number of concurrent aggregate queries run once per request is not N+1, even if it could be optimized. Require `EXPLAIN ANALYZE` evidence before reporting either as a performance finding.

### 7. Architectural prescriptions without design evidence
Do not recommend "Unit of Work framework", "universal EntityResolver", "DLQ table", or "transaction-aware EventBus" without first reading whether a simpler existing primitive already handles the case. Prisma `$transaction` is a Unit of Work. `FAILED` rows are a logical DLQ. Prescribing new infrastructure for solved problems wastes implementation effort and introduces risk.

### 8. Severity arithmetic must be self-consistent
If the body lists 7 critical findings, the summary table must say 7 — not 5. Recount before publishing. Inconsistent numbers signal the report was not reviewed before delivery.

### 9. Localized inspection without AST/branch tracing (The "First Match" Trap)
Never infer runtime behavior from where a helper function is defined or where a hook early-returns. Trace the actual router definitions and environment conditionals. For example, if an HTML test page helper exists in a service, check the route handler: does it branch on `NODE_ENV` or `environment === 'production'` to return `{ status: 'ok' }` instead? Check `readConfig()`: does startup throw if secrets are missing in production/UAT?

### 10. Theoretical code pattern vs. exploitable threat model (Severity Inflation)
A code-level smell (e.g. TOCTOU DNS rebinding, missing rate limiter) is not an automatic "P0 Critical Vulnerability" unless an attacker-accessible entrypoint actually exists in the runtime threat model. Before assigning P0 or P1, trace the data flow:
- Does the vulnerable code path run on user-submitted input, or only on private, approved storage buffers?
- Is the endpoint public or bound strictly to loopback behind a 32+ character internal API key?
If it is on an authenticated internal loopback route and bypassed by background workers, classify it as defense-in-depth / code hardening (P2), not an active P0 exploit.

### 11. Hallucinated synthetic calculations vs. verified code reality
Never fabricate memory calculations or concurrency models out of thin air:
- Do not assume a model runs in FP32; check the model loader/converter (e.g. checking for CTranslate2 `int8`, ONNX, or `torch.float16`).
- Do not assume 50 parallel jobs run concurrently unless the worker actually spawns 50 concurrent tasks. Check the polling loop: does it process serially (`claimJobs(1)`)?
- Always measure or verify against code constraints before asserting that memory will trigger OOM kills.

### 12. Theoretical interface risk vs. actual caller guarantees
If a database helper accepts a generic SQL client interface that *could* be invoked outside a transaction, check the callers before claiming an active concurrency bug or lock leak. If all callers wrap the helper in `prisma.$transaction(...)` or `client.query('BEGIN')`, the row lock is held until transaction commit under PostgreSQL's MVCC model. Frame an atomic CTE as an architectural refinement, not a live data-loss defect.

### 13. Broken or regressive code remediation snippets
Never emit drop-in diffs that omit domain rules, drop existing security checks, or introduce circular/broken imports:
- If suggesting a SQL CTE, preserve existing domain exclusions (e.g. worker event filters) and stale-job recovery intervals (`INTERVAL '5 minutes'`).
- If suggesting a fetch replacement, preserve redirect rejection, byte streaming caps, and content-type validations.
- Verify module exports before writing `import { foo } from './bar.js'`.

### 14. Framework stereotyping & imagined endpoints
Do not assume standard cloud conventions (e.g. `/health/live` and `/health/ready`) without reading the route registrations. Check `plugins/health.ts` or `routes.ts` directly. The application may use `/health` and `/ready`.

### 15. Arbitrary maturity scoring
Do not emit arbitrary quantitative scores (e.g. "7.8/10 enterprise maturity") unless explicitly evaluating against a formal, mathematically weighted rubric with empirical test and measurement evidence. Unmeasured scores erode technical credibility.

