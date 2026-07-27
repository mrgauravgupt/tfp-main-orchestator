# No-Shortcuts Engineering and Quality Gates

The objective is a reliable conclusion or implementation supported by repository evidence and appropriate validation, not the fastest plausible answer. Do not expose private hidden reasoning. Produce concise, reviewable artifacts: context, evidence, alternatives, plan, validation, and requirement reconciliation.

The user is not required to invoke a workflow, skill, or special prompt. Apply these gates automatically to non-trivial natural-language requests after `automatic-task-routing.md` selects the task mode.

## Non-trivial task gate

Treat work as non-trivial when it spans multiple files, packages, services, repositories, public contracts, schemas, events, authentication, architecture, security, reliability, deployment, migrations, root-cause analysis, unclear alternatives, or a request for complete, exhaustive, production-ready, or fully verified work.

Simple local tasks may proceed after relevant local context. Every non-trivial task must pass the applicable gates below.

## Mandatory lifecycle

`Classify → inspect workspace → understand architecture → identify sources of truth → define evidence → consider alternatives → plan → execute narrowly when authorized → validate → independently review → reconcile requirements → report honestly`.

Do not jump directly from a request to a broad search, scanner, code edit, codemod, dependency installation, refactor, guessed root cause, generic best-practice recommendation, or completion claim.

## Quality gates

### A. Task contract

Before broad tool use, record the requested outcome, mode, permitted changes, constraints, success criteria, required output, relevant areas, and evidence needed. Preserve mode: an audit is not an implementation; diagnosis is not a fix; release validation is not deployment.

### B. Context brief

Before broad conclusions or changes, read applicable instructions; identify repositories, branch and dirty state, sources of truth, manifests, configuration, CI, tests, scripts, entry points, exclusions, and affected boundaries. Read representative implementations and trace relevant callers, consumers, data flow, or control flow. Do not generalize one file to a whole repository.

### C. Evidence or hypothesis ledger

For audits, define confirmed and likely issue criteria, exceptions, false-positive categories, severity, confidence, scope, exclusions, and coverage. For debugging, record observed versus expected behaviour, strongest reproduction, hypotheses, and evidence that could confirm or reject each. For implementation, record current and intended behaviour, affected contracts and consumers, compatibility, and required validation.

### D. Alternatives and plan

For a non-trivial diagnosis, architecture decision, refactor, or implementation, consider at least one reasonable alternative when one exists. Record supporting and contradicting evidence, risks, compatibility, complexity, verification implications, and the selected rationale.

Before edits or broad automation, plan objective, current understanding, affected repositories/components, expected files or symbols, ordered steps, non-goals, risks, rollout/rollback where relevant, validation, and unavailable evidence. A plan made before reading relevant code does not satisfy this gate.

### E. Verification and reconciliation

Record each applicable command or procedure, result, what it proves, what it does not prove, and blockers. Reconcile every requirement against implementation or finding evidence and a status: verified, partially verified, statically supported, test-confirmed, runtime-confirmed, browser-confirmed, device-confirmed, externally blocked, failed, or not applicable.

### F. Independent review

Before completion, independently challenge assumptions, missed scope, false positives, regression risk, unnecessary change, weak validation, hidden failures, unrelated diffs, and conclusions stronger than their evidence.

## Tool and execution discipline

Search, regex, AST queries, linters, and scripts discover candidates; they do not prove findings. Validate significant candidates in their containing symbol and execution path, including conventions, wrappers, related consumers, dynamic behaviour, and exclusion status. Do not create scripts merely to avoid understanding the system.

When implementation is authorized, make the smallest coherent repository-native change, preserve unrelated work, check consumers, update behaviour-focused tests, and stop when evidence invalidates the plan. Do not perform broad replacement or unrelated cleanup without explicit scope.

## Stop and reassess

Stop and update the plan when evidence contradicts it; scope expands materially; an unexpected public contract changes; tests reveal a deeper issue; generated files dominate; validation cannot support the conclusion; read-only limits would be violated; secrets, production systems, or destructive operations become involved; unrelated work could be overwritten; or a safer established abstraction is found.

## Completion restrictions

Do not claim complete, exhaustive, production-ready, fully verified, runtime success, or correct completion based only on a search, scanner, one file, formatter, typecheck, build, one test, generated report, absence of command errors, plausible edit, or one responsive viewport. A passing build is not runtime proof; a passing typecheck is not behavioural proof; responsive emulation is not real-device proof. Do not hide failed commands.

For broad tasks, reconcile discovered, in-scope, inspected, excluded, generated, inaccessible, failed, candidate, validated, confirmed, rejected, accepted, and unresolved totals before claiming coverage.
