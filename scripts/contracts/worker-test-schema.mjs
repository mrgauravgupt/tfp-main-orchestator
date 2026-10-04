import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const migrations = path.join(root, 'tfpphotographers/packages/database/prisma/migrations');
const targets = [
  ['tfp-ai-interface/tests/fixtures/worker-schema.sql', ['event_outbox', 'moderation_jobs', 'moderation_results']],
  ['tfp-collage-service/src/tests/fixtures/worker-schema.sql', ['image_processing_jobs', 'privacy_erasure_requests', 'media_assets', 'media_manifests', 'media_physical_renditions', 'media_variant_aliases', 'event_outbox', 'evidence_holds']],
];
const statements = fs.readdirSync(migrations).sort().flatMap((name) => {
  const file = path.join(migrations, name, 'migration.sql');
  if (!fs.existsSync(file)) return [];
  return fs.readFileSync(file, 'utf8').replace(/^--.*$/gm, '').split(';')
    .map((sql) => sql.trim()).filter(Boolean);
});

// Use the owning application's migrations, including later ALTERs. External
// domain FKs are excluded: these fixtures test queue adapters, not domain writes.
function schemaFor(tables) {
  const tableName = '(?:public\\.)?"?(' + tables.join('|') + ')"?\\b';
  const ownsTable = new RegExp('(?:CREATE TABLE|ALTER TABLE(?: ONLY)?| ON)\\s+' + tableName);
  const selected = statements.map((sql) => {
    // Inline domain references must not discard an otherwise owned table.
    // Keep its columns/checks; domain FK and procedural-trigger behavior is
    // exercised by the owning application's integration tests.
    if (!sql.startsWith('CREATE TABLE')) return sql;
    return sql.replace(/REFERENCES\s+(?:public\.)?"?(\w+)"?\s*\([^)]*\)(?:\s+ON\s+(?:DELETE|UPDATE)\s+(?:RESTRICT|CASCADE|SET NULL|NO ACTION|SET DEFAULT))*/g,
      (reference, table) => tables.includes(table) ? reference : '');
  }).filter((sql) => {
    if (sql.startsWith('CREATE TRIGGER')) return false;
    if (!ownsTable.test(sql)) return false;
    const reference = sql.match(/REFERENCES\s+(?:public\.)?"?(\w+)/);
    return !reference || tables.includes(reference[1]);
  });
  const enumNames = new Set([...selected.join('\n').matchAll(/public\."(\w+)"/g)]
    .map((match) => match[1]));
  const enums = statements.filter((sql) => {
    const name = sql.match(/^(?:CREATE|ALTER) TYPE (?:public\.)?"(\w+)"/);
    return name && enumNames.has(name[1]);
  });
  return '-- Generated from tfpphotographers Prisma migrations. Do not edit by hand.\n'
    + '-- Regenerate: node scripts/contracts/worker-test-schema.mjs --patch | apply_patch\n'
    + '-- Queue adapter scope: external domain foreign keys intentionally excluded.\n\n'
    + [...enums, ...selected].map((sql) => sql + ';\n').join('\n');
}

let patch = '*** Begin Patch\n';
for (const [relative, tables] of targets) {
  const file = path.join(root, relative);
  const expected = schemaFor(tables);
  const actual = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : null;
  if (actual === expected) continue;
  if (process.argv.includes('--patch')) {
    patch += actual === null ? `*** Add File: ${relative}\n` : `*** Update File: ${relative}\n@@\n`;
    if (actual !== null) patch += actual.trimEnd().split('\n').map((line) => '-' + line).join('\n') + '\n';
    patch += expected.trimEnd().split('\n').map((line) => '+' + line).join('\n') + '\n';
  } else {
    console.error(`Worker test schema drift: ${relative}`);
    process.exitCode = 1;
  }
}
if (process.argv.includes('--patch')) console.log(patch + '*** End Patch');
else if (!process.exitCode) console.log('Worker test schemas match application migrations.');
