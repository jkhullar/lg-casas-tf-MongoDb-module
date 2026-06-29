# MongoDB Atlas Module - Simple Explanation

## What This Module Does

This Terraform module creates a **MongoDB database in the cloud** (MongoDB Atlas service). Think of it like creating a database server, but managed by MongoDB Atlas instead of GCP.

## Key Differences from Other Modules

| Feature | KMS/GCS/Valkey Modules | MongoDB Module |
|---------|------------------------|----------------|
| Where it runs | Google Cloud Platform (GCP) | MongoDB Atlas (separate cloud service) |
| Authentication | GCP credentials | MongoDB Atlas API keys |
| Billing | GCP bill | MongoDB Atlas bill (separate) |
| Management | GCP Console | MongoDB Atlas Console |

## Files Explained (Simple Terms)

### 1. `variables.tf` - Configuration Options
**What it does:** Lists all the settings you can customize for your MongoDB cluster.

**Key Variables:**
- `cluster_name`: Name of your database (e.g., "casas-app-db-prod")
- `project_id`: MongoDB Atlas Project ID (NOT GCP project ID!)
- `provider_instance_size`: How powerful the database is (M10 = small, M20 = medium, M30 = large)
- `disk_size_gb`: How much storage space (minimum 10GB)
- `backup_enabled`: Should we automatically backup the database? (default: yes)
- `replication_factor`: How many copies of data (3 = high availability)

**Think of it like:** Ordering a server - you specify RAM, disk size, backup options, etc.

### 2. `main.tf` - The Actual Database Creation
**What it does:** Creates the MongoDB cluster with all your settings.

**Key Features:**
- Creates one MongoDB cluster
- Automatically sets security: TLS encryption, no JavaScript (security risk)
- Adds labels (tags) for tracking
- Prevents accidental deletion (`prevent_destroy = true`)

**Think of it like:** The actual order form that creates the database server.

### 3. `outputs.tf` - Connection Information
**What it does:** After creating the database, this gives you the connection details.

**Key Outputs:**
- `mongo_uri`: Connection string to access the database
- `srv_address`: Modern SRV-style connection string
- `cluster_id`: Unique ID of your database
- `state_name`: Current status (IDLE, CREATING, UPDATING)

**Think of it like:** Getting the address and access details after your server is ready.

### 4. `versions.tf` - Required Software
**What it does:** Specifies which Terraform version and providers are needed.

**Requirements:**
- Terraform >= 1.15.2
- MongoDB Atlas provider ~> 1.21

**Think of it like:** System requirements for software installation.

### 5. `.gitignore` - Security
**What it does:** Prevents sensitive files from being committed to git.

**Protects:**
- `.tfvars` files (contain credentials and API keys)
- `.tfstate` files (contain resource details)
- `.terraform/` folder (downloaded providers)

**Think of it like:** A shield that prevents you from accidentally sharing passwords.

### 6. `README.md` - Complete User Manual
**What it does:** Step-by-step guide for using this module.

**Sections:**
- Prerequisites: How to create MongoDB Atlas account
- Usage examples: How to use this module in your infrastructure
- Troubleshooting: Common issues and solutions
- Pricing: Cost estimates for different cluster sizes

## How to Use This Module (Simplified)

### Step 1: Create MongoDB Atlas Account (One-Time)
1. Go to https://www.mongodb.com/cloud/atlas/register
2. Sign up with email
3. Create Organization (e.g., "LG-Casas")
4. Create Project (e.g., "casas-prod")
5. Get Project ID from Settings

### Step 2: Create API Keys (One-Time)
1. Go to Organization Settings → API Keys
2. Create new key with "Project Owner" permission
3. Save Public Key and Private Key (like username/password for Terraform)

### Step 3: Use in Your Infrastructure Code

```hcl
# In your main infrastructure repository

module "mongodb_app_db" {
  source = "git::https://github.com/your-org/lg-casas-tf-mongodb.git"

  cluster_name = "casas-app-db-prod"
  project_id   = "507f1f77bcf86cd799439011"  # Your Atlas Project ID

  provider_instance_size = "M10"   # Small production cluster
  disk_size_gb           = 10      # 10GB storage
  backup_enabled         = true    # Enable backups
  replication_factor     = 3       # 3 copies for high availability

  environment = "prod"
  labels = {
    purpose = "application-database"
    team    = "backend"
  }
}
```

## Cost Breakdown (Approximate)

| Cluster Size | RAM | Use Case | Monthly Cost |
|--------------|-----|----------|--------------|
| M0 | 512MB | **Free tier** - Dev/Test only | **$0** |
| M10 | 2GB | Small production | ~$60 |
| M20 | 4GB | Medium production | ~$150 |
| M30 | 8GB | Large production | ~$300 |

**Note:** M0 is free but limited (no backups, no encryption). M10+ is for production.

## Important Concepts

### 1. MongoDB Atlas vs GCP
- **MongoDB Atlas** is a separate cloud service (like AWS, Azure)
- It can run on GCP, AWS, or Azure infrastructure
- You need a separate MongoDB Atlas account (not part of GCP)
- You get a separate bill from MongoDB Atlas

### 2. Project ID Confusion
- **GCP Project ID**: Your Google Cloud project (e.g., "prj-d-srdl-casas-4zrs")
- **MongoDB Atlas Project ID**: Your MongoDB Atlas project (e.g., "507f1f77bcf86cd799439011")
- **This module uses MongoDB Atlas Project ID** (different from GCP!)

### 3. High Availability
- `replication_factor = 3` means 3 copies of your data
- If one server fails, others take over automatically (~10-30 seconds)
- Data is spread across different availability zones

### 4. Backups
- Continuous backups (hourly, daily, weekly, monthly snapshots)
- Point-in-time restore available (like time machine)
- Only available on M10+ clusters (not M0 free tier)

## How to Explain to Tech Leads

### Elevator Pitch
"This module creates a managed MongoDB database in MongoDB Atlas. It's similar to our GCS and KMS modules but for a different cloud provider. We use it because MongoDB Atlas provides better MongoDB management than running our own MongoDB on GCP."

### Key Points to Emphasize

1. **Separate Service**
   - "MongoDB Atlas is a separate SaaS like Datadog or PagerDuty"
   - "We need a MongoDB Atlas account independent of GCP"

2. **Simplified Management**
   - "MongoDB Atlas handles: backups, updates, scaling, monitoring"
   - "We just provision and configure through Terraform"

3. **Security**
   - "Encryption at rest and in transit by default"
   - "TLS 1.2+ enforced"
   - "IP whitelisting for network access"

4. **Cost Efficiency**
   - "M0 free tier for dev/test"
   - "M10 ($60/month) for small production"
   - "Pay only for what we use, can scale up/down"

5. **Follows Same Pattern**
   - "Single-resource module (one call = one cluster)"
   - "Use `for_each` for multiple clusters"
   - "Same variable structure as our other modules"

## Common Questions & Answers

**Q: Why not use GCP's managed MongoDB?**
A: GCP doesn't have a native managed MongoDB service. They have Cloud Firestore (NoSQL) but not MongoDB-compatible.

**Q: Is this more expensive than self-hosted?**
A: Initially yes, but saves ops time (no patching, backups, monitoring setup). For small clusters, Atlas is cost-effective.

**Q: Can we migrate existing MongoDB to Atlas?**
A: Yes, MongoDB provides migration tools. We can do gradual migration with minimal downtime.

**Q: What if MongoDB Atlas goes down?**
A: 99.95% SLA. High availability config (replication_factor=3) handles zone failures. Multi-region for disaster recovery.

**Q: How do applications connect?**
A: Standard MongoDB connection string. Applications don't know if it's Atlas or self-hosted. Just change connection URL.

## Comparison with Similar Modules

### Like GCS Module
- ✅ Single resource per module instance
- ✅ Use `for_each` for multiple instances
- ✅ Variables for all configuration
- ✅ Labels/tags for organization

### Like Valkey Module
- ✅ Managed database service
- ✅ High availability configuration
- ✅ Backup/restore capabilities
- ✅ Security (encryption, access control)

### Different from Both
- ❌ Not GCP-native (separate provider)
- ❌ Separate authentication (API keys)
- ❌ Different billing (MongoDB Atlas account)
- ✅ But same Terraform patterns!

## Next Steps for Your Team

1. **Create MongoDB Atlas Account** (Platform team)
   - Organization: LG-Casas
   - Project: casas-dev, casas-prod

2. **Generate API Keys** (Store in secrets manager)

3. **Test with Free Tier** (M0 cluster in dev)
   ```hcl
   provider_instance_size = "M0"
   backup_enabled         = false  # Not available on M0
   ```

4. **Deploy Production** (M10+ cluster)
   ```hcl
   provider_instance_size = "M10"
   backup_enabled         = true
   replication_factor     = 3
   ```

5. **Monitor Usage** (Atlas Console)
   - Check actual RAM/CPU usage
   - Adjust instance size if needed

## Troubleshooting Checklist

- [ ] MongoDB Atlas account created?
- [ ] Organization created?
- [ ] Project created and Project ID noted?
- [ ] API keys generated with correct permissions?
- [ ] Provider credentials configured in Terraform?
- [ ] IP whitelist configured (for testing)?
- [ ] Database users created?

## Summary

This module is **simple and follows the same pattern as our other modules**, but uses a different cloud provider (MongoDB Atlas) instead of GCP. The key difference is the **initial setup** (creating Atlas account and API keys), but once that's done, it works just like any other Terraform module.

**Bottom line:** Same Terraform workflow, different cloud service.
