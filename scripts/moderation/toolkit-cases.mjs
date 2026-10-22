// Synthetic, provider-free compatibility probes shared by snapshot and bundle checks.
export const policyText = `id: offline-golden
version: 1
default_outcome: APPROVED
constants:
  limit: 0.5
derived_signals:
  - id: derived.high
    expr: rawEnvelope.score > constants.limit
stages:
  - id: primary
    stop_on_match: true
    rules:
      - id: reject
        description: explicit positive
        when: 'derived.high && rawEnvelope.flag == true'
        outcome: REJECTED
      - id: diagnostic
        when: 'true || rawEnvelope.missing > 0.5'
        outcome: FLAGGED
`;

export function exerciseToolkit(t) {
  const rows = [{ id: 'public-api', value: Object.keys(t).sort() }];
  const input = { score: 0.8, flag: true, name: 'photo', items: [{ score: 0.2 }], nullable: null };
  const expressions = [
    'score >= .8', 'score < 8e-1', 'score == "0.8"', 'flag && missing > 0',
    'false && missing > 0', 'true || missing > 0', '!flag || items[0].score <= 0.2',
    'nullable == null', 'missing != null', '-.5 < score', '!(score < 0.5)',
    '(score >= 0.8 && name == "photo") || false', 'name.length == 5', 'true == true',
    'missing', 'null', '1 < 2 < 3', '"escaped\\"quote" == "escaped\\"quote"',
  ];
  for (const expression of expressions) {
    const ast = t.parseExpression(expression);
    const missing = new Set();
    const evaluated = new Set();
    const value = t.evaluateExpressionAst(ast, input, missing, evaluated);
    rows.push({ id: `expression:${expression}`, value: {
      tokens: t.tokenizeExpression(expression), ast, result: value,
      missing: [...missing], evaluated: [...evaluated],
      comparisons: t.collectComparisonResults(ast, input, []), atomics: t.collectAtomics(ast, []),
    } });
  }
  for (const expression of ['', 'score + 1', '"unterminated', '(flag', 'flag false', 'score >=']) {
    let message = null;
    try { t.parseExpression(expression); } catch (error) { message = error.message; }
    rows.push({ id: `invalid:${expression}`, value: message });
  }
  for (const operator of ['>', '>=', '<', '<=', '==', '!=']) {
    rows.push({ id: `comparison:${operator}`, value: [
      t.compareValues(operator, 0.5, 0.5), t.compareValues(operator, undefined, 0),
      t.compareValues(operator, '0.5', 0.5), t.compareValues(operator, null, null),
    ] });
  }
  rows.push({ id: 'invalid-ast', value: [t.evaluateAstNode(null, { input }), t.evaluateAstNode(false, { input })] });
  const parsed = t.parseSimpleYamlPolicy(policyText);
  rows.push({ id: 'yaml-and-compilation', value: { parsed, compiled: t.compilePolicy(parsed), flat: t.flattenPolicyRules(parsed) } });
  for (const row of [{ rawEnvelope: { score: 0.9, flag: true } }, { rawEnvelope: { score: 0.1 } }, {}]) {
    rows.push({ id: `report:${JSON.stringify(row)}`, value: {
      compiled: t.evaluateCompiledPolicy(t.compilePolicy(parsed), row),
      investigator: t.evaluateInvestigatorRules(row, policyText),
    } });
  }
  const nested = {};
  t.setByPath(nested, 'items[0].value', 0.1234567);
  rows.push({ id: 'helpers', value: { nested, read: t.getByPath(nested, 'items[0].value'),
    numbers: [0, 0.1234567, 1000, 1e-9, NaN].map(t.prettifyNumber),
    quotes: t.stripQuotes('"value"'), indent: t.getIndent('    value'),
    keyValue: t.parseYamlKeyValue('outcome: REJECTED'),
  } });
  return rows;
}
