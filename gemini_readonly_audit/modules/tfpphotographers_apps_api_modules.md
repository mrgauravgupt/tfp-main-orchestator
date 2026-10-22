# Module Review: `tfpphotographers/apps/api` (Domain Modules)

## 1. Module Overview
- **Path**: `tfpphotographers/apps/api/src/modules/*`
- **Purpose**: Vertical domain slices encapsulating business logic, route handlers, CQRS commands, queries, and validation schemas.
- **File Count**: 317 files (50,959 lines) assigned to domain modules, covering 20 domain feature areas under `apps/api/src/modules/` and their module-specific test suites.
- **Key Sub-Modules**:
  - `admin`, `auth`, `contest`, `event`, `legal`, `location`, `media`, `message`, `moderation`, `notifications`, `opportunity`, `quick-request`, `redirect`, `referral`, `report`, `search`, `telemetry`, `translation`, `upload`, `user`.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Route Registrars: `registerContestRoutes`, `registerOpportunityRoutes`, `registerUserRoutes`, `registerAuthRoutes`, etc.
- Commands & Queries: Segregated into `commands/` and `queries/` directories per domain module.
- Validation: Zod schemas for request body, querystrings, and route parameter parsing.

## 3. Architecture & Internal Responsibilities
- **CQRS Pattern Adoption**: Writing operations are encapsulated into explicit command functions (e.g. `SubmitContestEntry`, `CreateOpportunity`, `ApproveMediaAsset`) while read operations are isolated into query functions (e.g. `ListContests`, `GetContestDetails`).
- **Prisma Seams**: Command and query handlers utilize structural seams (`Pick<PrismaClient, ...>`) for targeted test double injection and transaction composition.
- **Transactional Outbox Integration**: Commands creating or updating domain state atomically append event records to `event_outbox` within the same database transaction.

## 4. Observed Strengths
- **Clean CQRS Partitioning**: Prevents monolithic service classes by separating read and write models.
- **Atomic Operations**: Critical mutations (e.g., contest submission, user onboarding) lock relevant parent entities and verify limits inside transactions before persisting.

## 5. Identified Deficiencies & Findings
- **Duplicate Moderation Appeal Creation Logic (AUD-0010)**:
  - `modules/admin/admin-appeal.commands.ts:4-24` (`CreateModerationAppeal`) and `modules/report/report.commands.ts:126-146` (`CreateReportAppeal`) are 100% duplicate implementations.
  - Both execute the exact same query against `prisma.moderationAppeal.create`.
  - In addition, `modules/moderation/moderation-appeal-routes.ts` imports from `admin.commands.js` to process end-user appeals, creating an inappropriate architectural dependency between public user routes and admin command files.
- **Inconsistent Validation Placement**:
  - Some route modules validate incoming input directly using Fastify route schemas (`schema: { body: ... }`), while others manually invoke `schema.parse(request.body)` inside handlers, leading to divergent error response shapes.

## 6. Review Status
- **Tool Scan**: COMPLETED (lexical rolling window and regex symbol scanner executed across all 317 files).
- **AI Review**: REVIEWED (in-depth inspection of CQRS commands, queries, route schemas, and outbox transactional patterns).
- **Cross-Module Comparison**: COMPLETED (cross-checked against API core, database models, and web/mobile API clients).
