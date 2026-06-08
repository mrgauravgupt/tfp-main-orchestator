# Collage Service & UAT Environment Configuration Guide

**Updated:** June 8, 2026  
**Status:** ✅ Complete - All systems configured and documented

---

## 📁 Collage Service Location & Structure

### Repository Location
```
/collage-service/          # Production Fastify service for generating mood-board collages
├── src/
│   ├── index.ts           # Main application entry point
│   ├── handlers/          # API request handlers
│   ├── utils/             # Utility functions
│   └── types/             # TypeScript type definitions
├── scripts/
│   ├── oci/
│   │   ├── deploy-prod-7003.sh      # OCI deployment script (port 7003)
│   │   └── deploy-to-instance.sh    # Generic instance deployment
│   └── [other scripts]
├── package.json           # Dependencies and build scripts
├── tsconfig.json          # TypeScript configuration
├── README.md              # Service documentation
└── .env.example           # Environment variable template
```

### Key Files

**Main Service Code:**
- `src/index.ts` - Fastify server, routes, health checks
- API endpoints:
  - `GET /health/live` - Process liveness (always available)
  - `GET /health/ready` - Readiness check for load balancers
  - `POST /api/v1/generate-collage` - Generate collage from images

**Configuration:**
- `package.json` - Build scripts: `pnpm dev`, `pnpm build`, `pnpm start`
- `.env.example` - Required environment variables
- `tsconfig.json` - TypeScript compilation settings

---

## 🚀 How Collage Service is Deployed

### OCI Deployment Architecture

```
┌─────────────────────────────────────────────────────────┐
│  OCI Instance: 80.225.208.169                           │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐         ┌─────────────────┐       │
│  │ Public: Port    │         │ Public: Port    │       │
│  │ 7001 (nginx)    │         │ 7003 (nginx)    │       │
│  │ AI Inference    │         │ Collage Service │       │
│  └────────┬────────┘         └────────┬────────┘       │
│           │                           │                 │
│  ┌────────▼────────┐         ┌────────▼────────┐       │
│  │ Private: Port   │         │ Private: Port   │       │
│  │ 7002 (uvicorn)  │         │ 7004 (node)     │       │
│  │ AI Inference    │         │ Collage Service │       │
│  └─────────────────┘         └─────────────────┘       │
│                                                         │
│  Services:                                              │
│  - ai-inference-platform (systemd service)             │
│  - collage-service (systemd service)                    │
│  - folder-moderation (cron: 23:00 UTC daily)           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Deployment Scripts

**Individual Service Deployment:**

```bash
# Deploy AI Inference Platform only
cd ai-inference-platform
bash scripts/oci/deploy-prod-7001.sh

# Deploy Collage Service only
cd collage-service
bash scripts/oci/deploy-prod-7003.sh
```

**Combined Deployment (Recommended):**

```bash
# Deploy both services in sequence
bash scripts/oci/deploy-both-services.sh

# Deploy only one service
DEPLOY_AI=false bash scripts/oci/deploy-both-services.sh        # Collage only
DEPLOY_COLLAGE=false bash scripts/oci/deploy-both-services.sh   # AI only
```

### Environment Variables During Deployment

**Collage Service expects:**
```bash
COLLAGE_SERVICE_API_KEY     # Optional: Enables API-key authentication
COLLAGE_MAX_IMAGES          # Default: 5 (max source images per collage)
COLLAGE_MAX_TARGET_WIDTH    # Default: 1600 (upper bound for width)
COLLAGE_BODY_LIMIT_BYTES    # Default: 10485760 (10MB)
COLLAGE_IMAGE_FETCH_TIMEOUT_MS # Default: 15000 (15 seconds)
```

---

## 🛠️ Managing TFP with UAT Environment

### Using manage-tfp.sh

```bash
cd tfp-workspace
bash scripts/manage-tfp.sh
```

### Menu Structure (Updated)

**Main Menu:**
```
1) Stack & Environment
2) Data & Seed Runners          ← NEW seed commands here
3) Moderation Runners
4) UI Coverage Runners
5) Reports & Artifacts
6) Utilities
0) Exit
```

**Stack & Environment Menu (Updated):**
```
1) Stop app
2) Start app
3) Restart app
4) Environment doctor
5) Storage doctor
6) Storage local smoke
7) Workspace typecheck
8) Change environment    ← NEW UAT option here
9) Show environment summary
b) Back
0) Exit
```

**Change Environment Options (NEW):**
```
1) local       (local storage, local DB)
2) development (Backblaze storage, dev DB)
3) uat         (Backblaze storage, UAT DB with collage worker) ✨ NEW
4) production  (production config, prod DB)
```

### Data & Seed Runners Menu (Updated)

**NEW SEED COMMANDS:**
```
15) Seed real data quick (with collage generation) ✨ NEW
    └─ pnpm qa:seed:real:quick
    └─ Creates real users, opportunities, and triggers collage worker

16) Seed real data quick (headed browser) ✨ NEW
    └─ pnpm qa:create-data:seed:real:quick -- --headed
    └─ Interactive seeding with browser automation
```

**Environment Awareness:**
```
All seed commands use the environment selected in step 8 (Change environment)

Examples:
  Select UAT → Run "Seed real data quick" → Updates tfp_photographers_uat DB
  Select local → Run "Seed real data quick" → Updates tfp_photographers_local DB
  Select dev → Run "Seed real data quick" → Updates tfp_photographers_dev DB
```

---

## 🌱 Seed Workflow with Collage Generation

### How Seeding Works in UAT

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Select Environment: UAT                                   │
│    └─ TFP_ENV_TARGET=uat                                     │
│    └─ DATABASE_URL=...tfp_photographers_uat                  │
│    └─ STORAGE_ROOT_PREFIX=tfp-uat/                           │
│                                                              │
│ 2. Run Seed: "Seed real data quick"                         │
│    └─ bash ./scripts/pnpm-node20.sh qa:seed:real:quick      │
│                                                              │
│ 3. Seed Script Creates:                                      │
│    ├─ Real users with portfolios (photos)                   │
│    ├─ Opportunities with mood_board_images                  │
│    ├─ Events, Contests, Applications                        │
│    └─ Stores images in B2: tfp-app-uat-public/uploads/...   │
│                                                              │
│ 4. Opportunity Created Hook Fires                           │
│    └─ Creates opportunity records with mood_board_images    │
│    └─ Database: opportunities.mood_board_image_urls         │
│                                                              │
│ 5. Collage Worker Detects Opportunity                       │
│    ├─ Polls opportunities table every 60 seconds            │
│    ├─ Finds opportunities with mood_board_images            │
│    ├─ Generates collage from mood board images              │
│    └─ Uploads to B2: tfp-app-uat-public/uploads/opportunities/
│                                                              │
│ 6. Collage Status Updated                                   │
│    └─ opportunity.mood_board_collage_image_url = B2 URL     │
│    └─ opportunity.mood_board_collage_status = "READY"       │
│                                                              │
│ 7. Home Page Dashboard Shows Status                         │
│    └─ Real-time polling every 30 seconds                    │
│    └─ Displays "Ready: 3/10" (for example)                  │
│    └─ Lists recent opportunities with status                │
└─────────────────────────────────────────────────────────────┘
```

### Database Schema Integration

**Opportunities Table (UAT Database):**
```sql
opportunities (
  id UUID PRIMARY KEY,
  title TEXT,
  description TEXT,
  
  -- Mood Board Fields (NEW)
  mood_board_image_urls TEXT[]           -- URLs of images for collage generation
  mood_board_collage_image_url TEXT      -- Output collage image URL
  mood_board_collage_status VARCHAR      -- READY, PROCESSING, PENDING, FAILED
  mood_board_collage_error TEXT          -- Error message if failed
  mood_board_collage_attempts INT        -- Retry count
  mood_board_collage_generated_at TIMESTAMP -- When collage was generated
  
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  ...
)
```

### Real Seed Data Example

When you run `pnpm qa:seed:real:quick` in UAT:

**Created Data:**
```
Users:         ~5-10 real photographers
Profiles:      ~5-10 with complete portfolios
Photos:        ~30-50 portfolio images per photographer
Opportunities: ~5-10 with mood boards (3-5 images each)
Events:        ~2-3 with registrations
Contests:      ~2-3 with submissions
```

**Collage Generation:**
```
✓ Opportunity 1: 3 images → collage generated (READY)
✓ Opportunity 2: 4 images → collage generated (READY)
✓ Opportunity 3: 5 images → collage generated (READY)
✓ ...

Total in B2: 10+ generated collages in tfp-app-uat-public/uploads/opportunities/
```

---

## 🔌 Environment Resolver Configuration

**File:** `tfp-workspace/scripts/env/env-resolver.mjs`

**Updated to Support UAT:**

```javascript
const TARGET_ALIASES = new Map([
  ['local', 'local'],
  ['test', 'test'],
  ['qa', 'local'],
  ['dev', 'development'],
  ['development', 'development'],
  ['uat', 'uat'],              // ✨ NEW
  ['staging', 'uat'],          // ✨ Alias for UAT
  ['prod', 'production'],
  ['production', 'production'],
]);

const ENV_DATABASE_NAMES = {
  local: 'tfp_photographers_local',
  test: 'tfp_photographers_test',
  development: 'tfp_photographers_dev',
  uat: 'tfp_photographers_uat',          // ✨ NEW
  production: 'tfp_photographers_prod',
};

// In getFileCandidates():
if (target === 'uat') {
  return ['.env.uat', 'apps/api/.env', '.env.uat.local', 'apps/api/.env.local'];
}

// In applyTargetDefaults():
if (target === 'uat') {
  env.STORAGE_ROOT_PREFIX = 'tfp-uat/';
  return;
}
```

---

## 📋 Step-by-Step: Seed Real Data in UAT

### 1. Start the app stack (if not running)

```bash
cd tfp-workspace
bash scripts/manage-tfp.sh
→ Select "Stack & Environment" (1)
→ Select "Start app" (2)
```

### 2. Select UAT environment

```bash
bash scripts/manage-tfp.sh
→ Select "Stack & Environment" (1)
→ Select "Change environment" (8)
→ Select "uat" (3)
```

**Verify environment:**
```bash
bash scripts/manage-tfp.sh
→ Select "Stack & Environment" (1)
→ Select "Show environment summary" (9)
# Should show:
# - target: uat
# - database: tfp_photographers_uat
# - storage: tfp-uat/
```

### 3. Run seed with collage generation

```bash
bash scripts/manage-tfp.sh
→ Select "Data & Seed Runners" (2)
→ Select "Seed real data quick (with collage generation)" (15)
→ Wait for completion...
```

### 4. Monitor collage generation

```bash
# In another terminal, watch the collage status in real-time:
curl -s http://localhost:7001/api/v1/collage-status | jq .

# Or open home page in browser:
# http://localhost:3000/
# → Look for "Mood Board Collage Status" card
# → Watch it update every 30 seconds as collages are generated
```

### 5. Verify results

```bash
# Check database for generated collages
psql tfp_photographers_uat -c "
  SELECT 
    id, 
    title, 
    mood_board_collage_status, 
    mood_board_collage_image_url 
  FROM opportunities 
  WHERE mood_board_image_urls IS NOT NULL
  LIMIT 10;
"

# Check B2 bucket for uploaded collages
aws s3 ls s3://tfp-app-uat-public/uploads/opportunities/ \
  --endpoint-url https://s3.us-east-005.backblazeb2.com \
  --profile b2-uat
```

---

## 🔄 Collage Service Integration Points

### How Services Communicate

```
TFP Workspace (PostgreSQL UAT)
    │
    ├─→ Creates opportunities with mood_board_images
    │
    └─→ AI Inference Platform (Port 7001/7002)
        │
        ├─→ Reads: opportunities table
        │         (mood_board_images, mood_board_collage_status)
        │
        ├─→ Collage Worker (Python background task)
        │   ├─ Polls opportunities every 60 seconds
        │   ├─ Detects opportunities with mood_board_images
        │   ├─ Calls Collage Service API for each opportunity
        │   └─ Updates mood_board_collage_image_url and status
        │
        └─→ Collage Service (Port 7003/7004)
            ├─ Receives: POST /api/v1/generate-collage
            ├─ Input: array of image URLs
            ├─ Processing:
            │  ├ Downloads images from B2/ImageKit URLs
            │  ├ Composites them into single collage image
            │  └ Returns JPEG buffer
            └─ Output: collage image

Home Page Dashboard (JavaScript)
    ├─ Polls: GET /api/v1/collage-status (every 30 seconds)
    ├─ Reads: opportunities table (status counts)
    └─ Displays: real-time collage generation stats
```

### API Integration

**Collage Worker → Collage Service:**

```bash
POST http://localhost:7003/api/v1/generate-collage
Content-Type: application/json

{
  "imageUrls": [
    "https://ik.imagekit.io/tfpphotographers_uat/portfolio/photo-1.jpg",
    "https://ik.imagekit.io/tfpphotographers_uat/portfolio/photo-2.jpg",
    "https://ik.imagekit.io/tfpphotographers_uat/portfolio/photo-3.jpg"
  ],
  "targetWidth": 1000
}

Response: JPEG image buffer (200 OK)
```

---

## 📊 Monitoring & Troubleshooting

### Check Collage Service Status

```bash
# Health check
curl http://localhost:7003/health/live
# → {"status":"ok"}

# Service logs
journalctl -u collage-service -f
# Look for:
# ✓ "Collage service listening on port 7004"
# ✗ "Error", "Connection refused"

# On OCI (via SSH)
ssh ubuntu@80.225.208.169 "journalctl -u collage-service -n 50"
```

### Check Collage Worker

```bash
# Status
curl http://localhost:7001/api/v1/collage-status | jq .

# Logs
journalctl -u ai-inference-platform -f | grep -i collage
# Look for:
# ✓ "Collage worker initialized"
# ✓ "Generated collage for opportunity"
# ✗ "Failed to generate collage"
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Collage status shows 0 ready | No opportunities with mood_board_images | Run seed data: `pnpm qa:seed:real:quick` |
| Worker not polling | Collage worker disabled | Check `config/base.yaml`: `collage_worker.enabled: true` |
| B2 upload fails | Invalid credentials | Verify `STORAGE_S3_*` env vars |
| Worker timeout | Network issue | Check database connectivity, B2 reachability |
| ImageKit errors | Wrong URL endpoint | Verify `IMAGEKIT_URL_ENDPOINT` matches actual ImageKit URL |

---

## 📚 Documentation References

- **Collage Service Details:** `collage-service/README.md`
- **AI Inference Platform:** `ai-inference-platform/COLLAGE_WORKER_DEPLOYMENT.md`
- **UAT Setup:** `UAT_ENVIRONMENT_SETUP.md`
- **Environment Configuration:** `tfp-workspace/scripts/env/env-resolver.mjs`

---

## ✅ Checklist: Deploy & Test Collage Service in UAT

- [ ] Infrastructure ready
  - [ ] `tfp_photographers_uat` database created
  - [ ] B2 UAT buckets created
  - [ ] ImageKit UAT instance configured
- [ ] Deployment
  - [ ] Run `bash scripts/oci/deploy-both-services.sh`
  - [ ] Verify both services are running
- [ ] Configuration
  - [ ] Set `AIP_ENABLE_COLLAGE_WORKER=true` before deploy
  - [ ] Set B2 and ImageKit credentials
- [ ] Testing
  - [ ] Run `pnpm qa:seed:real:quick` in UAT environment
  - [ ] Monitor `/api/v1/collage-status` endpoint
  - [ ] Check home page collage dashboard
  - [ ] Verify B2 bucket for generated collages
- [ ] Monitoring
  - [ ] Check service logs for errors
  - [ ] Monitor collage worker polling
  - [ ] Track collage generation success rate

---

**Ready to deploy and test!** 🚀
