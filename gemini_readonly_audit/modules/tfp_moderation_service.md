# Module Review: `tfp-moderation-service`

## 1. Module Overview
- **Path**: `tfp-moderation-service`
- **Purpose**: Python 3.12 / FastAPI content moderation microservice running multi-stage deep learning inference (YOLO, CLIP, NudeNet, Marqo, SigLIP) and policy evaluation on user imagery and text.
- **File Count**: 82 files (37,377 lines) across `src/` (29 files, 18,256 lines), `tests/` (22 files, 4,305 lines), root policies and configs (20 files, 12,222 lines), `scripts/` (10 files, 2,568 lines), and `infra/` (2 files, 26 lines).
- **Inclusion Status**: INCLUDED (with working tree diff on policy YAML noted in baseline).

## 2. Public Contract & Key Exports
- API Routes: `apps/api/main.py`, FastAPI routers for `/verify/image`, `/analyze/image`, `/analyze/text`, `/health`.
- Core Service: `src/tfp_moderation_service/service.py` (`InferenceService`, `ImageDerivedSignalBuilder` [lines 234–4506], `SignalResponseBuilder`).
- Adapters: `src/tfp_moderation_service/adapters.py` (20 classes, including `ModelAdapterFactory`, `ImageAdapter`, `TextAdapter`, and 11 computer vision model adapters).
- Policy Evaluator: `src/tfp_moderation_service/raw_verify.py` (`RawImageVerifier`).
- Offline Evaluation: `scripts/eval_192_moderation_service.py` (evaluates moderation service accuracy against 192 test samples; distinct from `tfp-inhouse-moderation/scripts/compare_golden_results.py`).

## 3. Architecture & Internal Responsibilities
- **Multi-Model Pipeline**: Dispatches image evaluation to parallel neural networks:
  - YOLO: Private part and subject bounding box detection.
  - NudeNet: Raw exposure likelihood and anatomical calibration.
  - CLIP: Explicit semantic embeddings and contrastive prompt scores.
  - Marqo & FalconsAI: Broad NSFW classification.
- **Rule Engine**: Evaluates YAML policies (`policy_ai_inference_raw_envelope.yml`) containing boolean expressions over `rawEnvelope` metrics.

## 4. Observed Strengths
- **Resilient Fallback Handling**: `_marqo_failure_fallback()` and `validate_image_adapter_result` ensure that individual model failures or NaN/infinite outputs do not crash the service.
- **Diagnostic Logging**: Redacts raw image payloads while outputting detailed correlation IDs and timing benchmarks.

## 5. Identified Deficiencies & Findings
- **Extreme Monolithic Complexity & God Method (AUD-0006)**:
  - `src/tfp_moderation_service/service.py` is **6,162 lines long**.
  - Within this file, the class `ImageDerivedSignalBuilder` spans **4,272 lines** (lines 234 to 4506), and its primary method `build` spans **2,170 continuous lines** (lines 251 to 2420).
  - The class contains deeply nested heuristic score aggregations, manual dictionary traversals, and hardcoded threshold evaluations.
  - `src/tfp_moderation_service/adapters.py` packs 20 classes into a single **2,207-line** file, combining 11 distinct vision and text model adapters (YOLO, NudeNet, CLIP, Owlv2, Florence, ToxicBERT, etc.) alongside lifecycle instantiation logic.
- **Duplicate AST Expression Evaluator**:
  - `src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js` (1,236 lines) duplicates the tokenizing, parsing, and AST evaluation logic present in `tfpphotographers/packages/moderation/src/raw-policy/runtime.ts`.

## 6. Review Status
- **Tool Scan**: COMPLETED (rolling-hash lexical window scanner and regex symbol scanner executed across all 82 files).
- **AI Review**: REVIEWED (in-depth structural review of monolithic service, adapter factory, and evaluation scripts).
- **Cross-Module Comparison**: COMPLETED (evaluated against `packages/moderation` and `tfp-inhouse-moderation`).
