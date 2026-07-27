# Evidence-First Engineering

Apply this rule to every non-trivial audit, investigation, debugging task, code review, implementation, QA task, or deployment task.

## Mandatory phase gates

1. Classify the request as explanation, read-only audit, diagnosis, implementation, QA, or deployment.
2. Read applicable `AGENTS.md`, `RULES.md`, `MEMORY.md`, routing indexes, architecture documents, and runbooks.
3. Inspect repository state, repository boundaries, branches, and unrelated dirty work.
4. Identify the relevant source of truth, conventions, runtime paths, tests, and generated or excluded areas.
5. Map the affected boundaries before searching broadly: UI, shared packages, API, database, workers, mobile, tests, and deployment as applicable.
6. Read representative implementation files before designing searches or fixes.
7. State scope, diagnosis or hypotheses, affected files, non-goals, risks, and validation strategy before implementation.
8. Use search, regex, AST scans, scripts, and linters only for candidate discovery or deterministic checks. Raw matches are never confirmed findings.
9. Open and validate each reported candidate in context against code, conventions, tests, and runtime behaviour where relevant.
10. Implement only when authorized, and make the smallest architecture-native change.
11. Stop and reassess if evidence contradicts the diagnosis, the affected surface expands, public contracts change, generated code dominates, or validation cannot prove the claimed result.
12. Do not report completion until validation results, coverage, unresolved items, and external blockers are recorded.

## Decision log for complex work

Record approaches considered, evidence for each, rejected alternatives, assumptions made, assumptions verified, and assumptions still unresolved.

## Mandatory impact analysis before implementation

For every non-trivial fix, feature, refactor, migration, redesign, or configuration change, complete an impact analysis before editing source. A suspicious file, regex result, error message, failing test, old audit, prior plan, similar implementation, or plausible solution is not sufficient.

Establish current and intended behaviour, confirmed requirement or root cause, source of truth, direct and indirect files, callers and consumers, shared abstractions, contracts, tests, runtime/operational impact, compatibility, and rollback or recovery where relevant.

Create a concise affected-surface map. Consciously classify every applicable category as **directly affected**, **indirectly affected**, **potentially affected**, **reviewed and unaffected**, **requires runtime verification**, **requires external verification**, or **not applicable**:

- repositories, applications, services, shared packages, generated clients, and gitlinks;
- imports, callers, consumers, adapters, providers, factories, registrations, event handlers, scheduled jobs, and workers;
- APIs, DTOs, schemas, validation, database models/migrations, enums, events, queues, cache/search documents, file formats, and provider contracts;
- web/mobile pages, forms, states, accessibility, i18n, responsive behaviour, notifications, and emails;
- configuration, flags, secrets usage, logging, metrics, tracing, rate limits, retries, timeouts, idempotency, concurrency, transactions, deployment, rollback, monitoring, and alerts;
- unit, integration, contract, browser, mobile, build, type, lint, runtime, and manual verification.

Trace definitions, imports/references, direct callers, practical indirect consumers, registrations, tests, shared types, generated outputs, external dependencies, and compatibility requirements. Search is not sufficient for dynamic imports, DI/config registrations, event subscriptions, route conventions, runtime strings, generated code, or database-driven behaviour; state uncertainty and select a runtime or integration check when needed.

For cross-layer behaviour, trace the relevant end-to-end path rather than only the symptomatic layer. Before coding, record why each affected area matters, evidence inspected, expected change, compatibility risk, validation, and final classification.

The pre-implementation plan must include the affected-surface map, direct files, indirect consumers, contracts/compatibility, alternatives, ordered steps, tests, runtime/browser/device checks, risks, non-goals, stop conditions, and unavailable evidence. Revalidate old findings and plans against current code before relying on them.

During implementation, stop and reassess when new consumers appear, scope expands, diagnosis changes, a contract or migration becomes necessary, tests reveal a deeper issue, static assumptions conflict with runtime evidence, a safer abstraction exists, generated output is being edited, unrelated work is at risk, or privileged/destructive operations become involved.

After implementation, revisit every affected or potentially affected map entry: inspect consumers, run required validation, record the result and limitation, and reconcile affected areas as well as original requirements before completion.

## Task-mode boundaries

- Read-only audit: do not edit application files, dependencies, configuration, or generated output.
- Diagnosis: determine and explain the cause; do not implement the fix unless requested.
- Implementation: revalidate the diagnosis, change code, test it, and inspect the final diff.
- QA/deployment: distinguish static proof from browser, mobile, service, infrastructure, secret, and production proof.

Never claim complete coverage without an inventory and reconciliation of inspected, excluded, generated, skipped, and inaccessible files. Separate confirmed findings, rejected candidates, uncertain items, and blockers.
