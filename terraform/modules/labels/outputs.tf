# Outputs transformed for GCP compatibility
output "transformed_labels" {
  description = "Map of transformed labels adhering to GCP restrictions"
  value       = local.transformed_labels
}

# Resource names (derived from transformed tags)
output "resource_name" {
  description = "Standardised resource name"
  value       = local.resource_name
}

output "random_resource_name" {
  description = "Standardised resource name with a random suffix to facilitate uniqueness"
  value       = local.random_resource_name
}

output "underscore_resource_name" {
  description = "Standardised resource name with underscore delimiter"
  value       = local.underscore_resource_name
}

output "underscore_random_resource_name" {
  description = "Standardised resource name with a random suffix to facilitate uniqueness and underscore delimiter"
  value       = local.underscore_random_resource_name
}

# Output as supplied, NOT transformed.
output "raw_labels" {
  description = "Map of labels with no transformation"
  value = {
    email          = var.email
    live           = var.live
    environment    = var.environment
    servicename    = var.servicename
    subservicename = var.subservicename
  }
}
