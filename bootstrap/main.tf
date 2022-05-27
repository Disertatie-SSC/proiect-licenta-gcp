locals {
  org_id          = "651150601306"        # propellant.digital
  billing_account = "01CF65-E838CD-27FD32" # My Billing Account
  folder_id       = "410060222494"         #dev
  bucket_location = "US"
  replica_locations_for_secrets = toset([
    "europe-west1",
    "europe-west2"
  ])
}



module "project" {
  source = "..//terraform/stacks/project"

  folder_id       = local.folder_id
  billing_account = local.billing_account

  labels = {
    email          = "sh4gie@gmail.com"
    live           = "no"
    environment    = "live"
    servicename    = "terraform"
    subservicename = ""
  }

  services = [
    "iam.googleapis.com",
    "cloudbilling.googleapis.com",
    "billingbudgets.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "container.googleapis.com",
    "containerscanning.googleapis.com",
    "storage-api.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudkms.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "appengine.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com"
  ]

}

### Terraform ###

# Create terraform service account
resource "google_service_account" "terraform" {
  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  project      = module.project.project.project_id
  account_id   = module.project.labels.resource_name
  display_name = module.project.labels.resource_name
  description  = "Terraform service account"
}

# Create terraform state bucket
module "state" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket?ref=v2.1.0"
  name       = "${module.project.labels.resource_name}-state"
  project_id = module.project.project.project_id
  location   = local.bucket_location
  labels     = module.project.labels.transformed_labels
}

# Terraform service account permissions
resource "google_organization_iam_member" "terraform_org" {
  for_each = toset([
    "roles/billing.admin",
    "roles/billing.costsManager",
    "roles/billing.projectManager",
    "roles/compute.networkAdmin",
    "roles/compute.xpnAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.organizationRoleAdmin",
    "roles/logging.configWriter",
    "roles/orgpolicy.policyAdmin",
    "roles/resourcemanager.folderAdmin",
    "roles/resourcemanager.organizationViewer",
    "roles/resourcemanager.lienModifier",
    "roles/bigquery.admin",
    "roles/resourcemanager.projectCreator",
    "roles/resourcemanager.projectDeleter",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin"
  ])
  org_id = local.org_id
  role   = each.value
  member = "serviceAccount:${google_service_account.terraform.email}"
}

resource "google_storage_bucket_iam_member" "terraform_state" {
  bucket = module.state.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform.email}"
}

