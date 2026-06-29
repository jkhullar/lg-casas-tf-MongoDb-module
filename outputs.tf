###############################################################################
#                           Cluster Outputs                                    #
###############################################################################

output "cluster_id" {
  description = "The cluster ID (unique identifier)"
  value       = mongodbatlas_advanced_cluster.this.cluster_id
}

output "cluster_name" {
  description = "The name of the MongoDB Atlas cluster"
  value       = mongodbatlas_advanced_cluster.this.name
}

output "mongo_uri" {
  description = "Base connection string for the cluster (without credentials)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard
  sensitive   = true
}

output "mongo_uri_with_options" {
  description = "Connection string with options for the cluster"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}

output "connection_strings" {
  description = "Full connection strings object with standard, private, and SRV formats"
  value       = mongodbatlas_advanced_cluster.this.connection_strings
  sensitive   = true
}

output "srv_address" {
  description = "SRV connection string (recommended for modern drivers)"
  value       = mongodbatlas_advanced_cluster.this.connection_strings[0].standard_srv
  sensitive   = true
}

###############################################################################
#                        Configuration Outputs                                 #
###############################################################################

output "state_name" {
  description = "Current state of the cluster (e.g., IDLE, CREATING, UPDATING)"
  value       = mongodbatlas_advanced_cluster.this.state_name
}

output "cluster_type" {
  description = "The cluster type (REPLICASET or GEOSHARDED)"
  value       = mongodbatlas_advanced_cluster.this.cluster_type
}

output "mongodb_version" {
  description = "MongoDB version running on the cluster"
  value       = mongodbatlas_advanced_cluster.this.version_release_system
}

output "disk_size_gb" {
  description = "Disk size in GB"
  value       = mongodbatlas_advanced_cluster.this.disk_size_gb
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
  value       = mongodbatlas_advanced_cluster.this.backup_enabled
}

output "termination_protection" {
  description = "Whether termination protection is enabled"
  value       = mongodbatlas_advanced_cluster.this.termination_protection_enabled
}
