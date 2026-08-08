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
