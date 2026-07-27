# Safe Implementation

Use only after source changes are explicitly authorized.

1. Revalidate the requirement or diagnosis against current code.
2. Record branch and status for every affected repository; preserve unrelated changes.
3. Before coding, document current and intended behaviour, source of truth, direct and indirect affected areas, callers and consumers, contracts and compatibility, alternatives, file-level plan, validation matrix, and stop-and-reassess conditions.
4. Build an affected-surface map covering applicable repositories/services/packages, dependencies/consumers, data/contracts, user-facing surfaces, operations, and verification. Classify each as directly affected, indirectly affected, potentially affected, reviewed and unaffected, requires runtime verification, requires external verification, or not applicable.
5. Inspect established abstractions and similar code, then choose the smallest repository-native solution. Do not implement from one file, one search result, one failing test, an old audit, a previous plan, or generic best-practice assumptions alone.
6. Implement incrementally, inspecting call sites and focused validation after meaningful steps; stop and reassess when evidence, scope, consumers, contracts, migrations, runtime assumptions, or safety boundaries change.
7. Add or update behaviour-focused tests and run broader checks proportionate to risk; state what each check proves and cannot prove.
8. Return to every affected or potentially affected map entry, validate it, and record result and limitation. Review the complete diff for unrelated churn, generated output, secret leakage, contract changes, and missing consumers; reconcile requirements and impact before completion.

Do not commit, push, deploy, migrate, or install dependencies unless separately authorized.
