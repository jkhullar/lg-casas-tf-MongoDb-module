###############################################################################
#                           Cluster Outputs                                    #
###############################################################################

output "cluster_id" {
  description = "The cluster ID (unique identifier)"
  value       = mongodbatlas_cluster.this.cluster_id
}

output "cluster_name" {
  description = "The name of the MongoDB Atlas cluster"
  value       = mongodbatlas_cluster.this.name
}

output "mongo_uri" {
  description = "Base connection string for the cluster (without credentials)"
  value       = mongodbatlas_cluster.this.mongo_uri
  sensitive   = true
}

output "mongo_uri_with_options" {
  description = "Connection string with options for the cluster"
  value       = mongodbatlas_cluster.this.mongo_uri_with_options
  sensitive   = true
}

output "connection_strings" {
  description = "Full connection strings object with standard, private, and SRV formats"
  value       = mongodbatlas_cluster.this.connection_strings
  sensitive   = true
}

output "srv_address" {
  description = "SRV connection string (recommended for modern drivers)"
  value       = mongodbatlas_cluster.this.srv_address
  sensitive   = true
}

###############################################################################
#                        Configuration Outputs                                 #
###############################################################################

output "state_name" {
  description = "Current state of the cluster (e.g., IDLE, CREATING, UPDATING)"
  value       = mongodbatlas_cluster.this.state_name
}

output "provider_name" {
  description = "Cloud provider hosting the cluster"
  value       = mongodbatlas_cluster.this.provider_name
}

output "provider_region" {
  description = "Cloud provider region"
  value       = mongodbatlas_cluster.this.provider_region_name
}

output "instance_size" {
  description = "Instance size/tier of the cluster"
  value       = mongodbatlas_cluster.this.provider_instance_size_name
}

output "mongodb_version" {
  description = "MongoDB version running on the cluster"
  value       = mongodbatlas_cluster.this.mongo_db_version
}

output "replication_factor" {
  description = "Number of replica set members"
  value       = mongodbatlas_cluster.this.replication_factor
}

output "disk_size_gb" {
  description = "Disk size in GB"
  value       = mongodbatlas_cluster.this.disk_size_gb
}

###############################################################################
#                        Security Outputs                                      #
###############################################################################

output "encryption_at_rest_enabled" {
  description = "Whether encryption at rest is enabled"
  value       = var.encryption_at_rest_enabled
}

output "backup_enabled" {
  description = "Whether continuous backup is enabled"
  value       = mongodbatlas_cluster.this.backup_enabled
}

output "termination_protection" {
  description = "Whether termination protection is enabled"
  value       = var.termination_protection_enabled
}
