# Line-by-Line Explanation of MongoDB Atlas Module

Complete breakdown of every single line in every Terraform file.

---

## Table of Contents
1. [variables.tf - Complete Breakdown](#variablestf---complete-breakdown)
2. [main.tf - Complete Breakdown](#maintf---complete-breakdown)
3. [outputs.tf - Complete Breakdown](#outputstf---complete-breakdown)
4. [versions.tf - Complete Breakdown](#versionstf---complete-breakdown)

---

# variables.tf - Complete Breakdown

## File Purpose
This file **defines all the settings** (inputs) that users can customize when creating a MongoDB cluster.

Think of it like a **restaurant menu** - it lists all the options you can choose from.

---

## Line-by-Line Explanation

### Lines 1-3: Section Header (Comment)
```hcl
###############################################################################
#                           Required Variables                                 #
###############################################################################
```

**What this is:** Just a comment (ignored by Terraform)

**Purpose:** Organizes the file into sections for readability

**The `#` symbol:** In Terraform, `#` means "this is a comment, ignore it"

**Why use it:** Helps humans understand the code structure

---

### Lines 5-16: Variable `cluster_name`

```hcl
variable "cluster_name" {
  description = "Name of the MongoDB Atlas cluster (must be unique within the project)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.cluster_name))
    error_message = "Cluster name must start with a letter, contain only letters, numbers, and hyphens, and be 1-64 characters long."
  }
}
```

#### Line 5: `variable "cluster_name" {`
**Syntax breakdown:**
- `variable` = Terraform keyword meaning "this is a configurable input"
- `"cluster_name"` = The name of this variable (what users will reference)
- `{` = Opening brace (everything until `}` belongs to this variable)

**Real-world analogy:** Like creating a form field labeled "Cluster Name"

---

#### Line 6: `description = "Name of the MongoDB Atlas cluster..."`
**What it does:** Human-readable explanation of what this variable is for

**Where it's used:**
- When you run `terraform plan`, it shows this description
- In documentation
- In IDE tooltips

**Example:** 
```
When user types: terraform plan
Terraform shows: "What is cluster_name? Name of the MongoDB Atlas cluster..."
```

---

#### Line 7: `type = string`
**What it does:** Defines what **kind of value** this variable accepts

**Available types in Terraform:**
- `string` = Text (e.g., "hello", "my-cluster-name")
- `number` = Numbers (e.g., 10, 3.14)
- `bool` = True or False
- `list` = Array of values (e.g., ["item1", "item2"])
- `map` = Key-value pairs (e.g., {key = "value"})

**Why `string` here:** Cluster name is text, not a number or boolean

**Example:**
```hcl
# Valid (string):
cluster_name = "my-app-db"

# Invalid (number):
cluster_name = 123  # ❌ Error! Expected string, got number
```

---

#### Lines 9-12: Validation Block
```hcl
validation {
  condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.cluster_name))
  error_message = "Cluster name must start with a letter..."
}
```

**What is validation:** A rule that checks if the value is acceptable

**Real-world analogy:** Like form validation on a website
```
Password must:
  ✅ Be at least 8 characters
  ✅ Contain a number
  ❌ If you type "abc", it says "Too short!"
```

---

#### Line 10: The `condition`
```hcl
condition = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.cluster_name))
```

**Breaking this down:**

**1. `regex(...)` - Pattern Matching**
- `regex` = Regular expression (pattern matching tool)
- Checks if text matches a specific pattern

**2. The Pattern: `"^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$"`**

Let me break this pattern into parts:

```
^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$
│    │          │         │        │
│    │          │         │        └─ Must end with letter or number
│    │          │         └─ Can have 0-62 more characters
│    │          └─ Letters, numbers, or hyphens
│    └─ Must start with a letter
└─ Start of string
```

**Part-by-part explanation:**

| Pattern Part | Meaning | Example |
|-------------|---------|---------|
| `^` | Start of string | (Ensures we check from beginning) |
| `[a-zA-Z]` | One letter (a-z or A-Z) | `a`, `B`, `m` ✅<br>`1`, `-` ❌ |
| `[a-zA-Z0-9-]` | Letter, number, or hyphen | `a`, `5`, `-` ✅<br>`_`, `@` ❌ |
| `{0,62}` | Repeat 0 to 62 times | Min 0, Max 62 characters |
| `[a-zA-Z0-9]` | End with letter or number | `a`, `5` ✅<br>`-` ❌ |
| `$` | End of string | (Ensures nothing after) |

**Examples:**
```
✅ Valid names:
  "app-db"           → Starts with 'a', ends with 'b'
  "MyCluster123"     → Starts with 'M', ends with '3'
  "a"                → Minimum 1 character (1 + 0 + 0)
  
❌ Invalid names:
  "123-db"           → Starts with number ❌
  "app-db-"          → Ends with hyphen ❌
  "app_db"           → Contains underscore ❌
  "app@db"           → Contains @ symbol ❌
```

**3. `can(...)` - Error Handler**

**What `can()` does:** Tries to run something, returns true if it succeeds, false if it fails

```hcl
can(regex(...))
```

**Behavior:**
```
If regex matches:     can() returns true  ✅
If regex doesn't match: can() returns false ❌
```

**Example:**
```hcl
can(regex("^[a-zA-Z]...", "app-db"))    → true  ✅ (starts with 'a')
can(regex("^[a-zA-Z]...", "123-db"))    → false ❌ (starts with '1')
```

**4. Full Condition Logic**

```hcl
condition = can(regex(..., var.cluster_name))
```

**Terraform reads this as:**
```
IF can(regex...) returns true:
  ✅ Validation passes, continue
ELSE:
  ❌ Validation fails, show error_message
```

---

#### Line 11: The `error_message`
```hcl
error_message = "Cluster name must start with a letter, contain only letters, numbers, and hyphens, and be 1-64 characters long."
```

**What it does:** The error message shown when validation fails

**When shown:**
```bash
$ terraform plan
│ 
│ Error: Invalid value for variable
│ 
│ Cluster name must start with a letter, contain only letters, 
│ numbers, and hyphens, and be 1-64 characters long.
│ 
```

**Example scenario:**
```hcl
# User provides:
cluster_name = "123-invalid"

# Validation fails:
condition = can(regex("^[a-zA-Z]...", "123-invalid"))  → false

# Terraform shows:
Error: Cluster name must start with a letter...
```

---

### Lines 18-20: Variable `project_id`

```hcl
variable "project_id" {
  description = "MongoDB Atlas Project ID (NOT GCP project ID - get this from Atlas console)"
  type        = string
}
```

#### Line 18: `variable "project_id" {`
**What:** Defines the MongoDB Atlas Project ID variable

**Important note in description:** "NOT GCP project ID"

**Why this matters:**
```
GCP Project ID:          "prj-d-srdl-casas-4zrs"      (Google Cloud)
MongoDB Atlas Project ID: "507f1f77bcf86cd799439011"  (MongoDB Atlas)

These are DIFFERENT!
```

#### Line 19: `description`
**Explains:** This is the MongoDB Atlas project ID (24-character hex string)

**How to get it:**
1. Login to MongoDB Atlas Console
2. Select your project
3. Settings → General → Project ID

#### Line 20: `type = string`
**Why string:** The ID is a mix of letters and numbers like "507f1f77bcf86cd799439011"

**No validation here** - MongoDB Atlas will reject invalid IDs anyway

---

### Lines 22-25: Section Header
```hcl
###############################################################################
#                        Cluster Configuration                                 #
###############################################################################
```

**Purpose:** Marks start of cluster configuration variables section

---

### Lines 27-36: Variable `cluster_type`

```hcl
variable "cluster_type" {
  description = "Type of cluster: REPLICASET (single region) or GEOSHARDED (multi-region)"
  type        = string
  default     = "REPLICASET"

  validation {
    condition     = contains(["REPLICASET", "GEOSHARDED"], var.cluster_type)
    error_message = "Cluster type must be REPLICASET or GEOSHARDED."
  }
}
```

#### Line 30: `default = "REPLICASET"`

**What `default` means:** If user doesn't provide a value, use this

**Example:**
```hcl
# User doesn't specify cluster_type:
module "db" {
  source = "lg-casas-tf-mongodb"
  cluster_name = "my-db"
  # cluster_type not specified
}

# Terraform automatically uses:
cluster_type = "REPLICASET"  ← default value
```

**When to use defaults:**
- For values that are "usually the same"
- Makes module easier to use (fewer required inputs)

---

#### Lines 32-35: Validation with `contains()`

```hcl
validation {
  condition     = contains(["REPLICASET", "GEOSHARDED"], var.cluster_type)
  error_message = "Cluster type must be REPLICASET or GEOSHARDED."
}
```

**New function: `contains(list, value)`**

**What it does:** Checks if a value exists in a list

**Syntax:**
```hcl
contains(list, value)
```

**Breaking down our example:**
```hcl
contains(["REPLICASET", "GEOSHARDED"], var.cluster_type)
         └──────────┬──────────────┘  └──────┬────────┘
                    │                        │
                List of allowed values    Value to check
```

**How it works:**
```
List: ["REPLICASET", "GEOSHARDED"]
Value: var.cluster_type

IF var.cluster_type is in the list:
  contains() returns true  ✅
ELSE:
  contains() returns false ❌
```

**Examples:**
```hcl
# Valid values:
contains(["REPLICASET", "GEOSHARDED"], "REPLICASET")  → true  ✅
contains(["REPLICASET", "GEOSHARDED"], "GEOSHARDED")  → true  ✅

# Invalid values:
contains(["REPLICASET", "GEOSHARDED"], "SHARDED")     → false ❌
contains(["REPLICASET", "GEOSHARDED"], "replicaset")  → false ❌ (case-sensitive!)
contains(["REPLICASET", "GEOSHARDED"], "")            → false ❌
```

**Real-world scenario:**
```hcl
# User provides:
cluster_type = "SHARDED"  # Typo!

# Validation:
contains(["REPLICASET", "GEOSHARDED"], "SHARDED")  → false

# Terraform shows:
Error: Cluster type must be REPLICASET or GEOSHARDED.
```

---

### Lines 38-52: Variable `provider_name`

```hcl
variable "provider_name" {
  description = "Cloud provider: GCP, AWS, or AZURE"
  type        = string
  default     = "GCP"

  validation {
    condition     = contains(["GCP", "AWS", "AZURE"], var.provider_name)
    error_message = "Provider must be GCP, AWS, or AZURE."
  }
}
```

**Similar to `cluster_type`, but for cloud provider**

**Allowed values:** Only "GCP", "AWS", or "AZURE"

**Default:** "GCP" (assumes you're using Google Cloud)

**Why these exact values:**
- MongoDB Atlas uses these specific strings
- Case-sensitive (must be UPPERCASE)
- No other variations allowed

**Examples:**
```hcl
✅ Valid:
  provider_name = "GCP"
  provider_name = "AWS"
  provider_name = "AZURE"

❌ Invalid:
  provider_name = "gcp"       # Wrong case
  provider_name = "Google"    # Wrong name
  provider_name = "amazon"    # Wrong name
```

---

### Lines 54-57: Variable `provider_region`

```hcl
variable "provider_region" {
  description = "Cloud provider region (e.g., WESTERN_EUROPE for GCP, EU_WEST_1 for AWS)"
  type        = string
  default     = "WESTERN_EUROPE"
}
```

**What it is:** Physical location where database will be hosted

**Format:** MongoDB Atlas region codes (NOT GCP region names!)

**Common confusion:**
```
❌ WRONG (GCP format):
  provider_region = "europe-west1"

✅ CORRECT (MongoDB Atlas format):
  provider_region = "WESTERN_EUROPE"
```

**No validation here** - MongoDB Atlas will reject invalid region names

**Why no validation:**
- Too many regions to list (50+)
- Regions change over time (new ones added)
- Better to let MongoDB Atlas validate

---

### Lines 59-78: Variable `provider_instance_size`

```hcl
variable "provider_instance_size" {
  description = <<-EOT
    Instance size tier. Common values:
      - M0 (Free tier, 512MB RAM, shared CPU)
      - M10 (2GB RAM, 2 vCPU)
      - M20 (4GB RAM, 2 vCPU)
      - M30 (8GB RAM, 2 vCPU)
      - M40 (16GB RAM, 4 vCPU)
    See: https://www.mongodb.com/docs/atlas/reference/amazon-aws/
  EOT
  type        = string
  default     = "M10"
}
```

#### Lines 60-69: Multi-line Description with `<<-EOT`

**What `<<-EOT ... EOT` means:**

**Syntax:** Heredoc (here document) - allows multi-line strings

```hcl
description = <<-EOT
  Line 1
  Line 2
  Line 3
EOT
```

**Breaking it down:**
- `<<-EOT` = Start of multi-line string
- `EOT` = End of multi-line string (can be any word, "EOT" = End Of Text)
- Everything between is the description

**Why use it:**
```hcl
# Single line (hard to read):
description = "Instance size tier. Common values: M0 (Free tier, 512MB RAM, shared CPU), M10 (2GB RAM, 2 vCPU)..."

# Multi-line (easy to read):
description = <<-EOT
  Instance size tier. Common values:
    - M0 (Free tier, 512MB RAM, shared CPU)
    - M10 (2GB RAM, 2 vCPU)
EOT
```

**The `-` in `<<-EOT`:**
- Allows indentation to be stripped
- Makes code formatting cleaner

**Example:**
```hcl
# Without - (indentation included):
<<EOT
    Text here
EOT
Result: "    Text here" (has spaces)

# With - (indentation stripped):
<<-EOT
    Text here
EOT
Result: "Text here" (no leading spaces)
```

---

### Lines 80-83: Variable `mongodb_major_version`

```hcl
variable "mongodb_major_version" {
  description = "MongoDB major version (e.g., '7.0', '8.0')"
  type        = string
  default     = "7.0"
}
```

**What it is:** Which version of MongoDB software to use

**Format:** String (not a number!) - `"7.0"` not `7.0`

**Why string, not number:**
```hcl
# As number:
mongodb_major_version = 7.0
Terraform reads as: 7 (loses the .0)

# As string:
mongodb_major_version = "7.0"
Terraform reads as: "7.0" ✅ (keeps full version)
```

**Default:** "7.0" (stable, production-ready version)

---

### Lines 85-103: Variable `disk_size_gb`

```hcl
variable "disk_size_gb" {
  description = "Storage capacity in GB. Minimum: 10GB for M10+, not configurable for M0/M2/M5"
  type        = number
  default     = 10

  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Disk size must be at least 10GB for M10+ clusters."
  }
}
```

#### Line 87: `type = number`
**Why number, not string:**
```hcl
disk_size_gb = 10    # ✅ Number (can do math: 10 + 5 = 15)
disk_size_gb = "10"  # ❌ String (can't do math: "10" + "5" = "105")
```

#### Line 90: Comparison Validation
```hcl
condition = var.disk_size_gb >= 10
```

**New operator: `>=` (greater than or equal to)**

**Comparison operators in Terraform:**
```
==   Equal to
!=   Not equal to
>    Greater than
<    Less than
>=   Greater than or equal to
<=   Less than or equal to
```

**How this validation works:**
```hcl
var.disk_size_gb >= 10
```

**Logic:**
```
IF disk_size_gb is 10 or more:
  Validation passes ✅
ELSE:
  Validation fails ❌ Show error
```

**Examples:**
```hcl
disk_size_gb = 10   → 10 >= 10  → true  ✅
disk_size_gb = 50   → 50 >= 10  → true  ✅
disk_size_gb = 9    → 9 >= 10   → false ❌
disk_size_gb = 0    → 0 >= 10   → false ❌
```

---

### Lines 105-109: Variable `auto_scaling_disk_enabled`

```hcl
variable "auto_scaling_disk_enabled" {
  description = "Enable automatic disk scaling (not available for M0/M2/M5)"
  type        = bool
  default     = true
}
```

#### Line 107: `type = bool`

**What is `bool`:** Boolean - can only be `true` or `false`

**Valid values:**
```hcl
auto_scaling_disk_enabled = true   ✅
auto_scaling_disk_enabled = false  ✅
auto_scaling_disk_enabled = "yes"  ❌ (string, not bool)
auto_scaling_disk_enabled = 1      ❌ (number, not bool)
```

**No quotes around true/false:**
```hcl
✅ Correct:
  auto_scaling_disk_enabled = true

❌ Wrong:
  auto_scaling_disk_enabled = "true"  # This is a string!
```

**Default:** `true` (enable auto-scaling by default)

---

### Lines 111-131: Variable `backup_enabled`

```hcl
variable "backup_enabled" {
  description = "Enable continuous cloud backup (not available for M0/M2/M5)"
  type        = bool
  default     = true
}
```

**Same pattern as `auto_scaling_disk_enabled`**

**Type:** Boolean (true/false)

**Default:** `true` (enable backups by default for safety)

**Important note in description:** Not available for free tiers (M0/M2/M5)

---

### Lines 133-137: Variable `pit_enabled`

```hcl
variable "pit_enabled" {
  description = "Enable point-in-time restore (requires backup_enabled = true)"
  type        = bool
  default     = false
}
```

**Type:** Boolean

**Default:** `false` (disabled by default - costs extra money)

**Dependency:** Only works if `backup_enabled = true`

**Note:** This validation is NOT in variables.tf (would require in main.tf)

---

### Lines 139-158: Variable `num_shards`

```hcl
variable "num_shards" {
  description = "Number of shards (only for GEOSHARDED cluster_type, min: 1)"
  type        = number
  default     = 1

  validation {
    condition     = var.num_shards >= 1
    error_message = "Number of shards must be at least 1."
  }
}
```

**What it is:** How many pieces to split data across (for GEOSHARDED clusters)

**Type:** Number (not string)

**Default:** 1 (single shard)

**Validation:** Must be at least 1

**Only used when:** `cluster_type = "GEOSHARDED"`

**Examples:**
```hcl
num_shards = 1   ✅ Minimum
num_shards = 3   ✅ Three shards
num_shards = 0   ❌ Too low
num_shards = -1  ❌ Negative not allowed
```

---

### Lines 160-170: Variable `replication_factor`

```hcl
variable "replication_factor" {
  description = "Number of replica set members (3, 5, or 7 for high availability)"
  type        = number
  default     = 3

  validation {
    condition     = contains([3, 5, 7], var.replication_factor)
    error_message = "Replication factor must be 3, 5, or 7."
  }
}
```

#### Line 165: `contains()` with Number List

**Important:** This is a **list of numbers**, not strings

```hcl
contains([3, 5, 7], var.replication_factor)
         └──┬───┘
     Numbers (no quotes)
```

**Difference between number and string lists:**
```hcl
# Number list:
[3, 5, 7]          ✅

# String list:
["3", "5", "7"]    ❌ (different type!)

# If replication_factor is number 3:
contains([3, 5, 7], 3)      → true  ✅
contains(["3","5","7"], 3)  → false ❌ (type mismatch!)
```

**Valid values:** Only 3, 5, or 7 (odd numbers for voting)

**Why only odd numbers:**
- Prevents split-brain scenarios in failover
- Need majority for elections
- 3 nodes: need 2 to agree (majority)
- 4 nodes: 2 vs 2 = tie! (no majority)

---

### Lines 172-188: Variable `encryption_at_rest_enabled`

```hcl
variable "encryption_at_rest_enabled" {
  description = "Enable encryption at rest using cloud provider's encryption (M10+)"
  type        = bool
  default     = true
}
```

**Type:** Boolean

**Default:** `true` (encrypt by default - security best practice)

**Only available:** M10+ clusters (not M0 free tier)

---

### Lines 190-194: Variable `termination_protection_enabled`

```hcl
variable "termination_protection_enabled" {
  description = "Enable termination protection to prevent accidental deletion"
  type        = bool
  default     = true
}
```

**Type:** Boolean

**Default:** `true` (prevent accidents by default)

**Purpose:** Requires extra steps to delete cluster (safety feature)

---

### Lines 196-212: Variable `environment`

```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}
```

**Type:** String

**Default:** "dev" (assume development unless specified)

**Common values:** "dev", "staging", "prod" (but not validated)

**Why no validation:** Different teams use different environment names

---

### Lines 214-218: Variable `labels`

```hcl
variable "labels" {
  description = "Labels/tags to apply to the cluster (key-value pairs)"
  type        = map(string)
  default     = {}
}
```

#### Line 216: `type = map(string)`

**New type: `map(string)`**

**What is a map:** Collection of key-value pairs

**Syntax:**
```hcl
{
  key1 = "value1"
  key2 = "value2"
}
```

**`map(string)` means:**
- Keys are always strings (automatically)
- Values must be strings
- Each key must be unique

**Examples:**
```hcl
✅ Valid:
labels = {
  team = "backend"
  env  = "prod"
}

✅ Empty map (default):
labels = {}

❌ Invalid (value is number):
labels = {
  team = "backend"
  count = 5  # ❌ Number, not string
}

✅ Valid (number as string):
labels = {
  team = "backend"
  count = "5"  # ✅ String
}
```

#### Line 217: `default = {}`

**Empty map `{}`:**
- No labels by default
- User can optionally add labels
- Empty is valid (no labels = no problem)

---

## Summary of variables.tf

**File structure:**
```
1. Required Variables (must provide):
   - cluster_name
   - project_id

2. Cluster Configuration (optional, have defaults):
   - cluster_type
   - provider_name
   - provider_region
   - provider_instance_size
   - mongodb_major_version

3. Storage Configuration:
   - disk_size_gb
   - auto_scaling_disk_enabled

4. Backup Configuration:
   - backup_enabled
   - pit_enabled

5. High Availability:
   - num_shards
   - replication_factor

6. Security:
   - encryption_at_rest_enabled
   - termination_protection_enabled

7. Metadata:
   - environment
   - labels
```

**Validation techniques used:**
1. `can(regex(...))` - Pattern matching (cluster_name)
2. `contains([...], value)` - List membership (cluster_type, provider_name, replication_factor)
3. `value >= number` - Numeric comparison (disk_size_gb, num_shards)

---

# main.tf - Complete Breakdown

## File Purpose
This file **creates the actual MongoDB cluster** using the variables defined in variables.tf.

Think of it as the **construction blueprint** that builds the database.

---

## Line-by-Line Explanation

### Lines 1-3: File Header
```hcl
###############################################################################
#            Reusable MongoDB Atlas Advanced Cluster Module                   #
###############################################################################
```

**Just a comment** explaining what this file does.

---

### Lines 5-6: Resource Declaration
```hcl
# MongoDB Atlas Advanced Cluster (modern resource type)
resource "mongodbatlas_advanced_cluster" "this" {
```

#### Breaking down `resource "mongodbatlas_advanced_cluster" "this" {`

**Syntax:**
```hcl
resource "RESOURCE_TYPE" "LOCAL_NAME" {
```

**Parts explained:**

**1. `resource`** - Terraform keyword
- Means: "I want to create something in the cloud"
- Like saying "Create a..." in English

**2. `"mongodbatlas_advanced_cluster"`** - Resource Type
- Format: `provider_resourcetype`
- `mongodbatlas` = Provider name (MongoDB Atlas)
- `advanced_cluster` = Resource type (a cluster)

**Where this comes from:**
- Defined by the `mongodbatlas` provider
- From: `versions.tf` → `source = "mongodb/mongodbatlas"`

**3. `"this"`** - Local Name (nickname)
- Can be any name you want
- Used to reference this resource elsewhere in code
- Convention: use "this" for single-resource modules

**Example of using the local name:**
```hcl
# Creating the resource:
resource "mongodbatlas_advanced_cluster" "this" { ... }

# Referencing it in outputs:
output "cluster_id" {
  value = mongodbatlas_advanced_cluster.this.cluster_id
          └────────────────────────────────┬───────────────┘
                                    Full reference to "this" resource
}
```

**Real-world analogy:**
```
"Create a MongoDB cluster and call it 'this'"

Later: "What's the ID of 'this' cluster?"
```

---

### Lines 7-8: Project and Name

```hcl
  project_id = var.project_id
  name       = var.cluster_name
```

#### Line 7: `project_id = var.project_id`

**Syntax breakdown:**
- `project_id` = Argument name (defined by MongoDB provider)
- `=` = Assignment operator
- `var.project_id` = Value from our variables

**`var.` prefix:**
- `var` = Access a variable
- `var.project_id` = Get the value of the `project_id` variable

**Flow:**
```
User provides:
  cluster_name = "my-db"
  project_id = "abc123..."

variables.tf receives:
  var.cluster_name = "my-db"
  var.project_id = "abc123..."

main.tf uses:
  name = var.cluster_name        → "my-db"
  project_id = var.project_id    → "abc123..."

MongoDB Atlas receives:
  "Create cluster 'my-db' in project 'abc123...'"
```

---

### Lines 10-12: Cluster Type and Version

```hcl
  # Cluster type and MongoDB version
  cluster_type = var.cluster_type
  mongo_db_major_version = var.mongodb_major_version
```

**Comments:**
- `# Cluster type and MongoDB version`
- Inline comment explaining the section
- `#` makes everything after it on that line a comment

**Direct variable assignment:**
```hcl
cluster_type = var.cluster_type
```

**This passes the variable value directly without modification**

---

### Lines 14-15: Backup Configuration

```hcl
  # Backup configuration
  backup_enabled = var.backup_enabled
```

**Simple assignment** - backup setting from variable

---

### Line 16: Point-in-Time Restore

```hcl
  pit_enabled    = var.pit_enabled
```

**Note the spacing:**
```hcl
backup_enabled = var.backup_enabled
pit_enabled    = var.pit_enabled
            └──┘
         Extra spaces for alignment (cosmetic, ignored by Terraform)
```

**Both styles are valid:**
```hcl
# Without alignment:
backup_enabled = var.backup_enabled
pit_enabled = var.pit_enabled

# With alignment (prettier):
backup_enabled = var.backup_enabled
pit_enabled    = var.pit_enabled
```

---

### Lines 18-19: Security Configuration

```hcl
  # Security configuration
  termination_protection_enabled = var.termination_protection_enabled
```

**Direct assignment** of termination protection setting.

---

### Lines 21-22: Encryption Configuration

```hcl
  # Encryption at rest
  encryption_at_rest_provider = var.encryption_at_rest_enabled ? var.provider_name : "NONE"
```

#### Line 22: Ternary Operator (Conditional Expression)

**This is the MOST IMPORTANT LINE to understand!**

**Syntax:**
```hcl
condition ? value_if_true : value_if_false
```

**Breaking down our example:**
```hcl
var.encryption_at_rest_enabled ? var.provider_name : "NONE"
└──────────┬──────────────────┘   └──────┬──────┘   └──┬─┘
        Condition              Value if true  Value if false
```

**How it works:**

**Step 1: Check condition**
```hcl
var.encryption_at_rest_enabled
```

This is a boolean (true or false)

**Step 2: Choose value based on condition**
```
IF var.encryption_at_rest_enabled == true:
  Use var.provider_name (e.g., "GCP", "AWS", "AZURE")
  
ELSE (if false):
  Use "NONE"
```

**Examples:**

**Example 1: Encryption enabled**
```hcl
# User provides:
encryption_at_rest_enabled = true
provider_name = "GCP"

# Ternary operator:
var.encryption_at_rest_enabled ? var.provider_name : "NONE"
true                           ? "GCP"             : "NONE"
                               ↓
                            "GCP"

# Result:
encryption_at_rest_provider = "GCP"
```

**Example 2: Encryption disabled**
```hcl
# User provides:
encryption_at_rest_enabled = false
provider_name = "GCP"

# Ternary operator:
var.encryption_at_rest_enabled ? var.provider_name : "NONE"
false                          ? "GCP"             : "NONE"
                                                    ↓
                                                "NONE"

# Result:
encryption_at_rest_provider = "NONE"
```

**Why use ternary operator here:**

MongoDB Atlas requires specific values:
- If encryption enabled: must be "GCP", "AWS", or "AZURE"
- If encryption disabled: must be "NONE"

We have a boolean `encryption_at_rest_enabled` (true/false) but need a string ("GCP" or "NONE").

The ternary operator converts:
```
true  → "GCP" (or whatever provider_name is)
false → "NONE"
```

**Alternative (longer) way:**
```hcl
# Without ternary (hypothetical, doesn't work in Terraform):
if encryption_at_rest_enabled == true:
  encryption_at_rest_provider = provider_name
else:
  encryption_at_rest_provider = "NONE"

# With ternary (actual Terraform):
encryption_at_rest_provider = encryption_at_rest_enabled ? provider_name : "NONE"
```

---

### Lines 24-26: Replication Specs Block

```hcl
  # Replication specs - defines cluster topology
  replication_specs {
```

**New concept: Nested block**

**What is a block:**
```hcl
block_name {
  # Configuration inside block
}
```

**`replication_specs` block:**
- Defines cluster architecture/topology
- How many regions, how many servers, etc.
- Can have multiple `replication_specs` blocks (for multi-region)

**Why nested blocks:**
- Groups related configuration
- Can repeat for multiple regions
- Clearer organization

---

### Lines 27-28: Number of Shards

```hcl
    # Number of shards (for GEOSHARDED) or zones (for REPLICASET)
    num_shards = var.cluster_type == "GEOSHARDED" ? var.num_shards : 1
```

#### Line 28: Conditional with Comparison

**Breaking this down:**

**1. Comparison operator `==`**
```hcl
var.cluster_type == "GEOSHARDED"
```

**`==` means:** "is equal to" (comparison, not assignment)

**Comparison vs Assignment:**
```hcl
# Assignment (=):
cluster_type = "REPLICASET"    # SET cluster_type TO "REPLICASET"

# Comparison (==):
cluster_type == "REPLICASET"   # CHECK if cluster_type IS "REPLICASET"
                               # Returns true or false
```

**2. Full ternary operator:**
```hcl
var.cluster_type == "GEOSHARDED" ? var.num_shards : 1
└───────────┬────────────────────┘   └─────┬─────┘   └┘
         Condition               Value if true  Value if false
```

**Logic:**
```
IF cluster_type equals "GEOSHARDED":
  Use var.num_shards (user's value, e.g., 3)
ELSE:
  Use 1 (always 1 shard for REPLICASET)
```

**Examples:**

**Example 1: GEOSHARDED cluster**
```hcl
# User provides:
cluster_type = "GEOSHARDED"
num_shards = 3

# Evaluation:
var.cluster_type == "GEOSHARDED" ? var.num_shards : 1
"GEOSHARDED"     == "GEOSHARDED" ? 3              : 1
true                             ? 3              : 1
                                   ↓
                                   3

# Result:
num_shards = 3
```

**Example 2: REPLICASET cluster**
```hcl
# User provides:
cluster_type = "REPLICASET"
num_shards = 5  # User value ignored for REPLICASET

# Evaluation:
var.cluster_type == "GEOSHARDED" ? var.num_shards : 1
"REPLICASET"     == "GEOSHARDED" ? 5              : 1
false                            ? 5              : 1
                                                    ↓
                                                    1

# Result:
num_shards = 1  # Always 1 for REPLICASET
```

**Why this logic:**
- REPLICASET: Always uses 1 shard (single-region)
- GEOSHARDED: Uses user-specified number of shards

---

### Lines 30-32: Region Configs Block

```hcl
    # Region configuration
    region_configs {
```

**Another nested block** inside `replication_specs`

**Structure so far:**
```hcl
resource "..." "..." {
  replication_specs {          ← First level
    region_configs {           ← Second level (nested inside replication_specs)
      # Configuration here      ← Third level
    }
  }
}
```

**`region_configs` defines:**
- Which cloud provider
- Which region
- Instance sizes
- How many servers

---

### Lines 33-35: Cloud Provider and Region

```hcl
      # Cloud provider and region
      provider_name = var.provider_name
      region_name   = var.provider_region
```

**Simple assignments** from variables:
- `provider_name`: "GCP", "AWS", or "AZURE"
- `region_name`: MongoDB Atlas region code (e.g., "WESTERN_EUROPE")

---

### Line 36: Priority

```hcl
      priority      = 7  # Highest priority for this region
```

**What is priority:**
- Determines which region is "primary"
- Higher number = higher priority
- Range: 0-7

**Why priority matters:**

In multi-region clusters:
```
Region 1: priority = 7  ← Primary (writes go here)
Region 2: priority = 6  ← Secondary
Region 3: priority = 5  ← Secondary
```

**For single-region (our case):**
- Only one region, so priority doesn't matter much
- Use 7 (highest) by convention

**Hardcoded value `7`:**
- Not from a variable
- Always uses 7
- User cannot change (not needed for single-region)

---

### Lines 38-40: Electable Specs Block

```hcl
      # Electable nodes (voting members)
      electable_specs {
```

**What are "electable" nodes:**
- Voting members of replica set
- Can become primary in elections
- These are your main database servers

**Why "electable":**

MongoDB has different node types:
- **Electable**: Can vote, can become primary
- **Read-only**: Cannot vote, never primary
- **Analytics**: Special nodes for analytics queries

**We're defining electable nodes** (the main database servers)

---

### Lines 41-42: Instance Size and Node Count

```hcl
        instance_size = var.provider_instance_size
        node_count    = var.replication_factor  # Number of replica set members
```

#### Line 41: `instance_size`

**Value:** From `var.provider_instance_size`
- Examples: "M10", "M20", "M30"
- Defines server power (RAM, CPU)

#### Line 42: `node_count`

**Value:** From `var.replication_factor`
- Examples: 3, 5, or 7
- How many database servers

**Important mapping:**
```
Old terminology:      replication_factor = 3
New terminology:      node_count = 3
Same meaning:         "Create 3 database servers"
```

**Example:**
```hcl
# User provides:
provider_instance_size = "M20"
replication_factor = 3

# Creates:
3 servers, each M20 size
```

---

### Lines 44-45: Disk Configuration

```hcl
        # Disk configuration
        disk_iops      = null  # Auto-configured based on instance size
```

**What is IOPS:**
- Input/Output Operations Per Second
- How fast disk can read/write
- Higher = faster

**Why `null`:**
```hcl
disk_iops = null
```

**`null` in Terraform:**
- Means "not set" or "use default"
- Let MongoDB Atlas decide IOPS based on instance size
- Different from `0` (zero means zero IOPS - bad!)

**Comparison:**
```hcl
disk_iops = null     # ✅ Auto-configure
disk_iops = 3000     # Manual value
# disk_iops not set  # ✅ Same as null (MongoDB decides)
```

---

### Line 46: EBS Volume Type

```hcl
        ebs_volume_type = "STANDARD"  # Standard SSD
```

**What is EBS:**
- Elastic Block Store (AWS term, but used by all providers)
- Type of storage disk

**Available types:**
- `"STANDARD"` - Standard SSD (good performance, lower cost)
- `"PROVISIONED"` - Provisioned IOPS (higher performance, higher cost)

**Why "STANDARD":**
- Good performance for most workloads
- Cost-effective
- Can upgrade later if needed

**Hardcoded:**
- Not a variable
- Always uses STANDARD
- Good default for most users

---

### Lines 48-50: Auto-scaling Block

```hcl
      # Auto-scaling configuration
      auto_scaling {
```

**New block:** `auto_scaling`

**Defines:** Automatic scaling behavior

**Nested inside:** `region_configs`

**Structure:**
```hcl
region_configs {
  electable_specs { ... }
  auto_scaling {             ← We are here
    # Auto-scaling settings
  }
}
```

---

### Lines 51-52: Compute Auto-scaling

```hcl
        disk_gb_enabled = var.auto_scaling_disk_enabled
        compute_enabled = false  # Compute auto-scaling disabled by default
```

#### Line 51: Disk Auto-scaling

**Value:** From variable `var.auto_scaling_disk_enabled`
- `true` = Automatically grow disk when full
- `false` = Manual disk management

#### Line 52: Compute Auto-scaling

**Value:** Hardcoded `false`

**What is compute auto-scaling:**
- Automatically change instance size (M10 → M20)
- Based on CPU/RAM usage

**Why disabled (`false`):**
- More expensive
- Can cause unexpected costs
- Most users prefer manual control
- Less common use case

**Disk vs Compute auto-scaling:**
```
Disk auto-scaling (enabled):
  10 GB → 90% full → Automatically grow to 11 GB

Compute auto-scaling (disabled):
  M10 → 80% CPU → Stay M10 (don't auto-upgrade to M20)
```

---

### Lines 54-59: Dynamic Disk Auto-scaling Block

```hcl
        # Disk auto-scaling limits
        dynamic "disk_gb" {
          for_each = var.auto_scaling_disk_enabled ? [1] : []
          content {
            enabled = true
          }
        }
```

**This is ADVANCED Terraform - let me break it down carefully:**

#### What is a `dynamic` block?

**Purpose:** Conditionally create a block

**Syntax:**
```hcl
dynamic "BLOCK_NAME" {
  for_each = COLLECTION
  content {
    # Block configuration
  }
}
```

**How it works:**

```
IF for_each has items:
  Create the block (once per item)
ELSE (for_each is empty):
  Don't create the block at all
```

**Real-world analogy:**
```
dynamic "dessert" {
  for_each = user_wants_dessert ? [1] : []
  content {
    type = "ice cream"
  }
}

If user_wants_dessert = true:
  Create dessert block (serve ice cream)
If user_wants_dessert = false:
  Don't create dessert block (no dessert)
```

---

#### Breaking down our example:

**Line 55: `dynamic "disk_gb" {`**
- Create a `disk_gb` block conditionally

**Line 56: `for_each = var.auto_scaling_disk_enabled ? [1] : []`**

**This is complex - let's break it down:**

**1. Ternary operator:**
```hcl
var.auto_scaling_disk_enabled ? [1] : []
└──────────┬──────────────────┘   └┬┘   └┬┘
        Condition          True value  False value
```

**2. The values:**
```hcl
[1]  = List with one item (the number 1)
[]   = Empty list (no items)
```

**Why these values:**

`for_each` needs a collection (list, set, map):
- If collection has items → create block
- If collection is empty → don't create block

**3. Full logic:**

```
IF var.auto_scaling_disk_enabled == true:
  for_each = [1]              ← List with 1 item
  Result: Create disk_gb block
  
ELSE (false):
  for_each = []               ← Empty list
  Result: Don't create disk_gb block
```

**Examples:**

**Example 1: Auto-scaling enabled**
```hcl
# User provides:
auto_scaling_disk_enabled = true

# Evaluation:
for_each = var.auto_scaling_disk_enabled ? [1] : []
for_each = true                          ? [1] : []
for_each = [1]                           ← List with 1 item

# Result:
Creates this block:
disk_gb {
  enabled = true
}
```

**Example 2: Auto-scaling disabled**
```hcl
# User provides:
auto_scaling_disk_enabled = false

# Evaluation:
for_each = var.auto_scaling_disk_enabled ? [1] : []
for_each = false                         ? [1] : []
for_each = []                            ← Empty list

# Result:
Does NOT create disk_gb block at all
```

---

#### Why use `[1]` instead of just `true`?

**Question:** Why not `for_each = true`?

**Answer:** `for_each` requires a collection (list/set/map), not a boolean

```hcl
❌ Invalid:
for_each = true                # Error: for_each must be a map or set

✅ Valid:
for_each = [1]                 # List with one item
for_each = ["anything"]        # List with one item
for_each = toset(["value"])    # Set with one item
```

**Why `[1]` specifically:**
- Convention in Terraform
- The value doesn't matter (could be `["x"]`, `[true]`, etc.)
- We just need "a list with one item" vs "empty list"
- `[1]` is short and clear

---

#### Line 57-59: The `content` block

```hcl
content {
  enabled = true
}
```

**What is `content`:**
- Required part of `dynamic` blocks
- Defines what to create when `for_each` has items

**Our content:**
```hcl
disk_gb {
  enabled = true
}
```

**Why `enabled = true` is hardcoded:**
- If we're creating this block at all, we want it enabled
- The conditional logic is in `for_each` (create block or not)
- Once block is created, it's always enabled

---

#### Full flow example:

**Scenario 1: User wants auto-scaling**
```hcl
# User provides:
auto_scaling_disk_enabled = true

# Step 1: Evaluate for_each
for_each = true ? [1] : []  →  [1]

# Step 2: [1] has items, so create block
disk_gb {
  enabled = true
}

# Result in MongoDB Atlas:
Disk auto-scaling: ENABLED
```

**Scenario 2: User doesn't want auto-scaling**
```hcl
# User provides:
auto_scaling_disk_enabled = false

# Step 1: Evaluate for_each
for_each = false ? [1] : []  →  []

# Step 2: [] is empty, so DON'T create block
(no disk_gb block created)

# Result in MongoDB Atlas:
Disk auto-scaling: NOT CONFIGURED (disabled)
```

---

### Lines 63-64: Disk Size Configuration

```hcl
  # Disk size configuration
  disk_size_gb = var.disk_size_gb
```

**Simple assignment** from variable

**Important:** This is at the **top level** of the resource, not inside `replication_specs`

**Structure:**
```hcl
resource "..." "..." {
  # Other top-level settings
  disk_size_gb = var.disk_size_gb  ← Here (top level)
  
  replication_specs {
    region_configs {
      # Not here
    }
  }
}
```

---

### Lines 66-70: Advanced Configuration Block

```hcl
  # Advanced configuration for production readiness
  advanced_configuration {
    javascript_enabled           = false  # Security: disable server-side JavaScript
    minimum_enabled_tls_protocol = "TLS1_2"
  }
```

**New block:** `advanced_configuration`

**Purpose:** MongoDB-specific settings

---

#### Line 68: JavaScript Enabled

```hcl
javascript_enabled = false  # Security: disable server-side JavaScript
```

**What is server-side JavaScript:**
- MongoDB can run JavaScript code inside the database
- Used for complex queries/operations
- **Security risk:** Can be exploited

**Why `false`:**
- Security best practice
- Most apps don't need it
- Prevents code injection attacks

**Example of the risk:**
```javascript
// Malicious user input:
db.users.find({ $where: "this.password == 'leaked-password' || true" })

// If JavaScript enabled:
// This runs malicious code ❌

// If JavaScript disabled:
// This is rejected ✅
```

**Hardcoded `false`:**
- Not a variable
- Always disabled for security
- User cannot enable (intentional)

---

#### Line 69: Minimum TLS Protocol

```hcl
minimum_enabled_tls_protocol = "TLS1_2"
```

**What is TLS:**
- Transport Layer Security
- Encrypts data in transit (over network)
- Like HTTPS for databases

**TLS versions:**
```
TLS 1.0  ❌ Old, insecure
TLS 1.1  ❌ Old, insecure
TLS 1.2  ✅ Secure (minimum acceptable)
TLS 1.3  ✅ Most secure (latest)
```

**Why "TLS1_2":**
- Minimum acceptable security level
- Blocks old, insecure connections
- Widely supported by clients

**What this does:**
```
Client tries to connect with TLS 1.0:  ❌ Rejected
Client tries to connect with TLS 1.1:  ❌ Rejected
Client tries to connect with TLS 1.2:  ✅ Allowed
Client tries to connect with TLS 1.3:  ✅ Allowed
```

**Hardcoded:**
- Not a variable
- Security standard
- User should not lower this

---

### Lines 72-88: Labels Configuration

```hcl
  # Labels (MongoDB Atlas uses tags)
  labels {
    key   = "environment"
    value = var.environment
  }

  labels {
    key   = "managed_by"
    value = "terraform"
  }

  # Additional custom labels
  dynamic "labels" {
    for_each = var.labels
    content {
      key   = labels.key
      value = labels.value
    }
  }
```

#### Lines 73-76: First Label (environment)

```hcl
labels {
  key   = "environment"
  value = var.environment
}
```

**What this creates:**
```
Label:
  Key: "environment"
  Value: "prod" (or whatever var.environment is)
```

**Example:**
```hcl
# If user provides:
environment = "prod"

# Creates label:
environment = "prod"
```

---

#### Lines 78-81: Second Label (managed_by)

```hcl
labels {
  key   = "managed_by"
  value = "terraform"
}
```

**Hardcoded label:**
```
Key: "managed_by"
Value: "terraform" (always)
```

**Why this label:**
- Track how cluster was created
- Differentiate from manually-created clusters
- Useful for automation/governance

**Example in MongoDB Atlas:**
```
Cluster: casas-app-db-prod
Labels:
  environment = "prod"
  managed_by = "terraform"  ← This label
```

---

#### Lines 83-89: Dynamic Custom Labels

```hcl
dynamic "labels" {
  for_each = var.labels
  content {
    key   = labels.key
    value = labels.value
  }
}
```

**We've seen `dynamic` blocks before, but this is different!**

**Previous dynamic block:**
```hcl
for_each = var.auto_scaling_disk_enabled ? [1] : []
           └───────────────┬──────────────────────┘
                    Boolean → List

Create block if true, don't create if false
```

**This dynamic block:**
```hcl
for_each = var.labels
           └────┬─────┘
              Map (key-value pairs)

Create one block per map entry
```

---

#### Understanding `for_each` with maps:

**Syntax:**
```hcl
dynamic "labels" {
  for_each = var.labels  ← Map
  content {
    key   = labels.key   ← Access map key
    value = labels.value ← Access map value
  }
}
```

**How it works:**

**1. `var.labels` is a map:**
```hcl
# User provides:
labels = {
  team = "backend"
  tier = "production"
}
```

**2. `for_each` iterates over each entry:**
```
Iteration 1:
  labels.key = "team"
  labels.value = "backend"
  
Iteration 2:
  labels.key = "tier"
  labels.value = "production"
```

**3. Creates one `labels` block per iteration:**

```hcl
# Iteration 1 creates:
labels {
  key   = "team"
  value = "backend"
}

# Iteration 2 creates:
labels {
  key   = "tier"
  value = "production"
}
```

**4. Final result:**
```hcl
# All labels combined:
labels {
  key   = "environment"
  value = "prod"
}

labels {
  key   = "managed_by"
  value = "terraform"
}

labels {
  key   = "team"
  value = "backend"
}

labels {
  key   = "tier"
  value = "production"
}
```

---

#### Special variable name inside `dynamic` blocks:

**The variable name matches the block name:**

```hcl
dynamic "labels" {
  for_each = var.labels
  content {
    key   = labels.key    ← "labels" matches dynamic "labels"
    value = labels.value
  }
}
```

**If we named it differently:**
```hcl
dynamic "my_label" {
  for_each = var.labels
  content {
    key   = my_label.key    ← Must match "my_label"
    value = my_label.value
  }
}
```

**Convention:** Use the same name as the block type

---

#### Complete example:

**User input:**
```hcl
environment = "prod"

labels = {
  team        = "backend"
  cost_center = "engineering"
  criticality = "high"
}
```

**What gets created:**
```
MongoDB Atlas Cluster Labels:
  environment  = "prod"        ← From hardcoded label
  managed_by   = "terraform"   ← From hardcoded label
  team         = "backend"     ← From dynamic labels (iteration 1)
  cost_center  = "engineering" ← From dynamic labels (iteration 2)
  criticality  = "high"        ← From dynamic labels (iteration 3)
```

---

### Lines 91-101: Lifecycle Configuration

```hcl
  # Lifecycle configuration
  lifecycle {
    # Prevent accidental deletion - must be manually disabled to destroy
    prevent_destroy = true

    # Ignore changes to backup settings if managed externally
    ignore_changes = [
      backup_enabled,
      pit_enabled
    ]
  }
```

**What is `lifecycle`:**
- Special Terraform block
- Controls how resource is managed
- Different from MongoDB settings

**Not sent to MongoDB Atlas** - Terraform-only configuration

---

#### Line 93: `prevent_destroy`

```hcl
prevent_destroy = true
```

**What it does:**
- Prevents `terraform destroy` from deleting this resource
- Safety mechanism

**How it works:**

**With `prevent_destroy = true`:**
```bash
$ terraform destroy

Error: Instance cannot be destroyed

  on main.tf line 5:
   5: resource "mongodbatlas_advanced_cluster" "this" {

Resource has lifecycle.prevent_destroy set, but the plan calls for
this resource to be destroyed. To avoid this error and continue with
the plan, either disable lifecycle.prevent_destroy or reduce the scope
of the plan using the -target flag.
```

**To actually delete:**
```hcl
# 1. Change code:
lifecycle {
  prevent_destroy = false  ← Change to false
}

# 2. Apply change:
terraform apply

# 3. Now you can destroy:
terraform destroy
```

**Why use it:**
```
Production database:
  One accidental command → All data gone!
  
With prevent_destroy = true:
  Accidental destroy → Terraform blocks it ✅
  Intentional destroy → Change code first (deliberate process)
```

---

#### Lines 96-99: `ignore_changes`

```hcl
ignore_changes = [
  backup_enabled,
  pit_enabled
]
```

**What `ignore_changes` does:**
- Terraform ignores changes to these fields
- Useful when settings are managed outside Terraform

**Scenario this solves:**

**Problem without `ignore_changes`:**
```
1. Terraform creates cluster:
   backup_enabled = true

2. Someone changes in MongoDB Atlas Console:
   backup_enabled = false (manually)

3. Next terraform apply:
   Terraform sees: "Hey! backup_enabled should be true!"
   Terraform changes: backup_enabled back to true
   → Resets manual change ❌
```

**Solution with `ignore_changes`:**
```
1. Terraform creates cluster:
   backup_enabled = true

2. Someone changes in Atlas Console:
   backup_enabled = false (manually)

3. Next terraform apply:
   Terraform: "ignore_changes says ignore backup_enabled"
   Terraform: "I'll leave it as false"
   → Keeps manual change ✅
```

**Why for backups specifically:**
- Backups might be managed by ops team in Atlas Console
- Or managed by separate backup tool
- Don't want Terraform to override their changes

**List syntax:**
```hcl
ignore_changes = [
  field1,
  field2
]
```

Each field name is from the resource (not `var.` prefix)

---

### Line 102: Closing Brace

```hcl
}
```

**Closes the entire resource block**

**Everything from line 6 to 102 is one resource definition!**

---

## Summary of main.tf

**File structure:**
```
resource "mongodbatlas_advanced_cluster" "this" {
  
  1. Basic Settings (top-level)
     - project_id, name, cluster_type, version
     - backup, security, encryption
  
  2. Replication Specs (nested)
     └─ Region Configs (nested deeper)
        ├─ Provider, region, priority
        ├─ Electable Specs (nested deeper still)
        │  ├─ Instance size, node count
        │  └─ Disk configuration
        └─ Auto-scaling (nested)
           └─ Dynamic disk_gb block (conditional)
  
  3. Disk Size (top-level)
  
  4. Advanced Configuration (nested)
     - JavaScript disabled
     - TLS 1.2 minimum
  
  5. Labels (multiple blocks)
     - Hardcoded: environment, managed_by
     - Dynamic: Custom user labels
  
  6. Lifecycle (Terraform-specific)
     - Prevent accidental deletion
     - Ignore backup changes
}
```

**Advanced Terraform features used:**
1. ✅ Ternary operators (`condition ? true_value : false_value`)
2. ✅ Dynamic blocks (conditional block creation)
3. ✅ For_each with maps (iterate over key-value pairs)
4. ✅ Lifecycle rules (Terraform behavior control)
5. ✅ Nested blocks (complex structure)

---

# outputs.tf - Complete Breakdown

## File Purpose
This file defines what **information to return** after creating the cluster.

Think of it as the **receipt** you get after making a purchase.

---

## Line-by-Line Explanation

### Lines 1-3: Section Header
```hcl
###############################################################################
#                           Cluster Outputs                                    #
###############################################################################
```

**Comment:** Marks the section for cluster identification outputs.

---

### Lines 5-8: Cluster ID Output

```hcl
output "cluster_id" {
  description = "The cluster ID (unique identifier)"
  value       = mongodbatlas_advanced_cluster.this.cluster_id
}
```

#### Line 5: `output "cluster_id" {`

**Syntax:**
```hcl
output "OUTPUT_NAME" {
```

**What outputs do:**
- Return values from created resources
- Make values available to users
- Can be referenced by other modules

---

#### Line 6: `description`

**Same as variable descriptions:**
- Human-readable explanation
- Shown when you run `terraform output`

---

#### Line 7: `value` - Accessing Resource Attributes

```hcl
value = mongodbatlas_advanced_cluster.this.cluster_id
```

**Breaking this down:**

**Full syntax:**
```hcl
RESOURCE_TYPE.LOCAL_NAME.ATTRIBUTE
```

**Our example:**
```hcl
mongodbatlas_advanced_cluster.this.cluster_id
└──────────┬─────────────────┘ └─┬─┘ └────┬────┘
       Resource type      Local name  Attribute
```

**Parts:**

**1. `mongodbatlas_advanced_cluster`** - Resource type
- Same as in resource declaration

**2. `.this`** - Local name
- Matches `resource "mongodbatlas_advanced_cluster" "this"`

**3. `.cluster_id`** - Attribute
- Property of the created cluster
- Provided by MongoDB Atlas after creation

---

#### How this works:

**Step 1: Resource is created**
```hcl
resource "mongodbatlas_advanced_cluster" "this" {
  name = "my-cluster"
  # ... other settings
}
```

**Step 2: MongoDB Atlas returns info**
```json
{
  "cluster_id": "507f1f77bcf86cd799439011-my-cluster",
  "name": "my-cluster",
  "state": "IDLE",
  ...
}
```

**Step 3: Terraform stores these attributes**
```
mongodbatlas_advanced_cluster.this.cluster_id = "507f1f77bcf86cd799439011-my-cluster"
mongodbatlas_advanced_cluster.this.name = "my-cluster"
mongodbatlas_advanced_cluster.this.state = "IDLE"
```

**Step 4: Output accesses the attribute**
```hcl
output "cluster_id" {
  value = mongodbatlas_advanced_cluster.this.cluster_id
  # Returns: "507f1f77bcf86cd799439011-my-cluster"
}
```

---

### Lines 10-13: Cluster Name Output

```hcl
output "cluster_name" {
  description = "The name of the MongoDB Atlas cluster"
  value       = mongodbatlas_advanced_cluster.this.name
}
```

**Same pattern:**
- Access `.name` attribute
- Returns cluster name

**Example:**
```bash
$ terraform output cluster_name
"casas-app-db-prod"
```

---

### Lines 15-19: Mongo URI Output

```hcl
output "mongo_uri" {
  description = "Base connection string for the cluster (without credentials)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard
  sensitive   = true
}
```

#### Line 17: Accessing Nested Attributes with Array Index

```hcl
value = mongodbatlas_advanced_cluster.this.connection_strings[0].standard
```

**New concept: Array access with `[0]`**

**Breaking this down:**

**Full syntax:**
```hcl
mongodbatlas_advanced_cluster.this.connection_strings[0].standard
└──────────┬─────────────────┘ └────────┬───────────┘ └┬┘ └───┬──┘
       Resource             Attribute (array)  Index  Sub-attribute
```

**Parts:**

**1. `.connection_strings`** - Attribute that's an array

**What MongoDB Atlas returns:**
```json
{
  "connection_strings": [
    {
      "standard": "mongodb://cluster.mongodb.net",
      "standard_srv": "mongodb+srv://cluster.mongodb.net",
      "private": "mongodb://10.0.0.5:27017",
      ...
    }
  ]
}
```

**2. `[0]`** - Array index (first item)

**Array indexing in Terraform:**
```
[0] = First item
[1] = Second item
[2] = Third item
etc.
```

**Why `[0]`:**
- `connection_strings` is an array
- Usually has only 1 item (for single region)
- We want the first (and usually only) item

**3. `.standard`** - Sub-attribute

**Access nested structure:**
```hcl
connection_strings[0].standard
                  └┬┘ └───┬──┘
           First item   Get "standard" field
```

**Full example:**

```json
// MongoDB Atlas returns:
{
  "connection_strings": [
    {
      "standard": "mongodb://casas-app-db.abc.mongodb.net:27017",
      "standard_srv": "mongodb+srv://casas-app-db.abc.mongodb.net"
    }
  ]
}
```

```hcl
// Terraform access:
connection_strings[0].standard
= "mongodb://casas-app-db.abc.mongodb.net:27017"
```

---

#### Line 18: `sensitive = true`

**What `sensitive` does:**
- Hides value in Terraform output
- Not shown in logs or plan output
- Prevents accidental exposure

**Without `sensitive`:**
```bash
$ terraform plan

Changes:
  + mongo_uri = "mongodb://secret-cluster.mongodb.net"  ← Visible!
```

**With `sensitive = true`:**
```bash
$ terraform plan

Changes:
  + mongo_uri = (sensitive value)  ← Hidden!
```

**To see the value:**
```bash
$ terraform output mongo_uri
"mongodb://secret-cluster.mongodb.net"  ← Shows only when explicitly requested
```

**Why mark connection strings as sensitive:**
- They contain cluster address (semi-sensitive)
- Good security practice
- Prevents accidental leak in logs/CI output

---

### Lines 21-25: Mongo URI with Options

```hcl
output "mongo_uri_with_options" {
  description = "Connection string with options for the cluster"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}
```

**Similar to `mongo_uri`, but:**
- Uses `.standard_srv` instead of `.standard`
- SRV format (modern, recommended)

**Difference between standard and SRV:**

```
Standard:
mongodb://cluster.mongodb.net:27017

SRV (recommended):
mongodb+srv://cluster.mongodb.net
```

**SRV benefits:**
- Simpler format
- Automatic server discovery
- Modern drivers prefer this

---

### Lines 27-31: Connection Strings (Full Object)

```hcl
output "connection_strings" {
  description = "Full connection strings object with standard, private, and SRV formats"
  value       = mongodbatlas_advanced_cluster.this.connection_strings
  sensitive   = true
}
```

**Different from previous outputs:**
- Returns **entire array** (not just `[0]`)
- Returns **entire object** (not just `.standard`)
- All connection string formats

**What this returns:**
```json
[
  {
    "standard": "mongodb://...",
    "standard_srv": "mongodb+srv://...",
    "private": "mongodb://10.0.0.5:27017",
    "private_srv": "mongodb+srv://...",
    ...
  }
]
```

**Why return the full object:**
- Advanced users might need all formats
- Private connections available
- Different options for different use cases

---

### Lines 33-37: SRV Address

```hcl
output "srv_address" {
  description = "SRV connection string (recommended for modern drivers)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}
```

**Same as `mongo_uri_with_options`**
- Different name (clearer purpose)
- SRV format
- Recommended for applications

---

### Lines 39-48: Configuration Outputs

```hcl
###############################################################################
#                        Configuration Outputs                                 #
###############################################################################

output "state_name" {
  description = "Current state of the cluster (e.g., IDLE, CREATING, UPDATING)"
  value       = mongodbatlas_advanced_cluster.this.state_name
}
```

**What is `state_name`:**
- Current cluster status
- Returned by MongoDB Atlas

**Possible values:**
```
"IDLE"      - Cluster is running normally ✅
"CREATING"  - Cluster is being created
"UPDATING"  - Cluster is being modified
"DELETING"  - Cluster is being deleted
"DELETED"   - Cluster has been deleted
```

**Why useful:**
```bash
# Check if cluster is ready:
$ terraform output state_name
"IDLE"  ← Ready to use!
```

---

### Lines 50-53: Cluster Type Output

```hcl
output "cluster_type" {
  description = "The cluster type (REPLICASET or GEOSHARDED)"
  value       = mongodbatlas_advanced_cluster.this.cluster_type
}
```

**Returns:** "REPLICASET" or "GEOSHARDED"

**Why useful:**
- Confirm cluster configuration
- Documentation
- Other modules might need this info

---

### Lines 55-58: MongoDB Version Output

```hcl
output "mongodb_version" {
  description = "MongoDB version running on the cluster"
  value       = mongodbatlas_advanced_cluster.this.version_release_system
}
```

**Attribute:** `.version_release_system`

**What this returns:**
- NOT the major version we specified ("7.0")
- The **actual installed version** ("7.0.12")

**Example:**
```hcl
# We specified:
mongo_db_major_version = "7.0"

# MongoDB Atlas installed:
version_release_system = "7.0.12"  ← Specific patch version

# Output returns:
mongodb_version = "7.0.12"
```

**Why useful:**
- See exact version installed
- Track patch levels
- Security compliance (need to track exact versions)

---

### Lines 60-63: Disk Size Output

```hcl
output "disk_size_gb" {
  description = "Disk size in GB"
  value       = mongodbatlas_advanced_cluster.this.disk_size_gb
}
```

**Returns:** Current disk size

**Why this might differ from input:**
```hcl
# User specifies:
disk_size_gb = 10

# Auto-scaling grows it:
disk_size_gb = 12  ← Grew automatically

# Output shows actual size:
output disk_size_gb = 12
```

---

### Lines 65-78: Security Outputs

```hcl
###############################################################################
#                        Security Outputs                                      #
###############################################################################

output "encryption_at_rest_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = var.encryption_at_rest_enabled
}
```

**Important difference:**

**Previous outputs:**
```hcl
value = mongodbatlas_advanced_cluster.this.ATTRIBUTE
        └────────────────┬──────────────────────┘
            From created resource
```

**This output:**
```hcl
value = var.encryption_at_rest_enabled
        └────────┬─────────────────────┘
          From input variable (not resource)
```

**Why return the variable, not resource attribute:**
- This boolean flag (`true`/`false`) is our internal variable
- MongoDB Atlas doesn't have a simple `encryption_enabled` attribute
- Easier to return what we know (the variable)

---

### Lines 80-83: Backup Enabled Output

```hcl
output "backup_enabled" {
  description = "Whether continuous backup is enabled"
  value       = mongodbatlas_advanced_cluster.this.backup_enabled
}
```

**From resource attribute** (not variable)

**Why from resource:**
- MongoDB Atlas confirms if backup is actually enabled
- Might be different from input (e.g., M0 can't have backups)

---

### Lines 85-88: Termination Protection Output

```hcl
output "termination_protection" {
  description = "Whether termination protection is enabled"
  value       = mongodbatlas_advanced_cluster.this.termination_protection_enabled
}
```

**From resource attribute**

**Returns:** `true` or `false`

**Why useful:**
- Confirm safety settings
- Documentation
- Compliance checks

---

## How to Use Outputs

### In Terraform

**View all outputs:**
```bash
$ terraform output

cluster_id = "507f..."
cluster_name = "casas-app-db-prod"
mongo_uri = <sensitive>
state_name = "IDLE"
...
```

**View specific output:**
```bash
$ terraform output cluster_name
"casas-app-db-prod"
```

**View sensitive output:**
```bash
$ terraform output mongo_uri
"mongodb://casas-app-db.abc.mongodb.net:27017"
```

**Use in other Terraform code:**
```hcl
# In another module or resource:
resource "app_config" "this" {
  database_url = module.mongodb.mongo_uri
                 └──────┬──────┘ └────┬────┘
                   Module name    Output name
}
```

**Use in scripts:**
```bash
#!/bin/bash

# Get connection string
MONGO_URI=$(terraform output -raw mongo_uri)

# Use in application
export DATABASE_URL="$MONGO_URI"
node app.js
```

---

## Summary of outputs.tf

**Output categories:**

**1. Identifiers:**
- `cluster_id` - Unique ID
- `cluster_name` - Human-readable name

**2. Connection Information (all sensitive):**
- `mongo_uri` - Standard format
- `mongo_uri_with_options` - SRV format
- `connection_strings` - All formats
- `srv_address` - Recommended format

**3. Status:**
- `state_name` - Current state (IDLE, CREATING, etc.)
- `cluster_type` - Architecture type
- `mongodb_version` - Installed version
- `disk_size_gb` - Current disk size

**4. Security:**
- `encryption_at_rest_enabled` - Encryption status
- `backup_enabled` - Backup status
- `termination_protection` - Protection status

**Key concepts:**
1. ✅ Accessing resource attributes (`resource.name.attribute`)
2. ✅ Array indexing (`[0]`)
3. ✅ Nested attributes (`.connection_strings[0].standard`)
4. ✅ Sensitive values (`sensitive = true`)
5. ✅ Returning variables vs. resource attributes

---

# versions.tf - Complete Breakdown

## File Purpose
Specifies which **versions of software** are required to use this module.

Think of it like **system requirements** for a video game.

---

## Line-by-Line Explanation

### Lines 1-10: Complete File

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
```

---

### Line 1: Terraform Block

```hcl
terraform {
```

**What is the `terraform` block:**
- Special configuration block
- Not a resource, not a variable
- Terraform-specific settings

**Other uses of `terraform` block:**
```hcl
terraform {
  backend "s3" { ... }        # Where to store state
  required_version = "..."    # Terraform version
  required_providers { ... }  # Provider versions
}
```

---

### Line 2: Required Terraform Version

```hcl
required_version = ">= 1.15.2"
```

**What this means:**
- User must have Terraform version 1.15.2 or higher
- Will not work with older versions

**Version constraint syntax:**

| Operator | Meaning | Example |
|----------|---------|---------|
| `>=` | Greater than or equal | `>= 1.15.2` |
| `>` | Greater than | `> 1.0.0` |
| `<=` | Less than or equal | `<= 2.0.0` |
| `<` | Less than | `< 2.0.0` |
| `=` | Exactly | `= 1.15.2` |
| `~>` | Pessimistic constraint | `~> 1.15` |

**Why `>= 1.15.2`:**
- This module uses features from Terraform 1.15.2
- Older versions might not support those features
- Newer versions are backwards compatible

**What happens if wrong version:**
```bash
# User has Terraform 1.10.0:
$ terraform init

Error: Unsupported Terraform version

This module requires Terraform version >= 1.15.2,
but you are running version 1.10.0.
```

---

### Lines 4-9: Required Providers Block

```hcl
required_providers {
  mongodbatlas = {
    source  = "mongodb/mongodbatlas"
    version = "~> 1.21"
  }
}
```

**What are providers:**
- Plugins that talk to APIs
- Each cloud/service has its own provider
- Terraform downloads them automatically

**Examples of providers:**
```
google     → Google Cloud (GCP)
aws        → Amazon Web Services
azurerm    → Microsoft Azure
mongodbatlas → MongoDB Atlas
```

---

#### Line 5: Provider Local Name

```hcl
mongodbatlas = {
```

**This is the name used in code:**
```hcl
# In main.tf:
resource "mongodbatlas_advanced_cluster" "this" {
         └───────┬────────┘
        Prefix matches provider name
```

**Can be any name, but convention:**
- Use official provider name
- Lowercase
- No spaces

---

#### Line 6: Provider Source

```hcl
source = "mongodb/mongodbatlas"
```

**What is `source`:**
- Where to download the provider from
- Format: `NAMESPACE/NAME`

**Breaking down `"mongodb/mongodbatlas"`:**
```
mongodb/mongodbatlas
└───┬──┘ └─────┬─────┘
Namespace   Provider name
```

**Parts:**

**1. `mongodb`** - Namespace (organization)
- The company/organization that publishes the provider
- MongoDB Inc. in this case

**2. `mongodbatlas`** - Provider name
- The actual provider plugin

**Full URL:**
```
registry.terraform.io/mongodb/mongodbatlas
└────────┬───────────┘ └───────┬────────┘
   Registry URL      Source identifier
```

**Terraform Registry:**
- https://registry.terraform.io/
- Official marketplace for providers
- Like npm for Node.js, or pip for Python

**When you run `terraform init`:**
```bash
$ terraform init

Initializing provider plugins...
- Finding mongodb/mongodbatlas versions matching "~> 1.21"...
- Installing mongodb/mongodbatlas v1.21.3...
- Installed mongodb/mongodbatlas v1.21.3
```

Terraform:
1. Reads `source = "mongodb/mongodbatlas"`
2. Goes to https://registry.terraform.io/providers/mongodb/mongodbatlas
3. Downloads the provider plugin
4. Installs it locally

---

#### Line 7: Provider Version

```hcl
version = "~> 1.21"
```

**Version constraint:** `~> 1.21`

**What `~>` means:** "Pessimistic constraint operator"

**Detailed explanation:**

**`~> 1.21` means:**
```
Allow:
  1.21.0 ✅
  1.21.1 ✅
  1.21.2 ✅
  1.21.999 ✅
  
Block:
  1.22.0 ❌
  2.0.0 ❌
  1.20.0 ❌
```

**Rule:** 
- Allow minor and patch updates
- Block major updates

**Version number format:**
```
1.21.3
│ │  └── Patch version (bug fixes)
│ └───── Minor version (new features, backwards compatible)
└─────── Major version (breaking changes)
```

**`~> 1.21` expands to:** `>= 1.21.0, < 1.22.0`

**Why use `~>`:**
- Get bug fixes automatically (1.21.0 → 1.21.5)
- Avoid breaking changes (1.21 → 1.22 might break)
- Balance stability and updates

**Other examples:**
```hcl
~> 1.21.3  →  >= 1.21.3, < 1.22.0   (patch updates only)
~> 1.21    →  >= 1.21.0, < 1.22.0   (minor + patch updates)
~> 1       →  >= 1.0.0, < 2.0.0     (major version 1.x.x)
```

**Why `~> 1.21` for MongoDB Atlas provider:**
- Provider version 1.21 has the features we need
- Allow bug fixes (1.21.1, 1.21.2, etc.)
- Block potentially breaking changes (1.22, 2.0, etc.)

---

### Line 10: Closing Braces

```hcl
}
```

**Closes the `terraform` block**

---

## How Terraform Uses This File

### Step 1: User Runs `terraform init`

```bash
$ terraform init
```

### Step 2: Terraform Reads `versions.tf`

```hcl
terraform {
  required_version = ">= 1.15.2"        ← Check Terraform version
  required_providers {
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"  ← Where to download
      version = "~> 1.21"               ← Which version
    }
  }
}
```

### Step 3: Version Checks

**Check 1: Terraform version**
```
User's Terraform version: 1.15.5
Required: >= 1.15.2
Result: ✅ Compatible
```

**Check 2: Provider version**
```
Available provider versions: 1.21.0, 1.21.1, 1.21.2, 1.21.3
Constraint: ~> 1.21 (>= 1.21.0, < 1.22.0)
Best match: 1.21.3 (latest within constraint)
```

### Step 4: Download Provider

```bash
Initializing provider plugins...
- Finding mongodb/mongodbatlas versions matching "~> 1.21"...
- Installing mongodb/mongodbatlas v1.21.3...
```

Downloads to: `.terraform/providers/registry.terraform.io/mongodb/mongodbatlas/1.21.3/`

### Step 5: Lock File Created

Terraform creates `.terraform.lock.hcl`:
```hcl
provider "registry.terraform.io/mongodb/mongodbatlas" {
  version     = "1.21.3"
  constraints = "~> 1.21"
  ...
}
```

**Lock file purpose:**
- Records exact version used
- Ensures team uses same version
- Like `package-lock.json` in npm

---

## Summary of versions.tf

**File structure:**
```hcl
terraform {
  required_version = "TERRAFORM_VERSION_CONSTRAINT"
  
  required_providers {
    PROVIDER_NAME = {
      source  = "NAMESPACE/PROVIDER"
      version = "VERSION_CONSTRAINT"
    }
  }
}
```

**Our configuration:**
```
Terraform: >= 1.15.2 (version 1.15.2 or newer)
Provider:  mongodb/mongodbatlas ~> 1.21 (1.21.x versions only)
```

**Version constraint operators:**
```
>=   Greater than or equal
~>   Pessimistic (allow minor/patch, block major)
=    Exact version
```

**Why this file matters:**
1. ✅ Ensures compatible software versions
2. ✅ Prevents errors from version mismatches
3. ✅ Documents dependencies
4. ✅ Enables reproducible builds

---

## Complete File Summary

You now understand **every line** in **every .tf file**:

### 1. variables.tf (218 lines)
- 17 variables defined
- Validation techniques: regex, contains, comparisons
- Types: string, number, bool, map
- Defaults for optional settings

### 2. main.tf (102 lines)
- 1 resource: `mongodbatlas_advanced_cluster`
- Nested blocks: replication_specs → region_configs → electable_specs
- Advanced features: ternary operators, dynamic blocks, lifecycle rules
- Conditional logic throughout

### 3. outputs.tf (88 lines)
- 11 outputs defined
- Connection strings, configuration, security info
- Sensitive values marked
- Accessing resource attributes and arrays

### 4. versions.tf (10 lines)
- Terraform version: >= 1.15.2
- Provider: mongodbatlas ~> 1.21
- Version constraints explained

**Total:** 418 lines of Terraform code, **100% explained**! 🎉
