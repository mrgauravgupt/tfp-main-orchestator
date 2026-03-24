# Workspace-Wide Agent Notes

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-latest`.
- Main application workspace: `/Users/hexa/Desktop/tfp-latest/tfp-workspace`.
- If both root and nested workspaces changed, update and commit in both repositories.

## Commit Preference
- For this workspace, commit completed work by default unless the user explicitly says not to.
- When the user asks to "commit everything", stage and commit the full current working tree as-is, including untracked files, with a clear summary message.
- If a nested project has its own `AGENTS.md`, follow those instructions in addition to this file.

## Commit Message Conventions
- Use clear, scoped commit subjects (50-72 chars when possible).
- Prefer imperative style: `feat(...)`, `fix(...)`, `docs(...)`, `chore(...)`.
- Add a concise body for non-trivial changes: what changed, why, and any risk notes.

## Execution Defaults
- Run fast validation before finalizing when applicable (`tsc`, build, and targeted tests).
- Do not revert user-authored unrelated changes unless explicitly requested.
- Keep changes minimal, traceable, and production-safe.

## Reporting Expectations
- Final responses should include:
  - what was changed,
  - file paths affected,
  - commit hash(es),
  - verification commands run.
