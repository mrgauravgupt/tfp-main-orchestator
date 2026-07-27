---
name: safe-implementation-planner
description: Produces TFP implementation and refactoring plans grounded in current code, including impact analysis, alternatives, compatibility, rollout, rollback, and validation. Use before multi-file, architectural, cross-repository, or high-risk changes.
---

# Safe Implementation Planner

Include objective, success criteria, current behaviour, source-of-truth evidence, affected repositories and components, alternatives, selected approach, ordered file changes, contracts, migration or rollback implications, validation, non-goals, and unresolved assumptions.

Inspect relevant code first. Do not invent commands or paths. Consider nested repository and parent gitlink effects. Do not implement during planning mode.
