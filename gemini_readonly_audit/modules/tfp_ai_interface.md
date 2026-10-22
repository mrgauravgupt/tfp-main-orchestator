# Module Review: `tfp-ai-interface`

## 1. Module Overview
- **Path**: `tfp-ai-interface`
- **Purpose**: Python 3.12 / FastAPI microservice and background worker acting as a gateway/proxy for local and hosted Large Language Models and Vision inference.
- **File Count**: 70 tracked files (src, tests, docker, pyproject).
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- API Endpoints: `src/tfp_ai_interface/api.py`.
- Outbox Worker: `src/tfp_ai_interface/worker_service.py`, `src/tfp_ai_interface/worker_repository.py`.
- Domain & Models: `src/tfp_ai_interface/domain.py`, `src/tfp_ai_interface/ports.py`.

## 3. Architecture & Internal Responsibilities
- **Dual Operating Modes**: Can operate as an HTTP API server for real-time model queries or as a detached PostgreSQL outbox polling daemon (`PostgresOutboxRepository`).
- **Transactional Polling**: Claims `process_moderation` and `process_translation` jobs directly from the monorepo's PostgreSQL `event_outbox` table and writes `apply_ai_moderation_result` back.

## 4. Observed Strengths
- **Clean Worker Separation**: The outbox worker repository is well-separated from the inference providers via abstract ports (`worker_ports.py`).
- **Connection Pooling**: Uses `psycopg_pool.ConnectionPool` with strictly validated pool sizes and query timeouts.

## 5. Identified Deficiencies & Findings
- **Direct Database Table Coupling**:
  - `PostgresOutboxRepository` directly queries and updates `event_outbox` in the monorepo's PostgreSQL database using raw SQL queries with JSON payload assumptions.
  - Changes to the monorepo Prisma schema or column naming in `event_outbox` will break `tfp-ai-interface` at runtime unless synchronized carefully.
  - (Note: While intentional in the architecture for high-performance job processing, it is an important coupling point that requires cross-service schema synchronization as noted in `RULES.md`).

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
