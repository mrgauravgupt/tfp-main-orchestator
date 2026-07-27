---
name: safe-implementation-planner
description: >-
  Automatically plans non-trivial fixes, features, refactors, redesigns,
  migrations, and multi-file changes when the user asks to add, implement, fix,
  change, update, remove, refactor, redesign, migrate, or improve something.
  Inspects current architecture, affected contracts, alternatives, risks, and
  validation before implementation.
---

# Safe Implementation Planner

Include objective, success criteria, current behaviour, source-of-truth evidence, affected repositories and components, alternatives, selected approach, ordered file changes, contracts, migration or rollback implications, validation, non-goals, and unresolved assumptions.

A plan is incomplete until it contains an affected-surface map covering direct and indirect consumers, shared contracts, persistence, events and queues, web and mobile surfaces, tests, configuration, deployment implications, compatibility, and rollback where applicable. Classify each applicable area as directly affected, indirectly affected, potentially affected, reviewed and unaffected, requires runtime verification, requires external verification, or not applicable.

Inspect relevant code first. Do not invent commands or paths. Consider nested repository and parent gitlink effects. Do not implement during planning mode.
