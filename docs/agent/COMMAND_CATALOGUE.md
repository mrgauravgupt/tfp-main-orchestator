# Command Catalogue

Commands below are confirmed from checked-in manifests or README files. Use repository wrappers instead of global tools.

| Area | Commands | Source |
| --- | --- | --- |
| TFP web/API build | `bash ./scripts/pnpm-node20.sh build`, `... --filter api build`, `... --filter web build` | `tfpphotographers/package.json` |
| TFP checks | `bash ./scripts/pnpm-node20.sh typecheck`, `lint:architecture`, `lint:eslint`, `test:web` | `tfpphotographers/package.json` |
| Mobile | `bash ./scripts/manage-tfp-mobile.sh validate`, `test`, `typecheck`, `doctor` | `tfpphotographers/AGENTS.md`, `package.json` |
| UI QA | `qa:design-tokens`, `qa:ui:capture:smoke`, `qa:ui:analyze:strict` through the Node wrapper | `tfpphotographers/package.json` |
| Collage | `bash ./scripts/pnpm-node.sh exec tsc`; `NODE_ENV=test bash ./scripts/run-node.sh --test dist/tests/*.test.js` | `tfp-collage-service/package.json` |
| AI inference | `uv sync --extra local-ml`, `uv run ruff check .`, `uv run pytest -q` | `tfp-ai-interface/README.md` |

Database reset, migration, seed, deployment, and VPS commands are destructive or environment-mutating. Use only under explicit authorization and the relevant runbook.
