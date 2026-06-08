# UAT Environment Setup & Configuration Guide

**Created:** June 8, 2026  
**Status:** ✅ Ready for deployment  
**Purpose:** Cloud-native UAT environment using B2 storage and ImageKit

---

## 📋 Overview

### What Was Created

1. **AI Inference Platform UAT Config** (`config/environments/uat/settings.yaml`)
   - Uses B2 storage (not local filesystem)
   - Uses ImageKit for image processing
   - Connects to TFP UAT database
   - Collage worker enabled with B2 output

2. **TFP Workspace UAT Config** (`tfp-workspace/.env.uat`)
   - Complete UAT environment template
   - All secrets marked for injection from secrets manager
   - Separate B2 buckets and database for UAT
   - ImageKit UAT instance configuration

### Environment Structure

```
Production vs UAT comparison:
┌─────────────────────────────────────────────────────────────┐
│                          FEATURE                             │
├─────────────────────────────────────────────────────────────┤
│ Storage              │ B2 (prod bucket)  │ B2 (uat bucket)  │
│ Database             │ tfp_photographers │ tfp_photographers_uat
│ ImageKit Instance    │ tfpphotographers  │ tfpphotographers_uat
│ Public URL           │ tfpphotographers  │ uat.tfpphotographers
│ CDN                  │ cdn.tfpphotographers | cdn-uat.tfpphotographers
│ API Instance         │ api.tfpphotographers | ai-api-uat.tfpphotographers
│ Collage Storage      │ prod-uploads      │ uat-uploads (same B2, different prefix)
│ Model Preloading     │ ✅ All            │ ✅ All (same as prod)
│ Debug Mode           │ ❌ false          │ ❌ false (production-like)
│ API Key Required     │ ✅ Yes            │ ✅ Yes
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Deployment Instructions

### Step 1: Set Up UAT Database

```bash
# 1. Create UAT database in TFP PostgreSQL server
psql -h <PROD_DB_HOST> -U postgres -c "CREATE DATABASE tfp_photographers_uat;"

# 2. Run migrations to create schema
cd tfp-workspace
DATABASE_URL=postgresql://USER:PASSWORD@HOST:5432/tfp_photographers_uat uv run prisma migrate deploy

# 3. Verify tables exist
psql -h <PROD_DB_HOST> -d tfp_photographers_uat -c "\dt"
```

### Step 2: Create B2 UAT Buckets

Using Backblaze B2 console:

1. **Public Bucket:** `tfp-app-uat-public`
   - Lifecycle: Keep files 30+ days for testing
   - Allowed access: Public read, authenticated write
   - CORS: Allow all origins (for testing)

2. **Private Bucket:** `tfp-app-uat-private`
   - Allowed access: Private
   - Used for sensitive collage metadata

### Step 3: Configure ImageKit UAT Instance

Contact ImageKit support or create sub-account:
- **URL Endpoint:** `ik.imagekit.io/tfpphotographers_uat`
- **Public Key:** From ImageKit dashboard
- **Private Key:** From ImageKit dashboard

### Step 4: Deploy AI Inference Platform to UAT

```bash
# Using the UAT environment
cd ai-inference-platform

# Set environment
export AIP_ENV=uat

# Install dependencies
uv sync

# Create directories
mkdir -p .runtime/uat/{analytics,models,cache/image-responses}

# Start service (example with systemd)
sudo systemctl start ai-inference-platform-uat

# Verify it's using UAT config
curl http://localhost:7001/health/live
```

### Step 5: Deploy TFP Workspace to UAT

```bash
cd tfp-workspace

# Create .env.uat.local with actual credentials
cp .env.uat .env.uat.local
# Edit .env.uat.local with real secrets

# Deploy using your standard deployment process
./scripts/deploy-uat.sh  # or equivalent
```

---

## 🔧 Configuration Details

### AI Inference Platform (UAT)

**File:** `config/environments/uat/settings.yaml`

Key settings:
```yaml
app:
  public_base_url: https://ai-api-uat.tfpphotographers.com
  
collage_worker:
  enabled: true
  # Database URL injected from TFP_DATABASE_URL env var
  # Points to: tfp_photographers_uat database
  # S3 credentials injected from STORAGE_S3_* env vars
  # Points to: tfp-app-uat-public bucket
  
models:
  # Preload same heavy models as production (Marqo, CLIP, NudeNet, YOLO, NLLB)
  # For performance testing and consistency
```

### TFP Workspace (UAT)

**File:** `tfp-workspace/.env.uat`

Environment variables divided by service:

| Category | Variables | Purpose |
|----------|-----------|---------|
| **Database** | `DATABASE_URL`, `DATABASE_DIRECT_URL` | TFP main DB (UAT) |
| **B2 Storage** | `B2_*`, `BACKBLAZE_*` | Object storage for uploads |
| **ImageKit** | `IMAGEKIT_*` | Image optimization & CDN |
| **Collage Worker** | `AIP_COLLAGE_WORKER_*`, `STORAGE_S3_*` | AI inference platform integration |
| **Security** | `JWT_SECRET`, `COOKIE_SECRET` | Auth tokens (must be different from prod) |

---

## ✅ Verification Checklist

### 1. Database Connectivity

```bash
# From AI Inference Platform
curl -X GET "http://ai-api-uat:7001/api/v1/collage-status" \
  -H "X-Internal-API-Key: <YOUR_KEY>"

# Expected response:
# {
#   "total_opportunities": 0,
#   "ready": 0,
#   "processing": 0,
#   "pending": 0,
#   "failed": 0,
#   "service_health": { "collage_service": "healthy", "last_check": "..." }
# }
```

### 2. Collage Worker Connectivity

```bash
# Check collage worker logs
journalctl -u ai-inference-platform-uat -f | grep collage

# Expected: "Collage worker initialized" and "Polling opportunities..."
```

### 3. B2 Storage Connectivity

```bash
# Check if collage uploads are going to UAT bucket
aws s3 ls s3://tfp-app-uat-public/uploads/opportunities/ \
  --endpoint-url https://s3.us-east-005.backblazeb2.com \
  --profile b2-uat

# After generating a collage, you should see files:
# - metadata.json
# - collage.png or collage.jpg
```

### 4. ImageKit Integration

```bash
# Test ImageKit image transformation
curl "https://ik.imagekit.io/tfpphotographers_uat/test.jpg?tr=w-400,h-300"

# Should return a transformed image (or 404 if test image doesn't exist)
```

---

## 🔄 Collage Service Integration

### How Collage Worker Uses UAT Config

1. **On Startup:**
   ```
   AIP_ENV=uat → loads config/environments/uat/settings.yaml
   ↓
   collage_worker.enabled=true → Worker starts
   ↓
   Reads from env vars (set during deployment):
     - TFP_DATABASE_URL=postgresql://...tfp_photographers_uat
     - STORAGE_S3_*=<B2 UAT credentials>
   ```

2. **During Processing:**
   ```
   Opportunity created in tfp_photographers_uat
   ↓
   Collage worker polls every 60 seconds
   ↓
   Generates collage image
   ↓
   Uploads to s3://tfp-app-uat-public/uploads/opportunities/<id>
   ↓
   Updates opportunity.mood_board_collage_image with B2 URL
   ```

3. **Frontend Display:**
   ```
   Home page /api/v1/collage-status endpoint
   ↓
   Queries tfp_photographers_uat → mood_board_* fields
   ↓
   Returns stats for UAT collages only
   ↓
   JS polls every 30 seconds, displays real-time status
   ```

---

## 🔐 Secrets Management

### Required Credentials (to be injected at deploy time)

```bash
# B2 Credentials (Backblaze)
B2_ACCESS_KEY_ID=<application_key_id>
B2_SECRET_ACCESS_KEY=<application_key>

# ImageKit Credentials
IMAGEKIT_PUBLIC_KEY=<public_key>
IMAGEKIT_PRIVATE_KEY=<private_key>

# Database Credentials
DATABASE_URL=postgresql://tfp_uat:PASSWORD@HOST:5432/tfp_photographers_uat

# TFP/AI Inference Platform Secrets
JWT_SECRET=<secure_random_string>
COOKIE_SECRET=<secure_random_string>
AIP__SECURITY__INTERNAL_API_KEY=<internal_api_key>
```

**Do NOT commit these to git.** Use your platform's secrets manager:
- AWS Secrets Manager
- Vault
- Environment-specific .env.uat.local (gitignore'd)

---

## 📊 Monitoring & Troubleshooting

### Check Collage Worker Status

```bash
# On the UAT deployment host
journalctl -u ai-inference-platform-uat -n 100 | grep -i collage

# Look for:
# ✅ "Collage worker initialized with database"
# ✅ "Polling opportunities table for pending collages"
# ❌ "AttributeError", "Connection refused" → debug needed
```

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Collage worker won't start | Missing DATABASE_URL | Set `TFP_DATABASE_URL=postgresql://...` |
| S3 upload fails | Wrong B2 credentials | Verify in logs, check B2 app key permissions |
| Images not in ImageKit | Endpoint mismatch | Verify IMAGEKIT_URL_ENDPOINT matches actual ImageKit URL |
| Database connection timeout | Network/firewall | Whitelist UAT server IP in DB security group |

---

## 🚦 Migration Path: Local → Dev → UAT → Prod

```
Development:
  ├─ local: Local storage, debug mode, fast iteration
  └─ dev: /dev/shm storage, remote URLs allowed

Staging:
  ├─ uat: ✨ NEW - B2 storage, ImageKit, separate DB

Production:
  └─ prod: B2 storage, ImageKit, prod DB
```

**Testing Collage Feature Flow:**
1. ✅ **Local:** Test collage logic with local images
2. ✅ **Dev:** Test with larger dataset, fast iteration
3. ✅ **UAT (new):** Test with production-like config (B2, ImageKit, external DB)
4. ✅ **Prod:** Full production deployment

---

## 📝 Environment Variables Reference

### For AI Inference Platform

To use UAT config, set:
```bash
export AIP_ENV=uat

# Collage worker will look for:
export TFP_DATABASE_URL=postgresql://...tfp_photographers_uat
export STORAGE_S3_ENDPOINT=s3.us-east-005.backblazeb2.com
export STORAGE_S3_ACCESS_KEY_ID=...
export STORAGE_S3_SECRET_ACCESS_KEY=...
export STORAGE_S3_BUCKET_NAME=tfp-app-uat-public
```

Or use the longer form:
```bash
export AIP__COLLAGE_WORKER__DATABASE_URL=...
export AIP__COLLAGE_WORKER__S3_ENDPOINT=...
export AIP__COLLAGE_WORKER__S3_ACCESS_KEY_ID=...
export AIP__COLLAGE_WORKER__S3_SECRET_ACCESS_KEY=...
export AIP__COLLAGE_WORKER__S3_BUCKET_NAME=...
```

### For TFP Workspace

```bash
# Copy template
cp tfp-workspace/.env.uat tfp-workspace/.env.uat.local

# Edit with real secrets
nano tfp-workspace/.env.uat.local

# Deploy with it
NODE_ENV=production npm run deploy -- --env=uat.local
```

---

## ✨ Next Steps

1. **Set up infrastructure:**
   - Create UAT database
   - Create UAT B2 buckets
   - Create/configure ImageKit UAT instance

2. **Inject secrets:**
   - Add credentials to deployment pipeline
   - Configure environment-specific .env.uat.local

3. **Deploy and test:**
   - Deploy AI Inference Platform with `AIP_ENV=uat`
   - Deploy TFP workspace with `.env.uat.local`
   - Verify connectivity checklist (see above)

4. **Monitor:**
   - Watch collage worker logs
   - Check home page collage status dashboard
   - Verify B2 bucket for generated files

---

## 🎯 Benefits of This Setup

✅ **Isolated Testing** - UAT doesn't affect production data  
✅ **Production-Like** - Uses same B2, ImageKit, remote DB (not local)  
✅ **Scalable** - Can spin up multiple UAT instances if needed  
✅ **Cost-Effective** - B2 storage cheaper than AWS S3  
✅ **Consistent** - Same collage worker logic as production  
✅ **Monitored** - Dashboard shows real-time collage status  

---

## 📞 Support

For issues with:
- **Collage generation:** Check `/api/v1/collage-status` endpoint
- **Database connectivity:** Verify `TFP_DATABASE_URL` and firewall rules
- **B2 storage:** Test with `aws s3 ls s3://tfp-app-uat-public/`
- **ImageKit:** Test with curl to `https://ik.imagekit.io/tfpphotographers_uat/`

See COLLAGE_WORKER_DEPLOYMENT.md for additional troubleshooting.
