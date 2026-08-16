# Broad Audit Quality Protocol

Apply this rule when the user says check, review, audit, inspect, find issues, identify gaps, make sure, every file, entire repository, complete, exhaustive, every page, or every service. It covers repository-wide reviews and consistency checks.

Before candidate discovery, define the objective, confirmed-issue criteria, accepted exceptions, false-positive categories, relevant repositories and file types, source-of-truth conventions, exclusions, and coverage ledger.

Automated scans produce candidates only. For every reported finding, inspect surrounding code, validate semantic relevance, identify the violated convention, trace related abstractions or dynamic behaviour, and state confidence. Separate confirmed findings, likely findings, accepted exceptions, rejected candidates, and manual-verification items.

Reconcile discovered, in-scope, inspected, excluded, generated, inaccessible, candidate, validated, and confirmed totals. Re-review critical findings and dynamic/framework-wrapper patterns. Never claim full coverage without reconciliation.

When auditing test coverage or layered architecture, never assume a feature is "uncovered" simply because it is absent from one specific layer (e.g., domain vs. human E2E suites). Always check the entire test pyramid. Do not invent product features (like disabled OAuth paths) or report non-existent files as missing coverage gaps. Verify file presence (`find`) and active CI workflows before claiming missing enforcement.
