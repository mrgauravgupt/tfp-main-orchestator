# TFP workspace documentation

Start with [how the application works](../tfpphotographers/docs/architecture/SYSTEM_GUIDE.md), then follow the source paths for the domain you are changing. Executable code and active configuration determine behavior; documentation supplies context and navigation.

| Need | Read |
| --- | --- |
| Current deep audit and implementation backlog | [8 September code/architecture audit](reviews/2026-09-08-deep-architecture-audit-and-implementation-plan.md) |
| Product documentation | [Product index](../tfpphotographers/docs/README.md) |
| Architecture ownership | [Canonical guide](../tfpphotographers/docs/CANONICAL_DOCS.md) |
| Cross-service wire contract | [AI outbox JSON Schema](../contracts/ai-outbox.schema.json) |
| Active UAT operations | [OCI deployment](operations/deploy.md) |
| Security operations | [Deployment security](operations/SECURITY_DEPLOYMENT_README.md) |
| Contributor tooling | [Tooling and validation entrypoints](../SKILLS.md) |

Dated files in `reviews/` preserve review/verification history. They do not compete with the current implementation plan or certify the presently deployed application. Service-specific inference evaluations remain with the service that produced them. Legal policies and operational recovery evidence are retained.
