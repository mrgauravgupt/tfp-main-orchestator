# Module Review: `tfpphotographers/packages/shared`

## 1. Module Overview
- **Path**: `tfpphotographers/packages/shared`
- **Purpose**: Central repository for universal domain types, contracts, DTO schemas, utility functions, and cross-cutting abstractions shared across Fastify API, Astro Web, and Expo Mobile.
- **File Count**: 84 files (42 in `src/`, 33 in `tests/`, package manifests, configs).
- **Line Count**: ~33,000 lines (including large static registries like `locale-registry.ts` at 4,207 lines).
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Domain Event Bus: `getEventBus`, `DomainEventSchemas`, `DomainEvents`, `EventBusOutboxAdapter`, `validateDomainEventPayload` (`src/eventBus.ts`).
- Core Contracts: Universal API response wrappers, DTO schemas, pagination contracts (`src/contracts.ts`, `src/api-contracts/*`).
- Content Options & Enums: Compensation types, experience levels, rate types, opportunity categories (`src/content-options.ts`).
- Localization & Locale Registry: Language codes, directionality (LTR/RTL), country normalization (`src/localization.ts`, `src/locale-registry.ts`).
- Design Tokens & Icons: Shared UI token definitions and SVG path constants (`src/design-tokens.ts`, `src/icons.ts`).
- Media & Storage Helpers: Key generation, image delivery URLs, media lifecycle states (`src/media-lifecycle.ts`, `src/image-delivery.ts`).

## 3. Architecture & Internal Responsibilities
- **Coupling & Dependencies**: Cleanly decoupled. Depends only on `zod` and node core primitives. Does not depend on database or UI frameworks.
- **Event Bus Pattern**: `TypedEventBus` validates payloads against `DomainEventSchemas` using Zod before delegating to an injected `EventBusOutboxAdapter`. Supports deferred completion and claim tracking.
- **Two-Sided Traceability**: API contracts under `src/api-contracts/` provide explicit JSON response schemas for endpoints consumed by Web and Mobile clients.

## 4. Observed Strengths
- **Strict Payload Validation**: `validateDomainEventPayload` guarantees that invalid events cannot enter the transactional outbox.
- **Privacy Guarding**: Sanitizes Zod validation error messages in `validateDomainEventPayload` to prevent sensitive or PII values from being persisted in outbox error logs.
- **Isomorphic Design**: Key utilities (`api-version.ts`, `datetime-local.ts`, `formatters.ts`) are compatible across Node.js runtime, browser DOM, and React Native / Hermes.

## 5. Identified Deficiencies & Findings
- **High Static Overhead (`locale-registry.ts`)**: Contains 4,207 lines of hardcoded static locale data structures, contributing over 100KB to client bundles if not tree-shaken aggressively.
- **Redundant Function Definitions**: `normalizeLocaleCode` duplicated between `packages/shared/src/localization.ts` and `packages/i18n/src/index.ts`.
- **Duplicate Date Formatters**: `formatRelativeTime` and `formatDate` implemented in `packages/shared/src/formatters.ts` while `apps/web/src/utils/format.ts` and `apps/web/src/utils/admin-formatters.ts` maintain separate implementations.

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
