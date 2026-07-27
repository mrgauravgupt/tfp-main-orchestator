# Automatic Engineering Task Routing

Apply this rule to every user request. The user is not required to invoke `/full-engineering-task`, another workflow, a skill, or a special prompt format. Infer the appropriate engineering process from ordinary natural language, then apply the evidence-first and no-shortcuts rules automatically.

## Mode inference

| Natural-language intent | Default mode | Default boundary |
| --- | --- | --- |
| explain, how does, where is, what does | explanation | inspect and explain; no edits |
| check, review, audit, inspect, find issues, identify gaps, make sure, report | read-only audit | no source edits unless fixes are explicitly requested |
| why, debug, investigate, broken, stuck, flaky, root cause | diagnosis | establish cause and plan; no edits unless requested |
| plan, design, propose, what needs to change | planning | grounded plan only |
| fix, add, change, update, remove, refactor, redesign, migrate, implement | implementation | plan before non-trivial edits; validate proportionally |
| verify, validate, double-check, confirm, review implementation | independent verification | inspect and validate; do not fix unless requested |
| page, UI, responsive, browser, mobile, console, user flow | runtime or browser QA | inspect routes/states and distinguish emulation from device proof |
| deploy, release, publish, migrate | release/deployment preparation | identify environment and require explicit approval before mutation |

When language is ambiguous, choose the safest non-destructive interpretation and continue when repository evidence can resolve scope. Do not turn audits into fixes, diagnosis into implementation, validation into cleanup, or release validation into deployment.

## Automatic skill selection

Before significant tool use, inspect available skill names and descriptions and load only the most specific relevant skills:

- TFP work: `tfp-repository-context`.
- Check, review, audit, hardcoded content, i18n, consistency, or broad findings: `evidence-based-auditor`.
- Bug, failure, stuck workflow, or unexplained behaviour: `root-cause-debugger`.
- Feature, fix, refactor, migration, redesign, or multi-file change: `safe-implementation-planner`; use `change-verifier` before completion.
- Page, form, responsive, accessibility, navigation, browser, or visual work: `browser-ui-qa` and relevant implementation/verifier skills.
- Independent completion or correctness review: `change-verifier`.

Do not load all skills indiscriminately. Workflows remain optional manual shortcuts; correctness must not depend on their invocation.

## Default automatic behaviour

For every non-trivial request, apply the appropriate lifecycle automatically: classify, inspect instructions and repository state, establish scope and success criteria, understand architecture and sources of truth, identify boundaries, define evidence, consider alternatives or hypotheses, plan, execute only when authorized, validate proportionally, independently review, reconcile requirements, and report honestly.

For generic audits, understand architecture before scanning; define classifications and exceptions; inventory scope; maintain coverage; treat searches as candidates; validate findings semantically; reject false positives; reconcile coverage; and remain read-only unless fixes are requested.

For every implementation request, automatically perform a complete pre-implementation impact analysis. Do not start coding until relevant callers, consumers, contracts, tests, shared packages, runtime paths, user-facing surfaces, configuration, and operational concerns have been reviewed and a grounded implementation plan has been produced. Then inspect repository state and current system; consider alternatives; request review for non-trivial work; implement narrowly; validate every affected area; review the final diff; and never commit, push, deploy, migrate, or perform unrelated cleanup without explicit authorization.

Do not expose hidden reasoning. Provide concise, useful artifacts: selected mode, context summary, evidence, alternatives, plan, validation, limitations, and requirement reconciliation.
