# Final Verification

Use after an implementation or before a commit/release.

1. Read the requirement, approved plan, and current diff; do not trust summaries.
2. Map each requirement and each entry in the pre-implementation affected-surface map to implementation, test, and runtime/browser/device evidence where applicable.
3. Inspect changed files and affected consumers for architecture, contracts, compatibility, security, accessibility, performance, and operations impact; do not mark a mapped area unaffected without supporting evidence.
4. Run the applicable checks from `docs/agent/VALIDATION_MATRIX.md`.
5. Create a requirement-and-impact reconciliation table: requirement or affected area, evidence inspected, implementation/finding evidence, validation evidence, result, and limitation. Classify proof as static, test-confirmed, runtime-confirmed, browser-confirmed, device-confirmed, externally blocked, failed, or not applicable.
6. Review root and nested Git status and ensure no secret or unrelated file is in the diff.
7. Independently challenge unsupported completion claims, missed requirements, weak validation, and unaddressed failures. Produce blocking and non-blocking findings; do not commit, push, or deploy automatically.
