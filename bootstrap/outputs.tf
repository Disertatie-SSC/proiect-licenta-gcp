output "project" {
  description = "Terraform project outputs"
  value       = module.project.project
}

output "service_account" {
  description = "Terraform service account outputs"
  value       = google_service_account.terraform
}

output "state" {
  description = "Terraform state bucket outputs"
  value       = module.state
}
