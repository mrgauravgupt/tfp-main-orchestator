# TFP Workspace Context

This workspace coordinates the TFP Photographers monorepo, collage service, and moderation service. Read `AGENTS.md`, `RULES.md`, and `MEMORY.md` before non-trivial work; for product work, use `tfpphotographers/docs/agent-index.json` and the nested repository instructions.

Treat each nested Git repository independently. Preserve unrelated working-tree changes. Use repository wrappers and checked-in runbooks rather than global tooling. Do not infer runtime or production proof from static checks.

The PostgreSQL `event_outbox` plus `FOR UPDATE SKIP LOCKED` worker model is intentional. Never expose credentials, tokens, presigned URLs, raw moderation payloads, or production connection strings. Destructive database, deployment, and release operations require explicit task authorization.
