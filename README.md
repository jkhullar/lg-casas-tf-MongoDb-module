# MongoDB Atlas Terraform Module

Terraform module for creating MongoDB Atlas database clusters for the Casas project using the modern `mongodbatlas_advanced_cluster` resource.

## Overview

This is a **single-cluster module** following the standard Terraform pattern. Use `for_each` in your consuming repository to create multiple MongoDB clusters efficiently.

**Important:** MongoDB Atlas is a **separate cloud service** from GCP. You need to set up a MongoDB Atlas account and organization first before using this module.

**Note:** This module uses the modern `mongodbatlas_advanced_cluster` resource (not the deprecated `mongodbatlas_cluster`).

## Prerequisites

### 1. MongoDB Atlas Account Setup

Before using this module, you MUST:

1. **Create MongoDB Atlas Account**
   - Go to https://www.mongodb.com/cloud/atlas/register
   - Sign up with your email
   - Verify your email address

2. **Create an Organization**
   - After login, create a new organization (e.g., "LG-Casas")
   - This is the top-level container for your projects

3. **Create a Project**
   - Inside your organization, create a project (e.g., "casas-prod")
   - **Note the Project ID** - you'll need this for the `project_id` variable
   - Find it at: Project Settings → General → Project ID

4. **Create API Keys for Terraform**
   - Go to Organization Settings → Access Manager → API Keys
   - Click "Create API Key"
   - Enter description: "Terraform Automation"
   - Set permissions: "Organization Project Creator" + "Organization Owner" (or minimum: "Project Owner" for existing projects)
   - **Save the Public Key and Private Key** - you'll use these as credentials

5. **Whitelist IP Addresses (Optional but Recommended)**
   - In API Key settings, add IP Access List
   - Add your Terraform execution environment's IP
   - For CI/CD: Add your CI/CD runner IPs

### 2. Configure Terraform Provider Credentials

Add to your consuming repository's `provider.tf`:

```hcl
provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key   # From step 4 above
  private_key = var.mongodb_atlas_private_key  # From step 4 above
}
```

**Security Best Practice:** Store credentials as environment variables or in a secrets manager:

```bash
export MONGODB_ATLAS_PUBLIC_KEY="your-public-key"
export MONGODB_ATLAS_PRIVATE_KEY="your-private-key"
```

Or use Terraform variables (never commit to git):

```hcl
# variables.tf in consuming repo
variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas API public key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas API private key"
  type        = string
  sensitive   = true
}
```

## Features

- Single MongoDB Atlas cluster per module instance
- Support for GCP, AWS, and Azure cloud providers
- Configurable instance sizes (M0 free tier to M400+)
- High availability with replica sets (3, 5, or 7 members)
- Optional geo-sharding for global distribution
- Continuous cloud backup with point-in-time restore
- Encryption at rest using cloud provider encryption
- Auto-scaling disk storage
- Termination protection
- Custom labels/tags

## Important Differences from GCP Modules

| Aspect | GCP Modules (KMS, GCS, etc.) | MongoDB Atlas |
|--------|----------------------------|---------------|
| **Provider** | Google Cloud Platform | MongoDB Atlas (SaaS) |
| **Authentication** | GCP Service Account | MongoDB Atlas API Keys |
| **Project ID** | GCP Project ID | MongoDB Atlas Project ID |
| **Region Format** | `europe-west1` | `WESTERN_EUROPE` |
| **Encryption** | Google KMS or default | Cloud provider managed |
| **Billing** | GCP billing account | MongoDB Atlas billing |

## Usage Example

### Step 1: Get MongoDB Atlas Project ID

```bash
# Login to MongoDB Atlas: https://cloud.mongodb.com/
# Navigate to: Your Project → Settings → General
# Copy the "Project ID" (format: 507f1f77bcf86cd799439011)
```

### Step 2: Create `variables.tf` in Consuming Repo

```hcl
variable "mongodb_atlas_public_key" {
  description = "MongoDB Atlas API public key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_private_key" {
  description = "MongoDB Atlas API private key"
  type        = string
  sensitive   = true
}

variable "mongodb_atlas_project_id" {
  description = "MongoDB Atlas Project ID (from Atlas console)"
  type        = string
}

variable "project_name" {
  type    = string
  default = "casas"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "mongodb_clusters" {
  description = "Map of MongoDB cluster definitions"
  type = map(object({
    provider_name          = optional(string, "GCP")
    provider_region        = optional(string, "WESTERN_EUROPE")
    provider_instance_size = optional(string, "M10")
    mongodb_major_version  = optional(string, "7.0")
    disk_size_gb           = optional(number, 10)
    backup_enabled         = optional(bool, true)
    replication_factor     = optional(number, 3)
    labels                 = optional(map(string), {})
  }))
  default = {}
}
```

### Step 3: Create `provider.tf` in Consuming Repo

```hcl
terraform {
  required_version = ">= 1.15.2"

  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.21"
    }
  }
}

provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}
```

### Step 4: Create `terraform.tfvars` in Consuming Repo

```hcl
# MongoDB Atlas credentials (get from Atlas console → Organization → API Keys)
# NEVER commit this file to git! (.gitignore it)
mongodb_atlas_public_key    = "your-public-key-here"
mongodb_atlas_private_key   = "your-private-key-here"
mongodb_atlas_project_id    = "507f1f77bcf86cd799439011"  # Your Atlas Project ID

project_name = "casas"
environment  = "prod"

mongodb_clusters = {
  app-db = {
    provider_instance_size = "M10"
    backup_enabled         = true
    replication_factor     = 3
    labels = {
      purpose = "application-database"
      team    = "backend"
    }
  }

  analytics-db = {
    provider_instance_size = "M20"
    disk_size_gb           = 50
    backup_enabled         = true
    labels = {
      purpose = "analytics"
      team    = "data-engineering"
    }
  }
}
```

### Step 5: Create `main.tf` in Consuming Repo

```hcl
module "mongodb_clusters" {
  for_each = var.mongodb_clusters

  source = "git::https://github.com/your-org/lg-casas-tf-mongodb.git"

  # Cluster naming: casas-{key}-prod (e.g., casas-app-db-prod)
  cluster_name = "${var.project_name}-${each.key}-${var.environment}"
  project_id   = var.mongodb_atlas_project_id

  # Configuration
  provider_name          = each.value.provider_name
  provider_region        = each.value.provider_region
  provider_instance_size = each.value.provider_instance_size
  mongodb_major_version  = each.value.mongodb_major_version
  disk_size_gb           = each.value.disk_size_gb
  backup_enabled         = each.value.backup_enabled
  replication_factor     = each.value.replication_factor

  # Metadata
  environment = var.environment
  labels      = each.value.labels
}
```

### Step 6: Deploy

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply (create clusters - this takes 5-10 minutes)
terraform apply
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `cluster_name` | MongoDB Atlas cluster name | `string` | n/a | **Yes** |
| `project_id` | MongoDB Atlas Project ID | `string` | n/a | **Yes** |
| `cluster_type` | Cluster type (REPLICASET or GEOSHARDED) | `string` | `"REPLICASET"` | No |
| `provider_name` | Cloud provider (GCP, AWS, AZURE) | `string` | `"GCP"` | No |
| `provider_region` | Cloud provider region | `string` | `"WESTERN_EUROPE"` | No |
| `provider_instance_size` | Instance size (M0, M10, M20, M30, etc.) | `string` | `"M10"` | No |
| `mongodb_major_version` | MongoDB version | `string` | `"7.0"` | No |
| `disk_size_gb` | Disk size in GB | `number` | `10` | No |
| `auto_scaling_disk_enabled` | Enable auto-scaling disk | `bool` | `true` | No |
| `backup_enabled` | Enable continuous backup | `bool` | `true` | No |
| `pit_enabled` | Enable point-in-time restore | `bool` | `false` | No |
| `replication_factor` | Number of replicas (3, 5, or 7) | `number` | `3` | No |
| `encryption_at_rest_enabled` | Enable encryption at rest | `bool` | `true` | No |
| `termination_protection_enabled` | Enable termination protection | `bool` | `true` | No |
| `environment` | Environment name | `string` | `"dev"` | No |
| `labels` | Custom labels | `map(string)` | `{}` | No |

## Outputs

| Name | Description |
|------|-------------|
| `cluster_id` | The cluster ID |
| `cluster_name` | The cluster name |
| `mongo_uri` | Connection string (sensitive) |
| `srv_address` | SRV connection string (sensitive) |
| `state_name` | Current cluster state |
| `mongodb_version` | MongoDB version |

## Instance Sizes and Pricing

### Common Instance Sizes (GCP, WESTERN_EUROPE region)

| Size | RAM | vCPU | Storage | Approx. Cost/Month | Use Case |
|------|-----|------|---------|-------------------|----------|
| **M0** | 512MB | Shared | 512MB | **Free** | Development/testing only |
| **M10** | 2GB | 2 | 10GB+ | ~$60 | Small production apps |
| **M20** | 4GB | 2 | 20GB+ | ~$150 | Medium production apps |
| **M30** | 8GB | 2 | 40GB+ | ~$300 | Large production apps |
| **M40** | 16GB | 4 | 80GB+ | ~$600 | High-traffic apps |

**Notes:**
- M0 (free tier) has limitations: no backups, no encryption, no auto-scaling
- M10+ required for production: backups, encryption, auto-scaling
- Prices approximate - check MongoDB Atlas pricing calculator
- Additional costs: Data transfer, backup storage, serverless queries

### Region Naming (GCP Examples)

| GCP Region | MongoDB Atlas Region Code |
|------------|---------------------------|
| europe-west1 (Belgium) | `WESTERN_EUROPE` |
| us-east4 (Virginia) | `EASTERN_US` |
| asia-south1 (Mumbai) | `CENTRAL_INDIA` |

Full list: https://www.mongodb.com/docs/atlas/reference/google-gcp/

## Security Best Practices

### 1. Network Access

After creating the cluster, configure IP whitelist:

```bash
# Login to Atlas console
# Go to: Network Access → IP Access List
# Add IP addresses or CIDR blocks that can connect

# For GCP services: Add GCP NAT Gateway IP
# For development: Add your office/VPN IP
```

### 2. Database Users

Create database users separately (not managed by this module):

```bash
# Atlas Console → Database Access → Add New Database User
# Username: app-user
# Authentication: Password (generate strong password)
# Database User Privileges: Read and write to any database
```

Or use Terraform resource:

```hcl
resource "mongodbatlas_database_user" "app_user" {
  username           = "app-user"
  password           = var.mongodb_app_password  # Use secrets manager!
  project_id         = var.mongodb_atlas_project_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "production"
  }
}
```

### 3. Connection String Format

```
mongodb+srv://<username>:<password>@<cluster-address>/<database>?retryWrites=true&w=majority
```

Example:

```
mongodb+srv://app-user:MyPassword@casas-app-db-prod.abc123.mongodb.net/production?retryWrites=true&w=majority
```

### 4. Encryption

- **At Rest:** Enabled by default (cloud provider encryption)
- **In Transit:** Always TLS 1.2+ (enforced by Atlas)
- **Client-Side Field Level Encryption:** Configure in application

## Backup and Disaster Recovery

### Backup Configuration

This module enables **continuous cloud backup** (M10+ clusters):

- **Snapshots:** Hourly, daily, weekly, monthly
- **Retention:** Customizable (default: 7 days)
- **Point-in-Time Restore:** Optional (`pit_enabled = true`)

### Restore Process

1. Go to Atlas Console → Clusters → Backup tab
2. Select snapshot or point-in-time
3. Choose restore option:
   - **Download** snapshot files
   - **Restore to new cluster** (safest - doesn't affect production)
   - **Restore to same cluster** (replaces data)

### High Availability

- **Replica Sets:** 3 members (default) spread across availability zones
- **Automatic Failover:** ~10-30 seconds
- **Zero-Downtime Upgrades:** Rolling upgrades, no downtime

## Monitoring

### Built-in Monitoring (Atlas Console)

- **Metrics:** CPU, Memory, Disk I/O, Connections, Operations/sec
- **Query Performance:** Slow query log, index recommendations
- **Alerts:** Email/Slack/PagerDuty notifications for anomalies

### Custom Alerts (Example)

```hcl
resource "mongodbatlas_alert_configuration" "high_connections" {
  project_id = var.mongodb_atlas_project_id
  event_type = "CONNECTIONS"
  enabled    = true

  threshold {
    operator  = "GREATER_THAN"
    threshold = 100
    units     = "RAW"
  }

  notification {
    type_name     = "EMAIL"
    email_address = "ops@example.com"
  }
}
```

## Troubleshooting

### Common Issues

**1. "Project ID not found"**
- Verify Project ID from Atlas Console → Project Settings
- Ensure API key has access to this project

**2. "IP not whitelisted"**
- Add your IP to Network Access → IP Access List
- Wait 1-2 minutes for propagation

**3. "Cluster creation failed - region unavailable"**
- Check if region supports your instance size
- Try different region or instance size

**4. "Authentication failed"**
- Verify API keys are correct
- Check API key permissions (must have Project Owner role)

**5. "Disk size too small"**
- M10+ requires minimum 10GB
- M0/M2/M5 have fixed disk sizes (not configurable)

## Cost Optimization

### Tips to Reduce Costs

1. **Right-size instances:**
   - Start with M10 for small apps
   - Monitor actual usage (Atlas shows recommendations)
   - Scale up only when needed

2. **Use auto-pause for dev clusters:**
   - M0/M2/M5 free/shared tiers auto-pause after inactivity
   - Not available for M10+ (always-on)

3. **Optimize storage:**
   - Enable compression (default in MongoDB)
   - Archive old data to cheaper storage (S3/GCS)
   - Use lifecycle rules to delete temporary data

4. **Regional selection:**
   - Choose region closest to your application
   - Reduces latency AND data transfer costs

5. **Backup retention:**
   - Default: 7 days
   - Reduce to 3 days for dev/test
   - Increase to 30+ days only for critical production

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.15.2 |
| mongodbatlas provider | ~> 1.21 |

## Module Design Philosophy

This module follows the **single-resource pattern**:
- One module call = one cluster
- Use `for_each` in consuming repo for multiple clusters
- Standard Terraform pattern, widely understood
- Maximum flexibility and reusability
- Clean defaults using `optional()` in consuming repo variables

## Additional Resources

- **MongoDB Atlas Docs:** https://www.mongodb.com/docs/atlas/
- **Terraform Provider Docs:** https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs
- **Instance Sizes:** https://www.mongodb.com/docs/atlas/reference/google-gcp/
- **Region List:** https://www.mongodb.com/docs/atlas/reference/google-gcp/#std-label-google-gcp
- **Pricing Calculator:** https://www.mongodb.com/pricing

## Support

For MongoDB Atlas issues:
- Atlas Support: https://support.mongodb.com/
- Community Forums: https://www.mongodb.com/community/forums/

For Terraform module issues:
- Create issue in this repository
- Contact platform team
