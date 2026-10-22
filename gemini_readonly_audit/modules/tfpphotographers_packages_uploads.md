# Module Review: `tfpphotographers/packages/uploads`

## 1. Module Overview
- **Path**: `tfpphotographers/packages/uploads`
- **Purpose**: Upload orchestration, direct-to-storage presigned upload URL generation, file signature inspection, and storage completion handoff.
- **File Count**: 3 source files + configuration and package manifest.
- **Line Count**: 756 lines in `src/index.ts`.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- Orchestration: `detectMimeByMagicBytes`, `resolvePrivateObjectUrl`, `PresignUploadInput`, `UploadOrchestratorDeps`.
- Enums & Mappings: `MEDIA_KIND_BY_UPLOAD_SCOPE`.

## 3. Architecture & Internal Responsibilities
- **Direct Upload Flow**: Clients request presigned URLs with precomputed SHA-256 checksums and MIME types, upload directly to object storage, and then notify the backend to verify headers and magic bytes before marking assets ready.
- **Transactional State Transition**: Connects with Prisma database to track upload intents and link uploaded files to domain entities (`CONTEST_SUBMISSION`, `OPPORTUNITY_MOODBOARD`, etc.).

## 4. Observed Strengths
- **Magic Byte Validation**: `detectMimeByMagicBytes` reads file header bytes (PDF, JPEG, PNG, WEBP) to prevent MIME spoofing attacks.
- **Upload Scope Verification**: Strictly maps upload scopes to media kinds via `MEDIA_KIND_BY_UPLOAD_SCOPE`.

## 5. Identified Deficiencies & Findings
- **Duplicate Magic Byte Implementation (AUD-0002)**:
  - Magic byte detection logic is duplicated in `apps/api/src/utils/image-signature.ts` (`detectImageMimeType`).
  - Both check the exact same byte arrays (`[0xff, 0xd8, 0xff]`, `[0x89, 0x50, 0x4e, 0x47]`, RIFF/WEBP).

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
