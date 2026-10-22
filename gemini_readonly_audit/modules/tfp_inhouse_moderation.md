# Module Review: `tfp-inhouse-moderation`

## 1. Module Overview
- **Path**: `tfp-inhouse-moderation`
- **Purpose**: Independent Python-based microservice for in-house machine learning content moderation, wrapping local computer vision models (NudeNet, Viddexa, YOLO) and providing a REST API for image analysis and policy scoring.
- **File Count**: 37 repository files included (11 application files in `app/`, 12 test files in `tests/`, 3 evaluation scripts in `scripts/`, workflows, config, requirements) + 1 root directory record.
- **Line Count**: ~3,950 lines of Python code, tests, and configuration.
- **Inclusion Status**: INCLUDED.

## 2. Public Contract & Key Exports
- **REST Endpoints (`app/main.py`)**:
  - `POST /v1/analyze`: Accepts multipart image upload or image URL, runs configured model pipeline, and returns raw detection boxes and classification scores.
  - `POST /v1/policy/evaluate`: Evaluates model predictions against configurable threshold rules and returns a structured moderation decision (`APPROVED`, `FLAGGED`, `REJECTED`).
  - `GET /health` and `GET /ready`: Health check and model readiness probes.
- **Schemas (`app/schemas.py`)**: Pydantic models for `AnalyzeRequest`, `AnalyzeResponse`, `DetectionBox`, `PolicyEvaluationRequest`, `PolicyDecision`.
- **Model Registry (`app/models/registry.py`)**: Factory and lifecycle manager for computer vision models (`NudeNetDetector`, `ViddexaClassifier`, `YoloDetector`).

## 3. Architecture & Internal Responsibilities
- **Service Layering**:
  - `app/models/base.py`: Declares abstract `BaseModelWrapper` interface (`load()`, `predict()`, `is_ready()`).
  - `app/service/analyzer.py`: Orchestrates multi-model execution in parallel or sequential pipeline.
  - `app/service/policy.py`: Applies deterministic threshold rules against raw model scores.
- **Model Isolation**: Each model wrapper cleanly encapsulates model-specific dependencies (e.g. PyTorch, ONNX Runtime) and maps disparate model outputs into unified schema boxes and confidence scores.

## 4. Observed Strengths
- **Modular Model Abstraction**: `BaseModelWrapper` allows adding or swapping computer vision models without changing the API schemas or policy evaluation logic.
- **Evaluation and Tuning Tooling**: Includes dedicated scripts (`scripts/compare_golden_results.py`, `scripts/tune_policy_thresholds.py`) to benchmark model accuracy against golden datasets before deploying policy updates.
- **Comprehensive Unit and Integration Tests**: High test density with mocked model predictions (`tests/fakes.py`), verifying edge cases in box parsing, label mapping, and policy threshold boundary conditions.

## 5. Identified Deficiencies & Findings
- **Heavy Local Model Cache Dependencies**: Model weights in `models-cache/` require substantial disk capacity; startup fails if offline and weights are missing unless `prefetch_models.py` has run.
- **Divergent Policy Rules from Monorepo**: Uses Python-native threshold evaluation in `app/service/policy.py` rather than the AST-based `raw-policy` engine implemented in `packages/moderation` and `tfp-moderation-service`, requiring policy rule authors to maintain separate threshold configurations.

## 6. Review Status
- **Tool Scan**: COMPLETED
- **AI Review**: REVIEWED
- **Cross-Module Comparison**: COMPLETED
