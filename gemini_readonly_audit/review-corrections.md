# Source review corrections, 22 October 2026

This addendum supersedes conflicting claims in the original report and index.
The original inventory, scan output, and execution log remain historical receipts.

- AUD-0009 is rejected. The cited test imports its local AST scanner, which uses
  TypeScript source/program analysis. The environment resolver imports Node built-ins.
- An extension/module classification cannot prove execution or individual review.
  The generator now writes `file_inventory.current.csv` and uses unverified statuses;
  the blanket-status updater refuses to run. Do not present 2,905 discovered files
  as 2,905 individually reviewed files or 147 candidates as 147 defects.
- Correct existing test owners are `tests/unit/test_signal_response_builder.py`
  and `tests/unit/test_moderation_policy.py` in the historical moderation checkout.
- User repository consumers include auth logout as well as OAuth provisioning.
- Notification intent belongs in the transaction committing the entity decision;
  reminder intent and reminder marker must commit together with deduplication.
- AI event/payload contracts and migration-derived queue fixture checks already
  exist. The domain enrichment SELECT check extends those checks; it statically
  validates names/shape, not PostgreSQL performance or deployed compatibility.
- Moderation service and browser toolkit work is scoped offline historical tooling.
  Current deploy composition is application + AI interface + collage service.
- File size and disk catalog bytes establish structural observations only. They
  do not establish cyclomatic complexity, production latency, heap use or savings.
- Keep localized redirect stubs. Repository deletion is bounded cleanup with factory,
  interface, export and consumer checks, never "zero behavioral risk".

Execution follows `docs/reviews/2026-10-22-audit-remediation-plan.md` in the parent.
