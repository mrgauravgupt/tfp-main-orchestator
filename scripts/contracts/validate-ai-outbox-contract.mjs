import fs from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = path.resolve(
  path.dirname(fileURLToPath(import.meta.url)),
  "../..",
);
const CONTRACT_PATH = path.join(ROOT, "contracts/ai-outbox.schema.json");

const CONSUMERS = [
  {
    path: "tfpphotographers/packages/shared/src/interfaces/job-queue.ts",
    values: [
      "process_moderation",
      "process_translation",
      "apply_ai_moderation_result",
      "apply_ai_translation_result",
    ],
  },
  {
    path: "tfpphotographers/apps/api/src/modules/moderation/application/image-moderation-jobs.ts",
    values: ["ENTITY"],
  },
  {
    path: "tfpphotographers/apps/api/src/background/process-ai-result-jobs.ts",
    values: ["IMAGE_RESULT", "ENTITY_RESULT"],
  },
  {
    path: "tfpphotographers/apps/api/src/modules/translation/application/entity-translation-job.ts",
    values: ["ENTITY_TRANSLATION", "ENTITY_TRANSLATION_RESULT"],
  },
  {
    path: "tfp-ai-interface/src/tfp_ai_interface/worker_ports.py",
    values: ["process_moderation", "process_translation"],
  },
  {
    path: "tfp-ai-interface/src/tfp_ai_interface/worker_repository.py",
    values: [
      "apply_ai_moderation_result",
      "apply_ai_translation_result",
      "IMAGE_RESULT",
      "ENTITY_RESULT",
      "ENTITY_TRANSLATION_RESULT",
    ],
  },
  {
    path: "tfp-ai-interface/src/tfp_ai_interface/worker_service.py",
    values: ["ENTITY", "ENTITY_TRANSLATION"],
  },
];

function contractVocabulary(schema) {
  const definitions = schema?.$defs || {};
  return new Set(
    [
      definitions.processModerationEnvelope?.properties?.eventName?.const,
      definitions.processTranslationEnvelope?.properties?.eventName?.const,
      definitions.applyModerationResultEnvelope?.properties?.eventName?.const,
      definitions.applyTranslationResultEnvelope?.properties?.eventName?.const,
      definitions.entityModerationRequest?.properties?.jobType?.const,
      definitions.translationRequest?.properties?.jobType?.const,
      ...(definitions.applyModerationResultEnvelope?.properties?.payload
        ?.properties?.jobType?.enum || []),
      definitions.applyTranslationResultEnvelope?.properties?.payload
        ?.properties?.jobType?.const,
    ].filter(Boolean),
  );
}

export function validateContractShape(schema) {
  const errors = [];
  if (schema?.$schema !== "https://json-schema.org/draft/2020-12/schema") {
    errors.push("contract must use JSON Schema draft 2020-12");
  }
  if (!Array.isArray(schema?.oneOf) || schema.oneOf.length !== 4) {
    errors.push("contract must expose exactly four event envelopes");
  }
  const vocabulary = contractVocabulary(schema);
  for (const value of [
    "process_moderation",
    "process_translation",
    "apply_ai_moderation_result",
    "apply_ai_translation_result",
    "ENTITY",
    "ENTITY_TRANSLATION",
    "IMAGE_RESULT",
    "ENTITY_RESULT",
    "ENTITY_TRANSLATION_RESULT",
  ]) {
    if (!vocabulary.has(value))
      errors.push(`contract vocabulary is missing ${value}`);
  }
  return errors;
}

export function findMissingConsumerValues(contents, values) {
  return values.filter((value) => !contents.includes(value));
}

export async function validateAiOutboxContract() {
  const schema = JSON.parse(await fs.readFile(CONTRACT_PATH, "utf8"));
  const errors = validateContractShape(schema);
  for (const consumer of CONSUMERS) {
    let contents;
    try {
      contents = await fs.readFile(path.join(ROOT, consumer.path), "utf8");
    } catch (error) {
      errors.push(
        `${consumer.path}: cannot read consumer (${error.code || "unknown error"})`,
      );
      continue;
    }
    for (const value of findMissingConsumerValues(contents, consumer.values)) {
      errors.push(`${consumer.path}: missing contract value ${value}`);
    }
  }
  return errors;
}

const isMain =
  process.argv[1] &&
  path.resolve(process.argv[1]) ===
    path.resolve(fileURLToPath(import.meta.url));
if (isMain) {
  const errors = await validateAiOutboxContract();
  if (errors.length) {
    for (const error of errors) process.stderr.write(`${error}\n`);
    process.exitCode = 1;
  } else {
    process.stdout.write(
      "AI outbox contract matches every TypeScript and Python consumer.\n",
    );
  }
}
