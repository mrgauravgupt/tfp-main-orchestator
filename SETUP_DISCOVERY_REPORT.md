# Antigravity Setup Discovery Report

Date: 2026-07-27

## Current state before installation

- Existing minimal setup: one rule, one workflow, one TFP context skill.
- Global Gemini context exists but is empty.
- The Antigravity project had broad wildcard grants and sandboxing disabled.
- Root and three nested Git repositories were identified.
- Unrelated root files were already untracked: `docs/operations/AGENT_DUE_DILIGENCE.md` and `scripts/qa/capture-screenshots.ts`; nested `tfpphotographers` state was preserved.

## Merge plan

Retain and strengthen the existing setup, add focused rules/workflows/skills, add grounded root documentation, create workspace context and ignore files, and apply local Git identity updates. No application source, deployment, migration, or secret-bearing file is changed.
