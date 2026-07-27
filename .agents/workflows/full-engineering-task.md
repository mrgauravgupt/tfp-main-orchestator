# Full Engineering Task

Run the task through these phases and show the gate output before moving to the next phase.

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

## 9. Report

Report files changed, evidence, commands and results, coverage, confirmed findings, rejected or uncertain candidates, external blockers, and remaining risks. Never imply runtime or production proof from static checks alone.
