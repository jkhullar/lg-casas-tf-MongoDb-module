# MongoDB Atlas - Prerequisites and Setup Guide

## Why MongoDB Atlas?

> "MongoDB Atlas eliminates operational overhead while providing enterprise-grade security, automated backups, auto-scaling, and built-in monitoring. We can provision production-ready clusters in 10 minutes via Terraform instead of spending 2-4 weeks on manual setup. All security certifications (SOC2, HIPAA, PCI-DSS) are included."

---

## Quick Comparison: Self-Managed vs MongoDB Atlas

| Criteria | Self-Managed | MongoDB Atlas |
|----------|--------------|---------------|
| **Setup Time** | 2-4 weeks | 10 minutes |
| **Monthly Cost (Production)** | $893 | $300 |
| **Operational Effort** | High (20h/month) | None |
| **SLA** | None | 99.995% |
| **Security Certifications** | DIY | Included |
| **24/7 Support** | None | Included |
| **Disaster Recovery** | Manual | Automated |
| **Scalability** | Manual | Automatic |

**Result: MongoDB Atlas saves 66% cost and eliminates operational overhead.**

---

## What We Need

### 1. MongoDB Atlas Account
- Create organization account at https://www.mongodb.com/cloud/atlas/register
- Organization Name: `LG-CASAS`

### 2. Projects (3 environments)
- `casas-dev` - Development environment
- `casas-staging` - Staging environment
- `casas-prod` - Production environment

### 3. API Keys for Terraform Automation
- **Public Key** (like a username)
- **Private Key** (like a password - shown only once!)
- **Permissions**: Organization Project Creator + Organization Owner

### 4. Project IDs
- 24-character hex string for each project (e.g., `507f1f77bcf86cd799439011`)
- Found in: Atlas Console → Project → Settings → General → Project ID

### 5. Budget Approval
**Estimated Monthly Costs:**
- Development (M10): $60/month
- Staging (M10): $60/month
- Production (M30): $300/month
- **TOTAL: ~$420/month (~$5,000/year)**

---

## Detailed Setup Checklist

### Step 1: Create MongoDB Atlas Account
- [ ] Go to https://www.mongodb.com/cloud/atlas/register
- [ ] Sign up with company email (e.g., `fedric@company.com`)
- [ ] Verify email address
- [ ] Complete onboarding survey:
  - Select "Production Use"
  - Select "GCP" as cloud provider
  - Select "Managed Service"

---

### Step 2: Create Organization
- [ ] Click "Create Organization"
- [ ] Organization Name: `LG-CASAS`
- [ ] Add organization admins:
  - [ ] Technical Lead: `<tech-lead-email>`
  - [ ] DevOps Lead: `<devops-lead-email>`
  - [ ] Other team members as needed

---

### Step 3: Setup Billing
- [ ] Navigate to: Billing → Payment Method
- [ ] Add company credit card OR setup invoice billing
- [ ] Set billing email: `<billing-team-email>`
- [ ] Configure spending alerts:
  - [ ] Alert at $400/month
  - [ ] Alert at $500/month

---

### Step 4: Create Projects
- [ ] Create project: `casas-dev`
  - [ ] Note Project ID: `________________________`
  
- [ ] Create project: `casas-staging`
  - [ ] Note Project ID: `________________________`
  
- [ ] Create project: `casas-prod`
  - [ ] Note Project ID: `________________________`

**Where to find Project ID:**
- Login to MongoDB Atlas
- Select the Project
- Go to: Settings → General → Project ID
- Copy the 24-character hex string

---

### Step 5: Generate API Keys
- [ ] Go to: Organization Settings → Access Manager → API Keys
- [ ] Click "Create API Key"
- [ ] Description: `Terraform Automation - CASAS`
- [ ] Permissions (select both):
  - [ ] Organization Project Creator
  - [ ] Organization Owner
- [ ] Click "Next"
- [ ] **IMPORTANT:** Copy and securely save both keys:
  - [ ] Public Key: `________________________`
  - [ ] Private Key: `________________________` ⚠️ **Shown only once!**
- [ ] Add IP whitelist for API key:
  - [ ] `0.0.0.0/0` (for now - will be restricted later)
  - [ ] Or add company VPN IP range

⚠️ **CRITICAL:** The Private Key is shown only once. If you lose it, you must generate new API keys.

---

### Step 6: Share Credentials with Team

**Share via secure channel (NOT email):**
- [ ] Public API Key
- [ ] Private API Key
- [ ] Project ID for `casas-dev`
- [ ] Project ID for `casas-staging`
- [ ] Project ID for `casas-prod`
- [ ] Organization name: `LG-CASAS`

---

## Implementation

### Phase 1: Initial Setup 

| Day | Task 
Create MongoDB Atlas account 
Create organization 
Setup billing 
Create 3 projects (dev/staging/prod) 
Generate API keys 
Share credentials with team
Team configures Terraform
Team creates dev cluster
Team tests connectivity from GKE 
Team deploys test application 
Team validates setup

---

### Phase 2: Production Setup

| Task | Owner | Duration |
|------|-------|----------|
| Configure VPC Peering (GCP ↔ Atlas) | DevOps 
| Create production cluster (M30) | DevOps
| Setup backup policies | DevOps 
| Configure monitoring & alerts | DevOps
| Security hardening | DevOps 
| Load testing | QA 

---

## API Keys vs Database Credentials (Important!)

### API Keys (for Terraform)
- **Purpose**: Terraform uses these to CREATE infrastructure (clusters, users, etc.)
- **Used by**: Terraform automation only
- **Permissions**: Organization/Project level
- **Format**: 
  - Public Key: `abcdefgh`
  - Private Key: `12345678-abcd-1234-abcd-1234567890ab`

### Database Credentials (for Applications)
- **Purpose**: Applications use these to READ/WRITE data
- **Used by**: Your application code (Node.js, Python, etc.)
- **Permissions**: Database level
- **Format**:
  - Username: `app-user`
  - Password: `MySecretPassword123!`

**They are NOT the same! API keys manage infrastructure, database credentials access data.**

---

## What Happens After Setup?

### 1. Team Gets Credentials
You share the API keys and Project IDs with the team via secure channel.

### 2. Team Configures Terraform
Team creates `terraform.tfvars`:
```hcl
# API Keys
mongodb_atlas_public_key  = "your-public-key"
mongodb_atlas_private_key = "your-private-key"

# Project ID
mongodb_atlas_project_id  = "507f1f77bcf86cd799439011"

# Cluster Configuration
cluster_name              = "casas-dev-db"
environment               = "dev"
provider_instance_size    = "M10"
provider_region           = "WESTERN_EUROPE"
```

### 3. Team Deploys Cluster
```bash
terraform init
terraform plan
terraform apply
# ✅ Cluster ready in 10 minutes!
```

### 4. Team Gets Connection String
```bash
terraform output -raw mongo_uri
# Output: mongodb+srv://casas-dev-db.abc123.mongodb.net
```

### 5. Team Creates Database User (Manual)
In MongoDB Atlas Console:
- Database Access → Add New Database User
- Username: `app-user`
- Password: Generate strong password
- Privileges: Read and write to any database

### 6. Application Connects
```javascript
const uri = "mongodb+srv://app-user:PASSWORD@casas-dev-db.abc123.mongodb.net/mydb";
const client = new MongoClient(uri);
await client.connect();
// ✅ Connected!
```
## Important Reminders

### For Fedric (Stakeholder)
- [ ] **Save API keys securely** - especially the Private Key (shown only once!)
- [ ] **Note all 3 Project IDs** - you'll need to share these with the team
- [ ] **Setup billing alerts** - get notified before exceeding budget
- [ ] **Use secure channel** - DO NOT share credentials via regular email

### For Team
- [ ] **Never commit credentials to Git** - add `terraform.tfvars` to `.gitignore`
- [ ] **Use environment variables in CI/CD** - don't hardcode credentials
- [ ] **API keys are for Terraform only** - applications need separate database credentials
- [ ] **Test in dev first** - validate everything before deploying to production

---

## Contact Information

### MongoDB Atlas Support
- **Website:** https://www.mongodb.com/contact
- **Sales Email:** sales@mongodb.com
- **Phone:** +1-866-237-8815
- **Support Portal:** https://support.mongodb.com/

### MongoDB Atlas Documentation
- **Getting Started:** https://www.mongodb.com/docs/atlas/getting-started/
- **Pricing Calculator:** https://www.mongodb.com/pricing
- **Security Overview:** https://www.mongodb.com/cloud/atlas/security
- **Terraform Provider:** https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs

### Internal Team Contacts
- **Technical Lead:** `<name>` - `<email>`
- **DevOps Lead:** `<name>` - `<email>`
- **Project Manager:** `<name>` - `<email>`

---
