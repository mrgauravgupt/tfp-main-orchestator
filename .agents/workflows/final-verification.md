# Final Verification

Use after an implementation or before a commit/release.

1. Read the requirement, approved plan, and current diff; do not trust summaries.
2. Map each requirement to implementation, test, and runtime/browser/device evidence where applicable.
3. Inspect changed files and affected consumers for architecture, contracts, compatibility, security, accessibility, performance, and operations impact.
4. Run the applicable checks from `docs/agent/VALIDATION_MATRIX.md`.
5. Classify proof as static, test-confirmed, runtime-confirmed, externally blocked, or failed.
6. Review root and nested Git status and ensure no secret or unrelated file is in the diff.
7. Produce blocking and non-blocking findings; do not commit, push, or deploy automatically.
