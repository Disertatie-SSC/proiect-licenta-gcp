locals {
  org_id          = "651150601306"        # propellant.digital
  billing_account = "01CF65-E838CD-27FD32" # My Billing Account
  folder_id       = "410060222494"         #dev
  bucket_location = "US"
  package_versions = jsondecode(file("${path.module}/cloudbuild_builder/packageVersions.json"))
  replica_locations_for_secrets = toset([
    "us-east1",
    "us-east4"
  ])
}

module "project" {
  source = "..//terraform/stacks/project"

  folder_id       = local.folder_id
  billing_account = local.billing_account

  labels = {
    email          = "andrei.platon@infoifr-licenta.net"
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

# Cream terraform service account
resource "google_service_account" "terraform" {
  #checkov:skip=CKV2_GCP_3: "Ensure that there are only GCP-managed service account keys for each service account"
  project      = module.project.project.project_id
  account_id   = module.project.labels.resource_name
  display_name = module.project.labels.resource_name
  description  = "Terraform service account"
}

# Se creaza terraform state bucket
module "state" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage//modules/simple_bucket?ref=v2.1.0"
  name       = "${module.project.labels.resource_name}-state"
  project_id = module.project.project.project_id
  location   = local.bucket_location
  labels     = module.project.labels.transformed_labels
}

# Terraform service account permisiuni
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

### Cloud Build ###

# Construim un bucket pentru artefactele in urma procesului de deployment a infrastructuri atat pentru pasul de apply cat si cel pentru paln  si , stocam si aspecte legate de build-ul de container
module "artifacts" {
  source     = "github.com/terraform-google-modules/terraform-google-cloud-storage///modules/simple_bucket?ref=v2.2.0"
  name       = "${module.project.labels.resource_name}-artifacts"
  project_id = "${module.project.project.project_id}"
  location   = local.bucket_location
  labels     = module.project.labels.transformed_labels
}

# Cloud build service account IAM permissions
resource "google_storage_bucket_iam_member" "cloudbuild_artifacts" {
  bucket = module.artifacts.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.project.project.number}@cloudbuild.gserviceaccount.com"
}
resource "google_storage_bucket_iam_member" "cloudbuild_state" {
  bucket = module.state.bucket.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${module.project.project.number}@cloudbuild.gserviceaccount.com"
}


#Permitem cloud build sa faca impersonate terraform service account
resource "google_service_account_iam_member" "cloudbuild_terraform_impersonate" {
  service_account_id = google_service_account.terraform.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${module.project.project.number}@cloudbuild.gserviceaccount.com"
}

# Construim si impingem containerul nostru in ./cloudbuild_builder
module "image_builder" {
  source = "github.com/terraform-google-modules/terraform-google-gcloud.git?ref=v3.0.1"

  module_depends_on = [
    module.project
  ]

  # Daca se schimba parametri aici vrem sa ruleze de fiecare data
  create_cmd_triggers = {
    cloudbuild_project_id = module.project.project.project_id
    cloudbuild_yaml_sha1  = sha1(file("${path.module}/cloudbuild_builder/cloudbuild.yaml"))
    dockerfile_sha1       = sha1(file("${path.module}/cloudbuild_builder/Dockerfile"))
    tf_version_sha1       = sha1(chomp(file("${path.module}/../.terraform-version")))
    tg_version_sha1       = sha1(chomp(file("${path.module}/../.terragrunt-version")))
    package_version_sha1  = sha1(chomp(file("${path.module}/cloudbuild_builder/packageVersions.json")))
  }

  create_cmd_entrypoint = "gcloud"
  create_cmd_body       = <<EOT
      builds submit ${path.module}/cloudbuild_builder/ \
      --project ${module.project.project.project_id} \
      --gcs-source-staging-dir="gs://${module.artifacts.bucket.name}/staging" \
      --config=${path.module}/cloudbuild_builder/cloudbuild.yaml \
      --substitutions=_CHECKOV_VERSION="${local.package_versions.checkovVersion}",\
_MARKDOWNLINK_VERSION="${local.package_versions.markdownlinkVersion}",\
_MDL_VERSION="${local.package_versions.mdlVersion}",\
_TF_DOCS_VERSION="${local.package_versions.tfdocsVersion}",\
_TERRAFORM_VERSION=${chomp(file("${path.module}/../.terraform-version"))},\
_TERRAGRUNT_VERSION=${chomp(file("${path.module}/../.terragrunt-version"))},\
_TFENV_VERSION="${local.package_versions.tfenvVersion}",\
_TFSEC_VERSION="${local.package_versions.tfsecVersion}",\
_TGENV_VERSION="${local.package_versions.tgenvVersion}"\
  EOT
}

# Cloud Build triggere pt fiecare situatie
resource "google_cloudbuild_trigger" "master" {
  project     = module.project.project.name
  description = "terragrunt plan orice commit in branch-uri"

  #trigger_template and github blocks exclude eachother
  #enable trigger_template for Google Source Repositories and github for GitHub repo
  # trigger_template {
  #   branch_name = "^main$"
  #   repo_name   = "proiect-licenta-gcp"
  # }

  github {
    owner = "Andrei-Platon-Appsbroker"
    name  = "proiect-licenta-gcp"
    push {
      branch = "^main$"
      invert_regex = true
    }

  }

  substitutions = {
    _TF_SA_EMAIL          = google_service_account.terraform.email
    _ARTIFACT_BUCKET_NAME = module.artifacts.bucket.name
    _GITHUB_TOKEN_ID      = google_secret_manager_secret.github_token_id.secret_id
  }

  filename = "cloudbuild-tg-plan.yaml"
  depends_on = [
    module.image_builder,
  ]
}

resource "google_cloudbuild_trigger" "pull_requests" {
  project     = module.project.project.name
  description = "Trigger care ruleaza doar cand avem un Pull Request"

  #trigger_template and github blocks exclude eachother
  #enable trigger_template for Google Source Repositories and github for GitHub repo
  # trigger_template {
  #   branch_name  = "^main$"
  #   repo_name    = "proiect-licenta-gcp"
  #   invert_regex = true
  # }

  github {
    owner = "Andrei-Platon-Appsbroker"
    name  = "proiect-licenta-gcp"
    pull_request {
      branch = "^main$"
    }
  }

  substitutions = {
    _TF_SA_EMAIL          = google_service_account.terraform.email
    _ARTIFACT_BUCKET_NAME = module.artifacts.bucket.name
    _GITHUB_TOKEN_ID      = google_secret_manager_secret.github_token_id.secret_id
  }

  filename = "cloudbuild-tg-apply.yaml"
  depends_on = [
    module.image_builder,
  ]
}

resource "google_secret_manager_secret" "github_token_id" {
  project   = module.project.project.project_id
  secret_id = "${module.project.labels.resource_name}-github_token_id"

  replication {
    user_managed {
      dynamic "replicas" {
        for_each = local.replica_locations_for_secrets
        content {
          location = replicas.value
        }
      }
    }
  }

  labels = module.project.labels.transformed_labels

}

# Permitem Service Account-ului de Cloud Build sa aiba access la secret
resource "google_secret_manager_secret_iam_member" "cloudbuild_secretaccessor_member" {
  project   = module.project.project.project_id
  secret_id = google_secret_manager_secret.github_token_id.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${module.project.project.number}@cloudbuild.gserviceaccount.com"
}