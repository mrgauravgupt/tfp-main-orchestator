# Read-Only Audit

Use for investigations and reviews where source must not change.

1. Record initial status for every affected repository.
2. Define scope, classifications, severity, confidence, and false-positive categories.
3. Inventory paths, conventions, generated areas, exclusions, and sources of truth.
4. Build a coverage ledger before scanning.
5. Discover candidates with appropriate semantic and mechanical methods.
6. Validate each reported finding in context; classify rejected and unresolved candidates explicitly.
7. Reconcile coverage and re-review severe findings.
8. Generate only approved report artifacts, record final status, and state limitations.

Do not implement fixes, run codemods, reformat source, update dependencies, or create commits.
