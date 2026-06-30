
## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         GCP Cloud                            │
│                                                              │
│  ┌────────────────────────────────────────────┐             │
│  │           GKE Cluster                       │             │
│  │  ┌──────────────┐  ┌──────────────┐        │             │
│  │  │   Pod 1      │  │   Pod 2      │        │             │
│  │  │  (App + DB   │  │  (App + DB   │        │             │
│  │  │   Client)    │  │   Client)    │        │             │
│  │  └──────┬───────┘  └──────┬───────┘        │             │
│  │         │                  │                │             │
│  │         └──────────┬───────┘                │             │
│  │                    │                        │             │
│  │              Kubernetes Secret              │             │
│  │         (MongoDB Connection String)         │             │
│  └────────────────────┼────────────────────────┘             │
│                       │                                      │
│                       │ Encrypted Connection                 │
│                       │ (TLS/SSL)                            │
└───────────────────────┼──────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────────┐
        │     MongoDB Atlas Cluster         │
        │   (Multi-region, Managed DBaaS)   │
        │                                   │
        │  Authentication:                  │
        │  - IP Whitelist / VPC Peering     │
        │  - Database User/Password         │
        └───────────────────────────────────┘
```

---

## Prerequisites

### 1. MongoDB Atlas Cluster
- ✅ Cluster created using this Terraform module
- ✅ Connection string available from Terraform output:
  ```bash
  terraform output -raw mongo_uri
  # Output: mongodb+srv://casas-dev-db.abc123.mongodb.net
  ```

### 2. GKE Cluster
- ✅ GKE cluster running in GCP
- ✅ `kubectl` configured to access your GKE cluster
- ✅ Appropriate IAM permissions

### 3. Database User
- ✅ Database user created in MongoDB Atlas console
- ✅ Username and password saved securely

---

## Network Connectivity Options

### Comparison

| Option | Security | Complexity | Cost | Use Case |
|--------|----------|------------|------|----------|
| **IP Whitelist** | Low | Low | Free | Dev/Testing |
| **VPC Peering** | Medium | Medium | Free* | Production |
| **Private Endpoint** | High | High | ~$0.01/hour | Enterprise |

\* VPC Peering is free, but you pay for cross-region egress if applicable

---

## Option 1: IP Whitelist (Simplest)

### When to Use
- ✅ Development and testing environments
- ✅ Quick setup needed
- ✅ Cost is primary concern
- ❌ NOT recommended for production (security risk)

### Step 1: Get GKE NAT Gateway IP

```bash
# Get the external IP of your GKE nodes
kubectl get nodes -o wide

# Or get NAT gateway IP if using Cloud NAT
gcloud compute addresses list --filter="name~nat" --format="value(address)"
```

### Step 2: Whitelist IPs in MongoDB Atlas

**Via Atlas Console:**
1. Login to MongoDB Atlas
2. Navigate to **Network Access** → **IP Access List**
3. Click **"Add IP Address"**
4. Add GKE node IPs or NAT gateway IP
5. Description: `GKE Cluster - casas-dev`
6. Click **"Confirm"**

**Via Terraform** (recommended):

Create `network-access.tf`:

```hcl
# Get GKE cluster details
data "google_container_cluster" "gke" {
  name     = "your-gke-cluster-name"
  location = "us-central1"
  project  = "your-gcp-project-id"
}

# Whitelist GKE NAT gateway IP
resource "mongodbatlas_project_ip_access_list" "gke_nat" {
  project_id = var.project_id
  cidr_block = "${data.google_compute_address.nat_ip.address}/32"
  comment    = "GKE Cluster NAT Gateway"
}
```

### Step 3: Test Connectivity from GKE

```bash
# Create a test pod
kubectl run mongodb-test --image=mongo:7.0 --rm -it --restart=Never -- bash

# Inside the pod, test connection
mongosh "mongodb+srv://app-user:password@casas-dev-db.abc123.mongodb.net/mydb"
```

---

## Option 2: VPC Peering (Production)

### When to Use
- ✅ Production environments
- ✅ Need secure, private connectivity
- ✅ Want to avoid exposing database to internet
- ✅ Same cloud provider (GCP ↔ MongoDB on GCP)

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your GCP Project                          │
│                                                              │
│  ┌────────────────────┐                                      │
│  │   GKE Cluster      │                                      │
│  │   VPC Network      │                                      │
│  │   10.0.0.0/16      │                                      │
│  └─────────┬──────────┘                                      │
│            │                                                 │
│            │ VPC Peering                                     │
└────────────┼─────────────────────────────────────────────────┘
             │
             │ Private Network
             │ (No internet exposure)
             │
┌────────────┼─────────────────────────────────────────────────┐
│            │        MongoDB Atlas Project                    │
│  ┌─────────▼──────────┐                                      │
│  │  MongoDB Cluster   │                                      │
│  │  VPC Network       │                                      │
│  │  192.168.0.0/16    │                                      │
│  └────────────────────┘                                      │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Get GCP VPC Information

```bash
# Get your GKE cluster's VPC network
gcloud container clusters describe your-gke-cluster \
  --zone=us-central1-a \
  --format="value(network)"

# Output: projects/your-project/global/networks/default

# Get VPC network details
gcloud compute networks describe default \
  --format="value(name, IPv4Range)"
```

### Step 2: Configure Network Peering in MongoDB Atlas

**Via Atlas Console:**

1. Login to MongoDB Atlas
2. Navigate to **Network Access** → **Peering**
3. Click **"Add Peering Connection"**
4. Select **GCP**
5. Fill in details:
   - **GCP Project ID**: `your-gcp-project-id`
   - **VPC Network Name**: `default` (or your custom VPC)
   - **Atlas CIDR Block**: `192.168.0.0/18` (must not overlap with your VPC)
6. Click **"Initiate Peering"**
7. Copy the command provided by Atlas

**Via Terraform:**

```hcl
# Create VPC peering connection
resource "mongodbatlas_network_peering" "gcp" {
  project_id     = var.project_id
  container_id   = mongodbatlas_network_container.gcp.id
  provider_name  = "GCP"
  
  gcp_project_id = "your-gcp-project-id"
  network_name   = "default"
}

# Create network container for peering
resource "mongodbatlas_network_container" "gcp" {
  project_id       = var.project_id
  atlas_cidr_block = "192.168.0.0/18"
  provider_name    = "GCP"
  region           = "WESTERN_EUROPE"
}
```

### Step 3: Accept Peering in GCP

```bash
# Accept the peering connection in GCP
gcloud compute networks peerings create atlas-peering \
  --network=default \
  --peer-project=<ATLAS_GCP_PROJECT_ID> \
  --peer-network=<ATLAS_NETWORK_NAME> \
  --auto-create-routes
```

**Note:** Replace `<ATLAS_GCP_PROJECT_ID>` and `<ATLAS_NETWORK_NAME>` with values from Atlas console.

### Step 4: Update MongoDB Connection String

Once peering is established, use **private connection string**:

```bash
# Get private connection string from Terraform
terraform output -raw connection_strings
```

---

## Option 3: Private Endpoint (Most Secure)

### When to Use
- ✅ Enterprise/regulated environments
- ✅ Maximum security required
- ✅ Compliance requirements (PCI-DSS, HIPAA)
- ✅ Budget allows (~$0.01/hour per endpoint)

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Your GCP Project                          │
│                                                              │
│  ┌────────────────────┐     ┌──────────────────┐            │
│  │   GKE Cluster      │────>│ Private Service  │            │
│  │                    │     │ Connect Endpoint │            │
│  └────────────────────┘     └────────┬─────────┘            │
│                                      │                      │
└──────────────────────────────────────┼──────────────────────┘
                                       │
                                       │ Private Link
                                       │ (No internet, no peering)
                                       │
┌──────────────────────────────────────┼──────────────────────┐
│                                      │  MongoDB Atlas        │
│                             ┌────────▼─────────┐             │
│                             │ MongoDB Cluster  │             │
│                             │ (Private Access) │             │
│                             └──────────────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### Setup

**Via Atlas Console:**
1. Navigate to **Network Access** → **Private Endpoint**
2. Click **"Add Private Endpoint"**
3. Select **GCP Private Service Connect**
4. Follow the wizard to create endpoint

**Terraform Example:**

```hcl
resource "mongodbatlas_privatelink_endpoint" "gcp" {
  project_id    = var.project_id
  provider_name = "GCP"
  region        = "us-central1"
}

resource "google_compute_address" "mongodb_psc" {
  name         = "mongodb-psc-endpoint"
  address_type = "INTERNAL"
  purpose      = "GCE_ENDPOINT"
  region       = "us-central1"
  subnetwork   = "default"
}

resource "google_compute_forwarding_rule" "mongodb_psc" {
  name                  = "mongodb-psc-forwarding-rule"
  region                = "us-central1"
  target                = mongodbatlas_privatelink_endpoint.gcp.service_attachment_name
  load_balancing_scheme = ""
  network               = "default"
  ip_address            = google_compute_address.mongodb_psc.id
}
```

---

## Storing MongoDB Credentials in Kubernetes

### Option A: Kubernetes Secrets (Manual)

#### Step 1: Create Database User in MongoDB Atlas

1. Navigate to **Database Access** → **Add New Database User**
2. Username: `gke-app-user`
3. Password: Generate strong password
4. Privileges: `Read and write to any database`
5. Save credentials

#### Step 2: Create Kubernetes Secret

```bash
# Create secret with connection string
kubectl create secret generic mongodb-secret \
  --from-literal=connection-string='mongodb+srv://gke-app-user:PASSWORD@casas-dev-db.abc123.mongodb.net/mydb?retryWrites=true&w=majority'

# Or create from individual components
kubectl create secret generic mongodb-secret \
  --from-literal=username='gke-app-user' \
  --from-literal=password='YOUR_PASSWORD' \
  --from-literal=host='casas-dev-db.abc123.mongodb.net' \
  --from-literal=database='mydb'
```

#### Step 3: Verify Secret

```bash
# List secrets
kubectl get secrets

# View secret (base64 encoded)
kubectl get secret mongodb-secret -o yaml

# Decode secret
kubectl get secret mongodb-secret -o jsonpath='{.data.connection-string}' | base64 -d
```

### Option B: Using Terraform to Create Secret

Create `kubernetes-secret.tf`:

```hcl
# Provider for Kubernetes
provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Get MongoDB connection string from outputs
locals {
  mongo_uri = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  
  # Assemble complete connection string
  connection_string = "mongodb+srv://${var.db_username}:${var.db_password}@${replace(local.mongo_uri, "mongodb+srv://", "")}/${var.db_name}?retryWrites=true&w=majority"
}

# Create Kubernetes secret
resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = "default"
  }

  data = {
    connection-string = local.connection_string
    username         = var.db_username
    password         = var.db_password
    host             = replace(local.mongo_uri, "mongodb+srv://", "")
    database         = var.db_name
  }

  type = "Opaque"
}
```

### Option C: Google Secret Manager (Production Best Practice)

#### Step 1: Store Secret in Google Secret Manager

```bash
# Create connection string secret
echo -n "mongodb+srv://gke-app-user:PASSWORD@casas-dev-db.abc123.mongodb.net/mydb" | \
  gcloud secrets create mongodb-connection-string \
  --data-file=- \
  --replication-policy="automatic"

# Grant GKE service account access
gcloud secrets add-iam-policy-binding mongodb-connection-string \
  --member="serviceAccount:YOUR-GKE-SA@YOUR-PROJECT.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

#### Step 2: Use External Secrets Operator

Install External Secrets Operator:

```bash
helm repo add external-secrets https://charts.external-secrets.io
helm install external-secrets external-secrets/external-secrets -n external-secrets-system --create-namespace
```

Create `external-secret.yaml`:

```yaml
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: gcpsm-secret-store
  namespace: default
spec:
  provider:
    gcpsm:
      projectID: "your-gcp-project-id"
      auth:
        workloadIdentity:
          clusterLocation: us-central1
          clusterName: your-gke-cluster
          serviceAccountRef:
            name: external-secrets-sa
---
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: mongodb-external-secret
  namespace: default
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: gcpsm-secret-store
    kind: SecretStore
  target:
    name: mongodb-secret
    creationPolicy: Owner
  data:
    - secretKey: connection-string
      remoteRef:
        key: mongodb-connection-string
```

Apply:

```bash
kubectl apply -f external-secret.yaml
```

---

## Deploying Applications

### Example 1: Node.js Application

Create `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nodejs-mongodb-app
  labels:
    app: nodejs-mongodb-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nodejs-mongodb-app
  template:
    metadata:
      labels:
        app: nodejs-mongodb-app
    spec:
      containers:
      - name: app
        image: gcr.io/your-project/nodejs-app:latest
        ports:
        - containerPort: 3000
        env:
        # Option 1: Use complete connection string
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: connection-string
        
        # Option 2: Use individual components
        # - name: MONGODB_HOST
        #   valueFrom:
        #     secretKeyRef:
        #       name: mongodb-secret
        #       key: host
        # - name: MONGODB_USER
        #   valueFrom:
        #     secretKeyRef:
        #       name: mongodb-secret
        #       key: username
        # - name: MONGODB_PASSWORD
        #   valueFrom:
        #     secretKeyRef:
        #       name: mongodb-secret
        #       key: password
        # - name: MONGODB_DATABASE
        #   valueFrom:
        #     secretKeyRef:
        #       name: mongodb-secret
        #       key: database
        
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: nodejs-mongodb-app
spec:
  selector:
    app: nodejs-mongodb-app
  ports:
  - port: 80
    targetPort: 3000
  type: LoadBalancer
```

**Application Code** (`server.js`):

```javascript
const express = require('express');
const { MongoClient } = require('mongodb');

const app = express();
const port = process.env.PORT || 3000;

// Get MongoDB URI from environment variable
const mongoUri = process.env.MONGODB_URI;

// Or build from components
// const mongoUri = `mongodb+srv://${process.env.MONGODB_USER}:${process.env.MONGODB_PASSWORD}@${process.env.MONGODB_HOST}/${process.env.MONGODB_DATABASE}`;

let db;

// Connect to MongoDB
async function connectDB() {
  try {
    const client = await MongoClient.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      maxPoolSize: 50,
      wtimeoutMS: 2500,
    });
    
    db = client.db();
    console.log('Connected to MongoDB Atlas');
  } catch (error) {
    console.error('MongoDB connection error:', error);
    process.exit(1);
  }
}

connectDB();

// Health check endpoint
app.get('/health', async (req, res) => {
  try {
    await db.admin().ping();
    res.status(200).json({ status: 'healthy', mongodb: 'connected' });
  } catch (error) {
    res.status(503).json({ status: 'unhealthy', mongodb: 'disconnected' });
  }
});

// Readiness probe
app.get('/ready', async (req, res) => {
  if (db) {
    res.status(200).json({ ready: true });
  } else {
    res.status(503).json({ ready: false });
  }
});

// API endpoints
app.get('/api/users', async (req, res) => {
  try {
    const users = await db.collection('users').find({}).limit(10).toArray();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
```

**Dockerfile**:

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

USER node

CMD ["node", "server.js"]
```

Deploy:

```bash
# Build and push image
docker build -t gcr.io/your-project/nodejs-app:latest .
docker push gcr.io/your-project/nodejs-app:latest

# Deploy to GKE
kubectl apply -f deployment.yaml

# Check deployment
kubectl get deployments
kubectl get pods
kubectl logs -l app=nodejs-mongodb-app

# Get service external IP
kubectl get service nodejs-mongodb-app
```

### Example 2: Python FastAPI Application

Create `deployment-python.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: python-mongodb-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: python-mongodb-app
  template:
    metadata:
      labels:
        app: python-mongodb-app
    spec:
      containers:
      - name: app
        image: gcr.io/your-project/python-app:latest
        ports:
        - containerPort: 8000
        env:
        - name: MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: mongodb-secret
              key: connection-string
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: python-mongodb-app
spec:
  selector:
    app: python-mongodb-app
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

**Application Code** (`main.py`):

```python
from fastapi import FastAPI, HTTPException
from pymongo import MongoClient
from pydantic import BaseModel
import os

app = FastAPI()

# Get MongoDB URI from environment
mongodb_uri = os.getenv("MONGODB_URI")

# Connect to MongoDB
client = MongoClient(mongodb_uri)
db = client.get_database()

class User(BaseModel):
    name: str
    email: str

@app.get("/health")
async def health_check():
    try:
        client.admin.command('ping')
        return {"status": "healthy", "mongodb": "connected"}
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

@app.get("/api/users")
async def get_users():
    try:
        users = list(db.users.find({}, {"_id": 0}).limit(10))
        return users
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/users")
async def create_user(user: User):
    try:
        result = db.users.insert_one(user.dict())
        return {"id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

---

## Best Practices

### 1. Connection Pooling

**Node.js:**
```javascript
const client = new MongoClient(uri, {
  maxPoolSize: 50,           // Maximum connections
  minPoolSize: 10,           // Minimum connections
  maxIdleTimeMS: 30000,      // Close idle connections after 30s
  serverSelectionTimeoutMS: 5000,
  socketTimeoutMS: 45000,
});
```

**Python:**
```python
client = MongoClient(
    uri,
    maxPoolSize=50,
    minPoolSize=10,
    maxIdleTimeMS=30000,
    serverSelectionTimeoutMS=5000,
    socketTimeoutMS=45000
)
```

### 2. Retry Logic

```javascript
async function connectWithRetry(retries = 5) {
  for (let i = 0; i < retries; i++) {
    try {
      const client = await MongoClient.connect(uri);
      console.log('Connected to MongoDB');
      return client;
    } catch (error) {
      console.log(`Connection attempt ${i + 1} failed. Retrying...`);
      await new Promise(resolve => setTimeout(resolve, 5000));
    }
  }
  throw new Error('Failed to connect to MongoDB after retries');
}
```

### 3. Monitoring and Logging

```yaml
# Add logging sidecar
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Flush        1
        Log_Level    info
    
    [INPUT]
        Name              tail
        Path              /var/log/containers/*app*.log
        Parser            docker
        Tag               app.*
    
    [OUTPUT]
        Name   stackdriver
        Match  *
```

### 4. Resource Limits

```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 5. Horizontal Pod Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: mongodb-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nodejs-mongodb-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### 6. Network Policies

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: mongodb-app-netpol
spec:
  podSelector:
    matchLabels:
      app: nodejs-mongodb-app
  policyTypes:
  - Egress
  egress:
  # Allow DNS
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
    ports:
    - protocol: UDP
      port: 53
  # Allow MongoDB Atlas (adjust based on your connection method)
  - to:
    - podSelector: {}
    ports:
    - protocol: TCP
      port: 27017
  # Allow HTTPS for MongoDB SRV
  - ports:
    - protocol: TCP
      port: 443
```

---

## Complete Example

### Full Terraform Configuration

Create `gke-integration.tf`:

```hcl
# Variables
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gke_cluster_name" {
  description = "GKE Cluster Name"
  type        = string
}

variable "db_username" {
  description = "MongoDB database username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "MongoDB database password"
  type        = string
  sensitive   = true
}

# Get GKE cluster info
data "google_container_cluster" "gke" {
  name     = var.gke_cluster_name
  location = "us-central1"
  project  = var.gcp_project_id
}

# Get GKE NAT IP (if using Cloud NAT)
data "google_compute_address" "nat_ip" {
  name    = "nat-gateway-ip"
  region  = "us-central1"
  project = var.gcp_project_id
}

# Whitelist GKE NAT IP in MongoDB Atlas
resource "mongodbatlas_project_ip_access_list" "gke" {
  project_id = var.project_id
  cidr_block = "${data.google_compute_address.nat_ip.address}/32"
  comment    = "GKE Cluster ${var.gke_cluster_name}"
}

# Create MongoDB database user
resource "mongodbatlas_database_user" "gke_user" {
  username           = var.db_username
  password           = var.db_password
  project_id         = var.project_id
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "mydb"
  }

  labels {
    key   = "environment"
    value = var.environment
  }

  labels {
    key   = "service"
    value = "gke-app"
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(data.google_container_cluster.gke.master_auth.0.cluster_ca_certificate)
}

data "google_client_config" "default" {}

# Create Kubernetes namespace
resource "kubernetes_namespace" "app" {
  metadata {
    name = "casas-app"
  }
}

# Create Kubernetes secret with MongoDB credentials
resource "kubernetes_secret" "mongodb" {
  metadata {
    name      = "mongodb-secret"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  data = {
    connection-string = "mongodb+srv://${var.db_username}:${var.db_password}@${replace(mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv, "mongodb+srv://", "")}/mydb?retryWrites=true&w=majority"
    username          = var.db_username
    password          = var.db_password
    host              = replace(mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv, "mongodb+srv://", "")
    database          = "mydb"
  }

  type = "Opaque"
}

# Output for verification
output "kubernetes_secret_name" {
  description = "Name of the Kubernetes secret containing MongoDB credentials"
  value       = kubernetes_secret.mongodb.metadata[0].name
}

output "kubernetes_namespace" {
  description = "Kubernetes namespace where secret is created"
  value       = kubernetes_namespace.app.metadata[0].name
}
```

### Deploy Everything

```bash
# 1. Create MongoDB cluster and configure GKE access
terraform init
terraform plan
terraform apply

# 2. Verify secret was created in GKE
kubectl get secret mongodb-secret -n casas-app

# 3. Deploy your application
kubectl apply -f deployment.yaml -n casas-app

# 4. Verify deployment
kubectl get pods -n casas-app
kubectl logs -l app=nodejs-mongodb-app -n casas-app

# 5. Test connectivity
kubectl exec -it <pod-name> -n casas-app -- sh
# Inside pod:
mongosh "$MONGODB_URI"
```

---

## Troubleshooting

### Issue 1: Connection Timeout

**Symptoms:**
```
MongooseServerSelectionError: connection timed out
```

**Solutions:**
1. Check IP whitelist in MongoDB Atlas
2. Verify GKE nodes can reach internet
3. Check firewall rules

```bash
# Test from GKE pod
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- sh
curl -v telnet://casas-dev-db.abc123.mongodb.net:27017
```

### Issue 2: Authentication Failed

**Symptoms:**
```
MongoServerError: Authentication failed
```

**Solutions:**
1. Verify database username/password
2. Check secret is correctly created
3. Ensure user has correct permissions

```bash
# Verify secret
kubectl get secret mongodb-secret -o jsonpath='{.data.connection-string}' | base64 -d
```

### Issue 3: DNS Resolution Failure

**Symptoms:**
```
Error: getaddrinfo ENOTFOUND casas-dev-db.abc123.mongodb.net
```

**Solutions:**
1. Check CoreDNS is running
2. Verify DNS resolution

```bash
# Check CoreDNS
kubectl get pods -n kube-system -l k8s-app=kube-dns

# Test DNS from pod
kubectl run -it --rm debug --image=busybox --restart=Never -- sh
nslookup casas-dev-db.abc123.mongodb.net
```

### Issue 4: Certificate Verification Failed

**Symptoms:**
```
Error: unable to verify the first certificate
```

**Solution:**
Ensure TLS/SSL is properly configured:

```javascript
const client = new MongoClient(uri, {
  tls: true,
  tlsAllowInvalidCertificates: false, // Don't set to true in production!
});
```

---

## Security Checklist

- [ ] Use VPC Peering or Private Endpoint (not IP whitelist in production)
- [ ] Store credentials in Google Secret Manager (not Kubernetes secrets directly)
- [ ] Use strong database passwords (20+ characters)
- [ ] Enable encryption at rest in MongoDB Atlas
- [ ] Enable audit logging in MongoDB Atlas
- [ ] Rotate credentials regularly (every 90 days)
- [ ] Use least privilege database roles
- [ ] Enable network policies in GKE
- [ ] Use Pod Security Policies
- [ ] Monitor connection patterns for anomalies
- [ ] Set up alerts for failed authentication attempts
- [ ] Use Workload Identity for GKE → GCP Secret Manager access

---

## Monitoring

### MongoDB Atlas Metrics

Monitor these in Atlas console:
- Connection count
- Query execution time
- Disk I/O
- CPU usage
- Memory usage
- Network throughput

### GKE Application Metrics

```yaml
# Prometheus ServiceMonitor
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: mongodb-app-metrics
spec:
  selector:
    matchLabels:
      app: nodejs-mongodb-app
  endpoints:
  - port: metrics
    interval: 30s
```

### Alerting

Set up alerts for:
- High connection count (>80% of max)
- Slow queries (>1000ms)
- Connection failures
- High error rates
- Pod restarts

---

## Summary

**Recommended Setup for Production:**

1. **Network:** VPC Peering or Private Endpoint
2. **Secrets:** Google Secret Manager with External Secrets Operator
3. **Database User:** Dedicated user per application with least privilege
4. **Monitoring:** MongoDB Atlas + Cloud Monitoring
5. **Scaling:** HPA based on CPU/Memory
6. **Security:** Network policies + Pod security policies

**Quick Start for Development:**

1. Use IP whitelist
2. Create Kubernetes secret manually
3. Deploy application with secret reference
4. Test connection

---

## Additional Resources

- [MongoDB Atlas GKE Best Practices](https://www.mongodb.com/docs/atlas/reference/google-gcp/)
- [GKE Networking Overview](https://cloud.google.com/kubernetes-engine/docs/concepts/network-overview)
- [External Secrets Operator](https://external-secrets.io/)
- [MongoDB Connection String Options](https://www.mongodb.com/docs/manual/reference/connection-string/)
