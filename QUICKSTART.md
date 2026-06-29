# MongoDB Atlas Quick Start Guide

## 🎯 Goal
Create a MongoDB database cluster in MongoDB Atlas using this Terraform module.

## ⚡ Prerequisites (5 minutes)

### 1. Create MongoDB Atlas Account
```
1. Go to: https://www.mongodb.com/cloud/atlas/register
2. Sign up with your email
3. Verify email
```

### 2. Create Organization & Project
```
1. Login to MongoDB Atlas
2. Create Organization: "LG-Casas"
3. Create Project: "casas-dev" or "casas-prod"
4. Note the Project ID (Settings → General → Project ID)
   Example: 507f1f77bcf86cd799439011
```

### 3. Generate API Keys
```
1. Go to: Organization Settings → Access Manager → API Keys
2. Click "Create API Key"
3. Description: "Terraform Automation"
4. Permissions: "Organization Project Creator" + "Organization Owner"
5. Save both keys:
   - Public Key (like username)
   - Private Key (like password)
```

## 🚀 Quick Setup (2 minutes)

### Option 1: Free Tier (Development)

Create `terraform.tfvars`:

```hcl
# MongoDB Atlas Credentials
mongodb_atlas_public_key  = "your-public-key"
mongodb_atlas_private_key = "your-private-key"
mongodb_atlas_project_id  = "507f1f77bcf86cd799439011"

# Basic Config
cluster_name              = "casas-dev-db"
environment               = "dev"
provider_instance_size    = "M0"  # FREE tier
backup_enabled            = false  # Not available on M0
```

### Option 2: Production (Paid)

Create `terraform.tfvars`:

```hcl
# MongoDB Atlas Credentials
mongodb_atlas_public_key  = "your-public-key"
mongodb_atlas_private_key = "your-private-key"
mongodb_atlas_project_id  = "507f1f77bcf86cd799439011"

# Basic Config
cluster_name              = "casas-prod-db"
environment               = "prod"
provider_instance_size    = "M10"  # ~$60/month
disk_size_gb              = 10
backup_enabled            = true
replication_factor        = 3
```

## 📦 Deploy (3 minutes)

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Deploy (takes 5-10 minutes to create cluster)
terraform apply

# Get connection string
terraform output mongo_uri
```

## 🔐 Post-Deployment (2 minutes)

### 1. Configure IP Whitelist
```
1. Login to MongoDB Atlas
2. Go to: Network Access → IP Access List
3. Click "Add IP Address"
4. Add your application's IP or 0.0.0.0/0 (for testing only!)
```

### 2. Create Database User
```
1. Go to: Database Access → Add New Database User
2. Username: app-user
3. Password: Generate strong password
4. Privileges: "Read and write to any database"
5. Save username and password (you'll need for connection string)
```

## 📝 Connect to Database

### Connection String Format
```
mongodb+srv://<username>:<password>@<cluster-address>/<database>?retryWrites=true&w=majority
```

### Example
```
mongodb+srv://app-user:MyPassword@casas-dev-db.abc123.mongodb.net/mydb?retryWrites=true&w=majority
```

### From Terraform Output
```bash
# Get connection string
terraform output -raw mongo_uri

# Get SRV address (modern format)
terraform output -raw srv_address
```

## 🧪 Test Connection

### Using MongoDB Shell (mongosh)
```bash
# Install mongosh
brew install mongosh  # macOS
# or download from: https://www.mongodb.com/try/download/shell

# Connect
mongosh "mongodb+srv://app-user:password@casas-dev-db.abc123.mongodb.net/mydb"
```

### Using Node.js
```javascript
const { MongoClient } = require('mongodb');

const uri = "mongodb+srv://app-user:password@casas-dev-db.abc123.mongodb.net/mydb";
const client = new MongoClient(uri);

async function run() {
  try {
    await client.connect();
    console.log("Connected to MongoDB Atlas!");
    
    const database = client.db('mydb');
    const collection = database.collection('test');
    
    await collection.insertOne({ message: "Hello from MongoDB Atlas!" });
    console.log("Document inserted!");
  } finally {
    await client.close();
  }
}

run().catch(console.dir);
```

### Using Python
```python
from pymongo import MongoClient

uri = "mongodb+srv://app-user:password@casas-dev-db.abc123.mongodb.net/mydb"
client = MongoClient(uri)

try:
    db = client.mydb
    collection = db.test
    
    collection.insert_one({"message": "Hello from MongoDB Atlas!"})
    print("Connected and inserted document!")
finally:
    client.close()
```

## 📊 Monitor Cluster

### Atlas Console
```
1. Login to MongoDB Atlas
2. Go to: Clusters → Your Cluster
3. View metrics:
   - CPU usage
   - Memory usage
   - Disk I/O
   - Connections
   - Operations per second
```

### Set Up Alerts
```
1. Go to: Alerts → Create New Alert
2. Example: Alert when connections > 80% capacity
3. Add notification email or Slack webhook
```

## 💰 Cost Estimates

| Tier | Monthly Cost | Use Case |
|------|--------------|----------|
| M0 | **FREE** | Dev/Test only |
| M10 | ~$60 | Small production |
| M20 | ~$150 | Medium production |
| M30 | ~$300 | Large production |

## 🔧 Common Issues

### Issue 1: "Authentication failed"
**Solution:** Check API keys are correct in `terraform.tfvars`

### Issue 2: "Project not found"
**Solution:** Verify Project ID from Atlas Console → Project Settings

### Issue 3: "Connection timeout"
**Solution:** Add your IP to Network Access whitelist

### Issue 4: "User not authorized"
**Solution:** Create database user in Atlas Console → Database Access

## 📚 Next Steps

1. ✅ Read [README.md](README.md) for full documentation
2. ✅ Read [EXPLANATION.md](EXPLANATION.md) for detailed explanations
3. ✅ Check [terraform.tfvars.example](terraform.tfvars.example) for all configuration options
4. ✅ Set up monitoring and alerts
5. ✅ Configure automated backups (M10+ only)
6. ✅ Review security best practices in README.md

## 🆘 Need Help?

- **MongoDB Atlas Docs:** https://www.mongodb.com/docs/atlas/
- **Terraform Provider:** https://registry.terraform.io/providers/mongodb/mongodbatlas/latest/docs
- **Support:** https://support.mongodb.com/

## 🎉 That's It!

You now have a fully functional MongoDB database running in MongoDB Atlas, managed by Terraform!

**Total time:** ~15 minutes (including account setup)
