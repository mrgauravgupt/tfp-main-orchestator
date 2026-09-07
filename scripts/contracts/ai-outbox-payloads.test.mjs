import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const root = fileURLToPath(new URL('../../', import.meta.url));
const require = createRequire(new URL('../../tfpphotographers/apps/api/package.json', import.meta.url));
const Ajv2020 = require('ajv/dist/2020.js');
const schema = JSON.parse(readFileSync(new URL('../../contracts/ai-outbox.schema.json', import.meta.url)));
const validate = new Ajv2020({ strict: false }).compile(schema);

test('actual application producers and correlated result envelopes satisfy the wire schema', () => {
  const output = execFileSync('bash', [
    'tfpphotographers/scripts/run-node20.sh',
    '--import', './tfpphotographers/apps/api/node_modules/tsx/dist/loader.mjs',
    '--input-type=module', '-e', `
      import { buildImageModerationOutboxEvent, buildEntityModerationOutboxEvent }
        from './tfpphotographers/apps/api/src/modules/moderation/application/image-moderation-jobs.ts';
      import { buildEntityTranslationOutboxEvent }
        from './tfpphotographers/apps/api/src/modules/translation/application/entity-translation-job.ts';
      const correlationId = 'review-request:123';
      console.log(JSON.stringify([
        buildImageModerationOutboxEvent({imageKey:'private/fixture.jpg',userId:'u',uploadId:'up',sourceType:'UPLOAD_PORTFOLIO',correlationId}),
        buildEntityModerationOutboxEvent({jobType:'ENTITY',sourceEntityType:'OPPORTUNITY',sourceEntityId:'opp',userId:'u',revisionCount:1,correlationId}),
        buildEntityTranslationOutboxEvent({entityType:'OPPORTUNITY',entityId:'opp',revision:1,sourceLocale:'en_US',targetLocales:['hi_IN'],correlationId}),
      ]));
    `,
  ], { cwd: root, encoding: 'utf8', timeout: 30000 });
  const requests = JSON.parse(output.trim());
  for (const request of requests) {
    assert.equal(validate(request), true, JSON.stringify(validate.errors));
    const isTranslation = request.eventName === 'process_translation';
    const result = {
      eventName: isTranslation ? 'apply_ai_translation_result' : 'apply_ai_moderation_result',
      payload: {
        jobType: isTranslation ? 'ENTITY_TRANSLATION_RESULT' : request.payload.imageKey ? 'IMAGE_RESULT' : 'ENTITY_RESULT',
        requestId: 'outbox-job-123',
        correlationId: request.payload.correlationId,
        request: request.payload,
        ...(isTranslation ? { translations: [] } : {}),
      },
    };
    assert.equal(validate(result), true, JSON.stringify(validate.errors));
    for (const invalid of [{ privateContent: 'must-not-be-an-id' }, 'x'.repeat(129), 'line\nbreak']) {
      assert.equal(validate({ ...result, payload: { ...result.payload, correlationId: invalid } }), false);
    }
    delete result.payload.correlationId;
    delete result.payload.request.correlationId;
    assert.equal(validate(result), true, 'old rows without correlation remain compatible');
    delete result.payload.requestId;
    assert.equal(validate(result), false, 'required job identity cannot be omitted');
  }
});
