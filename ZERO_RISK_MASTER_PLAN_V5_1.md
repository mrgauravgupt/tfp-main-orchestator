# Zero-Risk Master Plan v5.1 (Final, Planning-Only)

Date: March 27, 2026
Scope: India-operated, globally accessible AI-moderated platform
Status: Planning complete, implementation pending

## 1. Summary

v5.1 is the final launch blueprint for a compliance-first platform architecture. It keeps the v5 controls and adds final system hardening for cross-border disclosure, availability disclaimers, moderation transparency, legal-endpoint abuse protection, tertiary incident fallback, deletion-vs-retention clarity, contest-specific legal terms, and time-sync integrity.

## 2. Locked Decisions

1. Entity/Billing: India entity only. All direct billing contracts run via India entity. App stores act as merchant-of-record for in-app flows.
2. Ownership: Founder is interim primary statutory owner for 90 days, with named deputy and backup on-call.
3. Age policy: 18+ platform-wide at launch (contests, projects, events).
4. Content posture: App-store-safe baseline (no pornographic/sexual content; strict NCII/deepfake/copyright bans).
5. Rollout: Week 1 India, Week 2 Singapore + Nepal, Week 3 US + EU.

## 3. Core Controls (v5)

### 3.1 Legal Accountability and Escalation

- Role assignment: Grievance, DPO/privacy, Incident Commander, Deputy Compliance.
- Escalation chain: L1 Support -> L2 Compliance -> L3 Legal.
- Statutory SLA ownership matrix with primary/deputy/backup on-call assignments.

### 3.2 Tax and Billing Governance (India-only)

- GST/LUT/export-of-services control workflow.
- Region-aware invoice schema: user country, tax treatment, FX evidence, payment reference.
- Billing channel split: web billing vs app-store billing.

### 3.3 Moderation and Statutory Clock Engine

- SLA lanes: 2h NCII, 3h govt/court, 36h standard takedown, 24h acknowledgement, 7d resolution, 6h CERT-In incident response.
- Auto-escalation at 80% deadline.
- Break-glass flow: disable content, freeze account, hash blocklist, evidence preservation.
- Appeals and statement-of-reasons support.

### 3.4 Law Enforcement, DMCA, and CSAM

- Dedicated legal request intake and verification pipeline.
- Request classification: government, court order, law-enforcement inquiry.
- DMCA: notice, takedown, counter-notice, repeat-infringer controls.
- CSAM emergency containment and reporting workflow.

### 3.5 AI/SGI Governance

- Mandatory AI usage disclosure at upload.
- Non-removable AI labeling.
- Provenance records linked to moderation and evidence logs.

### 3.6 Data and Privacy Governance

- Data classification: PII, user content, security logs, legal evidence.
- Retention classes: 180-day CERT-In logs, 365-day security/remediation logs.
- Legal hold and WORM evidence path.
- User rights operations: access, delete, export, withdraw consent, US opt-out where applicable.
- Breach notifications: regulator and user notification templates and delivery playbooks.

### 3.7 Access Control and Human Error Prevention

- RBAC for Security, Compliance, Legal.
- Break-glass approvals and immutable access audit.
- Confirmations for destructive actions, recovery window, admin override logging.

### 3.8 App Store Compliance Layer

- UGC controls: report, filter, block, visible legal/support contacts.
- Sensitive content detector with blur/restrict and manual override path.
- Release gate blocks deployment if checklist fails.

### 3.9 Subscriptions and Consumer Protection

- One-step cancellation and no dark patterns.
- Clear refund/cancellation disclosures by channel/region.
- Chargeback and dispute SOP with audit trail.

### 3.10 Platform Integrity and Abuse Prevention

- Rate limiting, bot/fake-account controls.
- Contest integrity checks (anti-manipulation and duplicate-entry controls).
- Search/feed suppression of flagged/removed content and cache invalidation on takedown.

### 3.11 Legal Hardening Clauses

- Governing law and jurisdiction (India).
- Limitation of liability, indemnity, content license, intermediary position language.

### 3.12 Vendor Dependency Resilience

- Critical vendor register (payments, cloud, email/SMS).
- Fallback playbooks and SLA monitoring.

### 3.13 Insurance Track

- Cyber Liability and E&O coverage before broader market scale-up.

## 4. Final Hardening (v5.1 Addendum)

1. Cross-border transfer disclosure in policy and signup surfaces.
2. Service availability and no-uptime-guarantee disclaimer.
3. Moderation transparency UI with status lifecycle.
4. Dedicated anti-abuse rate limits on legal/report endpoints.
5. Tertiary incident fallback owner and emergency override path.
6. Explicit deletion-vs-retention behavior disclosures.
7. Contest-specific legal terms layer.
8. NTP and UTC-normalized time integrity for legal clocks.

## 5. Test Plan (Must Pass)

1. NCII flow resolves within 2h lane.
2. Govt/court flow resolves within 3h lane.
3. CERT-In response packet readiness within 6h.
4. DMCA lifecycle end-to-end.
5. Rights requests within policy SLA.
6. Breach notification drill covers regulator + user notifications.
7. App-store checklist passes.
8. Cancellation/refund flow validation.
9. Audit logs immutable and complete.
10. Abuse controls on report/legal endpoints tested under load.
11. Deletion-vs-retention behavior validated.
12. Clock drift alerts and time-integrity checks validated.

## 6. Go / No-Go Gates

Launch is blocked if any of these fail:

1. Ownership chain (primary, deputy, tertiary) not operational.
2. Statutory clocks and evidence trail not drill-passed.
3. Legal/report endpoints lack abuse controls.
4. Deletion/retention behavior diverges from policy.
5. App-store checklist has unresolved blocker.
6. Billing/tax export controls not approved.
7. Subscription cancellation/dispute controls fail validation.

## 7. Assumptions

1. This is planning-only; no implementation changes are executed in this document.
2. India-only entity model remains unchanged.
3. 18+ policy remains unchanged.
4. Final legal language and filings are counsel-validated before launch.
