# UAT visual sweep manifest (2026-08-24)

Capture transport: private SSH forward `localhost:18080 -> 161.118.161.98:8080`; public unauthenticated pages; Playwright browser emulation (not physical-device proof).

## Routes captured

| Route | Mobile | Desktop | Result |
|---|---|---|---|
| `/en-in/contests` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/contests-index-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/contests-index-desktop.png` | Renders; document/body scroll width 382 at 390px |
| `/en-in/contests/human-e2e-contest-1786847435709` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/contest-detail-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/contest-detail-desktop.png` | Renders; no horizontal overflow |
| `/en-in/opportunities` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/opportunities-index-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/opportunities-index-desktop.png` | Renders; no horizontal overflow |
| `/en-in/opportunities/human-e2e-opportunity-1786847435709` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/opportunity-detail-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/opportunity-detail-desktop.png` | Renders; no horizontal overflow |
| `/en-in/events` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/events-index-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/events-index-desktop.png` | Renders; no horizontal overflow |
| `/en-in/events/gallery-lifecycle-event-1786830037952` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/event-detail-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/event-detail-desktop.png` | Renders; no horizontal overflow |
| `/en-in/profile?location=Bengaluru%2C%20Karnataka%2C%20IN&lat=12.9716&lon=77.5946&sort=distance` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/discover-artists-mobile.png` | `/Users/hexa/Desktop/tfp-main-orchestator/uat-visual-sweep-20260824/discover-artists-desktop.png` | Renders; filters/cards fit; no horizontal overflow |

Viewport sizes: mobile 390x844; desktop 1440x900. Full-page screenshots were requested for each route.

## Findings

- All seven representative public route types rendered through the forward.
- No horizontal overflow was observed (`document.documentElement.scrollWidth` and `document.body.scrollWidth` were 382px at 390px viewport).
- Discover Artists desktop screenshot shows a clean, spacious layout: single creator card, aligned filter controls, no dense/overlapping regions.
- Browser console emitted three CSP errors per route while running through `localhost:18080`: telemetry/location requests attempted to connect to the Cloudflare Access login host, which is not in the forwarded page's `connect-src`. This is a local-forward harness artifact; direct UAT was Access-gated and no authenticated browser session was available. It should not be treated as a confirmed production/UAT application defect without a direct Access-authenticated pass.
