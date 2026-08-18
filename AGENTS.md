# Workspace-Wide Agent Notes

## Fast Orientation

- Read `RULES.md` for non-negotiable deployment and event-outbox safety rules.
- Read `MEMORY.md` for the current cross-repository architecture and runtime-evidence baseline.
- For product work, then read `tfpphotographers/docs/agent-index.json` and the nested repository `AGENTS.md`.
- The durable-event and release-gate guide is `tfpphotographers/docs/architecture/EVENT_OUTBOX_AND_DEPLOYMENT_READINESS.md`.
- The required pre-commit checks and validation flow is in `tfpphotographers/docs/operations/AGENT_DUE_DILIGENCE.md`.

## Scope
- Primary workspace root: `/Users/hexa/Desktop/tfp-main-orchestator`.
- Main application workspace: `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers`.
- For domain-level routing in the app workspace, use `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/docs/agent-index.json` first.
- If both root and nested workspaces changed, update and commit in both repositories.
- For cross-repo operator work, prefer the checked-in menu and runbook paths first:
  - `tfpphotographers/scripts/manage-tfp.sh`
  - `tfpphotographers/scripts/manage-tfp-mobile.sh`
  - `tfpphotographers/scripts/start-app.sh`
  - `tfpphotographers/tests/create-data/README.md`
  - `tfpphotographers/docs/operations/AGENT_RUNTIME_AND_SEED_GUIDE.md`
  - `tfpphotographers/docs/mobile/mobile-app-design-guide.md`
  - `tfpphotographers/docs/mobile/mobile-app-implementation-todo.md`

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
- **Mandatory Live Visual Verification**: Always run the application (web or mobile) and inspect impacted pages/screens either by computer use or by capturing and inspecting screenshots. Never guess, assume, or infer visual correctness from static checks or tests alone.
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
- Mobile currently keeps pure domain tests under `apps/mobile/src/**/__tests__` to keep Expo-facing rules close to the native implementation; if mobile component/E2E coverage expands, add app-local `apps/mobile/tests/**` and document the command here.
- When creating or updating test scripts/flows, update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/README.md` in the same change so script usage stays discoverable.
- When changing browser seed assets/configs/commands, also update `/Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/tests/create-data/README.md`.

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

## OCI UAT Database Rule

- UAT for the TFP stack uses PostgreSQL installed on the OCI UAT host, bound to `127.0.0.1:5432`; it does not use Contabo or a developer-local fallback.
- Local operator scripts that need direct database access must SSH-forward to the OCI host-local PostgreSQL listener through `ubuntu@161.118.161.98`.
- Keep the app, collage worker, and image moderation worker pointed at the same OCI host-local PostgreSQL database so they share moderation and collage state.
- Use localhost only for local and development workflows unless a task explicitly asks for an isolated override.

## Queue And Background Worker Audit Rule

- Do not flag the current PostgreSQL-backed queue/outbox model as a BullMQ/Redis migration requirement by default.
- The app intentionally uses database-backed job state for domain workflows where queue state must stay close to moderation, upload, report, opportunity, event, contest, and collage records.
- `event_outbox`, worker polling, retry fields, stale-processing recovery, and `FOR UPDATE SKIP LOCKED` are valid architectural choices in this workspace, not audit findings on their own.
- BullMQ/Redis should be recommended only when there is measured operational pain: backlog/latency under load, expensive DB polling, missing dead-letter/operator visibility that cannot be solved simply, many worker pools, complex delayed retries, or a real need for Bull Board-style queue operations.
- Prefer first improving the existing DB-backed model with health checks, backlog/failure queries, terminal failed/dead-letter states, indexes, stale-job recovery, and operator docs before proposing a queue migration.
- When comparing queue options, treat PostgreSQL consistency and inspectability as strengths for this product, especially because UAT services share one OCI PostgreSQL state source.

## OCI vs Retired Contabo Rule

- OCI is the current and only UAT deployment target. Use root `scripts/oci/*` for full-stack UAT orchestration and service-local `scripts/deploy/*` for each deployable.
- The active host is the Always Free Ampere instance `tfp-a1-free-2ocpu-12gb` at `161.118.161.98`, shape `VM.Standard.A1.Flex`, with `2 OCPU / 12 GB RAM` in `ap-mumbai-1`.
- The older OCI E2 micro `aip-mumbai-e2-micro-new` at `140.245.30.133` is retained separately and is not the UAT deployment target.
- Contabo `13.140.189.236` is retired from UAT. Do not deploy, tunnel, seed, moderate, or run database operations against it unless the user explicitly authorizes a historical incident/recovery task.
- The acquisition helper `scripts/oci/acquire-a1-free.sh` remains available for capacity management; it is not the deployment entrypoint.

## UAT Deployment Target (OCI Always Free)

- **Environment boundary**: This host is for private UAT only. The TFP product
  has not been launched publicly from this instance; nevertheless, apply the same
  host-security baseline expected of an internet-reachable production host.
- **UAT Host Details**:
  - **Display Name**: `tfp-a1-free-2ocpu-12gb`
  - **Public IPv4**: `161.118.161.98`
  - **Private IPv4**: `10.0.1.114`
  - **Shape**: `VM.Standard.A1.Flex` (`2 OCPU / 12 GB RAM`, ARM64)
  - **Region / AD**: `ap-mumbai-1` / `lqoG:AP-MUMBAI-1-AD-1`
  - **OS / SSH user**: Ubuntu ARM64 / `ubuntu`
  - **Public tester URL**: `https://uat.tfpphotographers.com`
  - **Cloudflare tunnel**: `tfp-oci-uat` -> `http://localhost:8080`
- **Private service listeners**: PostgreSQL `5432`, API `4000`, web `8080`, AI inference `7011`, and collage `7003/7004` bind only to `127.0.0.1`. There is no V1 moderation runtime.
- **Public ingress**: application ports are closed at OCI and the host firewall. Only key-based administrative SSH is retained; tester traffic must pass Cloudflare Access and Tunnel.
- **SSH network boundary**:
  - Treat the August 2026 `SSH_BRUTE_FORCE` report as alleged outbound traffic
    from the retired Contabo VPS; the root cause remains unproven until host and
    provider logs can be correlated. It is historical context, not OCI evidence.
  - Deny new outbound connections to public TCP port `22` by default before
    restoring general network access. Allow only explicitly reviewed destination
    addresses when a real deployment dependency requires SSH; prefer HTTPS over
    port `443` where possible.
  - Do not implement this as a blanket two-way port-22 closure. Administrative
    inbound SSH remains a separate control and must be key-only, restricted to
    trusted operator sources or a private access path, use an unprivileged
    deployment account, and disable direct root login after recovery/bootstrap.
  - On reactivation or migration, preserve evidence first, inspect auth and
    process persistence, rotate credentials and application secrets, and rebuild
    from a trusted image if compromise cannot be excluded.

## Folder Moderation Boundary

- Folder moderation is not deployed to OCI UAT. `/srv/tfp-folder-moderation` must remain absent, and no images, raw reports, reviewer chunks, or generated folder-audit artifacts may be transferred by normal UAT deployment.
- No folder-moderation launcher exists in the active repositories. Reintroducing one requires explicit, separately scoped authorization.
- If folder moderation is reintroduced later, it needs a new private-storage design and a dedicated runbook; do not silently point the legacy wrapper at OCI.
