# Known Exclusions

Exclude generated or runtime artifacts from broad audits unless they are the task target: `node_modules`, `test-results`, `coverage`, `tmp`, `.astro`, build output, screenshots, and cached artifacts.

Treat `.env*`, credentials, private keys, presigned URLs, raw moderation payloads, and production connection strings as inaccessible sensitive material. Tests, seed fixtures, routes, telemetry names, CSS classes, internal identifiers, URLs, MIME types, and user-generated/database content require semantic classification before being reported as defects.

All exclusions must be disclosed in an audit coverage ledger.
