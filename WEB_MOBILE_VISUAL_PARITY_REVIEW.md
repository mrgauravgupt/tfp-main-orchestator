# WEB <-> MOBILE VISUAL PARITY & SCREEN-BY-SCREEN AUDIT REVIEW

> **Forensic Visual Verification & Comparison Report**
> **Document Version:** 1.0.0
> **Execution Date:** 22 August 2026
> **Testing Viewport:** iPhone 17 Pro Baseline (`402 × 874 pt/px`, `deviceScaleFactor: 2`)
> **Live Runtime Targets:** Responsive Web (`http://localhost:3000/en-in`) vs Native Expo Mobile (`http://localhost:8081`)
> **Data Environment:** Local PostgreSQL API (`http://localhost:4000/api/v1`) with seed-login bridge

---

## 1. Executive Visual Parity Summary

This visual audit report presents live visual captures of the Web application and Native Mobile application executed simultaneously on identical mobile viewports (`402 × 874 pt/px`). Every major user journey—including discovery, listings, detail split layouts, creation wizards, authenticated dashboards, account settings, legal policies, and 404 error boundaries—was rendered with real local database records.

### Key Visual Parity Highlights
- **High Visual Alignment:** Core brand gradients, color palettes (`#05030a` base background, `#0d0713` surface, `#151021` elevated surface), typography scales (`Inter`), and primary buttons demonstrate unified visual hierarchy.
- **Content Boundary Precision:** Web captures were bounded to avoid whitespace below footers.
- **Annotated Mobile Screenshots:** All mobile screenshots feature distinct red callout tags (`🔍 PARITY DEFECT: [...]`) that highlight visual, structural, and semantic discrepancies.

## 2. Screen-by-Screen Visual Comparison Ledger

### 1. Home Screen (`01-home`)

- **Web Route:** `http://localhost:3000/en-in`
- **Mobile Route:** `http://localhost:8081/`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Home Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-01-home.png) | ![Mobile Annotated - Home Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-01-home.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-COPY-02] Hardcoded Hero Tagline ("Connect. Collaborate. Create."):**
  - *Web:* Localizes hero tagline via translation catalog (`{t('home.hero_title_accent')}`).
  - *Mobile:* Hardcodes English string literal `"Connect. Collaborate. Create."` in `HomeScreen.tsx:157`.
- **[F-NAV-01] Bottom Navigation: Native 5-Tab Shell vs 4-Tab Bar:**
  - *Web:* Renders persistent 4-item public nav bar (Home: `layout-grid`, Opportunities, Contests, Events) with pink active pill.
  - *Mobile:* Switches between 5-tab shell (Home: `home` house icon) and 4-item `UniversalBottomNav` (Home: `layout-grid`) with cyan glow active container.
- **[F-LAYOUT-01] Screen Gutter 12px on Mobile vs 16px on Web:**
  - *Web:* Standard screen gutter padding is 16px (`1rem`).
  - *Mobile:* Screen gutter padding is 12px (`spacing.md`), placing content 4px closer to outer bezels.

---

### 2. Search & Discovery Screen (`02-search`)

- **Web Route:** `http://localhost:3000/en-in/search`
- **Mobile Route:** `http://localhost:8081/search`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Search & Discovery Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-02-search.png) | ![Mobile Annotated - Search & Discovery Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-02-search.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-COPY-03] Hardcoded "Portfolio" Search Tag Chip:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.
- **[F-NAV-01] Dual-Bar Nav Transition:**
  - *Web:* Renders persistent 4-item public nav bar (Home: `layout-grid`, Opportunities, Contests, Events) with pink active pill.
  - *Mobile:* Switches between 5-tab shell (Home: `home` house icon) and 4-item `UniversalBottomNav` (Home: `layout-grid`) with cyan glow active container.
- **[F-ICON-02] Location Detect Crosshair vs Pin Glyph:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 3. Opportunities Listing Screen (`03-opportunities-list`)

- **Web Route:** `http://localhost:3000/en-in/opportunities`
- **Mobile Route:** `http://localhost:8081/opportunities`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Opportunities Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-03-opportunities-list.png) | ![Mobile Annotated - Opportunities Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-03-opportunities-list.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-NAV-01] Universal Bottom Nav Bar Swap (Cyan Glow & Grid Icon):**
  - *Web:* Renders persistent 4-item public nav bar (Home: `layout-grid`, Opportunities, Contests, Events) with pink active pill.
  - *Mobile:* Switches between 5-tab shell (Home: `home` house icon) and 4-item `UniversalBottomNav` (Home: `layout-grid`) with cyan glow active container.
- **[F-HEAD-01] Hardcoded "TFP PLATFORM" Header Title:**
  - *Web:* Brand title uses localized `{t('layout.brand_short')}`; globe button opens in-place country modal.
  - *Mobile:* Hardcodes `"TFP PLATFORM"` in `StackHeader.tsx:39`; globe pill redirects to `/settings`.
- **[F-LAYOUT-02] Card Inner Padding: 12px Mobile vs 16-20px Web:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 4. Opportunity Detail Screen (`04-opportunity-detail`)

- **Web Route:** `http://localhost:3000/en-in/opportunities/intimate-wear-editorial`
- **Mobile Route:** `http://localhost:8081/opportunities/cmsr2sk6w00cmvase0g8h0kq9`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Opportunity Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-04-opportunity-detail.png) | ![Mobile Annotated - Opportunity Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-04-opportunity-detail.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-BORDER-01] Extra 36x36px Bordered Decorative Icon Bubble:**
  - *Web:* Renders naked icon inline within detail rows.
  - *Mobile:* Wraps detail icons inside an extra 36×36px bordered bubble with `colors.primarySoft` background.
- **[F-LAYOUT-03] Vertical Section Spacing: 16px Gap vs 24px Margin:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.
- **[F-HEAD-01] Stack Header Title Hardcoding & Settings Redirection:**
  - *Web:* Brand title uses localized `{t('layout.brand_short')}`; globe button opens in-place country modal.
  - *Mobile:* Hardcodes `"TFP PLATFORM"` in `StackHeader.tsx:39`; globe pill redirects to `/settings`.

---

### 5. Opportunity Create Screen (`05-opportunity-create`)

- **Web Route:** `http://localhost:3000/en-in/opportunities/create`
- **Mobile Route:** `http://localhost:8081/opportunities/create`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Opportunity Create Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-05-opportunity-create.png) | ![Mobile Annotated - Opportunity Create Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-05-opportunity-create.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ALIGN-01] Input Label Typography: 12px Regular Muted vs 13px SemiBold:**
  - *Web:* Form input labels use 13px SemiBold text (`#e2e8f0`).
  - *Mobile:* Form input labels use 12px Regular text (`#94a3b8`).
- **[F-TOKEN-03] Choice Chip Selection Accent: Gold vs Pink:**
  - *Web:* Active multi-choice chips highlight with Primary Pink (`#ec4899`) border and tint.
  - *Mobile:* Active choice chips highlight with Gold (`#f2d28a`) border and tint.

---

### 6. Events Listing Screen (`06-events-list`)

- **Web Route:** `http://localhost:3000/en-in/events`
- **Mobile Route:** `http://localhost:8081/events`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Events Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-06-events-list.png) | ![Mobile Annotated - Events Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-06-events-list.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-NAV-01] Universal Nav Bar Swap:**
  - *Web:* Renders persistent 4-item public nav bar (Home: `layout-grid`, Opportunities, Contests, Events) with pink active pill.
  - *Mobile:* Switches between 5-tab shell (Home: `home` house icon) and 4-item `UniversalBottomNav` (Home: `layout-grid`) with cyan glow active container.
- **[F-BG-01] Card Surface Elevation Contrast Nuance:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 7. Event Detail Screen (`07-event-detail`)

- **Web Route:** `http://localhost:3000/en-in/events/cmsr2smz109rwvase6idgwczo`
- **Mobile Route:** `http://localhost:8081/events/cmsr2smz109rvvasehr7vru0n`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Event Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-07-event-detail.png) | ![Mobile Annotated - Event Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-07-event-detail.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-BORDER-01] Extra Decorative Bordered Icon Bubble:**
  - *Web:* Renders naked icon inline within detail rows.
  - *Mobile:* Wraps detail icons inside an extra 36×36px bordered bubble with `colors.primarySoft` background.
- **[F-LAYOUT-03] Vertical Content Rhythm 16px vs 24px:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 8. Event Create Screen (`08-event-create`)

- **Web Route:** `http://localhost:3000/en-in/events/create`
- **Mobile Route:** `http://localhost:8081/events/create`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Event Create Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-08-event-create.png) | ![Mobile Annotated - Event Create Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-08-event-create.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ALIGN-01] Input Label Typography & Contrast Mismatch:**
  - *Web:* Form input labels use 13px SemiBold text (`#e2e8f0`).
  - *Mobile:* Form input labels use 12px Regular text (`#94a3b8`).
- **[F-FORM-02] Native Date/Time Sheet Adapters vs HTML Date Inputs:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 9. Contests Listing Screen (`09-contests-list`)

- **Web Route:** `http://localhost:3000/en-in/contests`
- **Mobile Route:** `http://localhost:8081/contests`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Contests Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-09-contests-list.png) | ![Mobile Annotated - Contests Listing Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-09-contests-list.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-NAV-01] Bottom Navigation Bar Swap:**
  - *Web:* Renders persistent 4-item public nav bar (Home: `layout-grid`, Opportunities, Contests, Events) with pink active pill.
  - *Mobile:* Switches between 5-tab shell (Home: `home` house icon) and 4-item `UniversalBottomNav` (Home: `layout-grid`) with cyan glow active container.

---

### 10. Contest Detail Screen (`10-contest-detail`)

- **Web Route:** `http://localhost:3000/en-in/contests/cmsr2slka05nxvasefbs1f05l`
- **Mobile Route:** `http://localhost:8081/contests/cmsr2slka05nxvasefbs1f05l`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Contest Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-10-contest-detail.png) | ![Mobile Annotated - Contest Detail Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-10-contest-detail.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ROUTE-02] Embedded Submissions Tab vs Dedicated Standalone Web Gallery Route:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.
- **[F-BORDER-01] Decorative Bordered Icon Bubbles:**
  - *Web:* Renders naked icon inline within detail rows.
  - *Mobile:* Wraps detail icons inside an extra 36×36px bordered bubble with `colors.primarySoft` background.

---

### 11. Authentication Login Screen (`11-auth-login`)

- **Web Route:** `http://localhost:3000/en-in/login`
- **Mobile Route:** `http://localhost:8081/auth/login`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Authentication Login Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-11-auth-login.png) | ![Mobile Annotated - Authentication Login Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-11-auth-login.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ICON-01] OAuth Brand Icons Fallback to ImagePlus:**
  - *Web:* Renders custom brand SVGs for Google, Apple, Facebook, and GitHub.
  - *Mobile:* Unmapped in `ICON_ADAPTER`, falling back to `ImagePlus` placeholder glyph.
- **[F-MODAL-01] Destructive Screen Push Navigation vs In-Place Web Dialog:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 12. Authentication Register Screen (`12-auth-register`)

- **Web Route:** `http://localhost:3000/en-in/register`
- **Mobile Route:** `http://localhost:8081/auth/register`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Authentication Register Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-12-auth-register.png) | ![Mobile Annotated - Authentication Register Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-12-auth-register.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ICON-01] Missing OAuth Brand SVG Icon Mappings:**
  - *Web:* Renders custom brand SVGs for Google, Apple, Facebook, and GitHub.
  - *Mobile:* Unmapped in `ICON_ADAPTER`, falling back to `ImagePlus` placeholder glyph.
- **[F-ALIGN-01] Form Field Label Size and Contrast Difference:**
  - *Web:* Form input labels use 13px SemiBold text (`#e2e8f0`).
  - *Mobile:* Form input labels use 12px Regular text (`#94a3b8`).

---

### 13. Public Profile Screen (`13-public-profile`)

- **Web Route:** `http://localhost:3000/en-in/profile/aarav-studio`
- **Mobile Route:** `http://localhost:8081/profile/aarav-studio`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Public Profile Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-13-public-profile.png) | ![Mobile Annotated - Public Profile Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-13-public-profile.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-HEAD-01] Stack Header Title Hardcoded ("TFP PLATFORM"):**
  - *Web:* Brand title uses localized `{t('layout.brand_short')}`; globe button opens in-place country modal.
  - *Mobile:* Hardcodes `"TFP PLATFORM"` in `StackHeader.tsx:39`; globe pill redirects to `/settings`.
- **[F-GALLERY-01] Lightbox Controls: Chevrons vs Arrows:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 14. Edit Profile Screen (`14-profile-edit`)

- **Web Route:** `http://localhost:3000/en-in/profile/edit`
- **Mobile Route:** `http://localhost:8081/profile/edit`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Edit Profile Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-14-profile-edit.png) | ![Mobile Annotated - Edit Profile Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-14-profile-edit.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ALIGN-01] Input Label Typography: 12px Regular Muted vs 13px SemiBold:**
  - *Web:* Form input labels use 13px SemiBold text (`#e2e8f0`).
  - *Mobile:* Form input labels use 12px Regular text (`#94a3b8`).

---

### 15. Creator Onboarding Screen (`15-profile-onboarding`)

- **Web Route:** `http://localhost:3000/en-in/login?setup=1`
- **Mobile Route:** `http://localhost:8081/profile/onboarding`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Creator Onboarding Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-15-profile-onboarding.png) | ![Mobile Annotated - Creator Onboarding Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-15-profile-onboarding.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-FORM-01] 2-Step Multi-Screen Wizard vs 1-Step Compact Form:**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.
- **[F-COPY-01] Conflicting i18n Consent Text ("I accept the Terms..."):**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 16. Referral Center Screen (`16-referrals`)

- **Web Route:** `http://localhost:3000/en-in/profile/referrals`
- **Mobile Route:** `http://localhost:8081/profile/referrals`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Referral Center Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-16-referrals.png) | ![Mobile Annotated - Referral Center Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-16-referrals.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-TOKEN-01] Referral Palette Structure Drift ({ink, paper...} vs {dark, light}):**
  - *Observation:* Discrepancy confirmed via runtime DOM inspection and visual comparison.

---

### 17. Inbox / Messages Screen (`17-inbox`)

- **Web Route:** `http://localhost:3000/en-in/messages`
- **Mobile Route:** `http://localhost:8081/inbox`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Inbox / Messages Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-17-inbox.png) | ![Mobile Annotated - Inbox / Messages Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-17-inbox.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-EMPTY-01] Empty State Namespace (mobile.inbox.noMessagesTitle vs messages.empty_title):**
  - *Web:* Uses shared keys `listing.no_items_found`, `activity.empty_title`, `messages.empty_title`.
  - *Mobile:* Declares custom `mobile.opportunities.*`, `mobile.inbox.*` namespaces and divergent icons.

---

### 18. Activity / Notifications Screen (`18-activity`)

- **Web Route:** `http://localhost:3000/en-in/notifications`
- **Mobile Route:** `http://localhost:8081/activity`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Activity / Notifications Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-18-activity.png) | ![Mobile Annotated - Activity / Notifications Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-18-activity.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-EMPTY-01] Empty State Icon: "inbox" vs "bell":**
  - *Web:* Uses shared keys `listing.no_items_found`, `activity.empty_title`, `messages.empty_title`.
  - *Mobile:* Declares custom `mobile.opportunities.*`, `mobile.inbox.*` namespaces and divergent icons.

---

### 19. Quick Requests Screen (`19-quick-requests`)

- **Web Route:** `http://localhost:3000/en-in/quick-requests`
- **Mobile Route:** `http://localhost:8081/quick-requests`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Quick Requests Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-19-quick-requests.png) | ![Mobile Annotated - Quick Requests Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-19-quick-requests.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-EMPTY-01] Empty State Icon: "file-text" vs "inbox":**
  - *Web:* Uses shared keys `listing.no_items_found`, `activity.empty_title`, `messages.empty_title`.
  - *Mobile:* Declares custom `mobile.opportunities.*`, `mobile.inbox.*` namespaces and divergent icons.

---

### 20. Settings Screen (`20-settings`)

- **Web Route:** `http://localhost:3000/en-in/settings`
- **Mobile Route:** `http://localhost:8081/settings`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Settings Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-20-settings.png) | ![Mobile Annotated - Settings Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-20-settings.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-I18N-02] 100+ Locales Listed in Selector vs Only 3 Bundled Catalogs:**
  - *Web:* Supports 100+ locales with complete dictionaries.
  - *Mobile:* Selector lists 100+ locales, but only 3 (`en_IN`, `hi_IN`, `ne_NP`) are bundled.

---

### 21. Help & FAQ Screen (`21-help`)

- **Web Route:** `http://localhost:3000/en-in/help`
- **Mobile Route:** `http://localhost:8081/help`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Help & FAQ Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-21-help.png) | ![Mobile Annotated - Help & FAQ Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-21-help.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-HEAD-01] Stack Header Title Hardcoded ("TFP PLATFORM"):**
  - *Web:* Brand title uses localized `{t('layout.brand_short')}`; globe button opens in-place country modal.
  - *Mobile:* Hardcodes `"TFP PLATFORM"` in `StackHeader.tsx:39`; globe pill redirects to `/settings`.

---

### 22. Terms of Service Screen (`22-legal-terms`)

- **Web Route:** `http://localhost:3000/en-in/terms`
- **Mobile Route:** `http://localhost:8081/legal/terms`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Terms of Service Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-22-legal-terms.png) | ![Mobile Annotated - Terms of Service Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-22-legal-terms.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ROUTE-01] Top-Level URL /terms Drops to Null in Route Resolver:**
  - *Web:* Server routes `/terms`, `/privacy`, etc. resolve directly.
  - *Mobile:* `mapPlatformHrefToMobileRoute` drops `/terms` and `/privacy` to `null`.

---

### 23. Privacy Policy Screen (`23-legal-privacy`)

- **Web Route:** `http://localhost:3000/en-in/privacy`
- **Mobile Route:** `http://localhost:8081/legal/privacy`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - Privacy Policy Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-23-legal-privacy.png) | ![Mobile Annotated - Privacy Policy Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-23-legal-privacy.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-ROUTE-01] Top-Level URL /privacy Drops to Null in Route Resolver:**
  - *Web:* Server routes `/terms`, `/privacy`, etc. resolve directly.
  - *Mobile:* `mapPlatformHrefToMobileRoute` drops `/terms` and `/privacy` to `null`.

---

### 24. 404 Not Found Screen (`24-not-found`)

- **Web Route:** `http://localhost:3000/en-in/404`
- **Mobile Route:** `http://localhost:8081/parity-not-found-route`

#### Visual Evidence (Side-by-Side Comparison)

| Responsive Web (402px Viewport) | Native Mobile (Annotated with Defect Tags) |
| :---: | :---: |
| ![Web - 404 Not Found Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/web-24-not-found.png) | ![Mobile Annotated - 404 Not Found Screen](/Users/hexa/.gemini/antigravity/brain/3c72a34f-29e1-4160-bf3b-ec78284193ed/screenshots/mobile-24-not-found.png) |

#### Marked Parity Discrepancies & Detailed Observations

- **[F-LAYOUT-01] 12px vs 16px Gutter Padding:**
  - *Web:* Standard screen gutter padding is 16px (`1rem`).
  - *Mobile:* Screen gutter padding is 12px (`spacing.md`), placing content 4px closer to outer bezels.

---

## 3. Summary of Visual Findings & Recommendations

| Category | Key Visual Discrepancy | Recommended Visual Alignment |
| --- | --- | --- |
| **Navigation** | Dual-bar navigation & Home glyph shift (`home` vs `layout-grid`) | Standardize bottom nav bar items and icons across all screens. |
| **Active Accents** | Choice chip active color Pink on Web vs Gold on Mobile | Unify active choice chip highlight token in shared design system. |
| **Gutters & Spacing** | Screen gutter padding 16px on Web vs 12px on Mobile | Standardize base screen container horizontal padding to 16px. |
| **Detail Icons** | Extra 36×36px bordered icon bubble on Mobile detail cards | Align detail info card icon container styling across surfaces. |
| **Form Labels** | Form label typography 13px SemiBold on Web vs 12px Regular on Mobile | Unify form control label typography token. |
| **Brand Icons** | Brand OAuth icons falling back to `ImagePlus` on Mobile | Add SVG paths for Google, Apple, Facebook, GitHub to `ICON_ADAPTER`. |
| **Header Shell** | Hardcoded `"TFP PLATFORM"` header title on Mobile | Localize header title using `{t('layout.brand_short')}`. |
