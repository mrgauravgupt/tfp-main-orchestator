---
name: root-cause-debugger
description: >-
  Automatically investigates bugs and unexplained behaviour when the user asks
  why something fails, is broken, is stuck, is inconsistent, is flaky, or needs
  debugging or root-cause analysis. Traces the relevant system path, maintains
  multiple hypotheses, validates evidence, and separates root cause from
  symptoms before suggesting changes.
---

# Root-Cause Debugger

Prefer evidence in this order: reproducible behaviour, failing behaviour-focused test, runtime/log/state evidence, source and contract trace, then static inference.

Establish expected and observed behaviour, trace the full relevant path, maintain multiple hypotheses, and use non-destructive checks to distinguish them. Separate root cause, trigger, symptom, and amplifying conditions. Identify affected contracts and regression surface. Produce a smallest-safe-change plan only; do not implement without authorization.
