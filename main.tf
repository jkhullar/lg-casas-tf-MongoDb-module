###############################################################################
#            Reusable MongoDB Atlas Cluster Module                            #
###############################################################################

# MongoDB Atlas Cluster
resource "mongodbatlas_cluster" "this" {
  project_id = var.project_id
  name       = var.cluster_name

  # Cluster type and MongoDB version
  cluster_type          = var.cluster_type
  mongo_db_major_version = var.mongodb_major_version

  # Cloud provider configuration
  provider_name               = var.provider_name
  provider_instance_size_name = var.provider_instance_size
  provider_region_name        = var.provider_region

  # High availability
  num_shards         = var.cluster_type == "GEOSHARDED" ? var.num_shards : null
  replication_factor = var.replication_factor

  # Storage configuration
  disk_size_gb = var.disk_size_gb

  # Auto-scaling configuration
  auto_scaling_disk_gb_enabled = var.auto_scaling_disk_enabled

  # Backup configuration
  backup_enabled                 = var.backup_enabled
  pit_enabled                    = var.pit_enabled
  cloud_backup                   = var.backup_enabled

  # Security configuration
  encryption_at_rest_provider = var.encryption_at_rest_enabled ? var.provider_name : "NONE"
  termination_protection_enabled = var.termination_protection_enabled

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
}
