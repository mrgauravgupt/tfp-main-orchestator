# i18n Architecture Review — TFP Photographers Monorepo

> **Scope:** Read-only review of `packages/i18n`, `apps/web`, `apps/mobile`, `apps/api`, `packages/shared`.
> **Mode:** No code changes. Findings only.
> **Date:** 2026-10-12

---

## 1. What Exists Today — System Map

```
packages/i18n/
├── src/
│   ├── index.ts                    ← Web/API entry (Node.js, fs-based, AsyncLocalStorage)
│   ├── mobile.ts                   ← Mobile entry (static imports, bundle-safe)
│   ├── catalog-core.ts             ← Shared: mergeCatalogs, getCatalogValue, interpolate, resolveBrand
│   ├── catalog-integrity.ts        ← Shared: inspectLocalePayload, sanitizeLocalePayload
│   ├── legal-copy.ts               ← 3 canonical legal keys that must stay English
│   └── catalogs/
│       ├── languages/              ← 80+ language JSON files (shared base, web + mobile)
│       │   └── en.json             ← Master (2,789 lines, 2,615 keys, 37 top-level namespaces)
│       ├── overrides/              ← Region-legal overrides (en-in, en-us, hi-in, ne-in, ne-np)
│       │   └── index.ts            ← Used by WEB only (dynamic fs loader)
│       └── mobile/                 ← Mobile-only catalog layer (en-in, hi-in, ne-np)
│           └── en-in.json          ← 795 lines, 704 keys, pure native-screen strings
├── tests/
│   ├── catalog-integrity.spec.ts
│   ├── contract-validation.spec.ts
│   ├── i18n-sync.spec.ts
│   └── mobile-runtime.spec.ts
└── scripts/
    ├── sync-master-keys.mjs        ← Syncs en.json structure to all language files
    └── validate-locales.mjs        ← Validates key parity and no extra keys

apps/web/src/          → imports 'i18n' (128 files, uses t(), runWithLocale())
apps/api/src/          → imports 'i18n' (2 files only)
apps/mobile/src/       → imports 'i18n/mobile' (translateMobile, createMobileTranslator)
packages/shared/src/   → locale-registry.ts, localization.ts (6-axis model, no catalog)
```

### Translation Merge Stack

**Web per request:**
```
en.json (master) → language/{code}.json → region override (en-in/en-us/hi-in/ne-np)
```

**Mobile per locale:**
```
en.json → en-in override → language/{code}.json → locale override → mobile/{locale}.json
```

---

## 2. What Is Working Well (Keep As-Is)

- **Single source of truth.** One package, no duplicated JSON between web and mobile.
- **`catalog-core.ts` is clean.** `mergeCatalogs`, `getCatalogValue`, `interpolateCatalogValue`, `resolveBrandPlaceholders` — small, well-scoped, shared by both runtimes.
- **`catalog-integrity.ts` is genuinely sophisticated.** Han contamination detection, English-fallback quarantine, brand-artifact repair, placeholder-artifact repair — all without a translation service dependency.
- **`legal-copy.ts` pattern is correct.** Pinning 3 legally sensitive keys to English-only until reviewed is the right call.
- **`sync-master-keys.mjs`** keeps every language file structurally aligned with `en.json` automatically.
- **Test coverage is layered and real.** Four separate spec files each covering a different boundary: integrity, contract, sync parity, and mobile runtime.
- **The 6-axis model in `shared/localization.ts`** (language ≠ region) is architecturally sound and documented.

---

## 3. Gaps and Issues Found

### 3.1 Mobile Catalog Partial Translation — No Enforcement

`hi-in.json` and `ne-np.json` under `catalogs/mobile/` have only **331 keys** each out of **704 keys** in the reference `en-in.json`. That means **373 keys silently fall back to English** in Hindi and Nepali mobile screens.

**Namespaces with zero translation in hi-in and ne-np:**
- `about.*` (6 keys) — the About TFP screen
- `faq.*` (8 keys) — FAQ screen
- `safety.*` (8 keys) — Safety guide screen
- Many `mobile.contests.*`, `mobile.reports.*`, `mobile.files.*` keys

There is no test, no script, and no CI check that validates mobile catalog completeness. The `i18n-sync.spec.ts` only checks `languages/` parity. Mobile catalogs are invisible to it.

**Verdict:** Silent degradation. Hindi/Nepali mobile users see English on significant screens.

---

### 3.2 No `sync-master-keys` Equivalent for Mobile Catalogs

`scripts/sync-master-keys.mjs` keeps all 80+ `languages/` files structurally aligned with `en.json`. There is **no equivalent script for `catalogs/mobile/`**.

When a new key is added to `mobile/en-in.json`, `hi-in.json` and `ne-np.json` are not automatically scaffolded. A developer has to manually add it to each file. This is the source of the 373-key gap above.

**Verdict:** A `sync-mobile-keys.mjs` mirroring the existing script would close this mechanically.

---

### 3.3 `mobile.ts` Has 80+ Static Imports — No Codegen

[`mobile.ts`](file:///Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/packages/i18n/src/mobile.ts) manually imports all ~80 language catalogs:

```ts
import afLanguageCatalog from './catalogs/languages/af.json';
import amLanguageCatalog from './catalogs/languages/am.json';
// ... 80 more lines
```

And then manually maps them:
```ts
const languageCatalogs = {
  af: afLanguageCatalog,
  am: amLanguageCatalog,
  // ... 80 more entries
};
```

Adding a new language requires **two manual edits** in `mobile.ts`. The `sync-master-keys.mjs` adds it to `languages/`, but `mobile.ts` will not pick it up until someone remembers. The web side correctly uses `readdirSync` at runtime — mobile can't do that, but a codegen script generating the import map would solve this.

**Verdict:** Maintenance burden. Codegen removes the risk of drift.

---

### 3.4 `overrides/index.ts` Is Web-Only but Has No Package Boundary Guard

[`catalogs/overrides/index.ts`](file:///Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/packages/i18n/src/catalogs/overrides/index.ts) uses `fs.existsSync` + `fs.readFileSync` — it is Node.js-only. `mobile.ts` correctly avoids it and statically imports override JSONs directly.

But there is no barrier preventing an accidental import of `overrides/index.ts` from mobile code. It would crash at bundle time in React Native. The package exports `./catalogs/overrides/*.json` (fine), but not the `index.ts` specifically — however it's also not guarded.

**Verdict:** Low-risk today. A comment or `.package.json` `browser: false` field makes the intent explicit.

---

### 3.5 `ne-in.json` Override Exists But Is Not Loaded by Mobile

[`catalogs/overrides/ne-in.json`](file:///Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/packages/i18n/src/catalogs/overrides/ne-in.json) is correctly loaded by the web `overrides/index.ts` (`buildLocaleOverrideKey('ne', 'IN')`). But `mobile.ts` loads only:
- `enInOverride`, `enUsOverride`, `hiInOverride`, `neNpOverride`

**`ne-in.json` is completely missing from mobile.** Nepali-speaking users in India (`ne_IN`) on mobile get no regional legal override, while web correctly applies it.

**Verdict:** Actual bug. One import + one map entry to fix.

---

### 3.6 Duplicate `quick_requests` Namespace — Different Shapes and Conventions

- `languages/en.json` has `quick_requests.*` (snake_case, 30+ keys — full web UX)
- `mobile/en-in.json` has `mobile.quickRequests.*` (camelCase, 3 keys only)

Both cover the Quick Requests feature. The naming convention is inconsistent (snake vs camel) inside the same package. These are parallel features with different screens, so different keys are expected — but the convention drift is worth noting and documenting.

---

### 3.7 `onboarding.*` Namespace Sits at Root of Mobile Catalog — Not Under `mobile.*`

```json
// mobile/en-in.json top-level namespaces:
{
  "onboarding": { ... },   ← NOT under "mobile.*"
  "common": { ... },       ← NOT under "mobile.*"
  "mobile": { ... },       ← All native screens correctly scoped here
  "about": { ... },        ← NOT under "mobile.*"
  "faq": { ... },          ← NOT under "mobile.*"
  "safety": { ... }        ← NOT under "mobile.*"
}
```

The `mobile.*` namespace is the right container. `onboarding`, `about`, `faq`, `safety`, `common` sitting at the root of `mobile/en-in.json` creates confusion:
- They visually look like they might relate to the identically named `onboarding.*` in `languages/en.json`
- The existing test (`keeps shared semantic keys in language catalogs instead of mobile overlays`) confirms zero key overlap, but doesn't prevent namespace confusion for future developers

**Verdict:** Move these into `mobile.onboarding`, `mobile.about`, etc. for consistency. Bounded rename with cascade to call sites.

---

### 3.8 `common.*` Has Two Separate Populations in Different Files

- `languages/en.json → common.*` — 55 keys (cancel, confirm, edit, close, back, app_name, etc.)
- `mobile/en-in.json → common.*` — 11 keys (checkFields, relativeToday, relativeTomorrow, etc.)

Zero overlap. The merge stack means mobile gets both sets, but conceptually having two `common.*` populations in different files is hidden coupling. If someone adds `common.relativeToday` to `languages/en.json`, the mobile override silently wins or silently loses depending on merge order.

**Verdict:** Mobile-specific `common.*` keys should be scoped as `mobile.common.*` to make the separation explicit and safe.

---

### 3.9 Web Has No Type Safety on Translation Keys

- Mobile uses `MobileCopyKey = DotPath<typeof enInMobileCatalog>` — typed at compile time, typos are caught by TypeScript.
- Web uses `t('some.key')` where `LocaleKey = string` — **any string is accepted**.

A typo in a web `t()` call silently returns the key name at runtime. There is no TypeScript error, no build failure. The `public-copy-contract.test.ts` catches hardcoded strings (strings that bypassed `t()`), but it doesn't catch `t('typo.key')` that resolves to itself.

**Verdict:** This is the biggest developer experience gap in the system. The mobile side solved this. The web side has not.

---

### 3.10 Only Two API Files Use i18n — Both Follow Slightly Different Patterns

- `apps/api/src/utils/request-i18n.ts` — wraps `translateWithLocale()` per request context.
- `apps/api/src/modules/admin/admin-report.commands.ts` — imports `i18n` directly for a notification.

The API's i18n surface is intentionally minimal and correct (no `runWithLocale()`, explicit per-call locale passing is right for a stateless handler). Minor pattern inconsistency but no action required.

---

### 3.11 `CANONICAL_LEGAL_FALLBACK_KEYS` Has Only 3 Keys — No Governance Docs or Test

[`legal-copy.ts`](file:///Users/hexa/Desktop/tfp-main-orchestator/tfpphotographers/packages/i18n/src/legal-copy.ts) pins 3 keys to English-only. But:
1. No comment explains *why these 3* — what criteria for inclusion vs `legal.region_scope_body` (which goes through the override system).
2. No test asserts that each pinned key actually exists in `en.json`.
3. No process documented for when a key graduates out of this set.

**Verdict:** Concept is correct, governance is implicit. Short comment + one test closes this.

---

### 3.12 `validate-locales.mjs` Does Not Cover Mobile or Override Files

`scripts/validate-locales.mjs` validates key parity for `catalogs/languages/` and region overrides. It does not validate:
- `catalogs/mobile/hi-in.json` completeness vs `catalogs/mobile/en-in.json`
- `catalogs/mobile/ne-np.json` completeness
- Whether new override files follow the same structure as existing ones

The 373-key gap (Finding 3.1) would be caught immediately if this script covered mobile.

---

## 4. Duplication to Consolidate

| Duplicate Pattern | Found In | Action |
|---|---|---|
| `flattenKeys` / `getAllKeys` / `flattenObject` | `i18n-sync.spec.ts`, `contract-validation.spec.ts`, `validate-locales.mjs`, `mobile/i18n.test.ts` | Export from `catalog-core.ts` and import everywhere |
| `isRecord()` guard | `catalog-core.ts` (as `isCatalogRecord`), `catalog-integrity.ts`, `i18n-sync.spec.ts`, `contract-validation.spec.ts`, all scripts | Already exported as `isCatalogRecord` — the others just re-implement it locally |
| `extractPlaceholders()` | `catalog-integrity.ts`, `contract-validation.spec.ts` | Consolidate into one export from `catalog-core.ts` |
| `collectLeafKeys` / `leafCount` | `mobile-runtime.spec.ts`, `i18n-sync.spec.ts` | Same function, different names |

---

## 5. Shared Component Opportunities (No Overengineering)

These are cases where the same logic is re-implemented, not hypothetical abstractions.

### 5.1 Export More Utilities from `catalog-core.ts`

Currently exported: `mergeCatalogs`, `getCatalogValue`, `interpolateCatalogValue`, `resolveBrandPlaceholders`, `isCatalogRecord`.

Should also export: `flattenCatalog(obj) → Record<string, string>` and `extractPlaceholders(value) → string[]`.

Both are already implemented in multiple places. Moving them into `catalog-core.ts` removes 4+ independent copies.

### 5.2 Mobile Catalog Sync Script

A `sync-mobile-keys.mjs` that scaffolds missing keys from `mobile/en-in.json` into `mobile/hi-in.json` and `mobile/ne-np.json` with empty strings as placeholders. Mirrors the existing pattern exactly.

### 5.3 Mobile `ne-in.json` Override in `mobile.ts`

One missing import + one entry in `mobileOverrides` map in `mobile.ts`. Closes the ne_IN legal content gap (Finding 3.5).

---

## 6. Missing Tests

| Gap | What's Missing |
|---|---|
| Mobile catalog completeness | No test asserting `hi-in.json` and `ne-np.json` key count ≥ reference vs `en-in.json` |
| Web key existence | No test asserting `t('key')` resolves to non-key string for all literal keys used in web source |
| Mobile override parity | No test asserting `mobile.ts` loads all override files that `overrides/index.ts` loads |
| `CANONICAL_LEGAL_FALLBACK_KEYS` | No test asserting each key exists in `en.json` |
| Override structural check | No test preventing a key in an override that has no base counterpart |

---

## 7. Summary Table

| # | Finding | Severity | Effort |
|---|---|---|---|
| 3.1 | hi-in and ne-np mobile catalogs silently missing 373 keys | **High** | Content (translation work) |
| 3.2 | No mobile catalog sync script | **High** | Low (script) |
| 3.3 | 80+ static imports in mobile.ts — no codegen | Medium | Medium |
| 3.4 | `overrides/index.ts` has no package boundary guard | Low | Low |
| 3.5 | `ne-in.json` override not loaded by mobile | **High** | Low (one import) |
| 3.6 | `quick_requests` namespace naming inconsistency (snake vs camel) | Low | Doc only |
| 3.7 | `onboarding.*`, `about.*`, `faq.*`, `safety.*` sit at mobile catalog root | Medium | Medium (rename) |
| 3.8 | `common.*` has two separate populations across files | Medium | Medium (rename) |
| 3.9 | Web has no TypeScript key safety (any string accepted by `t()`) | **High** | High |
| 3.10 | API's two i18n usages follow slightly different patterns | Low | None needed |
| 3.11 | `CANONICAL_LEGAL_FALLBACK_KEYS` has no governance docs or test | Low | Low |
| 3.12 | `validate-locales.mjs` doesn't cover mobile catalogs | Medium | Low |
| 4.x | `flattenKeys`, `isRecord`, `extractPlaceholders`, `leafCount` duplicated in 4+ files | Medium | Low |

---

## 8. What to Do First (Prioritized)

1. **Fix `ne-in.json` missing from `mobile.ts`** — one import, one map entry. Actual legal content bug.
2. **Add mobile catalog completeness test** — assert hi-in and ne-np structurally match en-in. Catches 3.1 in CI.
3. **Write `sync-mobile-keys.mjs`** — mirrors the existing sync script for mobile catalog. Closes the 373-key gap by scaffolding missing keys for translator pickup.
4. **Consolidate `flattenKeys` / `isRecord` / `extractPlaceholders`** — export from `catalog-core.ts`, remove 4+ copies from tests and scripts.
5. **Extend `validate-locales.mjs` to cover mobile** — adds mobile catalog check to the existing validation path.
6. **Rename root-level mobile catalog namespaces** — move `onboarding`, `about`, `faq`, `safety`, `common` under `mobile.*`. Update call sites. Makes separation explicit and safe.
7. **Web key type safety** — generate a `WebCopyKey` type from `en.json` (same DotPath pattern as `MobileCopyKey`) and tighten `t()` signature. Biggest DX improvement but most call-site changes.
8. **Document `CANONICAL_LEGAL_FALLBACK_KEYS` governance** — short comment + one test asserting each key exists in `en.json`.

---

*Read-only review. No source files were modified.*
