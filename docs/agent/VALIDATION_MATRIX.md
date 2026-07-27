# Validation Matrix

| Change type | Required evidence |
| --- | --- |
| Web UI | Focused test/typecheck, affected route browser QA, desktop/tablet/mobile responsive inspection |
| API or contract | API tests, affected consumer checks, contract/type validation, build |
| Mobile | Mobile test/typecheck/doctor and simulator or device proof when relevant |
| Database | Schema/client generation, migration review, service tests, rollback consideration; execution only when authorized |
| Collage/moderation | Service-specific type/lint/test commands plus integration/runtime evidence when changed |
| Cross-repository | Validate each changed repository, then inspect root gitlink status |
| Deployment | Redacted configuration evidence, health/smoke checks, and rollback evidence; static checks alone are insufficient |

Use the actual scripts in `COMMAND_CATALOGUE.md`; report unavailable runtime, browser, device, infrastructure, or production proof separately.

A passing build, formatter, typecheck, or isolated test is only one layer of evidence. Completion requires requirement-by-requirement reconciliation and proportional validation of the affected surface.
