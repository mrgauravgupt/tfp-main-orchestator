# Module Review: `tfpphotographers/packages/moderation`

## 1. Module Overview
- **Path**: `tfpphotographers/packages/moderation`
- **Purpose**: Defines shared content moderation contracts, the transactional upload moderation port, and the canonical AST parser, compiler, and evaluator for raw AI policy evaluation (`raw-policy`).
- **File Count**: 8 source/config files (`src/index.ts`, `src/raw-policy/types.ts`, `src/raw-policy/parser.ts`, `src/raw-policy/evaluator.ts`, `src/raw-policy/runtime.ts`, `src/raw-policy/yaml.ts`, `package.json`, `tsconfig.json`).
- **Line Count**: ~940 lines of TypeScript source code.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- **Upload Moderation Port**: `UploadModerationPort`, `QueueUploadModerationInput`, `UploadModerationOutcome`, `UploadModerationStatusRecord` (`src/index.ts`).
- **Raw Policy Engine Types**: `RawPolicyDocument`, `RawPolicyStage`, `RawPolicyRule`, `RawPolicyAstNode`, `RawPolicyToken`, `RawPolicyEvaluationSummary`, `RawPolicyMatch` (`src/raw-policy/types.ts`).
- **Tokenizer & Parser**: `tokenizeRawPolicyCondition`, `parseRawPolicyCondition`, `compileRawPolicyDocument` (`src/raw-policy/parser.ts`).
- **AST Evaluator & Runtime**: `evaluateCompiledRawPolicy`, `evaluateRawPolicyAst`, `evaluateCondition` (`src/raw-policy/evaluator.ts`, `src/raw-policy/runtime.ts`).
- **YAML Loader**: `parseRawPolicyYaml` (`src/raw-policy/yaml.ts`).

## 3. Architecture & Internal Responsibilities
- **Upload Moderation Port**: Declares `UploadModerationPort.enqueue(input, tx: Prisma.TransactionClient)` which enforces that enqueuing content moderation work occurs atomically within the caller's Prisma transaction.
- **Recursive-Descent AST Parser**: Implements a standard recursive descent parser for boolean expressions:
  - `parseOr` -> `parseAnd` -> `parseComparison` -> `parseUnary` -> `parsePrimary`.
  - Supports comparison operators (`==`, `!=`, `<`, `<=`, `>`, `>=`) and logical operators (`&&`, `||`, `!`).
  - Supports identifier path navigation (e.g., `model.nsfw.score > 0.85`).
- **Evaluator Runtime**: Navigates JSON/dictionary signal payloads (`rawEnvelope`) and evaluates compiled AST expressions safely without using `eval()` or `Function()`.

## 4. Observed Strengths
- **Safe Expression Evaluation**: Clean, isolated AST interpreter preventing arbitrary code execution.
- **Transactional Atomicity**: Requires an active `Prisma.TransactionClient` parameter for enqueuing moderation tasks, preventing orphaned or uncommitted moderation records.
- **Strict Typing**: Well-defined TypeScript union types for tokens, AST nodes, and evaluation outcomes (`APPROVED`, `FLAGGED`, `REJECTED`, `ERROR`).

## 5. Identified Deficiencies & Findings
- **Raw Policy Duplication across Microservices (AUD-0011 / DUP-004)**: The AST tokenizer, parser, and evaluator in `src/raw-policy/runtime.ts` (lines 1-320) are duplicated verbatim in a handwritten 1,236-line ES5 browser script in `tfp-moderation-service/src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js`. Any enhancement, bug fix, or operator addition in TypeScript is not automatically synced to the in-browser evaluation toolkit.
- **Type Duplication**: `ModerationOutcome` is declared both here (`src/raw-policy/types.ts:1`) and in `apps/api/src/modules/moderation/domain/types.ts:17`.

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
