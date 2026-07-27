---
name: tfp-repository-context
description: Automatically provides TFP repository boundaries, sources of truth, validation conventions, and cross-repository safety guidance for ordinary requests involving the TFP web, API, mobile, collage, moderation, shared packages, tests, QA, deployment, or cross-repository work.
---

# TFP Repository Context

Use this skill for work in `/Users/hexa/Desktop/tfp-main-orchestator` or its nested repositories.

## Start here

- Read the root `AGENTS.md` and `RULES.md`.
- For product work, read `tfpphotographers/AGENTS.md`, `docs/agent-index.json`, and the relevant architecture or operations runbook.
- Treat the orchestrator and every nested service repository as separate Git repositories.
- Inspect current git status and preserve unrelated user changes.

## Main boundaries

- `tfpphotographers/apps/web`: Astro web application
- `tfpphotographers/apps/api`: Fastify API
- `tfpphotographers/apps/mobile`: Expo native application
- `tfpphotographers/packages/*`: shared contracts, i18n, database, configuration, email, storage, and domain helpers
- `tfpphotographers/tests` and `qa`: browser, seed, and cross-surface validation
- `tfp-collage-service`: collage service
- `tfp-moderation-service`: moderation service

Do not introduce a second backend, duplicate shared contracts, or cross service boundaries without evidence and an explicit plan.

## Investigation defaults

Prefer scoped searches excluding `node_modules`, `test-results`, `coverage`, `tmp`, and generated output. Read source and tests around every candidate. Existing architecture and checked-in tests outrank generic framework conventions.

## Validation defaults

Static tests do not prove runtime, browser, mobile, infrastructure, secrets, edge configuration, or production behaviour. Use the repository wrappers and runbooks. For cross-repository changes, validate the nested repository first, then update the parent gitlink only when appropriate.

## Known safety constraints

Never print secrets, bearer tokens, presigned URLs, raw moderation payloads, or production connection strings. Do not use destructive reset, seed, delete, restore, or deployment commands unless the task explicitly authorizes them. PostgreSQL `event_outbox` and `FOR UPDATE SKIP LOCKED` are intentional architecture; do not recommend BullMQ or Redis merely because they are absent.
