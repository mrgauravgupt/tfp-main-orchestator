import assert from "node:assert/strict";
import test from "node:test";
import {
  findMissingConsumerValues,
  validateAiOutboxContract,
  validateContractShape,
} from "./validate-ai-outbox-contract.mjs";

test("the checked-in contract matches all active consumers", async () => {
  assert.deepEqual(await validateAiOutboxContract(), []);
});

test("contract validation detects an incomplete schema", () => {
  assert.ok(validateContractShape({ oneOf: [] }).length > 0);
});

test("consumer validation reports missing vocabulary", () => {
  assert.deepEqual(
    findMissingConsumerValues("process_moderation", [
      "process_moderation",
      "ENTITY",
    ]),
    ["ENTITY"],
  );
});
