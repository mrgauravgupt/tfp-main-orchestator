# Duplicate Groups and Reuse Opportunities

This document groups related implementations across the codebase by responsibility. Each group analyzes similarities, intentional differences, callers, and consolidation recommendations.

---

## Duplicate Group DUP-001: Cloudflare Media Purger
- **Shared Responsibility**: Sending authenticated HTTP POST requests in batches of 100 URLs to the Cloudflare API to invalidate cached image assets upon moderation or deletion.
- **Implementations**:
  1. `tfpphotographers/packages/storage/src/adapters/CloudflareMediaPurger.ts` (lines 3-31)
  2. `tfp-collage-service/src/adapters/cloudflareMediaPurger.ts` (lines 3-34)
- **Similarities**:
  - Both take `endpoint: string` and `token: string`.
  - Both deduplicate input URLs using `[...new Set(urls)]`.
  - Both slice URLs into batches of 100.
  - Both use `AbortSignal.timeout(10_000)` and POST `{ files: ... }`.
  - Both inspect `response.ok` and verify `{ success: true }`.
- **Differences**:
  - `packages/storage` throws `'Media purge token is not configured'`, `'Media purge transport unavailable'`, and `'Media purge failed with status ${response.status}'`.
  - `tfp-collage-service` throws `'CLOUDFLARE_MEDIA_PURGE_TOKEN_NOT_CONFIGURED'`, `'CDN_PURGE_UNAVAILABLE'`, and `'CDN_PURGE_FAILED:${response.status}'`.
  - `tfp-collage-service` accepts an optional `fetchImpl: typeof fetch` parameter for test injection.
- **Callers**:
  - In `tfpphotographers`: `createMediaStorageGateway` in `packages/storage/src/index.ts`.
  - In `tfp-collage-service`: `ImageProcessingWorker` in `services/imageProcessingWorker.ts`.
- **Consolidation Verdict**: `CONSOLIDATE`.
- **Suggested Ownership**: Extract into a shared contract library or publishable package consumed by both `tfpphotographers` and `tfp-collage-service`.
- **Expected Benefit**: Prevents divergence in timeout handling, error reporting, and purge chunking logic.
- **Risks**: Downstream monitoring expecting specific error strings must be updated to match the consolidated contract.

---

## Duplicate Group DUP-002: Binary Magic Byte MIME Detection
- **Shared Responsibility**: Inspecting the initial bytes of a binary buffer to detect whether the content is JPEG, PNG, or WEBP, preventing MIME-type spoofing.
- **Implementations**:
  1. `tfpphotographers/packages/uploads/src/index.ts` (lines 44-61, `detectMimeByMagicBytes`)
  2. `tfpphotographers/apps/api/src/utils/image-signature.ts` (lines 1-16, `detectImageMimeType`)
- **Similarities**:
  - Both define identical `hasPrefix(bytes, signature)`.
  - Both inspect `[0xff, 0xd8, 0xff]` for JPEG.
  - Both inspect `[0x89, 0x50, 0x4e, 0x47]` for PNG.
  - Both inspect bytes 0-4 for `'RIFF'` and bytes 8-12 for `'WEBP'`.
- **Differences**:
  - `detectMimeByMagicBytes` in `uploads` also detects PDF (`%PDF-`).
  - `detectImageMimeType` in `image-signature.ts` checks `imageBuffer.byteLength < 4` first and only supports images.
- **Callers**:
  - `detectMimeByMagicBytes`: Called by `packages/uploads` direct upload validator and re-exported in `apps/api/src/modules/upload/upload-validation.ts`.
  - `detectImageMimeType`: Called by `apps/api/src/modules/moderation/application/moderation.utils.ts` and `apps/api/src/modules/moderation/manual-analysis/ManualImageAnalysisService.ts`.
- **Consolidation Verdict**: `CONSOLIDATE`.
- **Suggested Ownership**: Retire `image-signature.ts` in `apps/api/src/utils/` and use `detectMimeByMagicBytes` from `packages/uploads`.
- **Expected Benefit**: Single source of truth for file signature verification.

---

## Duplicate Group DUP-003: Moderation Appeal Creation
- **Shared Responsibility**: Inserting a new record into `prisma.moderationAppeal` to allow a user to challenge an automated content moderation action.
- **Implementations**:
  1. `tfpphotographers/apps/api/src/modules/admin/admin-appeal.commands.ts` (lines 4-24, `CreateModerationAppeal`)
  2. `tfpphotographers/apps/api/src/modules/report/report.commands.ts` (lines 126-146, `CreateReportAppeal`)
- **Similarities**:
  - 100% identical implementation:
    ```typescript
    prisma.moderationAppeal.create({
      data: { eventId: input.eventId, userId: input.userId, reason: input.reason },
      select: { id: true, eventId: true, userId: true, reason: true, status: true, createdAt: true },
    })
    ```
- **Differences**: None in logic or return type; only function name differs.
- **Callers**:
  - `CreateModerationAppeal`: Called by `apps/api/src/modules/moderation/moderation-appeal-routes.ts` (line 54).
  - `CreateReportAppeal`: Called by `apps/api/src/modules/report/report.handlers.ts` (line 75).
- **Consolidation Verdict**: `CONSOLIDATE`.
- **Suggested Ownership**: Move to `apps/api/src/modules/moderation/` or `report/`, eliminating the duplicate command in `admin`.
- **Expected Benefit**: Removes code duplication and stops public user-facing moderation appeal routes from importing commands from the `admin` domain.

---

## Duplicate Group DUP-004: Raw Policy AST Tokenizer and Evaluator
- **Shared Responsibility**: Tokenizing boolean expressions, parsing them into an Abstract Syntax Tree (AST), and evaluating ASTs against `rawEnvelope` AI moderation signals.
- **Implementations**:
  1. `tfpphotographers/packages/moderation/src/raw-policy/runtime.ts` (lines 1-320)
  2. `tfp-moderation-service/src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js` (lines 650-980)
- **Similarities**:
  - Identical recursive descent parser structure: `parsePrimary()`, `parseUnary()`, `parseComparison()`, `parseAnd()`, `parseOr()`.
  - Identical token types: `number`, `string`, `boolean`, `null`, `ident`, `(`, `)`, comparison operators, logical operators.
  - Identical path navigation logic (`pathMatcher`).
- **Differences**:
  - `packages/moderation` is written in modern TypeScript with strict types (`CompiledRawPolicy`, `RawPolicyAstNode`).
  - `browser_policy_evaluator_toolkit.js` is written in ES5 JavaScript for in-browser evaluation inside the moderation review tool.
- **Consolidation Verdict**: `CONSOLIDATE` (via compilation / bundling).
- **Suggested Ownership**: Build the client toolkit bundle directly from `packages/moderation/src/raw-policy/runtime.ts` using Vite or esbuild, rather than maintaining a separate handwritten 1,236-line JavaScript copy.
- **Expected Benefit**: Guarantees that in-browser preview evaluation produces the exact same policy decisions as the backend TypeScript/Python runtime.

---

## Duplicate Group DUP-005: Exact Redirect Stubs
- **Shared Responsibility**: Redirecting legacy authentication URLs to `/login` preserving querystrings.
- **Implementations**:
  1. `tfpphotographers/apps/web/src/pages/forgot-password.astro` (lines 1-7)
  2. `tfpphotographers/apps/web/src/pages/reset-password.astro` (lines 1-7)
- **Similarities**:
  - Byte-for-byte identical (SHA-256 `327cc44c0ab2...`):
    ```astro
    ---
    return Astro.redirect(
      (await import('../utils/routing')).localizePathWithQuery('/login', Astro.url.searchParams),
      302,
    );
    ---
    ```
- **Differences**: None.
- **Consolidation Verdict**: `RETAIN_SEPARATELY` or declare in Astro redirects config.
- **Assessment**: While identical, separate files represent distinct URL endpoints (`/forgot-password` and `/reset-password`). They can remain separate as intentional routing stubs or be consolidated into `astro.config.mjs` redirect rules.
