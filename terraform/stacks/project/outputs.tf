output "labels" {
  description = "All outputs from labels module"
  value       = module.labels
}

output "project" {
  description = "Project outputs"
  value       = google_project.project
}

output "project_services" {
  description = "Project enabled services outputs"
  value       = google_project_service.service
}

output "project_audit_config" {
  description = "Audit config settings for project"
  value       = google_project_iam_audit_config.project_audit
}
