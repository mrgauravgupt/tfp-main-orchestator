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

## Task-mode boundaries

- Read-only audit: do not edit application files, dependencies, configuration, or generated output.
- Diagnosis: determine and explain the cause; do not implement the fix unless requested.
- Implementation: revalidate the diagnosis, change code, test it, and inspect the final diff.
- QA/deployment: distinguish static proof from browser, mobile, service, infrastructure, secret, and production proof.

Never claim complete coverage without an inventory and reconciliation of inspected, excluded, generated, skipped, and inaccessible files. Separate confirmed findings, rejected candidates, uncertain items, and blockers.
