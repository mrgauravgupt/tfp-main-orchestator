# Workspace-Wide Agent Notes

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-latest`.
- Main application workspace: `/Users/hexa/Desktop/tfp-latest/tfpphotographers`.
- For domain-level routing in the app workspace, use `/Users/hexa/Desktop/tfp-latest/tfpphotographers/docs/agent-index.json` first.
- If both root and nested workspaces changed, update and commit in both repositories.
- For cross-repo operator work, prefer the checked-in menu and runbook paths first:
  - `tfpphotographers/scripts/manage-tfp.sh`
  - `tfpphotographers/scripts/start-app.sh`
  - `tfpphotographers/tests/create-data/README.md`
  - `tfpphotographers/docs/operations/AGENT_RUNTIME_AND_SEED_GUIDE.md`

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
- If work happens on a branch, merge it back into `main` promptly after validation unless the user explicitly says not to. `main` should remain updated with completed work.
- For browser, UI, integration, or end-to-end work that depends on the running app, always restart both FE and BE first.
- Treat restart order as mandatory for any fresh UI verification pass: stop stale processes, restart services, confirm FE and BE health, then test.
- For destructive seed/reset work, use the checked-in launcher flow:
  - `bash ./scripts/start-app.sh reset <env>`
  - `pnpm qa:create-data:seed:real:quick`
  - `bash ./scripts/manage-tfp.sh` for menu-driven operator flows.
- Run fast validation before finalizing when applicable (`tsc`, build, and targeted tests).
- Do not revert user-authored unrelated changes unless explicitly requested.
- **Dirty Workspace Policy**: Unrelated pre-existing changes in the working tree are not blockers by themselves. Continue with the requested task. Make code changes very carefully to avoid overwriting anyone else's changes.
- **Selective Commits**: Stage, commit, and push only your specific changes. Avoid staging unrelated modified files.
- **Git Worktree Isolation Option**: Alternatively, if the working tree has complex dirty files, you may choose to execute your work inside a separate `git worktree` and merge back in the end, carefully committing and pushing only your changes.
- Keep changes minimal, traceable, and production-safe.

## Testing Conventions
- Prefer test roots over colocated source tests for new work:
  - app-local: `apps/<app>/tests/**`
  - workspace-level: `tests/**` for cross-app E2E/contract flows
- Keep API and web unit/integration tests in app-local test roots (`apps/api/tests/**`, `apps/web/tests/**`).
- When creating or updating test scripts/flows, update `/Users/hexa/Desktop/tfp-latest/tfpphotographers/tests/README.md` in the same change so script usage stays discoverable.
- When changing browser seed assets/configs/commands, also update `/Users/hexa/Desktop/tfp-latest/tfpphotographers/tests/seed/README.md`.

## Reporting Expectations
- Final responses should include:
  - what was changed,
  - file paths affected,
  - commit hash(es),
  - verification commands run.

## Agent Capabilities & System Access
- **MCP Servers**: Equipped with `filesystem`, `github`, `prisma-mcp-server`, and `puppeteer`.
- **Advanced Skills**: Equipped with plugin-based developer skills (`chrome-devtools`, `firebase-*`, `a11y-debugging`, `debug-optimize-lcp`, `troubleshooting`, `modern-web-guidance`, `uv`, etc.).
- **System Access via Shell**:
  - Direct execution access via `run_command` on the host macOS system.
  - Silent desktop screen capture via `screencapture -x /Users/hexa/.gemini/antigravity/scratch/screen.png`.
  - Opening files or launching apps via macOS `open`.
- See the full directory of tools and workflows in [SKILLS.md](file:///Users/hexa/Desktop/tfp-main-orchestator/SKILLS.md).

## Multi-Agent Coordination & Context Sharing
- **Workspace Sharing**: When spawning subagents via `invoke_subagent`, always prefer `inherit` or `share` workspaces to ensure they share file states and db states.
- **Messaging Protocol**: Use `send_message` with recipient conversation IDs to pass data and completion flags. Do not poll peer agent statuses in a loop.
- **Persistent State**: Document all configuration drift, branch switches, or tool updates in `MEMORY.md` and `AGENTS.md` so parallel/future agents inherit the context on startup.
- **Transcript Audits**: If tracing peer actions is needed, read the local JSONL log at `<appDataDir>/brain/<conversation-id>/.system_generated/logs/transcript.jsonl`.

## Cross-Agent & Codex (Vibe Coding) Coexistence Rules
- **Branch Strategy**: Since Codex creates feature branches prefixed with `codex/`, always verify the current active branch and pull the latest changes before starting work.
- **Worktree Isolation**: Respect Codex's isolated worktrees (e.g., in `/Users/hexa/.codex/worktrees/`). Do not modify files in those paths unless explicitly instructed.
- **Database Consistency**: If schema or migration changes are made by Codex, regenerate the Prisma client using `pnpm db:generate` and run migrations with `pnpm db:migrate`.
- **State Synchronization**: Document all active changes, new ports, or configuration variables in `MEMORY.md` and `AGENTS.md` to ensure both Antigravity and Codex read the same single source of truth.

## VPS Database Rule

- UAT for the TFP stack uses PostgreSQL on the Contabo VPS, not a local developer database.
- Local operator scripts should reach the UAT database through an SSH tunnel to the VPS local Postgres listener (`127.0.0.1:5432` on the VPS), not through a developer-local fallback.
- Keep the app, collage worker, and image moderation worker pointed at the same VPS DB target so they can share the same state for moderation and collage generation.
- Use localhost only for local and development workflows unless a task explicitly asks for an isolated override.
