# Broad Audit Quality Protocol

Apply this rule to repository-wide reviews, consistency checks, and requests involving all files, complete, exhaustive, every page, or every service.

Before candidate discovery, define the objective, confirmed-issue criteria, accepted exceptions, false-positive categories, relevant repositories and file types, source-of-truth conventions, exclusions, and coverage ledger.

Automated scans produce candidates only. For every reported finding, inspect surrounding code, validate semantic relevance, identify the violated convention, trace related abstractions or dynamic behaviour, and state confidence. Separate confirmed findings, likely findings, accepted exceptions, rejected candidates, and manual-verification items.

Reconcile discovered, in-scope, inspected, excluded, generated, inaccessible, candidate, validated, and confirmed totals. Re-review critical findings and dynamic/framework-wrapper patterns. Never claim full coverage without reconciliation.
