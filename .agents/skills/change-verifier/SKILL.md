---
name: change-verifier
description: >-
  Automatically performs independent verification when the user asks to verify,
  validate, double-check, review an implementation, confirm a fix, check whether
  work is complete, or ensure nothing was missed. Reviews requirements, code,
  affected consumers, tests, runtime evidence, and the final diff.
---

# Change Verifier

Reconstruct intended behaviour from the requirement, plan, source, and diff rather than trusting an implementation summary. Revisit every entry in the pre-implementation affected-surface map, including potentially affected consumers and contracts; inspect every changed file and relevant consumer, run focused then broader validation, and distinguish static, test, runtime, browser, device, infrastructure, and production proof. Check root and nested Git status, unrelated churn, and secret leakage. Report defects without fixing them unless implementation is explicitly authorized.
