# Overnight Mission Blockers

## Resolved During Run

1. **UI full capture bootstrap failed (resolved)**
- Time: 2026-04-05 02:07 IST
- Blocker: `qa:ui:capture:verify:full` initially failed with `ECONNREFUSED` because FE/BE were not active.
- Impact: Phase H could not start on first attempt.
- Resolution: Restarted stack via `./scripts/start-app.sh development`, validated service health, reran full capture and strict analysis successfully.

## Unresolved

- None.
