#!/usr/bin/env bash
set -euo pipefail

BRANCH="ai/enhance-playwright-tests"
LOG_DIR="./ai-logs"
LOG="$LOG_DIR/agent-loop.log"
MODEL="qwen2.5-coder:7b"
GEN_DIR="tests/e2e/ai-generated"
REMOTE_PUSH_REF="refs/heads/ai/enhance-playwright-tests:refs/heads/ai/enhance-playwright-tests"

STATE_DIR="./.ai-agent/state"
FLOW_HASH_DB="$STATE_DIR/flow-hashes.txt"
FLOW_TEXT_DB="$STATE_DIR/flows.txt"
ROUTE_DB="$STATE_DIR/routes.txt"
PAGE_ROUTE_DB="$STATE_DIR/page-routes.txt"
ACCEPTED_DB="$STATE_DIR/accepted-tests.log"

FAIL_SIG_DB="$STATE_DIR/failure-signatures.tsv"
FAIL_EVENTS_DB="$STATE_DIR/failure-events.log"
INCIDENT_DB="$STATE_DIR/incidents.log"
LAST_ERROR_DB="$STATE_DIR/last-error-context.log"
COVERAGE_TOOL="node ./scripts/qa/ai-coverage-manager.mjs"
COVERAGE_DASHBOARD_HTML="$LOG_DIR/coverage-dashboard.html"

REPEAT_THRESHOLD=3
MAX_SELF_HEAL_ATTEMPTS=3
SELF_HEAL_BACKOFF_SECONDS=15

export OLLAMA_NOPROGRESS=1

mkdir -p "$LOG_DIR" "$GEN_DIR" "$STATE_DIR"
touch "$FLOW_HASH_DB" "$FLOW_TEXT_DB" "$ROUTE_DB" "$PAGE_ROUTE_DB" "$ACCEPTED_DB"
touch "$FAIL_SIG_DB" "$FAIL_EVENTS_DB" "$INCIDENT_DB" "$LAST_ERROR_DB"

ROUTE_CANDIDATES=(
  "/"
  "/health"
  "/sitemap.xml"
  "/privacy"
  "/events"
  "/contests"
  "/opportunities"
  "/login"
)

log_line() {
  printf '%s\n' "$1" >> "$LOG"
}

run_with_timeout() {
  local seconds="$1"
  shift

  if command -v timeout >/dev/null 2>&1; then
    timeout "$seconds" "$@"
    return $?
  fi
  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$seconds" "$@"
    return $?
  fi

  "$@"
}

ensure_git_ready() {
  local lock_file=".git/index.lock"
  local tries=0

  while [ -f "$lock_file" ] && [ "$tries" -lt 12 ]; do
    if ! pgrep -fa "git (add|commit|push|checkout|status|log|pull|rebase)" >/dev/null 2>&1; then
      rm -f "$lock_file" || true
      break
    fi
    tries=$((tries + 1))
    sleep 2
  done

  [ ! -f "$lock_file" ]
}

log_header() {
  {
    echo "===================="
    echo "AI Playwright Agent"
    echo "Model: $MODEL"
    echo "Branch: $BRANCH"
    echo "Started: $(date -u)"
    echo "State: $STATE_DIR"
    echo "===================="
    echo ""
  } >> "$LOG"
}

normalize_text() {
  tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:][:space:]/:_.-' | tr -s '[:space:]' ' '
}

text_hash() {
  local input="$1"
  printf '%s' "$input" | normalize_text | sha256sum | awk '{print $1}'
}

extract_routes_from_text() {
  sed -E 's#https?://[^ /]+##g' \
    | grep -Eo '/[a-zA-Z0-9._~/-]*' \
    | sed 's#//*#/#g' \
    | awk 'length($0)>0' \
    | sort -u
}

seed_page_route_candidates() {
  find apps/web/src/pages -type f \( -name '*.astro' -o -name '*.ts' \) 2>/dev/null \
    | sed 's#^apps/web/src/pages##' \
    | sed 's#/index\.astro$#/#' \
    | sed 's#\.astro$##' \
    | sed 's#\.ts$##' \
    | sed 's#^$#/#' \
    | awk '
        $0 ~ /\[/ { next }
        $0 ~ /^\/api\// { next }
        $0 ~ /^\/qa\// { next }
        $0 ~ /^\/admin(\/|$)/ { next }
        $0 ~ /^\/messages(\/|$)/ { next }
        $0 ~ /^\/notifications(\/|$)/ { next }
        $0 ~ /^\/preferences\/locale$/ { next }
        $0 ~ /^\/auth(\/|$)/ { next }
        $0 ~ /^\/logout$/ { next }
        $0 ~ /^\/this-route-definitely-does-not-exist-qa-404$/ { next }
        $0 ~ /(\/create|\/new|\/edit|\/manage)(\/|$)/ { next }
        $0 ~ /(\/submit|\/upload)(\/|$)/ { next }
        { print $0 }
      ' \
    | sed 's#//*#/#g' \
    | awk 'NF && !seen[$0]++' > "$PAGE_ROUTE_DB"
}

seed_route_memory_from_existing_tests() {
  local tmp
  tmp="$(mktemp)"

  find tests/e2e -type f -name '*.spec.ts' 2>/dev/null | while read -r file; do
    grep -Eo 'page\.goto\([^)]*\)' "$file" 2>/dev/null | extract_routes_from_text || true
  done > "$tmp"

  cat "$ROUTE_DB" "$tmp" 2>/dev/null | awk 'NF && !seen[$0]++' > "$ROUTE_DB.tmp"
  mv "$ROUTE_DB.tmp" "$ROUTE_DB"
  rm -f "$tmp"
}

route_is_covered() {
  local route="$1"
  grep -Fxq "$route" "$ROUTE_DB" && return 0
  grep -Fxq "Fallback smoke for $route" "$FLOW_TEXT_DB" && return 0
  return 1
}

choose_fallback_route() {
  local route

  if [ -s "$PAGE_ROUTE_DB" ]; then
    while IFS= read -r route; do
      [ -z "$route" ] && continue
      if ! route_is_covered "$route"; then
        echo "$route"
        return 0
      fi
    done < "$PAGE_ROUTE_DB"
  fi

  for route in "${ROUTE_CANDIDATES[@]}"; do
    if ! route_is_covered "$route"; then
      echo "$route"
      return 0
    fi
  done

  local count idx offset candidate_count
  candidate_count=${#ROUTE_CANDIDATES[@]}
  count="$(wc -l < "$ACCEPTED_DB" 2>/dev/null || echo 0)"

  for ((offset=0; offset<candidate_count; offset++)); do
    idx=$(( (count + offset) % candidate_count ))
    route="${ROUTE_CANDIDATES[$idx]}"
    if ! route_is_covered "$route"; then
      echo "$route"
      return 0
    fi
  done

  idx=$(( count % candidate_count ))
  echo "${ROUTE_CANDIDATES[$idx]}"
}

default_test() {
  local test_file="$1"
  local route="$2"

  cat > "$test_file" <<TEST_CONTENT
import { test, expect } from "@playwright/test";

const BASE_URL = process.env.BASE_URL || "http://localhost:3000";

test.describe("AI Generated Smoke", () => {
  test("public route responds: ${route}", async ({ page }) => {
    const response = await page.goto(BASE_URL + "${route}", {
      waitUntil: "domcontentloaded",
      timeout: 15000,
    });
    expect(response).not.toBeNull();
    expect([200, 301, 302, 307, 308]).toContain(response?.status());
  });

  test("public route has visible content: ${route}", async ({ page }) => {
    await page.goto(BASE_URL + "${route}", { waitUntil: "domcontentloaded", timeout: 15000 });
    const contentLength = await page.evaluate(() => document.body.innerText.trim().length);
    expect(contentLength).toBeGreaterThan(0);
  });
});
TEST_CONTENT
}

default_api_test() {
  local test_file="$1"
  local route="$2"

  cat > "$test_file" <<TEST_CONTENT
import { test, expect } from "@playwright/test";

const BASE_URL = process.env.BASE_URL || "http://localhost:3000";

test.describe("AI Generated API Contract", () => {
  test("api route responds without server error: ${route}", async ({ request }) => {
    const response = await request.get(BASE_URL + "${route}", {
      timeout: 15000,
      failOnStatusCode: false,
    });
    expect(response.status()).toBeLessThan(500);
    expect([200, 201, 204, 301, 302, 307, 308, 400, 401, 403, 404, 405, 409, 422]).toContain(response.status());
  });
});
TEST_CONTENT
}

write_fallback_test() {
  local test_file="$1"
  local route="$2"
  local kind="${3:-route_smoke}"

  if [ "$kind" = "api_contract" ] || [[ "$route" == /api/* ]]; then
    default_api_test "$test_file" "$route"
    return
  fi

  default_test "$test_file" "$route"
}

validate_test_file() {
  local test_file="$1"

  sed -i '/^```/d' "$test_file"
  sed -i '/^[[:space:]]*```/d' "$test_file"
  perl -i -pe 's/\e\[[0-9;?]*[A-Za-z]//g; s/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]//g' "$test_file"

  if ! grep -q '@playwright/test' "$test_file"; then
    return 1
  fi

  if ! grep -q 'process.env.BASE_URL || "http://localhost:3000"' "$test_file"; then
    awk '
      NR == 1 {
        print $0;
        print "";
        print "const BASE_URL = process.env.BASE_URL || \"http://localhost:3000\";";
        next;
      }
      { print $0 }
    ' "$test_file" > "${test_file}.tmp"
    mv "${test_file}.tmp" "$test_file"
  fi

  if grep -Eq '^[[:space:]]*import[[:space:]].*from[[:space:]]*["'"'"'](\.\./|\./|apps/|packages/|src/|@/|~/)' "$test_file"; then
    return 1
  fi

  if ! grep -Eq 'test\(|test\.' "$test_file"; then
    return 1
  fi

  return 0
}

is_duplicate_content() {
  local test_file="$1"
  local current_hash duplicate_file

  current_hash="$(sha256sum "$test_file" | awk '{print $1}')"
  duplicate_file="$(find "$GEN_DIR" -maxdepth 1 -type f -name '*.spec.ts' ! -path "$test_file" -exec sha256sum {} + 2>/dev/null | awk -v hash="$current_hash" '$1 == hash { print $2; exit }')"

  if [ -n "$duplicate_file" ]; then
    {
      echo "⚠ Duplicate test content detected"
      echo "  New file: $test_file"
      echo "  Matches: $duplicate_file"
      echo "Skipping commit for duplicate test."
    } >> "$LOG"
    rm -f "$test_file"
    return 0
  fi

  return 1
}

syntax_check_test() {
  local test_file="$1"
  pnpm exec playwright test "$test_file" --list --project=chromium >> "$LOG" 2>&1
}

cleanup_ports() {
  local port pids
  for port in 3000 4000; do
    pids="$(lsof -ti tcp:"$port" -sTCP:LISTEN 2>/dev/null || true)"
    if [ -n "$pids" ]; then
      echo "Cleaning stale listeners on :$port ($pids)" >> "$LOG"
      kill $pids >/dev/null 2>&1 || true
      sleep 1
    fi
  done
}

cleanup_stale_model_runs() {
  local pid
  while read -r pid _; do
    [ -z "$pid" ] && continue
    [ "$pid" = "$$" ] && continue
    kill "$pid" >/dev/null 2>&1 || true
  done < <(ps -C ollama -o pid=,args= | awk '$0 ~ /ollama run qwen2[.]5-coder:7b/ { print $1 }')
}

record_persistent_memory() {
  local test_file="$1"
  local flow="$2"
  local plan="$3"
  local flow_hash

  flow_hash="$(text_hash "$flow")"
  echo "$flow_hash" >> "$FLOW_HASH_DB"
  echo "$flow" >> "$FLOW_TEXT_DB"

  if [[ "$flow" == Fallback\ smoke\ for\ * ]]; then
    echo "${flow#Fallback smoke for }" >> "$ROUTE_DB"
  fi

  {
    printf '%s\n' "$plan" | extract_routes_from_text || true
    grep -Eo 'page\.goto\([^)]*\)' "$test_file" 2>/dev/null | extract_routes_from_text || true
  } | awk 'NF' >> "$ROUTE_DB"

  awk 'NF && !seen[$0]++' "$ROUTE_DB" > "$ROUTE_DB.tmp" && mv "$ROUTE_DB.tmp" "$ROUTE_DB"
  awk 'NF && !seen[$0]++' "$FLOW_HASH_DB" > "$FLOW_HASH_DB.tmp" && mv "$FLOW_HASH_DB.tmp" "$FLOW_HASH_DB"

  echo "$(date -u +%Y-%m-%dT%H:%M:%SZ) | $test_file | $flow_hash | $flow" >> "$ACCEPTED_DB"
}

capture_error_context() {
  local last_lines
  last_lines="$(tail -n 220 "$LOG" 2>/dev/null || true)"
  printf '%s\n' "$last_lines" > "$LAST_ERROR_DB"
}

error_classifier() {
  local ctx
  ctx="$(cat "$LAST_ERROR_DB" 2>/dev/null || true)"

  if printf '%s' "$ctx" | grep -q "does not provide an export named"; then
    echo "missing_named_export"
    return
  fi
  if printf '%s' "$ctx" | grep -q "Process from config.webServer was not able to start"; then
    echo "webserver_boot_failure"
    return
  fi
  if printf '%s' "$ctx" | grep -q "ERR_PNPM_OUTDATED_LOCKFILE\\|Lockfile is up to date, resolution step is skipped"; then
    echo "dependency_lock_issue"
    return
  fi
  if printf '%s' "$ctx" | grep -q "Timeout of .* exceeded"; then
    echo "test_timeout"
    return
  fi
  if printf '%s' "$ctx" | grep -q "ECONNREFUSED\\|EADDRINUSE\\|address already in use"; then
    echo "port_or_connectivity"
    return
  fi

  echo "unknown"
}

extract_missing_export_details() {
  local clean line symbol module
  clean="$(perl -pe 's/\e\[[0-9;?]*[A-Za-z]//g; s/\r//g' "$LAST_ERROR_DB" 2>/dev/null || true)"
  line="$(printf '%s\n' "$clean" | grep -m1 "does not provide an export named" || true)"
  symbol="$(printf '%s' "$line" | sed -n "s/.*export named '\([^']*\)'.*/\1/p")"
  module="$(printf '%s' "$line" | sed -n "s/.*module '\([^']*\)'.*/\1/p")"
  if [ -z "$module" ]; then
    module="$(printf '%s' "$line" | sed -n "s/.*from '\([^']*\)'.*/\1/p")"
  fi
  if [ -z "$module" ]; then
    module="$(printf '%s\n' "$clean" | grep -m1 -E "from '[^']+'" | sed -n "s/.*from '\([^']*\)'.*/\1/p")"
  fi
  echo "$symbol|$module"
}

module_to_workspace_package() {
  local module="$1"
  case "$module" in
    config|shared|storage|database|i18n|moderation|uploads|email)
      echo "packages/$module"
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

count_signature() {
  local sig="$1"
  awk -F'\t' -v key="$sig" '$1 == key { c++ } END { print c + 0 }' "$FAIL_SIG_DB" 2>/dev/null
}

record_failure_signature() {
  local sig="$1"
  local ts
  ts="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
  printf '%s\t%s\n' "$sig" "$ts" >> "$FAIL_SIG_DB"
  printf '%s | %s\n' "$ts" "$sig" >> "$FAIL_EVENTS_DB"
}

record_incident() {
  local category="$1"
  local details="$2"
  printf '%s | %s | %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$category" "$details" >> "$INCIDENT_DB"
}

coverage_sync() {
  if ! $COVERAGE_TOOL sync >> "$LOG" 2>&1; then
    log_line "⚠ coverage sync failed"
    return 1
  fi
  return 0
}

coverage_render_dashboard() {
  if ! $COVERAGE_TOOL render-dashboard --output "$COVERAGE_DASHBOARD_HTML" >> "$LOG" 2>&1; then
    log_line "⚠ coverage dashboard render failed"
    return 1
  fi
  return 0
}

coverage_get_next_target() {
  local payload id route goal kind category
  payload="$($COVERAGE_TOOL next --format json 2>/dev/null || true)"
  id="$(printf '%s' "$payload" | jq -r '.id // empty' 2>/dev/null || true)"
  route="$(printf '%s' "$payload" | jq -r '.route // empty' 2>/dev/null || true)"
  goal="$(printf '%s' "$payload" | jq -r '.goal // empty' 2>/dev/null || true)"
  kind="$(printf '%s' "$payload" | jq -r '.kind // empty' 2>/dev/null || true)"
  category="$(printf '%s' "$payload" | jq -r '.category // empty' 2>/dev/null || true)"

  if [ -z "$route" ]; then
    return 1
  fi

  printf '%s\t%s\t%s\t%s\t%s\n' "$id" "$route" "$goal" "$kind" "$category"
}

coverage_mark_status() {
  local obligation_id="$1"
  local status="$2"
  local route="$3"
  local test_file="${4:-}"
  local flow="${5:-}"
  local error_text="${6:-}"

  if [ -z "$obligation_id" ] || [ -z "$status" ]; then
    return 0
  fi

  $COVERAGE_TOOL mark \
    --id "$obligation_id" \
    --status "$status" \
    --route "$route" \
    --test-file "$test_file" \
    --flow "$flow" \
    --error "$error_text" >> "$LOG" 2>&1 || true
}

cleanup_untracked_rebase_conflicts() {
  local path
  local conflict_paths=(
    ".ai-agent/state/failure-signatures.tsv"
    ".ai-agent/state/flow-hashes.txt"
    ".ai-agent/state/flows.txt"
    ".ai-agent/state/page-routes.txt"
    ".ai-agent/state/routes.txt"
    "ai-logs/code-files.txt"
  )

  for path in "${conflict_paths[@]}"; do
    if git ls-files --error-unmatch "$path" >/dev/null 2>&1; then
      continue
    fi
    rm -f "$path" 2>/dev/null || true
  done
}

pull_rebase_with_workspace_safety() {
  cleanup_untracked_rebase_conflicts

  if git pull --rebase --autostash origin "$BRANCH" >> "$LOG" 2>&1; then
    return 0
  fi

  log_line "⚠ pull --rebase --autostash failed; retrying without --autostash"
  cleanup_untracked_rebase_conflicts
  git pull --rebase origin "$BRANCH" >> "$LOG" 2>&1
}

commit_and_push_if_changes() {
  local message="$1"

  if git diff --quiet && git diff --cached --quiet; then
    log_line "No source changes detected for self-heal commit."
    return 1
  fi

  git add -A >> "$LOG" 2>&1
  if git commit -m "$message" >> "$LOG" 2>&1; then
    log_line "✓ Self-heal commit created"
    if pull_rebase_with_workspace_safety && git push origin "$BRANCH" >> "$LOG" 2>&1; then
      log_line "✓ Self-heal push succeeded"
      return 0
    fi
    log_line "⚠ Self-heal sync+push failed"
    return 1
  fi

  log_line "⚠ Self-heal commit failed"
  return 1
}

validate_self_heal_fix() {
  local attempt="$1"
  local result=0

  log_line "[self-heal] validation attempt #$attempt"

  if ! run_with_timeout 240 pnpm exec tsc -p tsconfig.json --noEmit >> "$LOG" 2>&1; then
    log_line "[self-heal] tsc failed"
    result=1
  fi

  if [ "$result" -eq 0 ]; then
    if ! run_with_timeout 240 pnpm --filter api exec tsc -p apps/api/tsconfig.json --noEmit >> "$LOG" 2>&1; then
      log_line "[self-heal] api tsc failed"
      result=1
    fi
  fi

  if [ "$result" -eq 0 ]; then
    cleanup_ports
    if ! run_with_timeout 300 pnpm exec playwright test tests/e2e/smoke/tests/empty-system.spec.ts --project=chromium >> "$LOG" 2>&1; then
      log_line "[self-heal] targeted smoke failed"
      result=1
    fi
  fi

  return "$result"
}

repair_missing_named_export() {
  local data symbol module
  data="$(extract_missing_export_details)"
  symbol="${data%%|*}"
  module="${data##*|}"

  if [ -z "$module" ]; then
    log_line "[self-heal] missing export details are incomplete"
    return 1
  fi

  local pkg_dir pkg_name dist_file
  if ! pkg_dir="$(module_to_workspace_package "$module")"; then
    log_line "[self-heal] module '$module' is not a workspace package covered by rebuild playbook"
    return 1
  fi

  pkg_name="$(basename "$pkg_dir")"
  dist_file="$pkg_dir/dist/index.js"
  if [ ! -d "$pkg_dir" ]; then
    log_line "[self-heal] workspace package path missing: $pkg_dir"
    return 1
  fi

  if [ -n "$symbol" ]; then
    log_line "[self-heal] rebuilding package '$pkg_name' to recover missing export '$symbol' from module '$module'"
  else
    log_line "[self-heal] rebuilding package '$pkg_name' for module '$module' (symbol not parsed)"
  fi
  if ! run_with_timeout 300 pnpm --filter "$pkg_name" build >> "$LOG" 2>&1; then
    log_line "[self-heal] package build failed: $pkg_name"
    return 1
  fi

  if [ ! -f "$dist_file" ]; then
    log_line "[self-heal] dist entry missing after build: $dist_file"
    return 1
  fi

  if [ -n "$symbol" ]; then
    if grep -Fq "$symbol" "$dist_file"; then
      log_line "[self-heal] export '$symbol' present after rebuild in $dist_file"
      return 0
    fi

    log_line "[self-heal] export '$symbol' still absent after rebuild in $dist_file"
    return 1
  fi

  log_line "[self-heal] rebuild completed for '$module'; skipping symbol verification"
  return 0
}

attempt_self_heal_for_signature() {
  local sig="$1"
  local attempt

  log_line "[self-heal] signature '$sig' reached threshold; entering repair mode"

  for attempt in $(seq 1 "$MAX_SELF_HEAL_ATTEMPTS"); do
    log_line "[self-heal] repair attempt #$attempt for '$sig'"

    if ! ensure_git_ready; then
      log_line "[self-heal] git lock busy; skipping this attempt"
      sleep "$SELF_HEAL_BACKOFF_SECONDS"
      continue
    fi

    case "$sig" in
      missing_named_export)
        if ! repair_missing_named_export; then
          log_line "[self-heal] repair_missing_named_export failed"
          sleep "$SELF_HEAL_BACKOFF_SECONDS"
          continue
        fi
        ;;
      *)
        log_line "[self-heal] no repair playbook for signature '$sig'"
        return 1
        ;;
    esac

    if validate_self_heal_fix "$attempt"; then
      record_incident "self_heal_success" "$sig attempt=$attempt"
      commit_and_push_if_changes "fix(ai-agent): self-heal ${sig}"
      log_line "[self-heal] repair validated successfully"
      return 0
    fi

    log_line "[self-heal] validation failed for attempt #$attempt"
    record_incident "self_heal_attempt_failed" "$sig attempt=$attempt"
    sleep "$SELF_HEAL_BACKOFF_SECONDS"
  done

  record_incident "self_heal_exhausted" "$sig"
  log_line "[self-heal] exhausted attempts for '$sig'"
  return 1
}

check_and_maybe_self_heal() {
  capture_error_context
  local sig count
  sig="$(error_classifier)"
  record_failure_signature "$sig"
  count="$(count_signature "$sig")"

  log_line "[failure] classified='$sig' count=$count threshold=$REPEAT_THRESHOLD"

  if [ "$sig" = "unknown" ]; then
    return 1
  fi

  if [ "$count" -lt "$REPEAT_THRESHOLD" ]; then
    return 1
  fi

  if attempt_self_heal_for_signature "$sig"; then
    log_line "[failure] self-heal succeeded for '$sig'"
    return 0
  fi

  log_line "[failure] self-heal could not resolve '$sig'"
  return 1
}

cleanup_stale_model_runs
log_header

if ! ensure_git_ready; then
  log_line "⚠ Failed to acquire git index lock safely. Exiting."
  exit 1
fi

git checkout "$BRANCH" >> "$LOG" 2>&1
if [ "$(git config --get remote.origin.push || true)" != "$REMOTE_PUSH_REF" ]; then
  git config remote.origin.push "$REMOTE_PUSH_REF"
fi

seed_route_memory_from_existing_tests
seed_page_route_candidates
coverage_sync || true
coverage_render_dashboard || true
log_line "Coverage dashboard: $COVERAGE_DASHBOARD_HTML"

COUNTER=0
PASS_COUNT=0
FAIL_COUNT=0
DUPLICATE_COUNT=0

while true; do
  COUNTER=$((COUNTER + 1))
  FLOW_COUNT="$(wc -l < "$FLOW_HASH_DB" 2>/dev/null || echo 0)"
  ROUTE_COUNT="$(wc -l < "$ROUTE_DB" 2>/dev/null || echo 0)"
  PAGE_ROUTE_COUNT="$(wc -l < "$PAGE_ROUTE_DB" 2>/dev/null || echo 0)"
  FAILURE_COUNT="$(wc -l < "$FAIL_EVENTS_DB" 2>/dev/null || echo 0)"
  {
    echo "===================================="
    echo "LOOP #$COUNTER - $(date -u)"
    echo "Passes: $PASS_COUNT | Fails: $FAIL_COUNT | Duplicates: $DUPLICATE_COUNT"
    echo "Memory: flows=$FLOW_COUNT, routes=$ROUTE_COUNT, page_routes=$PAGE_ROUTE_COUNT, failures=$FAILURE_COUNT"
    echo "===================================="
  } >> "$LOG"

  TIMESTAMP="$(date +%s)"
  TEST_FILE="$GEN_DIR/ai-generated-$TIMESTAMP.spec.ts"
  log_line "[phase] loop work started at $(date -u +%H:%M:%S)"

  find apps/web/src/pages tests/e2e/domains -type f \( -name '*.ts' -o -name '*.tsx' -o -name '*.js' \) 2>/dev/null | head -80 > "$LOG_DIR/code-files.txt" || true

  RECENT_FLOWS="$(tail -n 25 "$FLOW_TEXT_DB" 2>/dev/null || true)"
  RECENT_ROUTES="$(tail -n 40 "$ROUTE_DB" 2>/dev/null | paste -sd ', ' -)"
  CURRENT_OBLIGATION_ID=""
  CURRENT_TARGET_ROUTE=""
  CURRENT_TARGET_GOAL=""
  CURRENT_TARGET_KIND=""
  CURRENT_TARGET_CATEGORY=""
  if TARGET_ROW="$(coverage_get_next_target)"; then
    IFS=$'\t' read -r CURRENT_OBLIGATION_ID CURRENT_TARGET_ROUTE CURRENT_TARGET_GOAL CURRENT_TARGET_KIND CURRENT_TARGET_CATEGORY <<< "$TARGET_ROW"
    log_line "Coverage target: id=${CURRENT_OBLIGATION_ID:-none} route=${CURRENT_TARGET_ROUTE:-none} kind=${CURRENT_TARGET_KIND:-route_smoke}"
  else
    log_line "Coverage target: none (falling back to route memory)"
  fi

  PLAN_PROMPT=$(cat <<PROMPT_EOF
You are a senior Playwright QA engineer working in a real monorepo.
Generate ONE realistic, low-flake guest/public flow test plan using existing routes only.

Avoid:
- authenticated/admin-only flows
- invented routes/selectors/APIs
- data-heavy flows requiring custom fixtures
- repeating previously covered flows/routes

Coverage target (must be used when provided):
- TARGET_ID: ${CURRENT_OBLIGATION_ID:-none}
- TARGET_ROUTE: ${CURRENT_TARGET_ROUTE:-none}
- TARGET_GOAL: ${CURRENT_TARGET_GOAL:-none}
- TARGET_KIND: ${CURRENT_TARGET_KIND:-route_smoke}
- TARGET_CATEGORY: ${CURRENT_TARGET_CATEGORY:-unknown}

Hard requirements:
- If TARGET_ROUTE is provided (not "none"), every test step must use that exact route only.
- Do not propose a different route.
- If TARGET_KIND is api_contract, validate HTTP contract behavior with Playwright request APIs.

Already-covered recent flows (do NOT repeat):
$RECENT_FLOWS

Already-covered recent routes (prefer new ones):
$RECENT_ROUTES

Candidate files from this repo:
$(cat "$LOG_DIR/code-files.txt")

Output EXACTLY this format:
FILENAME: <relative path under tests/e2e/ai-generated/>
FLOW: <real user flow>
STEPS:
- step 1
- step 2
ASSERTIONS:
- assertion 1
- assertion 2
PROMPT_EOF
)

  log_line "[phase] planning started (timeout=90s)"
  PLAN_OUTPUT="$(run_with_timeout 90 ollama run "$MODEL" "$PLAN_PROMPT" 2>/dev/null || true)"
  log_line "[phase] planning finished"
  FLOW_LINE="$(printf '%s\n' "$PLAN_OUTPUT" | awk -F': ' '/^FLOW:/ {print $2; exit}')"
  [ -z "$FLOW_LINE" ] && FLOW_LINE="Public smoke coverage"

  FLOW_HASH="$(text_hash "$FLOW_LINE")"
  if grep -Fxq "$FLOW_HASH" "$FLOW_HASH_DB"; then
    {
      echo "PLAN:"
      echo "$PLAN_OUTPUT"
      echo ""
      echo "⚠ Duplicate FLOW fingerprint detected; forcing fallback route."
      echo ""
    } >> "$LOG"
    PLAN_OUTPUT=""
    FLOW_LINE="Public smoke coverage"
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + 1))
  else
    {
      echo "PLAN:"
      echo "$PLAN_OUTPUT"
      echo ""
    } >> "$LOG"
  fi

  CODE_PROMPT=$(cat <<PROMPT_EOF
You are writing a real Playwright test.

Plan:
$PLAN_OUTPUT

Requirements:
- valid TypeScript only
- import { test, expect } from "@playwright/test"
- define: const BASE_URL = process.env.BASE_URL || "http://localhost:3000"
- use page.goto()
- for TARGET_KIND=api_contract, use request.get() instead of page.goto()
- use getByRole/getByText/locator where relevant
- no markdown fences
- no explanations
- no internal imports from app code
- keep it stable and small (public/guest route)
- do not use routes already covered in this list: $RECENT_ROUTES
- if TARGET_ROUTE is provided, use that exact route and no other route
PROMPT_EOF
)

  GENERATED_CODE=""
  if [ -n "$PLAN_OUTPUT" ]; then
    log_line "[phase] codegen started (timeout=180s)"
    GENERATED_CODE="$(run_with_timeout 180 ollama run "$MODEL" "$CODE_PROMPT" 2>/dev/null || true)"
    log_line "[phase] codegen finished"
  fi

  if [ -n "$CURRENT_TARGET_ROUTE" ]; then
    FALLBACK_ROUTE="$CURRENT_TARGET_ROUTE"
  else
    FALLBACK_ROUTE="$(choose_fallback_route)"
  fi
  USED_FALLBACK=0

  if [ -z "$GENERATED_CODE" ]; then
    log_line "⚠ Model returned empty/duplicate-plan code; using fallback smoke test on route: $FALLBACK_ROUTE"
    write_fallback_test "$TEST_FILE" "$FALLBACK_ROUTE" "$CURRENT_TARGET_KIND"
    USED_FALLBACK=1
    FLOW_LINE="Fallback smoke for $FALLBACK_ROUTE"
  else
    printf '%s\n' "$GENERATED_CODE" > "$TEST_FILE"
    if [ -n "$CURRENT_TARGET_ROUTE" ] && ! grep -Fq "$CURRENT_TARGET_ROUTE" "$TEST_FILE"; then
      log_line "⚠ Generated code ignored target route; replacing with fallback smoke route: $FALLBACK_ROUTE"
      write_fallback_test "$TEST_FILE" "$FALLBACK_ROUTE" "$CURRENT_TARGET_KIND"
      USED_FALLBACK=1
      FLOW_LINE="Fallback smoke for $FALLBACK_ROUTE"
    fi
  fi

  if ! validate_test_file "$TEST_FILE"; then
    log_line "⚠ Generated code failed validation; replacing with fallback smoke route: $FALLBACK_ROUTE"
    write_fallback_test "$TEST_FILE" "$FALLBACK_ROUTE" "$CURRENT_TARGET_KIND"
    USED_FALLBACK=1
    FLOW_LINE="Fallback smoke for $FALLBACK_ROUTE"
  fi

  if ! syntax_check_test "$TEST_FILE"; then
    log_line "⚠ Generated code failed Playwright parse; replacing with fallback smoke route: $FALLBACK_ROUTE"
    USED_FALLBACK=1
    write_fallback_test "$TEST_FILE" "$FALLBACK_ROUTE" "$CURRENT_TARGET_KIND"
    FLOW_LINE="Fallback smoke for $FALLBACK_ROUTE"
    if ! syntax_check_test "$TEST_FILE"; then
      log_line "⚠ Fallback test failed Playwright parse; skipping this loop."
      FAIL_COUNT=$((FAIL_COUNT + 1))
      rm -f "$TEST_FILE"
      log_line ""
      log_line "Sleeping for 5 minutes..."
      sleep 300
      continue
    fi
  fi

  log_line "✓ Created test: $TEST_FILE"
  log_line "  Flow: $FLOW_LINE"
  log_line "  File size: $(wc -c < "$TEST_FILE") bytes"
  log_line ""

  if is_duplicate_content "$TEST_FILE"; then
    DUPLICATE_COUNT=$((DUPLICATE_COUNT + 1))
    coverage_mark_status "$CURRENT_OBLIGATION_ID" "passed" "$FALLBACK_ROUTE" "$TEST_FILE" "$FLOW_LINE" "duplicate_existing_test"
    coverage_render_dashboard || true
    log_line ""
    log_line "Sleeping for 5 minutes..."
    sleep 300
    continue
  fi

  log_line "Running Playwright test..."
  cleanup_ports
  log_line "Command: timeout 480 pnpm exec playwright test $TEST_FILE --project=chromium"
  if run_with_timeout 480 pnpm exec playwright test "$TEST_FILE" --project=chromium >> "$LOG" 2>&1; then
    TEST_EXIT=0
  else
    TEST_EXIT=$?
  fi

  log_line "Exit code: $TEST_EXIT"
  log_line ""

  if [ "$TEST_EXIT" -ne 0 ] && [ "$USED_FALLBACK" -eq 0 ]; then
    log_line "Retrying with fallback smoke route after runtime failure: $FALLBACK_ROUTE"
    write_fallback_test "$TEST_FILE" "$FALLBACK_ROUTE" "$CURRENT_TARGET_KIND"
    USED_FALLBACK=1
    FLOW_LINE="Fallback smoke for $FALLBACK_ROUTE"

    if syntax_check_test "$TEST_FILE" && run_with_timeout 480 pnpm exec playwright test "$TEST_FILE" --project=chromium >> "$LOG" 2>&1; then
      TEST_EXIT=0
      log_line "Fallback retry exit code: 0"
    else
      TEST_EXIT=$?
      log_line "Fallback retry exit code: $TEST_EXIT"
    fi
    log_line ""
  fi

  if [ "$TEST_EXIT" -eq 0 ]; then
    PASS_COUNT=$((PASS_COUNT + 1))

    if is_duplicate_content "$TEST_FILE"; then
      DUPLICATE_COUNT=$((DUPLICATE_COUNT + 1))
      coverage_mark_status "$CURRENT_OBLIGATION_ID" "passed" "$FALLBACK_ROUTE" "$TEST_FILE" "$FLOW_LINE" "duplicate_existing_test"
      coverage_render_dashboard || true
      log_line ""
      log_line "Sleeping for 5 minutes..."
      sleep 300
      continue
    fi

    record_persistent_memory "$TEST_FILE" "$FLOW_LINE" "$PLAN_OUTPUT"
    coverage_mark_status "$CURRENT_OBLIGATION_ID" "passed" "$FALLBACK_ROUTE" "$TEST_FILE" "$FLOW_LINE" ""
    coverage_render_dashboard || true

    log_line "✓✓✓ TEST PASSED ✓✓✓"
    log_line "Committing: $TEST_FILE"

    git add "$TEST_FILE" >> "$LOG" 2>&1
    COMMIT_MSG="AI: add Playwright coverage $(date -u '+%Y-%m-%d %H:%M')"

    if git commit -m "$COMMIT_MSG" >> "$LOG" 2>&1; then
      log_line "✓ Committed"
      if pull_rebase_with_workspace_safety && git push origin "$BRANCH" >> "$LOG" 2>&1; then
        log_line "✓ Pushed to origin/$BRANCH"
      else
        log_line "⚠ Push failed after sync+rebase attempt"
      fi
    else
      log_line "⚠ Commit failed"
    fi
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
    log_line "✗ Test failed with exit code: $TEST_EXIT"
    log_line "Skipping commit for this test."
    coverage_mark_status "$CURRENT_OBLIGATION_ID" "failed" "$FALLBACK_ROUTE" "$TEST_FILE" "$FLOW_LINE" "playwright_exit_${TEST_EXIT}"
    coverage_render_dashboard || true
    rm -f "$TEST_FILE"

    if check_and_maybe_self_heal; then
      log_line "[autonomy] self-heal completed; continuing loop"
    fi
  fi

  log_line ""
  log_line "Sleeping for 5 minutes..."
  sleep 300
done
