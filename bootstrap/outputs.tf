# output "folder" {
#   description = "Terraform folder outputs"
#   value       = google_folder.folder
# }

output "project" {
  description = "Terraform project outputs"
  value       = module.project.project
}

output "service_account" {
  description = "Terraform service account outputs"
  value       = google_service_account.terraform
}

output "state" {
  description = "State bucket outputs"
  value       = module.state
}

output "artifacts" {
  description = "Artifact bucket outputs"
  value       = module.artifacts
}

output "image_builder" {
  description = "Image builder outputs"
  value       = module.image_builder
}

output "trigger_master" {
  description = "Cloud Build trigger for master branch"
  value       = google_cloudbuild_trigger.master
}

output "trigger_pr" {
  description = "Cloud Build trigger for pull requests"
  value       = google_cloudbuild_trigger.pull_requests
}

output "github_token_id" {
  description = "GitHub token ID that will be used by pipelines"
  value       = google_secret_manager_secret.github_token_id
}
