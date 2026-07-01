###############################################################################
#                           Required Variables                                 #
###############################################################################

variable "cluster_name" {
  description = "Name of the MongoDB Atlas cluster (must be unique within the project)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.cluster_name))
    error_message = "Cluster name must start with a letter, contain only letters, numbers, and hyphens, and be 1-64 characters long."
  }
}

variable "project_id" {
  description = "MongoDB Atlas Project ID (NOT GCP project ID - get this from Atlas console)"
  type        = string
}

###############################################################################
#                        Cluster Configuration                                 #
###############################################################################

variable "cluster_type" {
  description = "Type of cluster: REPLICASET (single region) or GEOSHARDED (multi-region)"
  type        = string
  default     = "REPLICASET"

  validation {
    condition     = contains(["REPLICASET", "GEOSHARDED"], var.cluster_type)
    error_message = "Cluster type must be REPLICASET or GEOSHARDED."
  }
}

variable "provider_region" {
  description = "GCP region for MongoDB Atlas cluster (e.g., WESTERN_EUROPE, US_CENTRAL_1)"
  type        = string
  default     = "WESTERN_EUROPE"
}

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

variable "mongodb_major_version" {
  description = "MongoDB major version (e.g., '7.0', '8.0')"
  type        = string
  default     = "7.0"
}

###############################################################################
#                        Storage Configuration                                 #
###############################################################################

variable "disk_size_gb" {
  description = "Storage capacity in GB. Minimum: 10GB for M10+, not configurable for M0/M2/M5"
  type        = number
  default     = 10

  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Disk size must be at least 10GB for M10+ clusters."
  }
}

variable "auto_scaling_disk_enabled" {
  description = "Enable automatic disk scaling (not available for M0/M2/M5)"
  type        = bool
  default     = true
}

###############################################################################
#                        Backup Configuration                                  #
###############################################################################

variable "backup_enabled" {
  description = "Enable continuous cloud backup (not available for M0/M2/M5)"
  type        = bool
  default     = true
}

variable "pit_enabled" {
  description = "Enable point-in-time restore (requires backup_enabled = true)"
  type        = bool
  default     = false
}

###############################################################################
#                        High Availability Configuration                       #
###############################################################################

variable "num_shards" {
  description = "Number of shards (only for GEOSHARDED cluster_type, min: 1)"
  type        = number
  default     = 1

  validation {
    condition     = var.num_shards >= 1
    error_message = "Number of shards must be at least 1."
  }
}

variable "replication_factor" {
  description = "Number of replica set members (3, 5, or 7 for high availability)"
  type        = number
  default     = 3

  validation {
    condition     = contains([3, 5, 7], var.replication_factor)
    error_message = "Replication factor must be 3, 5, or 7."
  }
}

###############################################################################
#                        Security Configuration                                #
###############################################################################

variable "encryption_at_rest_enabled" {
  description = "Enable encryption at rest using cloud provider's encryption (M10+)"
  type        = bool
  default     = true
}

variable "termination_protection_enabled" {
  description = "Enable termination protection to prevent accidental deletion"
  type        = bool
  default     = true
}

###############################################################################
#                        Labels and Metadata                                   #
###############################################################################

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "labels" {
  description = "Labels/tags to apply to the cluster (key-value pairs)"
  type        = map(string)
  default     = {}
}
