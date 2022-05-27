locals {
  org_id    = var.org_id != "" ? var.org_id : null
  folder_id = var.folder_id != "" ? var.folder_id : null

  # Use override project ID if it's set, otherwise use resource name from labels module
  project_id = var.project_id_override != "" ? var.project_id_override : module.labels.random_resource_name
}

# Get standardised labels and resource name
module "labels" {
  source = "../../modules/labels"

  email          = var.labels.email
  live           = var.labels.live
  environment    = var.labels.environment
  servicename    = var.labels.servicename
  subservicename = var.labels.subservicename
}

resource "google_project" "project" {
  name       = local.project_id
  project_id = local.project_id

  billing_account = var.billing_account
  org_id          = local.org_id
  folder_id       = local.folder_id

  auto_create_network = false

  labels = module.labels.transformed_labels

  provisioner "local-exec" {
    command = "sleep 10"
  }

}

 resource "google_project_iam_audit_config" "project_audit" {
   project = google_project.project.id
   service = "allServices"

   audit_log_config {
     log_type = "ADMIN_READ"
   }

   audit_log_config {
    log_type = "DATA_READ"
   }

 }

resource "google_project_service" "service" {
  for_each                   = toset(var.services)
  project                    = google_project.project.project_id
  service                    = each.value
  disable_on_destroy         = var.disable_on_destroy
  disable_dependent_services = var.disable_dependent_services
}
