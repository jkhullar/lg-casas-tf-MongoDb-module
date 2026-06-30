# MongoDB Atlas Complete Flow Explanation

## Overview
This document explains the complete flow of setting up MongoDB Atlas, how API keys are generated and used, where connection strings come from, and how everything connects together.

---

## Table of Contents
1. [Phase 1: Manual Setup (Prerequisites)](#phase-1-manual-setup-prerequisites)
2. [Phase 2: Terraform Configuration](#phase-2-terraform-configuration)
3. [Phase 3: Connection String Generation](#phase-3-connection-string-generation)
4. [Phase 4: Application Connection](#phase-4-application-connection)
5. [Key Distinctions](#key-distinctions)
6. [Complete Flow Diagram](#complete-flow-diagram)
7. [FAQ](#faq)

---

## Phase 1: Manual Setup (Prerequisites)

### Step 1: Account Creation (Manual)
**What you do:**
- Navigate to https://www.mongodb.com/cloud/atlas/register
- Create a MongoDB Atlas account
- Verify your email address

**What you get:**
- Access to MongoDB Atlas console

---

### Step 2: Organization & Project Creation (Manual)
**What you do:**
1. Login to MongoDB Atlas console
2. Create an **Organization** (e.g., `LG-Casas`)
3. Within the organization, create a **Project** (e.g., `casas-dev` or `casas-prod`)
4. Navigate to Project Settings → General

**What you get:**
- **Project ID**: A unique identifier like `507f1f77bcf86cd799439011`
- **Important:** This is MongoDB Atlas Project ID, NOT your GCP/AWS project ID!

**Where it's used:**
- You'll provide this Project ID to Terraform
- Terraform uses it to know which MongoDB Atlas project to create resources in

---

### Step 3: API Key Generation (Manual)
**What you do:**
1. Navigate to Organization Settings → Access Manager → API Keys
2. Click **"Create API Key"**
3. Set description: `Terraform Automation`
4. Set permissions:
   - `Organization Project Creator`
   - `Organization Owner`
5. Save the generated keys

**What you get:**
- **Public Key**: Acts like a username (e.g., `abcdefgh`)
- **Private Key**: Acts like a password (e.g., `12345678-abcd-1234-abcd-1234567890ab`)
- **⚠️ WARNING:** Private key is shown **only once** - save it immediately!

**Where it's used:**
- These API keys authenticate **Terraform** to the MongoDB Atlas API
- They allow Terraform to create, modify, and delete infrastructure
- **NOT used by your application** - only for infrastructure management

---

## Phase 2: Terraform Configuration

### Step 4: Provide Credentials to Terraform
**What you do:**
Create a `terraform.tfvars` file:

```hcl
# MongoDB Atlas API Credentials (from Step 3)
mongodb_atlas_public_key  = "your-public-key-here"
mongodb_atlas_private_key = "your-private-key-here"

# MongoDB Atlas Project ID (from Step 2)
mongodb_atlas_project_id  = "507f1f77bcf86cd799439011"

# Cluster Configuration
cluster_name              = "casas-dev-db"
environment               = "dev"
provider_instance_size    = "M10"
```

**What happens:**
- Terraform reads these values
- Uses them to authenticate with MongoDB Atlas API

---

### Step 5: Terraform Provider Authentication
**How it works (behind the scenes):**

The MongoDB Atlas provider configuration looks like this:
```hcl
provider "mongodbatlas" {
  public_key  = var.mongodb_atlas_public_key
  private_key = var.mongodb_atlas_private_key
}
```

**What happens:**
- When you run `terraform apply`, Terraform uses these API keys
- Every API call to MongoDB Atlas includes authentication using these keys
- MongoDB Atlas verifies the keys and authorizes the operations

---

### Step 6: Terraform Creates the Cluster
**What you do:**
```bash
terraform init
terraform plan
terraform apply
```

**What Terraform does:**
1. Authenticates to MongoDB Atlas API using the API keys
2. Calls MongoDB Atlas API: "Create a cluster with these specifications"
3. MongoDB Atlas provisions the cluster infrastructure:
   - Allocates compute resources
   - Configures storage
   - Sets up networking
   - Configures replication
   - Enables backups (if configured)

**How long it takes:**
- 5-10 minutes for cluster to become ready

---

## Phase 3: Connection String Generation

### Step 7: MongoDB Auto-Generates Connection Strings
**What happens automatically:**
- Once the cluster is created, MongoDB Atlas **automatically generates** connection strings
- These connection strings are available via the MongoDB Atlas API
- Terraform retrieves them using: `mongodbatlas_advanced_cluster.this.connection_strings[0]`

**Connection string formats available:**
1. **Standard**: `mongodb://casas-dev-db-shard-00-00.abc123.mongodb.net:27017`
2. **Standard SRV** (recommended): `mongodb+srv://casas-dev-db.abc123.mongodb.net`

---

### Step 8: Terraform Outputs Connection Strings
**What's in [outputs.tf](outputs.tf):**

```hcl
output "mongo_uri" {
  description = "Base connection string for the cluster (without credentials)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard
  sensitive   = true
}

output "srv_address" {
  description = "SRV connection string (recommended for modern drivers)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}
```

**How to retrieve:**
```bash
# Get the connection string
terraform output -raw mongo_uri

# Output example:
# mongodb+srv://casas-dev-db.abc123.mongodb.net
```

**Important Notes:**
- ✅ These connection strings are **generated by MongoDB Atlas**
- ✅ Terraform just **reads and outputs** them
- ✅ These are **NOT complete** - they're missing username/password
- ❌ These are **NOT for Terraform** - they're for your application

---

## Phase 4: Application Connection

### Step 9: Create Database User (Manual)
**What you do:**
1. Navigate to MongoDB Atlas Console → Database Access
2. Click **"Add New Database User"**
3. Set credentials:
   - Username: `app-user`
   - Password: `MySecretPassword123!` (or auto-generate)
4. Set privileges: `Read and write to any database`
5. Save the user

**What you get:**
- Database username: `app-user`
- Database password: `MySecretPassword123!`

**Important Distinction:**
- These are **DATABASE credentials** for data access
- Different from **API keys** used by Terraform
- Used by your application to read/write data

---

### Step 10: Assemble Complete Connection String
**Your application needs:**

```
mongodb+srv://<username>:<password>@<cluster-address>/<database>?retryWrites=true&w=majority
```

**How to build it:**
1. Start with connection string from Terraform output: `casas-dev-db.abc123.mongodb.net`
2. Add database username from Step 9: `app-user`
3. Add database password from Step 9: `MySecretPassword123!`
4. Add database name: `mydb`

**Final connection string:**
```
mongodb+srv://app-user:MySecretPassword123!@casas-dev-db.abc123.mongodb.net/mydb?retryWrites=true&w=majority
```

---

### Step 11: Application Connects to Database
**Example in Node.js:**

```javascript
const { MongoClient } = require('mongodb');

// Connection string assembled from Terraform output + database credentials
const uri = "mongodb+srv://app-user:MySecretPassword123!@casas-dev-db.abc123.mongodb.net/mydb";
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    console.log("Connected to MongoDB Atlas!");
    
    const db = client.db('mydb');
    const collection = db.collection('users');
    
    await collection.insertOne({ name: "John Doe", email: "john@example.com" });
    console.log("Data inserted!");
  } finally {
    await client.close();
  }
}

run().catch(console.error);
```

**Example in Python:**

```python
from pymongo import MongoClient

# Connection string assembled from Terraform output + database credentials
uri = "mongodb+srv://app-user:MySecretPassword123!@casas-dev-db.abc123.mongodb.net/mydb"
client = MongoClient(uri)

try:
    db = client.mydb
    collection = db.users
    
    collection.insert_one({"name": "John Doe", "email": "john@example.com"})
    print("Connected and inserted data!")
finally:
    client.close()
```

---

## Key Distinctions

### API Keys vs Connection String

| Aspect | API Keys | Connection String |
|--------|----------|-------------------|
| **Purpose** | Infrastructure management | Application data access |
| **Who uses it** | Terraform | Your application code |
| **Generated by** | You (manually in Atlas console) | MongoDB Atlas (automatically) |
| **Used for** | Creating/modifying clusters | Reading/writing data |
| **Includes credentials** | Public + Private key pair | Hostname only (needs username/password) |
| **Permissions** | Organization/Project level | Database level |
| **Example** | Public: `abcdefgh`<br>Private: `12345-abcd-...` | `mongodb+srv://cluster.abc123.mongodb.net` |

### Complete Authentication Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    TWO SEPARATE AUTH FLOWS                   │
└─────────────────────────────────────────────────────────────┘

FLOW 1: Infrastructure Management (Terraform → MongoDB Atlas)
┌──────────┐    API Keys    ┌────────────────┐
│ Terraform│ ───────────────> MongoDB Atlas  │
│          │                 │ API            │
│          │ <──────────────  (Create cluster)│
└──────────┘   Cluster Info  └────────────────┘

FLOW 2: Data Access (Application → Database)
┌────────────┐   Connection String + DB User/Pass   ┌──────────┐
│ Your App   │ ──────────────────────────────────────> MongoDB  │
│ (Node.js/  │                                       │ Cluster  │
│  Python)   │ <─────────────────────────────────────  (Data)   │
└────────────┘          Read/Write Data              └──────────┘
```

---

## Complete Flow Diagram

```
╔══════════════════════════════════════════════════════════════════╗
║                   MONGODB ATLAS COMPLETE FLOW                     ║
╚══════════════════════════════════════════════════════════════════╝

PHASE 1: MANUAL SETUP (One-time prerequisites)
┌────────────────────────────────────────────────────────────────┐
│ Step 1: You → MongoDB Atlas Console → Create Account          │
│         Output: Account access                                 │
│                                                                │
│ Step 2: You → Create Organization & Project                   │
│         Output: Project ID (507f1f77bcf86cd799439011)          │
│                                                                │
│ Step 3: You → Generate API Keys                               │
│         Output: Public Key + Private Key                       │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
PHASE 2: TERRAFORM CONFIGURATION
┌────────────────────────────────────────────────────────────────┐
│ Step 4: You → Create terraform.tfvars                         │
│         - Paste API keys                                       │
│         - Paste Project ID                                     │
│         - Configure cluster settings                           │
│                                                                │
│ Step 5: terraform apply                                        │
│         - Terraform authenticates with API keys                │
│         - Calls MongoDB Atlas API                              │
│                                                                │
│ Step 6: MongoDB Atlas receives API call                       │
│         - Verifies API keys                                    │
│         - Provisions cluster infrastructure                    │
│         - Takes 5-10 minutes                                   │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
PHASE 3: CONNECTION STRING GENERATION (Automatic!)
┌────────────────────────────────────────────────────────────────┐
│ Step 7: MongoDB Atlas → Auto-generates connection strings     │
│         - Standard: mongodb://...                              │
│         - SRV: mongodb+srv://cluster.abc123.mongodb.net        │
│                                                                │
│ Step 8: Terraform → Reads connection strings                  │
│         - Via cluster resource API                             │
│         - Outputs them for you to use                          │
│                                                                │
│         terraform output -raw mongo_uri                        │
│         → mongodb+srv://casas-dev-db.abc123.mongodb.net        │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
PHASE 4: APPLICATION CONNECTION (Post-deployment)
┌────────────────────────────────────────────────────────────────┐
│ Step 9: You → MongoDB Atlas Console → Database Access         │
│         - Create database user                                 │
│         - Username: app-user                                   │
│         - Password: MySecretPassword123!                       │
│                                                                │
│ Step 10: You → Assemble complete connection string            │
│          Connection string (from Terraform output):            │
│            mongodb+srv://casas-dev-db.abc123.mongodb.net       │
│          + Database credentials:                               │
│            app-user : MySecretPassword123!                     │
│          = Complete string:                                    │
│            mongodb+srv://app-user:MySecretPassword123!@        │
│            casas-dev-db.abc123.mongodb.net/mydb                │
│                                                                │
│ Step 11: Your Application → Uses connection string            │
│          - Node.js / Python / Java code                        │
│          - Connects to database                                │
│          - Reads/writes data                                   │
└────────────────────────────────────────────────────────────────┘
```

---

## FAQ

### Q1: Are API keys the same as database credentials?
**No!** Completely different:
- **API Keys**: For Terraform to manage infrastructure (create/modify clusters)
- **Database Credentials**: For your application to access data (read/write)

### Q2: Where do I get the connection string?
The connection string is **automatically generated** by MongoDB Atlas when the cluster is created. Terraform reads it and outputs it for you:
```bash
terraform output -raw mongo_uri
```

### Q3: Can I use API keys to connect my application?
**No!** API keys are only for infrastructure management (Terraform). Your application needs:
- Connection string (from Terraform output)
- Database username/password (created manually in Atlas console)

### Q4: Why do I need to create database users manually?
This is intentional separation of concerns:
- **Infrastructure** (Terraform): Manages cluster creation, sizing, backups
- **Access Control** (Manual/IAM): Manages who can access data
- This prevents accidental exposure of database credentials in Terraform state

### Q5: Can Terraform create database users automatically?
Yes, using `mongodbatlas_database_user` resource, but it's generally not recommended because:
- Credentials end up in Terraform state (security risk)
- Better to manage access control separately from infrastructure
- Production systems should use IAM authentication instead

### Q6: What happens if I lose my API private key?
You'll need to generate new API keys in the MongoDB Atlas console. The old key cannot be recovered.

### Q7: How do I rotate API keys?
1. Generate new API keys in MongoDB Atlas console
2. Update `terraform.tfvars` with new keys
3. Run `terraform apply` (infrastructure won't change, just authentication)
4. Delete old API keys from MongoDB Atlas

### Q8: Why is the connection string marked as `sensitive = true`?
Even though it doesn't contain credentials, revealing the cluster hostname could be a security concern. It prevents the full connection string from appearing in logs.

---

## Security Best Practices

### For API Keys
- ✅ Store in `terraform.tfvars` (add to `.gitignore`)
- ✅ Use environment variables in CI/CD pipelines
- ✅ Rotate keys periodically
- ❌ Never commit to Git
- ❌ Never share publicly

### For Database Credentials
- ✅ Use strong passwords (20+ characters, mixed case, symbols)
- ✅ Use IAM database authentication in production
- ✅ Store in secret management systems (AWS Secrets Manager, HashiCorp Vault)
- ✅ Rotate credentials regularly
- ❌ Never hardcode in application code
- ❌ Never commit to Git

### For Connection Strings
- ✅ Store in environment variables
- ✅ Use secret management systems
- ✅ Configure IP whitelist properly
- ❌ Don't use `0.0.0.0/0` in production
- ❌ Never commit complete connection string (with credentials) to Git

---

## Troubleshooting

### Problem: "Authentication failed" during terraform apply
**Cause:** Invalid API keys  
**Solution:** Verify public and private keys are correct in `terraform.tfvars`

### Problem: "Project not found"
**Cause:** Wrong Project ID  
**Solution:** Check Project ID in MongoDB Atlas Console → Project Settings → General

### Problem: "Cannot connect to database" from application
**Cause 1:** IP not whitelisted  
**Solution:** Add your application's IP to Network Access in Atlas console

**Cause 2:** Wrong database credentials  
**Solution:** Verify username/password are correct

**Cause 3:** Wrong database name  
**Solution:** Ensure database name in connection string matches your database

### Problem: Connection string not appearing in outputs
**Cause:** Cluster still creating  
**Solution:** Wait for cluster to reach `IDLE` state (check `terraform output state_name`)

---

## Summary

1. **Manual Setup**: Create account, project, generate API keys
2. **Terraform**: Uses API keys to create cluster infrastructure
3. **Connection String**: Auto-generated by MongoDB, retrieved by Terraform
4. **Database User**: Create manually for application access
5. **Application**: Uses connection string + database credentials to access data

**Two separate authentication flows:**
- Terraform → MongoDB Atlas API (using API keys)
- Application → MongoDB Cluster (using connection string + DB credentials)

---

## Additional Resources

- [MongoDB Atlas Documentation](https://www.mongodb.com/docs/atlas/)
- [Terraform MongoDB Atlas Provider](https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs)
- [Connection String Documentation](https://www.mongodb.com/docs/manual/reference/connection-string/)
- [Security Best Practices](https://www.mongodb.com/docs/atlas/security/)
