# Full Engineering Task

Run the task through these phases and show concise gate output before moving to the next phase. Hidden reasoning is neither requested nor exposed; use observable evidence and decisions instead.

## Mandatory quality-gate outputs

For every non-trivial task, record:

- **Gate A — Task contract:** mode, objective, scope, permitted edits, success criteria, required evidence, and non-goals.
- **Gate B — Context brief:** applicable instructions, repository state, architecture, sources of truth, abstractions, boundaries, validation mechanisms, and known unknowns. Do not scan broadly or edit until this is grounded in inspected files.
- **Gate C — Evidence/hypothesis ledger:** audit classifications and coverage; debugging hypotheses with confirming/contradicting evidence; or implementation current/intended behaviour, contracts, alternatives, and compatibility.
- **Gate D — Execution plan:** selected approach, rationale, affected files/components, steps, risks, validation, and stop-and-reassess conditions. Do not edit source before this gate.
- **Gate E — Verification ledger:** requirement, evidence, validation performed, result, and remaining unknowns.
- **Gate F — Independent review:** challenge assumptions, missed scope, false positives, regression risk, unnecessary work, weak validation, and unsupported claims.

## 1. Classify

Identify the task mode, requested scope, affected repository or service, and whether edits are authorized.

## 2. Inspect

Read applicable agent guidance. Check git state and repository boundaries. Use the routing index and canonical documentation to locate the domain.

## 3. Understand

Describe the architecture, source of truth, existing conventions, runtime lifecycle, and relevant validation tools. Inventory relevant paths and exclusions.

## 4. Investigate

Read representative source files. Maintain competing hypotheses where the cause is uncertain. Use automated searches as candidates only, then validate candidates semantically.

## 5. Plan

State the diagnosis or evidence summary, affected boundaries, planned files, non-goals, risks, decision log, and validation plan. Do not edit before this gate.

## 6. Execute

If implementation is authorized, make the smallest architecture-native change and preserve unrelated work. If the task is read-only or diagnosis-only, stop after producing the report and plan.

## 7. Validate

Run focused checks first, then broader checks proportional to risk. Use browser, mobile, runtime, service, or deployment validation when the task depends on them.

## 8. Reassess

Compare results with the original hypothesis. Investigate contradictions and newly affected surfaces before claiming success.

## 9. Report and reconcile

Reconcile every requirement with implementation or finding evidence, validation evidence, status, and limitation. Report files changed, commands and results, coverage, confirmed findings, rejected or uncertain candidates, external blockers, and remaining risks. Never imply runtime or production proof from static checks alone.
