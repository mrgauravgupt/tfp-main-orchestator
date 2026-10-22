import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import fs from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';
import vm from 'node:vm';
import { generateToolkit } from './build-browser-policy-toolkit.mjs';
import { exerciseToolkit } from './toolkit-cases.mjs';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');
const artifactPath = resolve(root, 'tfp-moderation-service/src/tfp_moderation_service/static/browser_policy_evaluator_toolkit.js');
const golden = JSON.parse(fs.readFileSync(resolve(root, 'tfp-moderation-service/tests/fixtures/browser-policy-golden.json'), 'utf8'));
const artifact = fs.readFileSync(artifactPath, 'utf8');
const digest = (value) => createHash('sha256').update(JSON.stringify(value)).digest('hex');

test('committed browser artifact matches both canonical inputs', () => {
  assert.equal(artifact, generateToolkit());
});

for (const mode of ['browser', 'commonjs']) {
  test(`${mode} keeps every frozen public API, result, error and diagnostic`, () => {
    const context = mode === 'browser' ? { window: {} } : { module: { exports: {} } };
    vm.runInNewContext(artifact, context, { timeout: 1000 });
    const toolkit = mode === 'browser' ? context.window.TFPPolicyEvaluatorToolkit : context.module.exports;
    assert.deepEqual(exerciseToolkit(toolkit).map(({ id, value }) => ({ id, sha256: digest(value) })), golden.cases);
  });
}

test('shared runtime decisions still short-circuit while reports inspect both branches', async () => {
  const { createRawPolicyRuntime } = await import(resolve(root, 'tfpphotographers/packages/moderation/dist/raw-policy/runtime.js'));
  for (const [expression, expected] of [['false && absent > 0', false], ['true || absent > 0', true]]) {
    for (const allBranches of [false, true]) {
      const runtime = createRawPolicyRuntime({ evaluateAllBranches: allBranches });
      const missingPaths = new Set();
      const evaluatedPaths = new Set();
      assert.equal(runtime.evaluateAstNode(runtime.parseRawPolicyExpression(expression), { input: {}, missingPaths, evaluatedPaths }), expected);
      assert.deepEqual([...missingPaths], allBranches ? ['absent'] : []);
      assert.deepEqual([...evaluatedPaths], allBranches ? ['absent'] : []);
    }
  }
});

test('compiled application policy retains ordered first-match and default outcomes', async () => {
  const { createRawPolicyRuntime } = await import(resolve(root, 'tfpphotographers/packages/moderation/dist/raw-policy/runtime.js'));
  const runtime = createRawPolicyRuntime();
  const policy = {
    id: 'ordered', version: 1, defaultOutcome: 'APPROVED', stageCount: 1, ruleCount: 2,
    referencedPaths: ['score', 'absent'], stages: [{ id: 'first', rules: [
      { id: 'reject', description: 'high score', outcome: 'REJECTED', when: 'score > 0.5', ast: runtime.parseRawPolicyExpression('score > 0.5') },
      { id: 'flag', description: 'fallback', outcome: 'FLAGGED', when: 'absent > 0.1', ast: runtime.parseRawPolicyExpression('absent > 0.1') },
    ] }],
  };
  const first = runtime.evaluateCompiledRawPolicy(policy, { score: 0.8 });
  assert.equal(first.outcome, 'REJECTED');
  assert.equal(first.match.ruleId, 'reject');
  assert.equal(first.evaluatedRuleCount, 1);
  assert.deepEqual(first.evaluatedPaths, ['score']);
  const fallback = runtime.evaluateCompiledRawPolicy(policy, { score: 0.1 });
  assert.equal(fallback.outcome, 'APPROVED');
  assert.equal(fallback.defaultApplied, true);
  assert.equal(fallback.evaluatedRuleCount, 2);
  assert.deepEqual(fallback.missingPaths, ['absent']);
});
