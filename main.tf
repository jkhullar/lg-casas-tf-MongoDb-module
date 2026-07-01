###############################################################################
#            Reusable MongoDB Atlas Advanced Cluster Module                   #
###############################################################################

# MongoDB Atlas Advanced Cluster (modern resource type)
resource "mongodbatlas_advanced_cluster" "this" {
  project_id = var.project_id
  name       = var.cluster_name

  # Cluster type and MongoDB version
  cluster_type = var.cluster_type
  mongo_db_major_version = var.mongodb_major_version

  # Backup configuration
  backup_enabled = var.backup_enabled
  pit_enabled    = var.pit_enabled

  # Security configuration
  termination_protection_enabled = var.termination_protection_enabled

  # Encryption at rest
  encryption_at_rest_provider = var.encryption_at_rest_enabled ? "GCP" : "NONE"

  # Replication specs - defines cluster topology
  replication_specs {
    # Number of shards (for GEOSHARDED) or zones (for REPLICASET)
    num_shards = var.cluster_type == "GEOSHARDED" ? var.num_shards : 1

    # Region configuration
    region_configs {
      # Cloud provider and region
      provider_name = "GCP"
      region_name   = var.provider_region
      priority      = 7  # Highest priority for this region

      # Electable nodes (voting members)
      electable_specs {
        instance_size = var.provider_instance_size
        node_count    = var.replication_factor  # Number of replica set members

        # Disk configuration
        disk_iops      = null  # Auto-configured based on instance size
        ebs_volume_type = "STANDARD"  # Standard SSD
      }

      # Auto-scaling configuration
      auto_scaling {
        disk_gb_enabled = var.auto_scaling_disk_enabled
        compute_enabled = false  # Compute auto-scaling disabled by default

        # Disk auto-scaling limits
        dynamic "disk_gb" {
          for_each = var.auto_scaling_disk_enabled ? [1] : []
          content {
            enabled = true
          }
        }
      }
    }
  }

  # Disk size configuration
  disk_size_gb = var.disk_size_gb

  # Advanced configuration for production readiness
  advanced_configuration {
    javascript_enabled           = false  # Security: disable server-side JavaScript
    minimum_enabled_tls_protocol = "TLS1_2"
  }

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
}
