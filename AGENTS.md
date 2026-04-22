# Workspace-Wide Agent Notes

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-latest`.
- Main application workspace: `/Users/hexa/Desktop/tfp-latest/tfp-workspace`.
- For domain-level routing in the app workspace, use `/Users/hexa/Desktop/tfp-latest/tfp-workspace/docs/agent-index.json` first.
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
- Before starting repository work, sync the latest remote changes for any repo that has a configured remote.
- If `git pull --rebase` is blocked by unrelated local changes, continue with scoped work, leave those changes untouched, and mention the skipped sync in the final report instead of stopping the task.
- After completing each meaningful fix in a repo with a configured remote, push the commit promptly unless the user explicitly says not to.
- For browser, UI, integration, or end-to-end work that depends on the running app, always restart both FE and BE first.
- Treat restart order as mandatory for any fresh UI verification pass: stop stale processes, restart services, confirm FE and BE health, then test.
- Run fast validation before finalizing when applicable (`tsc`, build, and targeted tests).
- Do not revert user-authored unrelated changes unless explicitly requested.
- Unrelated pre-existing changes in the working tree are not blockers by themselves. Continue with the requested task, avoid staging those files, and call them out only if they materially affect the work.
- Keep changes minimal, traceable, and production-safe.

## Testing Conventions
- Prefer test roots over colocated source tests for new work:
  - app-local: `apps/<app>/tests/**`
  - workspace-level: `tests/**` for cross-app E2E/contract flows
- Keep API and web unit/integration tests in app-local test roots (`apps/api/tests/**`, `apps/web/tests/**`).
- When creating or updating test scripts/flows, update `/Users/hexa/Desktop/tfp-latest/tfp-workspace/tests/README.md` in the same change so script usage stays discoverable.
- When changing browser seed assets/configs/commands, also update `/Users/hexa/Desktop/tfp-latest/tfp-workspace/tests/seed/README.md`.

## Reporting Expectations
- Final responses should include:
  - what was changed,
  - file paths affected,
  - commit hash(es),
  - verification commands run.
