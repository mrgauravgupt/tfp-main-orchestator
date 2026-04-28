#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const ROOT = process.cwd();
const COVERAGE_DIR = path.resolve(ROOT, process.env.AI_COVERAGE_OUTPUT_DIR || 'tests/ai-coverage');
const STATE_DIR = path.join(ROOT, '.ai-agent', 'state');
const COVERAGE_DASHBOARD_DIR = path.join(STATE_DIR, 'coverage-dashboard');

const ROUTE_INVENTORY_PATH = path.join(COVERAGE_DIR, 'route-inventory.json');
const API_INVENTORY_PATH = path.join(COVERAGE_DIR, 'api-inventory.json');
const COMPONENT_INVENTORY_PATH = path.join(COVERAGE_DIR, 'component-inventory.json');
const COVERAGE_MATRIX_JSON_PATH = path.join(COVERAGE_DIR, 'coverage-matrix.json');
const COVERAGE_MATRIX_YAML_PATH = path.join(COVERAGE_DIR, 'coverage-matrix.yaml');
const RISK_PRIORITY_YAML_PATH = path.join(COVERAGE_DIR, 'risk-priority.yaml');
const TESTS_MD_PATH = path.join(COVERAGE_DIR, 'tests.md');
const DASHBOARD_DATA_PATH = path.join(COVERAGE_DASHBOARD_DIR, 'dashboard-data.json');
const COVERAGE_STATE_PATH = path.join(STATE_DIR, 'coverage-state.json');

const PRIORITY_ORDER = new Map([
  ['P0', 0],
  ['P1', 1],
  ['P2', 2],
  ['P3', 3],
]);

const PUBLIC_BLOCKLIST_EXACT = new Set([
  '/preferences/locale',
  '/this-route-definitely-does-not-exist-qa-404',
  '/logout',
]);

const PUBLIC_BLOCKLIST_PREFIX = [
  '/api/',
  '/qa/',
  '/admin',
  '/messages',
  '/notifications',
  '/auth/',
];

const PUBLIC_BLOCKLIST_SEGMENTS = ['create', 'new', 'edit', 'manage', 'submit', 'upload'];

function ensureDir(dirPath) {
  fs.mkdirSync(dirPath, { recursive: true });
}

function readJson(filePath, fallback) {
  try {
    return JSON.parse(fs.readFileSync(filePath, 'utf8'));
  } catch {
    return fallback;
  }
}

function writeJson(filePath, value) {
  fs.writeFileSync(filePath, `${JSON.stringify(value, null, 2)}\n`, 'utf8');
}

function listFilesRecursively(dirPath) {
  if (!fs.existsSync(dirPath)) return [];
  const results = [];
  const entries = fs.readdirSync(dirPath, { withFileTypes: true });
  for (const entry of entries) {
    const abs = path.join(dirPath, entry.name);
    if (entry.isDirectory()) {
      results.push(...listFilesRecursively(abs));
      continue;
    }
    results.push(abs);
  }
  return results;
}

function normalizeSlashes(input) {
  return input.replace(/\\/g, '/');
}

function routeFromPageFile(relativeFile) {
  const rel = normalizeSlashes(relativeFile);
  if (!rel.endsWith('.astro') && !rel.endsWith('.ts')) return null;
  if (rel.endsWith('.d.ts')) return null;

  let withoutExt = rel;
  if (rel.endsWith('.astro')) withoutExt = rel.slice(0, -'.astro'.length);
  if (rel.endsWith('.ts')) withoutExt = rel.slice(0, -'.ts'.length);
  if (withoutExt === 'index') return '/';
  if (withoutExt.endsWith('/index')) withoutExt = withoutExt.slice(0, -'/index'.length);
  if (!withoutExt) return '/';
  return `/${withoutExt}`.replace(/\/{2,}/g, '/');
}

function hasDynamicSegment(route) {
  return route.includes('[') || route.includes(']');
}

function sanitizeId(input) {
  return input.replace(/[^a-zA-Z0-9]+/g, '_').replace(/^_+|_+$/g, '').toLowerCase() || 'root';
}

function obligationIdForRoute(route) {
  return `route_smoke__${sanitizeId(route)}`;
}

function isLikelyPublicSmokeRoute(route) {
  if (!route || hasDynamicSegment(route)) return false;
  if (PUBLIC_BLOCKLIST_EXACT.has(route)) return false;
  if (PUBLIC_BLOCKLIST_PREFIX.some((prefix) => route.startsWith(prefix))) return false;
  if (/^\/auth(\/|$)/.test(route)) return false;
  const segments = route.split('/').filter(Boolean);
  if (segments.some((segment) => PUBLIC_BLOCKLIST_SEGMENTS.includes(segment))) return false;
  return true;
}

function routeCategory(route) {
  if (route.startsWith('/api/')) return 'api';
  if (route.startsWith('/qa/')) return 'qa';
  if (/^\/admin(\/|$)/.test(route)) return 'admin';
  if (/^\/auth(\/|$)/.test(route) || ['/login', '/register', '/forgot-password', '/reset-password'].includes(route)) {
    return 'auth';
  }
  if (/^\/(messages|notifications)(\/|$)/.test(route)) return 'member';
  if (route.includes('/create') || route.includes('/edit') || route.endsWith('/new') || route.includes('/upload')) {
    return 'authoring';
  }
  return 'public';
}

function defaultPriorityForRoute(route, category) {
  if (route === '/' || route === '/health' || route === '/login') return 'P0';
  if (category === 'auth' || category === 'authoring' || category === 'admin') return 'P0';
  if (category === 'public') return 'P1';
  return 'P2';
}

function buildCoverageArtifacts() {
  const pagesRoot = path.join(ROOT, 'apps', 'web', 'src', 'pages');
  const allFiles = listFilesRecursively(pagesRoot);
  const pageFiles = allFiles
    .map((abs) => path.relative(pagesRoot, abs))
    .filter((rel) => rel.endsWith('.astro') || rel.endsWith('.ts'))
    .sort();

  const routeInventory = [];
  const apiInventory = [];
  const componentInventory = [];

  for (const relativeFile of pageFiles) {
    const route = routeFromPageFile(relativeFile);
    if (!route) continue;

    const category = routeCategory(route);
    const isDynamic = hasDynamicSegment(route);
    const publicSmoke = isLikelyPublicSmokeRoute(route);
    const routeObj = {
      route,
      file: `apps/web/src/pages/${normalizeSlashes(relativeFile)}`,
      category,
      isDynamic,
      agentPublicSmokeCandidate: publicSmoke,
    };

    if (category === 'api') apiInventory.push(routeObj);
    else routeInventory.push(routeObj);

    componentInventory.push({
      id: `page::${sanitizeId(route)}`,
      route,
      file: `apps/web/src/pages/${normalizeSlashes(relativeFile)}`,
      type: relativeFile.endsWith('.astro') ? 'astro_page' : 'ts_page',
      category,
    });
  }

  routeInventory.sort((a, b) => a.route.localeCompare(b.route));
  apiInventory.sort((a, b) => a.route.localeCompare(b.route));
  componentInventory.sort((a, b) => a.route.localeCompare(b.route));

  const obligations = [];
  for (const routeObj of routeInventory) {
    const { route, category, isDynamic } = routeObj;
    const priority = defaultPriorityForRoute(route, category);
    const id = `route_smoke__${sanitizeId(route)}`;
    const automatable = !isDynamic
      && route !== '/preferences/locale'
      && route !== '/this-route-definitely-does-not-exist-qa-404'
      && !route.startsWith('/qa/');
    const assertions = ['response_status_expected', 'visible_content_non_empty'];

    obligations.push({
      id,
      kind: 'route_smoke',
      route,
      category,
      priority,
      dynamic: isDynamic,
      agentEnabled: automatable,
      goal: `Validate stable smoke behavior for ${route}`,
      assertions,
    });
  }

  for (const routeObj of apiInventory) {
    const route = routeObj.route;
    const id = `api_contract__${sanitizeId(route)}`;
    obligations.push({
      id,
      kind: 'api_contract',
      route,
      category: 'api',
      priority: 'P1',
      dynamic: routeObj.isDynamic,
      agentEnabled: true,
      goal: `Validate API contract behavior for ${route}`,
      assertions: ['status_contract', 'schema_contract'],
    });
  }

  obligations.sort((a, b) => {
    const pa = PRIORITY_ORDER.get(a.priority) ?? 9;
    const pb = PRIORITY_ORDER.get(b.priority) ?? 9;
    if (pa !== pb) return pa - pb;
    return a.route.localeCompare(b.route);
  });

  const matrix = {
    version: 1,
    obligations,
  };

  return { routeInventory, apiInventory, componentInventory, matrix };
}

function mergeStateWithMatrix(matrix, existingState) {
  const state = existingState && typeof existingState === 'object'
    ? existingState
    : { version: 1, obligations: {} };
  state.version = 1;
  state.updatedAt = new Date().toISOString();
  if (!state.obligations || typeof state.obligations !== 'object') state.obligations = {};

  const validIds = new Set();
  for (const obligation of matrix.obligations) {
    validIds.add(obligation.id);
    const current = state.obligations[obligation.id] || {};
    const defaultStatus = (!obligation.agentEnabled && PUBLIC_BLOCKLIST_EXACT.has(obligation.route)) ? 'waived' : 'pending';

    let normalizedStatus = current.status === 'baseline_existing' ? 'pending' : current.status;
    if (!obligation.agentEnabled && PUBLIC_BLOCKLIST_EXACT.has(obligation.route)) {
      normalizedStatus = 'waived';
    }

    state.obligations[obligation.id] = {
      id: obligation.id,
      route: obligation.route,
      kind: obligation.kind,
      category: obligation.category,
      priority: obligation.priority,
      goal: obligation.goal,
      assertions: obligation.assertions,
      agentEnabled: obligation.agentEnabled,
      status: normalizedStatus || defaultStatus,
      attempts: Number.isFinite(current.attempts) ? current.attempts : 0,
      lastUpdatedAt: current.lastUpdatedAt || null,
      lastTestFile: current.lastTestFile || null,
      lastError: current.lastError || null,
      lastFlow: current.lastFlow || null,
      lastCommit: current.lastCommit || null,
      baselineExisting: false,
      existingGeneratedTests: [],
    };
  }

  for (const id of Object.keys(state.obligations)) {
    if (!validIds.has(id)) {
      delete state.obligations[id];
    }
  }

  state.summary = computeSummary(state);
  return state;
}

function trackedGeneratedTestFiles() {
  try {
    const output = execFileSync('git', ['ls-files', '-z', 'tests/e2e/ai-generated/*.spec.ts'], {
      cwd: ROOT,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
    return output.split('\0').filter(Boolean);
  } catch {
    return [];
  }
}

function trackedE2eTestFiles() {
  try {
    const output = execFileSync('git', ['ls-files', '-z', 'tests/e2e'], {
      cwd: ROOT,
      encoding: 'utf8',
      stdio: ['ignore', 'pipe', 'ignore'],
    });
    return output.split('\0').filter((file) => file.endsWith('.spec.ts'));
  } catch {
    return [];
  }
}

function routesFromGeneratedTest(content) {
  const routes = new Set();
  const patterns = [
    /BASE_URL\s*\+\s*["'`](\/[^"'`]+)["'`]/g,
    /\$\{BASE_URL\}(\/[^`"'})]+)/g,
  ];
  for (const pattern of patterns) {
    for (const match of content.matchAll(pattern)) {
      if (match[1]) routes.add(match[1]);
    }
  }
  return [...routes];
}

function normalizeDynamicRoutePattern(route) {
  return route
    .replace(/\[\.\.\.[^\]]+\]/g, '__WILDCARD_REST__')
    .replace(/\[[^\]]+\]/g, '__WILDCARD_SEGMENT__');
}

function routePatternRegex(route) {
  const escaped = normalizeDynamicRoutePattern(route)
    .replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    .replace(/__WILDCARD_REST__/g, '.*')
    .replace(/__WILDCARD_SEGMENT__/g, '[^/]+');
  return new RegExp(escaped);
}

function sourceMentionsRoutePattern(source, route) {
  if (!route.includes('[')) return source.includes(route);
  const concretePattern = routePatternRegex(route);
  if (concretePattern.test(source)) return true;

  const templatePattern = normalizeDynamicRoutePattern(route)
    .replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
    .replace(/__WILDCARD_REST__/g, String.raw`\$\{[^}]+\}|[^\`"']+`)
    .replace(/__WILDCARD_SEGMENT__/g, String.raw`\$\{[^}]+\}|[^/\`"']+`);
  return new RegExp(templatePattern).test(source);
}

function reconcileStateFromTrackedGeneratedTests(state) {
  const now = new Date().toISOString();
  for (const relativeFile of trackedGeneratedTestFiles()) {
    const absoluteFile = path.join(ROOT, relativeFile);
    if (!fs.existsSync(absoluteFile)) continue;
    const routes = routesFromGeneratedTest(fs.readFileSync(absoluteFile, 'utf8'));
    for (const route of routes) {
      const id = obligationIdForRoute(route);
      const current = state.obligations?.[id];
      if (!current || current.status === 'passed') continue;
      state.obligations[id] = {
        ...current,
        status: 'passed',
        lastUpdatedAt: current.lastUpdatedAt || now,
        lastTestFile: current.lastTestFile || relativeFile,
        lastError: current.lastError === 'content_hash_duplicate' ? null : current.lastError,
        lastFlow: current.lastFlow || `Existing generated coverage for ${route}`,
      };
    }
  }
  state.summary = computeSummary(state);
  return state;
}

function reconcileStateFromExistingE2eSuite(state) {
  const now = new Date().toISOString();
  const files = trackedE2eTestFiles().filter((file) => !file.startsWith('tests/e2e/ai-generated/'));
  const contents = files.map((relativeFile) => ({
    relativeFile,
    content: fs.existsSync(path.join(ROOT, relativeFile)) ? fs.readFileSync(path.join(ROOT, relativeFile), 'utf8') : '',
  }));

  for (const current of Object.values(state.obligations || {})) {
    if (!current || current.status === 'passed' || current.status === 'baseline_existing') continue;
    if (current.agentEnabled && current.kind !== 'route_smoke') continue;

    const match = contents.find(({ content }) => sourceMentionsRoutePattern(content, current.route));
    if (!match) continue;

    state.obligations[current.id] = {
      ...current,
      status: 'baseline_existing',
      lastUpdatedAt: current.lastUpdatedAt || now,
      lastTestFile: current.lastTestFile || match.relativeFile,
      lastFlow: current.lastFlow || `Existing E2E suite coverage for ${current.route}`,
    };
  }

  state.summary = computeSummary(state);
  return state;
}

function computeSummary(state) {
  const obligations = Object.values(state.obligations || {});
  const summary = {
    total: obligations.length,
    byStatus: {},
    byCategory: {},
    byPriority: {},
    agentEnabled: {
      total: 0,
      passed: 0,
      pending: 0,
      baselineExisting: 0,
    },
    updatedAt: new Date().toISOString(),
  };

  for (const item of obligations) {
    summary.byStatus[item.status] = (summary.byStatus[item.status] || 0) + 1;
    summary.byCategory[item.category] = (summary.byCategory[item.category] || 0) + 1;
    summary.byPriority[item.priority] = (summary.byPriority[item.priority] || 0) + 1;

    if (item.agentEnabled) {
      summary.agentEnabled.total += 1;
      if (item.status === 'passed') summary.agentEnabled.passed += 1;
      if (item.status === 'pending') summary.agentEnabled.pending += 1;
      if (item.status === 'baseline_existing') summary.agentEnabled.baselineExisting += 1;
    }
  }

  summary.coveragePercent = summary.total > 0
    ? Number((((summary.byStatus.passed || 0) / summary.total) * 100).toFixed(2))
    : 0;

  summary.knownCoveragePercent = summary.total > 0
    ? Number(((((summary.byStatus.passed || 0) + (summary.byStatus.baseline_existing || 0) + (summary.byStatus.waived || 0)) / summary.total) * 100).toFixed(2))
    : 0;

  summary.agentCoveragePercent = summary.agentEnabled.total > 0
    ? Number(((summary.agentEnabled.passed / summary.agentEnabled.total) * 100).toFixed(2))
    : 0;

  return summary;
}

function toYamlScalar(value) {
  if (value === null || value === undefined) return 'null';
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  const text = String(value);
  if (/^[a-zA-Z0-9_./:-]+$/.test(text)) return text;
  return `"${text.replaceAll('"', '\\"')}"`;
}

function writeCoverageYaml(matrix) {
  const lines = [];
  lines.push('version: 1');
  lines.push('obligations:');
  for (const o of matrix.obligations) {
    lines.push(`  - id: ${toYamlScalar(o.id)}`);
    lines.push(`    kind: ${toYamlScalar(o.kind)}`);
    lines.push(`    route: ${toYamlScalar(o.route)}`);
    lines.push(`    category: ${toYamlScalar(o.category)}`);
    lines.push(`    priority: ${toYamlScalar(o.priority)}`);
    lines.push(`    dynamic: ${toYamlScalar(o.dynamic)}`);
    lines.push(`    agentEnabled: ${toYamlScalar(o.agentEnabled)}`);
    lines.push(`    goal: ${toYamlScalar(o.goal)}`);
    lines.push('    assertions:');
    for (const assertion of o.assertions) {
      lines.push(`      - ${toYamlScalar(assertion)}`);
    }
  }
  fs.writeFileSync(COVERAGE_MATRIX_YAML_PATH, `${lines.join('\n')}\n`, 'utf8');
}

function writeRiskYaml(matrix) {
  const lines = [];
  lines.push('version: 1');
  lines.push('riskBuckets:');
  lines.push('  P0:');
  lines.push('    - auth');
  lines.push('    - admin');
  lines.push('    - authoring');
  lines.push('  P1:');
  lines.push('    - public');
  lines.push('    - api');
  lines.push('  P2:');
  lines.push('    - qa');
  lines.push('routePriorities:');
  for (const o of matrix.obligations) {
    lines.push(`  ${toYamlScalar(o.id)}: ${toYamlScalar(o.priority)}`);
  }
  fs.writeFileSync(RISK_PRIORITY_YAML_PATH, `${lines.join('\n')}\n`, 'utf8');
}

function writeTestsMarkdown(matrix) {
  const lines = [];
  lines.push('# AI Coverage Tracker');
  lines.push('');
  lines.push('This file is the stable coverage obligation catalog for the AI Playwright agent.');
  lines.push('Runtime pass/fail state lives in `.ai-agent/state/coverage-state.json` and the HTML dashboard rendered by `scripts/qa/ai-coverage-manager.mjs`.');
  lines.push('');
  lines.push('## Commands');
  lines.push('');
  lines.push('```bash');
  lines.push('node scripts/qa/ai-coverage-manager.mjs sync');
  lines.push('node scripts/qa/ai-coverage-manager.mjs summary');
  lines.push('node scripts/qa/ai-coverage-manager.mjs next --format json');
  lines.push('node scripts/qa/ai-coverage-manager.mjs render-dashboard --output ai-logs/coverage-dashboard.html');
  lines.push('```');
  lines.push('');
  lines.push('## Route Obligations');
  lines.push('');
  lines.push('| ID | Route | Kind | Priority | Agent | Goal |');
  lines.push('|---|---|---|---|---|---|');
  for (const o of matrix.obligations) {
    lines.push(`| ${o.id} | \`${o.route}\` | ${o.kind} | ${o.priority} | ${o.agentEnabled ? 'yes' : 'no'} | ${o.goal} |`);
  }

  fs.writeFileSync(TESTS_MD_PATH, `${lines.join('\n')}\n`, 'utf8');
}

function renderDashboardData(matrix, state) {
  const obligations = matrix.obligations.map((o) => {
    const s = state.obligations[o.id] || {};
    return {
      id: o.id,
      route: o.route,
      kind: o.kind,
      category: o.category,
      priority: o.priority,
      goal: o.goal,
      status: s.status || 'pending',
      attempts: s.attempts || 0,
      agentEnabled: o.agentEnabled,
      lastUpdatedAt: s.lastUpdatedAt || null,
      lastTestFile: s.lastTestFile || null,
      lastError: s.lastError || null,
    };
  });

  const payload = {
    generatedAt: new Date().toISOString(),
    summary: state.summary || computeSummary(state),
    obligations,
  };

  writeJson(DASHBOARD_DATA_PATH, payload);
  return payload;
}

function renderDashboardHtml(payload, outputPath) {
  const html = `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>AI Coverage Dashboard</title>
  <style>
    body { font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, sans-serif; margin: 16px; color: #111; }
    h1, h2 { margin: 0 0 12px; }
    .grid { display: grid; grid-template-columns: repeat(4, minmax(120px, 1fr)); gap: 12px; margin: 16px 0; }
    .card { border: 1px solid #ddd; border-radius: 8px; padding: 10px; background: #fafafa; }
    .small { color: #555; font-size: 12px; }
    table { width: 100%; border-collapse: collapse; margin-top: 12px; font-size: 13px; }
    th, td { border: 1px solid #ddd; padding: 6px 8px; text-align: left; }
    th { background: #f4f4f4; }
    .status-passed { color: #0a7a1f; font-weight: 600; }
    .status-failed { color: #b00020; font-weight: 600; }
    .status-pending, .status-baseline_existing, .status-duplicate { color: #8a5a00; font-weight: 600; }
    .status-deprecated { color: #666; }
  </style>
</head>
<body>
  <h1>AI Coverage Dashboard</h1>
  <div class="small">Generated: ${payload.generatedAt}</div>
  <div class="grid">
    <div class="card"><div class="small">Total</div><div>${payload.summary.total}</div></div>
    <div class="card"><div class="small">Passed</div><div>${payload.summary.byStatus.passed || 0}</div></div>
    <div class="card"><div class="small">Pending</div><div>${payload.summary.byStatus.pending || 0}</div></div>
    <div class="card"><div class="small">Baseline Existing</div><div>${payload.summary.byStatus.baseline_existing || 0}</div></div>
    <div class="card"><div class="small">Failed</div><div>${payload.summary.byStatus.failed || 0}</div></div>
    <div class="card"><div class="small">Duplicate</div><div>${payload.summary.byStatus.duplicate || 0}</div></div>
    <div class="card"><div class="small">Coverage %</div><div>${payload.summary.coveragePercent}%</div></div>
    <div class="card"><div class="small">Known Coverage %</div><div>${payload.summary.knownCoveragePercent}%</div></div>
    <div class="card"><div class="small">Agent Coverage %</div><div>${payload.summary.agentCoveragePercent}%</div></div>
  </div>
  <h2>Obligations</h2>
  <table>
    <thead>
      <tr><th>ID</th><th>Route</th><th>Kind</th><th>Priority</th><th>Agent</th><th>Status</th><th>Attempts</th><th>Last Test</th><th>Last Error</th></tr>
    </thead>
    <tbody>
      ${payload.obligations.map((o) => `<tr>
        <td>${o.id}</td>
        <td><code>${o.route}</code></td>
        <td>${o.kind}</td>
        <td>${o.priority}</td>
        <td>${o.agentEnabled ? 'yes' : 'no'}</td>
        <td class="status-${String(o.status).replace(/[^a-z_]/g, '_')}">${o.status}</td>
        <td>${o.attempts || 0}</td>
        <td>${o.lastTestFile || ''}</td>
        <td>${o.lastError ? String(o.lastError).slice(0, 180) : ''}</td>
      </tr>`).join('\n')}
    </tbody>
  </table>
</body>
</html>`;

  fs.writeFileSync(outputPath, html, 'utf8');
}

function parseArgs(argv) {
  const args = { _: [] };
  for (let i = 0; i < argv.length; i += 1) {
    const token = argv[i];
    if (token.startsWith('--')) {
      const key = token.slice(2);
      const next = argv[i + 1];
      if (next && !next.startsWith('--')) {
        args[key] = next;
        i += 1;
      } else {
        args[key] = true;
      }
      continue;
    }
    args._.push(token);
  }
  return args;
}

function runSync() {
  ensureDir(COVERAGE_DIR);
  ensureDir(COVERAGE_DASHBOARD_DIR);
  ensureDir(STATE_DIR);

  const { routeInventory, apiInventory, componentInventory, matrix } = buildCoverageArtifacts();
  writeJson(ROUTE_INVENTORY_PATH, {
    version: 1,
    routes: routeInventory,
  });
  writeJson(API_INVENTORY_PATH, {
    version: 1,
    routes: apiInventory,
  });
  writeJson(COMPONENT_INVENTORY_PATH, {
    version: 1,
    components: componentInventory,
  });
  writeJson(COVERAGE_MATRIX_JSON_PATH, matrix);
  writeCoverageYaml(matrix);
  writeRiskYaml(matrix);

  const existingState = readJson(COVERAGE_STATE_PATH, null);
  const state = reconcileStateFromExistingE2eSuite(
    reconcileStateFromTrackedGeneratedTests(mergeStateWithMatrix(matrix, existingState)),
  );
  writeJson(COVERAGE_STATE_PATH, state);
  writeTestsMarkdown(matrix);

  const dashboardPayload = renderDashboardData(matrix, state);
  renderDashboardHtml(dashboardPayload, path.join(COVERAGE_DASHBOARD_DIR, 'index.html'));

  return { matrix, state };
}

function runNext(format = 'text') {
  const matrix = readJson(COVERAGE_MATRIX_JSON_PATH, { obligations: [] });
  const state = readJson(COVERAGE_STATE_PATH, { obligations: {} });
  const candidates = matrix.obligations
    .filter((o) => o.agentEnabled)
    .map((o) => {
      const s = state.obligations?.[o.id] || {};
      return {
        id: o.id,
        route: o.route,
        kind: o.kind,
        goal: o.goal,
        priority: o.priority,
        category: o.category,
        status: s.status || 'pending',
        attempts: Number.isFinite(s.attempts) ? s.attempts : 0,
      };
    })
    .filter((o) => !['passed', 'baseline_existing', 'duplicate', 'waived', 'deprecated'].includes(o.status))
    .sort((a, b) => {
      const pa = PRIORITY_ORDER.get(a.priority) ?? 9;
      const pb = PRIORITY_ORDER.get(b.priority) ?? 9;
      if (pa !== pb) return pa - pb;
      if ((a.attempts || 0) !== (b.attempts || 0)) return (a.attempts || 0) - (b.attempts || 0);
      return a.route.localeCompare(b.route);
    });

  const next = candidates[0] || {};
  if (format === 'json') {
    process.stdout.write(`${JSON.stringify(next)}\n`);
    return;
  }
  if (!next.route) {
    process.stdout.write('\n');
    return;
  }
  process.stdout.write(`${next.id}|${next.route}|${next.goal}\n`);
}

function runMark(args) {
  const id = String(args.id || '').trim();
  const status = String(args.status || '').trim();
  if (!id || !status) {
    process.stderr.write('mark requires --id and --status\n');
    process.exit(2);
  }

  const state = readJson(COVERAGE_STATE_PATH, { version: 1, obligations: {} });
  if (!state.obligations || typeof state.obligations !== 'object') state.obligations = {};
  const current = state.obligations[id] || { id };
  const now = new Date().toISOString();

  const attempts = Number.isFinite(current.attempts) ? current.attempts : 0;
  const shouldIncrement = ['failed', 'duplicate', 'blocked', 'flaky'].includes(status);

  state.obligations[id] = {
    ...current,
    status,
    attempts: shouldIncrement ? attempts + 1 : attempts,
    lastUpdatedAt: now,
    lastTestFile: args['test-file'] ? String(args['test-file']) : current.lastTestFile || null,
    lastError: args.error ? String(args.error).slice(0, 500) : current.lastError || null,
    lastFlow: args.flow ? String(args.flow).slice(0, 500) : current.lastFlow || null,
    lastCommit: args.commit ? String(args.commit) : current.lastCommit || null,
  };

  state.updatedAt = now;
  state.summary = computeSummary(state);
  writeJson(COVERAGE_STATE_PATH, state);

  const matrix = readJson(COVERAGE_MATRIX_JSON_PATH, { obligations: [] });
  const payload = renderDashboardData(matrix, state);
  renderDashboardHtml(payload, path.join(COVERAGE_DASHBOARD_DIR, 'index.html'));
}

function runSummary() {
  const state = readJson(COVERAGE_STATE_PATH, { obligations: {} });
  const summary = state.summary || computeSummary(state);
  process.stdout.write(`${JSON.stringify(summary)}\n`);
}

function runRenderDashboard(args) {
  const matrix = readJson(COVERAGE_MATRIX_JSON_PATH, { obligations: [] });
  const state = readJson(COVERAGE_STATE_PATH, { obligations: {} });
  const payload = renderDashboardData(matrix, state);
  const output = args.output ? path.resolve(ROOT, String(args.output)) : path.join(COVERAGE_DASHBOARD_DIR, 'index.html');
  ensureDir(path.dirname(output));
  renderDashboardHtml(payload, output);
}

function main() {
  const args = parseArgs(process.argv.slice(2));
  const command = args._[0] || 'sync';

  switch (command) {
    case 'sync':
      runSync();
      process.stdout.write('ok\n');
      break;
    case 'next':
      runNext(String(args.format || 'text'));
      break;
    case 'mark':
      runMark(args);
      process.stdout.write('ok\n');
      break;
    case 'summary':
      runSummary();
      break;
    case 'render-dashboard':
      runRenderDashboard(args);
      process.stdout.write('ok\n');
      break;
    default:
      process.stderr.write(`unknown command: ${command}\n`);
      process.exit(2);
  }
}

main();
