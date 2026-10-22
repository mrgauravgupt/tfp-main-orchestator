# Mechanical Tool Execution Log

This record documents all automated tools, static checks, scanners, and scripts executed during the audit, including parameters, scope, exit codes, and output references.

| Run ID | Tool / Command | Target / Scope | Status | Exit Code | Output Artifact | Findings / Notes |
|---|---|---|---|---|---|---|
| TR-001 | `generate_inventory.py` (v1) | Full Workspace (6 repos) | SUCCESS | 0 | `file_inventory.csv` | Initial discovery: 3,157 files discovered; 2,905 included, 252 excluded (923,603 lines) |
| TR-002 | `git status / rev-parse` | All 6 Git Repos | SUCCESS | 0 | `audit_index.md` | Baseline verification: clean repos except root (untracked) and moderation service (1 policy modified) |
| TR-003 | `mechanical_scan.py` (v1) | 2,103 source files | SUCCESS | 0 | `mechanical_scan_results.json` | Rolling window scanner (10 lines min, normalized whitespace). Note: initial run had contest path exclusion and output truncation |
| TR-004 | `symbol_duplicates.py` (v1) | All included TS/JS source | SUCCESS | 0 | `symbol_duplication.json` | Lexical regex scanner for exported functions/classes. Initial run had contest exclusion |
| TR-005 | `update_inventory_status.py` (v1) | `file_inventory.csv` | SUPERSEDED | 0 | `file_inventory.csv` | Assigned blanket completion; flagged in verification review for derivation repair |
| TR-006 | `generate_candidate_dispositions.py` (v1) | 97 duplicate blocks, 44 symbols | SUPERSEDED | 0 | `candidate_dispositions.csv` | Initial ledger with 141 rows; generic fallback certainty |
| TR-007 | `update_findings.py` (v1) | AUD-0001 through AUD-0012 | SUPERSEDED | 0 | `findings.jsonl` | Initial findings formulation; contained path and line count discrepancies |
| TR-008 | `generate_inventory.py` (v2 - repair) | Full Workspace (6 repos) | SUCCESS | 0 | `file_inventory.csv` | Repaired test classifier (directory boundary matching; restored 65 contest files to `SOURCE_CODE`). Re-evaluated evidence-derived statuses (`COMPLETED`, `PARTIAL`, `UNSUPPORTED`, `NOT_APPLICABLE`). 2,905 included files, 924,043 lines |
| TR-009 | `mechanical_scan.py` (v2 - repair) | 2,103 source files (including contests) | SUCCESS | 0 | `mechanical_scan_results.json` | Removed contest path exclusion; upgraded collision signature to full normalized block tuple; eliminated output truncations. Output: 96 block duplicates, 132 large files, 13 layer violations |
| TR-010 | `symbol_duplicates.py` (v2 - repair) | All included TS/JS source (including contests) | SUCCESS | 0 | `symbol_duplication.json` | Restored contest paths; eliminated output truncations. Labeled detector as lexical regex scanner. Output: 51 multi-defined exported symbols |
| TR-011 | `generate_candidate_dispositions.py` (v2) | 96 duplicate blocks, 51 symbols | SUCCESS | 0 | `candidate_dispositions.csv` | Reconciled all 147 candidate rows with evidence-grounded rationales (e.g. single-file TS function overloading) and transparent uncertainty flags |
| TR-012 | `update_findings.py` (v2) | AUD-0001 through AUD-0012 | SUCCESS | 0 | `findings.jsonl` | Updated all 12 findings with true source paths (`service.py`, `adapters.py`, `cache.adapter.ts`), exact line counts (`server.ts` 790 lines), PostgreSQL driver (`psycopg`), outbox transaction qualifications, soft-delete matrix, and `[EXISTING]` vs `[PROPOSED]` test labels |
