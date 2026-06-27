# Workspace-Wide Agent Notes

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-main-orchestator`.
- Main application workspace: `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers`.
- For domain-level routing in the app workspace, use `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/docs/agent-index.json` first.
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
- When creating or updating test scripts/flows, update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/README.md` in the same change so script usage stays discoverable.
- When changing browser seed assets/configs/commands, also update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/seed/README.md`.

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

## VPS vs OCI Rule

- Do not confuse the Contabo VPS with Oracle Cloud Infrastructure.
- Contabo VPS is the current UAT service host and deploy target for the checked-in `scripts/vps` flow.
- OCI is a separate Oracle Cloud account/tenancy used for Always Free Ampere A1 acquisition experiments and future ARM64 deployment planning.
- The root OCI helper is `scripts/oci/acquire-a1-free.sh`; it requests `VM.Standard.A1.Flex` at `2 OCPU / 12 GB RAM` and retries `Out of host capacity`.
- Current known OCI free-tier VM state from June 23, 2026:
  - `aip-mumbai-e2-micro-new`
  - public IP `140.245.30.133`
  - shape `VM.Standard.E2.1.Micro`
  - tagged `free-tier-retained=true`
- The OCI E2 micro is not the Contabo VPS and is not the public UAT service host.
- Never use `13.140.189.236` as an OCI host. That IP belongs to the Contabo VPS UAT target.

## UAT VPS and Deployment Target (Contabo)

- **UAT Host Details**:
  - **Display Name / Host**: `uat` (Contabo VPS 20)
  - **IP Address**: `13.140.189.236`
  - **Default User**: `root` (Option A: quick first deploy using root)
  - **Region**: `EU`
  - **SSH Access**: Key-based (`id_ed25519` from Mac client, added to `/root/.ssh/authorized_keys`)
- **UAT Service Ports and URLs**:
  - **Image Moderation public port**: `7001` (proxies to local app port `7002`)
    - URL: `http://13.140.189.236:7001`
  - **Collage public port**: `7003` (proxies to local app port `7004`)
    - URL: `http://13.140.189.236:7003`
  - **Private app ports**: `7002` and `7004` (not exposed publicly)

## VPS Folder Moderation Audit And Reviewer Flow

- Canonical local-to-VPS launcher: `tfpphotographers/scripts/vps/run-folder-moderation.sh`.
- VPS working directory: `/srv/tfp-folder-moderation/tfpphotographers`.
- VPS image drop/source directory: `/srv/tfp-folder-moderation/images`.
- VPS report directory: `/srv/tfp-folder-moderation/reports`.
- The launcher targets the Contabo VPS (`13.140.189.236`) and the moderation endpoint at `http://127.0.0.1:7001` from the VPS. Do not route this flow to OCI.
- If `MODERATION_REMOTE_AUTH_TOKEN` is not explicitly set, the launcher should load it from `/etc/systemd/system/tfp-image-moderation-service.service` via `AIP__SECURITY__INTERNAL_API_KEY`. A run where every row is `401 unauthorized` means this auth token was missing or wrong; stop the run and fix auth before retrying.
- Final downloadable audit JSON must preserve full `rawEnvelope` and `providerRawResponse` fields for policy debugging. The final writer streams large JSON files row-by-row; do not replace it with a single full `JSON.stringify(...)`, which can fail with `Invalid string length` on large raw payloads.
- Partial checkpoints and isolated reviewer chunks intentionally strip `rawEnvelope` and `providerRawResponse` to keep review pages small and loadable. Do not use those compact artifacts to judge whether the model/provider returned all policy fields.
- Local download flow should copy the VPS raw artifact first as `folder-moderation-audit-v1-vps-raw-<stamp>.json`, then create any local path-rewritten/review variants separately.
- Review page generation is intentionally separate from raw audit preservation. `build-folder-moderation-reviewers.sh` and `build-isolated-reviewer-route.ts` create compact reviewer artifacts/pages; they are not the canonical raw evidence source.
