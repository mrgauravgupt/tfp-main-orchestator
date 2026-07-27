# Safe Implementation

Use only after source changes are explicitly authorized.

1. Revalidate the requirement or diagnosis against current code.
2. Record branch and status for every affected repository; preserve unrelated changes.
3. State scope, non-goals, compatibility, risks, and validation.
4. Inspect established abstractions and similar code, then choose the smallest repository-native solution.
5. Implement incrementally, inspecting call sites and focused validation after meaningful steps.
6. Add or update behaviour-focused tests and run broader checks proportionate to risk.
7. Review the complete diff for unrelated churn, generated output, secret leakage, contract changes, and missing consumers.

Do not commit, push, deploy, migrate, or install dependencies unless separately authorized.
